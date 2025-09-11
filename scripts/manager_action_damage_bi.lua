-- Please see the LICENSE.txt file included with this distribution for
-- attribution and copyright information.

--luacheck: globals setActiveTarget clearActiveTarget
--luacheck: globals getDamageAdjust multiplyDamage applyDamage messageDamage
--luacheck: globals fhelperCheckBasicReductionType helperCheckBasicReductionTypeRIF
--luacheck: globals fhelperCheckNumericReductionType helperCheckNumericReductionTypeRIF

--local checkReductionTypeHelperOriginal;
--local checkNumericalReductionTypeHelperOriginal;
local getDamageAdjustOriginal;
local applyDamageOriginal;
local messageDamageOriginal;

local rActiveTarget;
local bAdjusted = false;
local bIgnored = false;
local bPreventCalculateRecursion = false;

function onInit()
	--checkReductionTypeHelperOriginal = ActionDamage.checkReductionTypeHelper;
	--ActionDamage.checkReductionTypeHelper = checkReductionTypeHelper;
	fhelperCheckBasicReductionType = ActionDamage.helperCheckBasicReductionType;
	ActionDamage.helperCheckBasicReductionType = helperCheckBasicReductionTypeRIF;

	--checkNumericalReductionTypeHelperOriginal = ActionDamage.checkNumericalReductionTypeHelper;
	--ActionDamage.checkNumericalReductionTypeHelper = checkNumericalReductionTypeHelper;
	fhelperCheckNumericReductionType = ActionDamage.helperCheckNumericReductionType;
	ActionDamage.helperCheckNumericReductionType = helperCheckNumericReductionTypeRIF;

	getDamageAdjustOriginal = ActionDamage.getDamageAdjust;
	ActionDamage.getDamageAdjust = getDamageAdjust;

	applyDamageOriginal = ActionDamage.applyDamage;
	ActionDamage.applyDamage = applyDamage;

	messageDamageOriginal = ActionDamage.messageDamage;
	ActionDamage.messageDamage = messageDamage;

	if EffectsManagerBCEDND then --luacheck: ignore 113
		EffectsManagerBCEDND.processAbsorb = function() end; --luacheck: ignore 112
	end
end

function setActiveTarget(rTarget)
	rActiveTarget = rTarget;
	rActiveTarget.tReductions = {
		["VULN"] = {},
		["RESIST"] = {},
		["IMMUNE"] = {},
		["ABSORB"] = {},
	};
end

function clearActiveTarget()
	rActiveTarget = nil;
end

--[[ DEPRECATED (2025-03)
function checkReductionTypeHelper(rMatch, aDmgType, ...)
	local result = checkReductionTypeHelperOriginal(rMatch, aDmgType, ...);
	if bPreventCalculateRecursion then
		return result;
	end

	if result then
		if rActiveTarget and ActionDamage.checkNumericalReductionType(rActiveTarget.tReductions["ABSORB"], aDmgType) ~= 0 then
			result = false;
		elseif rMatch.aIgnored then
			for _,sIgnored in pairs(rMatch.aIgnored) do
				if StringManager.contains(aDmgType, sIgnored) then
					bIgnored = true;
					result = false;
					break;
				end
			end
		elseif rMatch.bDemoted then
			bAdjusted = true;
			result = false;
		elseif rMatch.bAddIfUnresisted then
			bPreventCalculateRecursion = true;
			if rActiveTarget then
				result = not ActionDamage.checkReductionType(rActiveTarget.tReductions["RESIST"], aDmgType) and
					not ActionDamage.checkReductionType(rActiveTarget.tReductions["IMMUNE"], aDmgType) and
					not ActionDamage.checkReductionType(rActiveTarget.tReductions["ABSORB"], aDmgType);
			else
				result = true;
			end
			bPreventCalculateRecursion = false;
		end
	elseif rMatch and (rMatch.mod ~= 0) then
		if rMatch.sDemotedFrom then
			if rActiveTarget then
				local aMatches = rActiveTarget.tReductions[rMatch.sDemotedFrom];
				bPreventCalculateRecursion = true;
				result = ActionDamage.checkReductionType(aMatches, aDmgType) or
					ActionDamage.checkNumericalReductionType(aMatches, aDmgType) ~= 0;
			else
				result = false;
			end
			bPreventCalculateRecursion = false;
		end
	end

	return result;
end]]
function helperCheckBasicReductionTypeRIF(rMatch, aDmgType, ...)
	local result = fhelperCheckBasicReductionType(rMatch, aDmgType, ...);
	if bPreventCalculateRecursion then
		return result;
	end

	if result then
		if rActiveTarget and ActionDamage.checkNumericReductionType(rActiveTarget.tReductions["ABSORB"], aDmgType) ~= 0 then
			result = false;
		elseif rMatch.aIgnored then
			for _,sIgnored in pairs(rMatch.aIgnored) do
				if StringManager.contains(aDmgType, sIgnored) then
					bIgnored = true;
					result = false;
					break;
				end
			end
		elseif rMatch.bDemoted then
			bAdjusted = true;
			result = false;
		elseif rMatch.bAddIfUnresisted then
			bPreventCalculateRecursion = true;
			if rActiveTarget then
				result = not ActionDamage.checkBasicReductionType(rActiveTarget.tReductions["RESIST"], aDmgType) and
					not ActionDamage.checkBasicReductionType(rActiveTarget.tReductions["IMMUNE"], aDmgType) and
					not ActionDamage.checkBasicReductionType(rActiveTarget.tReductions["ABSORB"], aDmgType);
			else
				result = true;
			end
			bPreventCalculateRecursion = false;
		end
	elseif rMatch then
		if rMatch.sDemotedFrom then
			if rActiveTarget then
				local aMatches = rActiveTarget.tReductions[rMatch.sDemotedFrom];
				bPreventCalculateRecursion = true;
				result = ActionDamage.checkBasicReductionType(aMatches, aDmgType) or
					ActionDamage.checkNumericReductionType(aMatches, aDmgType) ~= 0;
			else
				result = false;
			end
			bPreventCalculateRecursion = false;
		end
	end

	return result;
