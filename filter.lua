if not Cursive.superwow then
	return
end

local filter = {
}

filter.attackable = function(unit)
	return UnitCanAttack("player", unit) and true or false
end

filter.player = function(unit)
	return UnitIsPlayer(unit) and true or false
end

filter.notplayer = function(unit)
	return not UnitIsPlayer(unit) and true or false
end

filter.infight = function(unit)
	return UnitAffectingCombat(unit) and true or false
end

filter.hascurse = function(unit)
	return Cursive.curses:HasAnyCurse(unit) and true or false
end

filter.alive = function(unit)
	return not UnitIsDead(unit) and true or false
end

filter.range = function(unit)
	if IsSpellInRange then
		-- 16707 is hex which has 45 yd range
		return IsSpellInRange(16707, unit) == 1 and true or false
	else
		return CheckInteractDistance(unit, 4) and true or false
	end
end

filter.icon = function(unit)
	return GetRaidTargetIndex(unit) and true or false
end

filter.normal = function(unit)
	local elite = UnitClassification(unit)
	return elite == "normal" and true or false
end

filter.elite = function(unit)
	local elite = UnitClassification(unit)
	return (elite == "elite" or elite == "rareelite") and true or false
end

filter.hostile = function(unit)
	return UnitIsEnemy("player", unit) and true or false
end

filter.notignored = function(unit)
	if not Cursive.db.profile.ignorelist or table.getn(Cursive.db.profile.ignorelist) == 0 then
		return true
	end

	local unitName = UnitName(unit)
	if not unitName then
		return true
	end
	for _, str in ipairs(Cursive.db.profile.ignorelist) do
		if string.find(string.lower(unitName), string.lower(str)) then
			return false
		end
	end
	return true
end

Cursive.filter = filter

function Cursive:ShouldDisplayGuid(guid)
	-- never display units that don't exist
	if not UnitExists(guid) then
		return false
	end

	-- never display dead units
	if not Cursive.filter.alive(guid) then
		return false
	end

	local _, targetGuid = UnitExists("target")

	-- always show target if attackable
	if (targetGuid == guid) and filter.attackable(guid) then
		return true
	end

	-- always show raid marks if attackable and not in combat or this guid is affecting combat
	if filter.icon(guid) and filter.attackable(guid) and (not UnitAffectingCombat("player") or UnitAffectingCombat(guid)) then
		return true
	end

	if Cursive.db.profile.filterincombat and not filter.infight(guid) then
		return false
	end

	if Cursive.db.profile.filterhascurse and not filter.hascurse(guid) then
		return false
	end

	if Cursive.db.profile.filterhostile and not filter.hostile(guid) then
		return false
	end

	if Cursive.db.profile.filterattackable and not filter.attackable(guid) then
		return false
	end

	if Cursive.db.profile.filterrange and not filter.range(guid) then
		return false
	end

	if Cursive.db.profile.filterraidmark and not filter.icon(guid) then
		return false
	end

	if Cursive.db.profile.filterplayer and not filter.player(guid) then
		return false
	end

	if Cursive.db.profile.filternotplayer and not filter.notplayer(guid) then
		return false
	end

	if Cursive.db.profile.filterignored and not filter.notignored(guid) then
		return false
	end

	return true
end
