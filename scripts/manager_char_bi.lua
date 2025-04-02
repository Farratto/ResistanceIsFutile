-- Please see the LICENSE.txt file included with this distribution for
-- attribution and copyright information.

-- luacheck: globals resetHealth setDBValue

local resetHealthOriginal;
local setDBValueOriginal;

function onInit()
	resetHealthOriginal = CharManager.resetHealth;
	CharManager.resetHealth = resetHealth;
end

function resetHealth(nodeChar, bLong)
	if bLong then
		local rActor = ActorManager.resolveActor(nodeChar);
		if EffectManager5E.hasEffectCondition(rActor, "UNHEALABLE")
		or #(EffectManager5E.getEffectsByType(rActor, "UNHEALABLE", {"rest"})) > 0 then
			setDBValueOriginal = DB.setValue;
			DB.setValue = setDBValue; --luacheck: ignore 122
		end
	end
	resetHealthOriginal(nodeChar, bLong);
end

function setDBValue(vFirst, vSecond, ...) --luacheck: ignore 212
	if vSecond == "hp.wounds" then
		DB.setValue = setDBValueOriginal; --luacheck: ignore 122
	else
		setDBValueOriginal(vFirst, vSecond, unpack(arg));
	end
end