end

--[[ DEPRECATED (2025-03)
function checkNumericalReductionTypeHelper(rMatch, aDmgType, nLimit, ...)
	local nMod;
	local aNegatives;
	if rMatch and rMatch.nReduceMod then
		nMod = rMatch.mod;
		aNegatives = rMatch.aNegatives;
		rMatch.mod = rMatch.nReduceMod;
		rMatch.aNegatives = rMatch.aReduceNegatives;
	end
	local result = checkNumericalReductionTypeHelperOriginal(rMatch, aDmgType, nLimit, ...);
	if nMod then
		rMatch.nReduceMod = rMatch.mod;
		rMatch.aReduceNegatives = rMatch.aNegatives;
		rMatch.mod = nMod;
		rMatch.aNegatives = aNegatives;
	end


	if bPreventCalculateRecursion then
		return result;
	end

	if result ~= 0 then
		if rMatch.aIgnored then
			for _,sIgnored in pairs(rMatch.aIgnored) do
				if StringManager.contains(aDmgType, sIgnored) then
					bIgnored = true;
					result = 0;
				end
			end
		elseif rMatch.bDemoted then
			bAdjusted = true;
			result = 0;
		end
	end
	if rMatch and rMatch.bIsAbsorb then
		rMatch.nApplied = 0;
	end
	return result;
end]]
function helperCheckNumericReductionTypeRIF(rMatch, aDmgType, nLimit, ...)
	local nMod;
	local aNegatives;
	if rMatch and rMatch.nReduceMod then
		if rMatch['tNumeric'] then
			nMod = rMatch['tNumeric'][1]['nMod'];
			aNegatives = rMatch['tNumeric'][1]['tNegatives'];
		else
			nMod = 0;
			aNegatives = rMatch['tBasic'][1]['tNegatives'];
			rMatch['tNumeric'] = UtilityManager.copyDeep(rMatch['tBasic']);
		end
		rMatch['tNumeric'][1]['nMod'] = rMatch.nReduceMod;
		rMatch['tNumeric'][1]['tNegatives'] = rMatch.aReduceNegatives;
	end
	local result = fhelperCheckNumericReductionType(rMatch, aDmgType, nLimit, ...);
	if nMod then
		if rMatch['tNumeric'] then
			rMatch.nReduceMod = rMatch['tNumeric'][1]['nMod'];
			rMatch.aReduceNegatives = rMatch['tNumeric'][1]['tNegatives'];
		else
			rMatch.nReduceMod = 0;
			rMatch.aReduceNegatives = rMatch['tBasic'][1]['tNegatives'];
		end
		if nMod == 0 then
			rMatch['tBasic'][1]['tNegatives'] = aNegatives;
			rMatch['tNumeric'] = nil;
		else
			rMatch['tNumeric'][1]['nMod'] = nMod;
			rMatch['tNumeric'][1]['tNegatives'] = aNegatives;
			rMatch['tBasic'] = nil;
		end
	end

	if bPreventCalculateRecursion then
		return result;
	end

	if result ~= 0 then
		if rMatch.aIgnored then
			for _,sIgnored in pairs(rMatch.aIgnored) do
				if StringManager.contains(aDmgType, sIgnored) then
					bIgnored = true;
					result = 0;
				end
			end
		elseif rMatch.bDemoted then
			bAdjusted = true;
			result = 0;
		end
	end
	if rMatch and rMatch.bIsAbsorb then
		rMatch.nApplied = 0;
	end
	return result;
