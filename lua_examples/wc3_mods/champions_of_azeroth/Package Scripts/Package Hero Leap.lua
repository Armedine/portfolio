-- @unit = unit to move
-- @leapDuration = duration to get to x,y
-- @x,y = target point to leap to
-- @customTakeoffFunc = function to run when effect starts
-- @customLandingFunc = function to run when effect ends
-- returns boolean
function HeroLeapTargetPoint(unit,leapDuration,x,y,customTakeoffFunc,customLandingFunc)
	local u = unit
	local x1 = x
	local y1 = y
	local x2 = GetUnitX(u)
	local y2 = GetUnitY(u)
	local angle = AngleBetweenPointsXY(x2,y2,x1,y1)
	local travelDistance = DistanceBetweenXY(x1,y1,x2,y2)
	local velocity = travelDistance/(leapDuration/.04)
	local i = (leapDuration/.04)
	local abilId = GetSpellAbilityId()

	if (not IsTerrainPathable(x1,y1,PATHING_TYPE_WALKABILITY)) then -- pathable, allow (pathing function returns opposite bool)

		SetUnitFacing(u, angle)
		SetUnitPathing(u, false)
		SetUnitAnimation(u,"walk")

		if (customTakeoffFunc ~= nil) then
			customTakeoffFunc()
		end

		TimerStart(NewTimer(),0.04,true,function() -- leap
			if (i > 0 and IsUnitAliveBJ(u)) then
				i = i-1
				x2,y2 = PolarProjectionXY(x2,y2,velocity,angle)
				SetUnitX(u,x2)
				SetUnitY(u,y2)
			else
				if (customLandingFunc ~= nil) then
					customLandingFunc()
				end
				ResetUnitAnimation(u)
				SetUnitPathing(u, true)
				ReleaseTimer()
			end
		end)

		return true
	else -- not pathable, reset abil cd
		SpellPackInvalidMsg(u, 'Target area is not pathable!')
		TimerStart(NewTimer(),0.25,false,function() BlzEndUnitAbilityCooldown(u,abilId) end)

		return false
	end

end
