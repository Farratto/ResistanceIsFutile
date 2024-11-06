-- Please see the LICENSE.txt file included with this distribution for
-- attribution and copyright information.

-- luacheck: globals resetHealth setDBValue

local resetHealthOriginal;
local setDBValueOriginal;

function onInit()
	resetHealthOriginal = CombatManager2.resetHealth;
	CombatManager2.resetHealth = resetHealth;
end

function resetHealth(nodeCT, bLong)
	if bLong then
		local rActor = ActorManager.resolveActor(nodeCT);
		if EffectManager5E.hasEffectCondition(rActor, "UNHEALABLE")
		or #(EffectManager5E.getEffectsByType(rActor, "UNHEALABLE", {"rest"})) > 0 then
			setDBValueOriginal = DB.setValue;
			DB.setValue = setDBValue; --luacheck: ignore 122
		end
	end
	resetHealthOriginal(nodeCT, bLong);
end

function setDBValue(vFirst, vSecond, ...) --luacheck: ignore 212
	if vSecond == "wounds" then
		DB.setValue = setDBValueOriginal; --luacheck: ignore 122
	else
		setDBValueOriginal(vFirst, vSecond, unpack(arg));
	end
end