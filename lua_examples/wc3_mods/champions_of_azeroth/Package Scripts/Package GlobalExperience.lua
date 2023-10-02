-- kept as a separate function on a timer for peformance
function UpdateExperience()

	local hero
	local xp = 0
	
	for i = 1,10,1 do
		hero = udg_playerHero[i]
		if hero ~= nil then
			if i <= 5 then
				xp = GetHeroXP(udg_zGlobalXPUnit[0])
			else
				xp = GetHeroXP(udg_zGlobalXPUnit[1])
			end
			SetHeroXP(hero, xp, true)
		end
	end

end

-- run at map init to begin collating exp
function InitUpdateExperience()
	globalExperienceTimer = NewTimer()
	TimerStart(globalExperienceTimer,2.33,true,function()
		UpdateExperience() end)
end

-- @slayer unit = award xp to this unit's faction unit
-- @victim unit = award xp based on this unit's type
-- returns true if experience was added, false if failed to add
function AddExperience(slayer, victim)

	local slayerOwner
	local victimOwner
	local factionUnit
	local xp = 0
	local loc
	local loopstart
	local loopend
	local x
	local y
	slayerOwner = GetOwningPlayer(slayer)
	victimOwner = GetOwningPlayer(victim)

	if ( IsPlayerAlly(slayerOwner, victimOwner) ) then
		return false
	else
		loc = GetUnitLoc(victim)
		x = GetLocationX(loc)
		y = GetLocationY(loc)
		-- force [0] = horde // [1] = alliance
		if ( IsPlayerInForce( slayerOwner, udg_playerForce[0] ) ) then
			factionUnit = udg_zGlobalXPUnit[0]
			loopstart = 1
			loopend = 5
		elseif ( IsPlayerInForce( slayerOwner, udg_playerForce[1] ) ) then
			factionUnit = udg_zGlobalXPUnit[1]
			loopstart = 6
			loopend = 10
		end

		if ( not IsUnitType( victim, UNIT_TYPE_SUMMONED ) and XPIsHeroInRange( loc, loopstart, loopend ) ) then
			if ( IsUnitType( victim, UNIT_TYPE_HERO ) ) then
				xp = udg_zGlobalXPVal*3 -- R2I(6 + ((GetHeroLevel(victim)*2)/GetHeroLevel(slayer))*6) -- award more experience to heroes that are a lower level than the hero slain
				if (GetHeroLevel(victim) > GetHeroLevel(slayer)) then
					xp = R2I(xp*1.5)
				end
			else
				xp = udg_zGlobalXPVal
			end
			AddHeroXP(factionUnit, xp, true)
			--ArcingTextTag( "|cffaa00aa+" .. R2I(xp) .. " xp|r", slayer )
			LeaderboardAddEligibleXP(x,y,xp,slayerOwner)
		end
		RemoveLocation(loc)
		return true
	end

end


-- @point = position of victim
-- @loopstart = declares start for loop to simplify loop check (performance)
-- @loopend = declares end for loop to simplify loop check (performance)
-- return boolean
function XPIsHeroInRange(point, loopstart, loopend)

	local bool = false
	local loc = point

	for i = loopstart,loopend,1 do
		if ( IsUnitInRangeLoc( udg_playerHero[i], loc, 1000.0 ) ) then
			bool = true
			break
		end
	end

	RemoveLocation(loc)
	return bool

end
