-- Please see the LICENSE.txt file included with this distribution for
-- attribution and copyright information.

-- luacheck: globals getDamageVulnerabilities getDamageResistances getDamageImmunities postProcessResistances
-- luacheck: globals addExtras addIgnoredDamageType ignoreReduction addDemotedDamagedType demoteReduction
-- luacheck: globals getDemotedEffect addVulnerableDamageType addResistantDamageType

local getDamageVulnerabilitiesOriginal;
local getDamageResistancesOriginal;
local getDamageImmunitiesOriginal;

function onInit()
	getDamageVulnerabilitiesOriginal = ActorManager5E.getDamageVulnerabilities;
	ActorManager5E.getDamageVulnerabilities = getDamageVulnerabilities;

	getDamageResistancesOriginal = ActorManager5E.getDamageResistances;
	ActorManager5E.getDamageResistances = getDamageResistances;

	getDamageImmunitiesOriginal = ActorManager5E.getDamageImmunities;
	ActorManager5E.getDamageImmunities = getDamageImmunities;
end

function getDamageVulnerabilities(rActor, rSource)
	local aVuln =  getDamageVulnerabilitiesOriginal(rActor, rSource);
	if not rActor.tReductions then rActor.tReductions = {} end
	rActor.tReductions["VULN"] = aVuln;
	addExtras(rSource, rActor, "IGNOREVULN", addIgnoredDamageType, "VULN");
	return aVuln;
end

function getDamageResistances(rActor, rSource)
	local aResist = getDamageResistancesOriginal(rActor, rSource);
	if not rActor.tReductions then rActor.tReductions = {} end
	rActor.tReductions["RESIST"] = aResist;
	addExtras(rSource, rActor, "IGNORERESIST", addIgnoredDamageType, "RESIST");
	return aResist;
end

function getDamageImmunities(rActor, rSource)
	local aImmune = getDamageImmunitiesOriginal(rActor, rSource);
	if not rActor.tReductions then rActor.tReductions = {} end
	rActor.tReductions["IMMUNE"] = aImmune;
	addExtras(rSource, rActor, "IGNOREIMMUNE", addIgnoredDamageType, "IMMUNE");

	-- Prevent the ruleset from bypassing all logic in the event of IMMUNE: all
	if aImmune["all"] then
		local rReduction = aImmune["all"];
		aImmune["all"] = nil;
		for _,sDamage in ipairs(DataCommon.dmgtypes) do
			aImmune[sDamage] = rReduction;
		end
	end

	-- Immunities are processed last by the ruleset
	postProcessResistances(rActor, rSource)

	return aImmune;
end

function postProcessResistances(rActor, rSource)
	local tAbsorb = ActorManager5E.getDamageVulnResistImmuneEffectHelper(rActor, "ABSORB", rSource);
	if not rActor.tReductions then rActor.tReductions = {} end
	rActor.tReductions["ABSORB"] = tAbsorb;
	for _,rAbsorb in pairs(tAbsorb) do
		if rAbsorb.mod == 0 then
			rAbsorb.mod = 1;
		end
		rAbsorb.mod = rAbsorb.mod + 1;
		rAbsorb.bIsAbsorb = true;
	end

	local tReduce = ActorManager5E.getDamageVulnResistImmuneEffectHelper(rActor, "REDUCE", rSource);
	for sType,rReduce in pairs(tReduce) do
		local rResist = rActor.tReductions["RESIST"][sType];
		if not rResist then
			rActor.tReductions["RESIST"][sType] = rReduce;
		else
			rResist.nReduceMod = (rResist.nReduceMod or 0) + rReduce.mod;
			rResist.aReduceNegatives = rReduce.aNegatives;
		end
	end

	for sOriginalType,_ in pairs(rActor.tReductions) do
		for sNewType,_ in pairs(rActor.tReductions) do
			addExtras(rSource, rActor, sOriginalType .. "TO" .. sNewType, addDemotedDamagedType, sOriginalType, sNewType);
		end
	end

	addExtras(rSource, rActor, "MAKEVULN", addVulnerableDamageType);
	addExtras(rSource, rActor, "MAKERESIST", addResistantDamageType);
end

function addExtras(rSource, rActor, sEffect, fAdd, sPrimaryReduction, sSecondaryReduction)
	local bHandledAll = false;
	local aEffects = EffectManager5E.getEffectsByType(rSource, sEffect, {}, rActor);
	for _,rEffect in pairs(aEffects) do
		for _,sType in pairs(rEffect.remainder) do
			if sType == "all" then
				for _,sDamage in ipairs(DataCommon.dmgtypes) do
					fAdd(rActor, sDamage, sPrimaryReduction, sSecondaryReduction);
				end
				bHandledAll = true;
				break;
			end
			fAdd(rActor, sType, sPrimaryReduction, sSecondaryReduction);
		end
		if bHandledAll then
			break;
		end
	end
end

function addIgnoredDamageType(rActor, sDamageType, sIgnoredType)
	local aEffects = rActor.tReductions[sIgnoredType];
	ignoreReduction(aEffects[sDamageType], sDamageType);
	ignoreReduction(aEffects["all"], sDamageType);
end

function ignoreReduction(rReduction, sDamageType)
	if rReduction then
		if not rReduction.aIgnored then
			rReduction.aIgnored = {};
		end
		table.insert(rReduction.aIgnored, sDamageType);
	end
end

function addDemotedDamagedType(rActor, sDamageType, sOriginalType, sNewType)
	local aOriginalEffects = rActor.tReductions[sOriginalType];
	local aNewEffects = rActor.tReductions[sNewType]
	demoteReduction(aOriginalEffects[sDamageType], sDamageType, sOriginalType, aNewEffects);
	demoteReduction(aOriginalEffects["all"], sDamageType, sOriginalType, aNewEffects);
end

function demoteReduction(rReduction, sDamageType, sOriginalType, aNewEffects)
	if rReduction and not (rReduction.aIgnored and StringManager.contains(rReduction.aIgnored, sDamageType)) then
		rReduction.bDemoted = true;
		local rDemoted = getDemotedEffect(aNewEffects, sDamageType);
		rDemoted.sDemotedFrom = sOriginalType;
	end
end

function getDemotedEffect(aDemotedEffects, sDamageType)
	local rDemoted = aDemotedEffects[sDamageType];
	if not rDemoted then
		rDemoted = {
			mod = 0;
			aNegatives = {}
		};
		aDemotedEffects[sDamageType] = rDemoted;
	end
	return rDemoted;
end

function addVulnerableDamageType(rActor, sDamageType)
	local aEffects = rActor.tReductions["VULN"];
	aEffects[sDamageType] = {
		mod = 0,
		aNegatives = {},
		bAddIfUnresisted = true
	};
end

function addResistantDamageType(rActor, sDamageType)
	local aEffects = rActor.tReductions["RESIST"];
	aEffects[sDamageType] = {
		mod = 0,
		aNegatives = {},
		bAddIfUnresisted = false
	};
end