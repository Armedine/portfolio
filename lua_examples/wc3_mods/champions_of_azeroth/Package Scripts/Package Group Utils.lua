--
-- group utils: functions to loop through groups to act on member units
--

LUA_FILTERUNIT = nil -- global filter unit that surplants blizzard.j filter unit

-- @g = group to loop through
-- @callback = function to run on each unit
function GroupUtilsAction(g,callback)
	local size = BlzGroupGetSize(g)
	if (size > 0) then
		local i = 0
	 	repeat
	 		LUA_FILTERUNIT = BlzGroupUnitAt(g,i)
	 		callback()
		    i = i + 1
	  	until (i >= size or LUA_FILTERUNIT == nil)
	end
end


--
-- group actions: variants that insert specific features into group loops
--

-- @g = group to check
-- @unit = remove this unit from group
function GroupActionRemoveDead(g)
	GroupUtilsAction(g,function()
		if (not IsUnitAliveBJ(LUA_FILTERUNIT)) then
			GroupRemoveUnit(g,LUA_FILTERUNIT)
		end
	end)
end


-- @unit = order this unit to attack @targetUnit
-- @targetUnit = unit to attack
function GroupActionAttackUnit(g,targetUnit)
	GroupUtilsAction(g,function()
		if (IsUnitAliveBJ(LUA_FILTERUNIT)) then
			IssueTargetOrder(LUA_FILTERUNIT,'attack',targetUnit)
		end
	end)
end
