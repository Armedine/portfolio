-- :: increase str, agi or int for hero
-- @unit = hero
-- @attributeInt = 0 for Str, 1 for Agi, 2 for Int
-- @amountReal = amount to increase
function HeroAddStat(unit, attributeInt, amountInt)

	ModifyHeroStat( attributeInt, unit, bj_MODIFYMETHOD_ADD, amountInt )

end


-- :: decrease str, agi or int for hero
-- @unit = hero
-- @attributeInt = 0 for Str, 1 for Agi, 2 for Int
-- @amountReal = amount to increase
function HeroRemoveStat(unit, attributeInt, amountInt)

	ModifyHeroStat( attributeInt, unit, bj_MODIFYMETHOD_SUB, amountInt )

end


-- :: increase str, agi or int for hero over time (for items that increment)
-- @unit = hero
-- @attributeInt = 0 for Str, 1 for Agi, 2 for Int
-- @amountReal = amount to increase
-- @periodReal = how often stat is added (e.g. 60.0)
-- @ceilingInt = max amount of stat to add (e.g. 10)
function HeroAddStatTimer(unit, attributeInt, amountInt, periodReal, ceilingInt)

	local i = 0
	TimerStart(NewTimer(),periodReal,true,function()
		ModifyHeroStat( attributeInt, unit, bj_MODIFYMETHOD_ADD, amountInt )
		i = i + 1
		if (i >= ceilingInt) then
			ReleaseTimer()
		end
	end)

end