end

function getDamageAdjust(rSource, rTarget, _, rDamageOutput, ...)
	setActiveTarget(rTarget);
	multiplyDamage(rSource, rTarget, rDamageOutput);

	local nDamageAdjust, bVulnerable, bResist, tAdjResults = getDamageAdjustOriginal(rSource, rTarget, rDamageOutput.nVal, rDamageOutput, ...);

	local tUniqueTypes = {};
	for k, v in pairs(rDamageOutput.aDamageTypes) do
		-- Get individual damage types for each damage clause
		local aSrcDmgClauseTypes = {};
		local aTemp = StringManager.split(k, ",", true);
		for _,vType in ipairs(aTemp) do
			if vType ~= "untyped" and vType ~= "" then
				table.insert(aSrcDmgClauseTypes, vType);
			end
		end

		--local nLocalAbsorb = ActionDamage.checkNumericalReductionType(rTarget.tReductions["ABSORB"], aSrcDmgClauseTypes);
		local nLocalAbsorb = ActionDamage.checkNumericReductionType(rTarget.tReductions["ABSORB"], aSrcDmgClauseTypes);
		if nLocalAbsorb ~= 0 then
			nDamageAdjust = nDamageAdjust - (v * nLocalAbsorb);
			for _,sDamageType in ipairs(aSrcDmgClauseTypes) do
				if sDamageType:sub(1,1) ~= "!" and sDamageType:sub(1,1) ~= "~" then
					tUniqueTypes[sDamageType] = true;
				end
			end
		end
	end
	rTarget.nAbsorbed = rDamageOutput.nVal + nDamageAdjust;

	local aAbsorbed = {};
	for sDamageType,_ in pairs(tUniqueTypes) do
		table.insert(aAbsorbed, sDamageType);
	end
	if #aAbsorbed > 0 then
		table.sort(aAbsorbed);
		table.insert(rDamageOutput.tNotifications, "[ABSORBED: " .. table.concat(aAbsorbed, ",") .. "]");
	end

	if bAdjusted then
		table.insert(rDamageOutput.tNotifications, "[RESISTANCE ADJUSTED]");
		bAdjusted = false;
	end
	if bIgnored then
		table.insert(rDamageOutput.tNotifications, "[RESISTANCE IGNORED]");
		bIgnored = false;
	end

	clearActiveTarget();
	return nDamageAdjust, bVulnerable, bResist, tAdjResults;
end

function multiplyDamage(rSource, rTarget, rDamageOutput)
	local nMult = 1;
	local bRateEffect = false;
	for _,rEffect in ipairs(EffectManager5E.getEffectsByType(rSource, "DMGMULT", nil, rTarget)) do
		nMult = nMult * rEffect.mod;
		bRateEffect = true;
	end
	for _,rEffect in ipairs(EffectManager5E.getEffectsByType(rTarget, "DMGEDMULT", nil, rSource)) do
		nMult = nMult * rEffect.mod;
		bRateEffect = true;
	end
	if not bRateEffect then
		return;
	end

	table.insert(rDamageOutput.tNotifications, "[MULTIPLIED: " .. nMult .. "]");

	local nCarry = 0;
	local nNegMult = 1;
	if nMult < 0 then nNegMult = -1 end
	local nMultAbs = math.abs(nMult);
	for kType, nType in pairs(rDamageOutput.aDamageTypes) do
		local nAdjusted = nType * nMultAbs;
		nCarry = nCarry + nAdjusted % 1;
		if nCarry >= 1 then
			nAdjusted = nAdjusted + 1;
			nCarry = nCarry - 1;
		end
		rDamageOutput.aDamageTypes[kType] = math.floor(nAdjusted);
	end
	local nValMax = math.max(math.floor(rDamageOutput.nVal * nMultAbs), 1);
	rDamageOutput.nVal = nValMax * nNegMult;
	--rDamageOutput.nVal = math.max(math.floor(rDamageOutput.nVal * nMult), 1);
end

function applyDamage(rSource, rTarget, rRoll, ...)
	if string.match(rRoll.sDesc, "%[RECOVERY")
	or string.match(rRoll.sDesc, "%[HEAL")
	or rRoll.nTotal < 0 then
		local sType = "heal"
		if string.match(rRoll.sDesc, "%[RECOVERY") then
			sType = "hitdice";
		end
		if EffectManager5E.hasEffectCondition(rTarget, "UNHEALABLE")
		or #(EffectManager5E.getEffectsByType(rTarget, "UNHEALABLE", {sType})) > 0 then
			rRoll.nTotal = 0;
			rRoll.sDesc = rRoll.sDesc .. "[UNHEALABLE]";
		else
			local nMult = 1;
			local bRateEffect = false;
			local bHeal2Dmg;
			local sAbsorbed;
			for _,rEffect in ipairs(EffectManager5E.getEffectsByType(rSource, "HEALMULT", {sType}, rTarget)) do
				if rEffect.mod < 0 then
					bHeal2Dmg = true;
					rEffect.mod = math.abs(rEffect.mod);
					local sRemainder = ''
					for _,remainder in ipairs(rEffect.remainder) do
						if sRemainder == '' then
							sRemainder = string.lower(remainder);
						else
							sRemainder = sRemainder..','..string.lower(remainder);
						end
					end
					if sRemainder == '' then sRemainder = 'untyped' end
					rRoll.sDesc = string.gsub(rRoll.sDesc, '%[HEAL%]', '[DAMAGE]');
					local sTypeDesc = '[TYPE: '..sRemainder..' ('..tostring(rRoll.nTotal)..'='..tostring(rRoll.nTotal)..')]'
					rRoll.sDesc = rRoll.sDesc..sTypeDesc;
					rRoll.healtype = nil;
					rRoll.sType = 'damage'
				end
				nMult = nMult * rEffect.mod;
				bRateEffect = true;
			end
			for _,rEffect in ipairs(EffectManager5E.getEffectsByType(rTarget, "HEALEDMULT", {sType}, rSource)) do
				sAbsorbed = string.match(rRoll.sDesc, "%[ABSORBED: [^%]]+%]");
				if rEffect.mod < 0 and not sAbsorbed then
					bHeal2Dmg = true;
					rEffect.mod = math.abs(rEffect.mod);
					local sRemainder = ''
					for _,remainder in ipairs(rEffect.remainder) do
						if sRemainder == '' then
							sRemainder = string.lower(remainder);
						else
							sRemainder = sRemainder..','..string.lower(remainder);
						end
					end
					if sRemainder == '' then sRemainder = 'untyped' end
					rRoll.sDesc = string.gsub(rRoll.sDesc, '%[HEAL%]', '[DAMAGE]');
					local sTypeDesc = '[TYPE: '..sRemainder..' ('..tostring(rRoll.nTotal)..'='..tostring(rRoll.nTotal)..')]'
					rRoll.sDesc = rRoll.sDesc..sTypeDesc;
					rRoll.healtype = nil;
					rRoll.sType = 'damage'
				end
				nMult = nMult * rEffect.mod;
				bRateEffect = true;
			end
			if bRateEffect then
				if not sAbsorbed then
					rRoll.nTotal = math.floor(rRoll.nTotal * nMult);
					if nMult ~= 1 then rRoll.sDesc = rRoll.sDesc .. "[MULTIPLIED: " .. nMult .."]" end
					if bHeal2Dmg then rRoll.sDesc = rRoll.sDesc.."[CONVHEAL2DMG]" end
				end
			end
		end
	end

	applyDamageOriginal(rSource, rTarget, rRoll, ...);
end

function messageDamage(rSource, rTarget, vRollOrSecret, sDamageText, sDamageDesc, sTotal, sExtraResult, ...)
	if type(vRollOrSecret) == "table" then
		local rRoll = vRollOrSecret;
		if (rTarget.nAbsorbed or 0) < 0 then
			local rNewRoll = {};
			rNewRoll.sType = "heal";
			rNewRoll.nTotal = -rTarget.nAbsorbed;
			rTarget.nAbsorbed = 0;
			rNewRoll.sDesc = "[HEAL] " .. rRoll.sResults;
			ActionDamage.applyDamage(rSource, rTarget, rNewRoll);
			return;
		end

		if string.match(rRoll.sDesc, "%[UNHEALABLE") then
			if rRoll.sResults ~= "" then
				rRoll.sResults = rRoll.sResults .. " ";
			end
			rRoll.sResults = rRoll.sResults .. "[UNHEALABLE]";
		end

		local sMult = string.match(rRoll.sDesc, "%[MULTIPLIED: [^%]]+%]");
		if sMult then
			rRoll.sResults = rRoll.sResults .. sMult;
		end

		local sAbsorbed = string.match(rRoll.sDesc, "%[ABSORBED: [^%]]+%]");
		if sAbsorbed then
			rRoll.sResults = rRoll.sResults .. sAbsorbed;
		end
	end

	messageDamageOriginal(rSource, rTarget, vRollOrSecret, sDamageText, sDamageDesc, sTotal, sExtraResult, ...);
end