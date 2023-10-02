function DAI__VarGen()
	-- [[ global agent config variables ---------------]]

	-- general config:
	ai__lowHealth__r = 30.0					-- if the agent reaches this percentage of health, they will retreat to heal at their regen point
	ai__safeHealth__r = 75.0				-- if the agent reaches this percentage of health, they will resume lane activity
	-- wave push settings:
	ai__isSafeToPushRange__r = 2150.0		-- searches this radius for an allied group of units (minion wave) and commands the agent to follow it if count > ai__feelsSafeThreshold__i
	ai__isSafeRange__r = 2000.0				-- determines the radius for an agent feeling safe (casting teleport, hold position at regen fountain, etc.)
	ai__teleportRegenRange__r = 0.0			-- (set to 0.0 to always teleport) if the agent is at least this far away from a regen point, the agent will teleport to base instead of running around the map
	ai__isNearEnemyHeroRange__r = 675.0		-- search this range to engage enemy heroes
	ai__isNearAllyHeroRange__r = 1500.0		-- search this range to assist ally heroes
	ai__isNearEnemyMinionRange__r = 650.0	-- search this range to engage minion waves
	ai__isNearEnemyMinionCount__i = 3		-- if at least this nearby enemy minions are nearby, engage in WAVECLEAR
	ai__followWaveLeashRange__r = 750.0		-- minimum follow distance before returning to an assigned wave during PUSH state
	ai__feelsSafeThreshold__i = 1			-- the number of nearby allied minions required for an agent to begin pushing forward; if less than this, they retreat to focus point
	-- combat settings:
	ai__combatAttemptsAllowed = 7			-- determines how many abilities are used in COMBAT state (this * ai__combatAbilityCadence__r = COMBAT duration)
	ai__combatFatigueDurationD__r = 1.13	-- the default setting for how long should the agent wait before entering COMBAT state again
	ai__combatAbilityCadenceD__r = 0.99		-- the default setting for how often the a.i. should cycle through abilities while in COMBAT state
	ai__combatDisengageHealthPerc__r = 22.5 -- if the agent loses this much % of their health after engaging, COMBAT ends early
	ai__combatFleeDuration__r = 2.33		-- how long the agent should flee when hit by an objective spell or enemy tower-
	ai__isNearTowersRange__r = 1500.0		-- determines if the agent is near an enemy base and prevents things like teleporting to home insie an enemy fortification
	-- objective settings:
	ai__combatFatigueDurationObj__r = 0.11	-- fatigue when objective is active
	ai__combatAbilityCadenceObj__r = 3.33	-- cadence when objective is active
	ai__objCenterBasesReq__i = 2			-- (0-based, 2 == 3 required) if number of bases owned by faction in center lane is less than this amount, ignore objective
	-- misc. config:
	ai__neutralOdds__i = 3					-- 1 in x chance for agent to select a neutral hero instead of a faction hero
	ai__laneConfig__t = {					-- set the number of heroes to assign to each lane by default (TODO: until we get more intelligent about reassignment)
		[0] = 2,
		[1] = 1,
		[2] = 2
	}
	-- do not edit past this point:
	ai__combatFatigueDuration__r = ai__combatFatigueDurationD__r	-- initialize default
	ai__combatAbilityCadence__r = ai__combatAbilityCadenceD__r	-- initialize default
	-- [[ ---------------------------------------------]]

	-- [[ global agent data ----------------------------]]
	-- udg_playerHero[n] == the agent's hero unit
	ai__ignoreObj = {}						-- if eligible, ignore objective when active
	ai__combatStartingHealthPerc = {}		-- percentage of life when entering combat
	ai__playerNum = {}						-- player slot the agent filled
	ai__factionNum = {}						-- assigned faction (0 = horde, 1 = alliance)
	ai__state = {}							-- the current state of the agent
	ai__combatState = {}					-- an intermediate state that determines what the agent should do in short windows of time
	ai__combatFatigue = {}					-- bool to control if the agent is avoiding combat
	ai__combatAttempts = {}					-- number of abilities attempted during COMBAT state; if this becomes equal to ai__combatDuration__r, COMBAT ends
	ai__debugTable = {}						-- debug only
	ai__stateTimer = {}						-- periodic timer that runs state priority stack
	ai__laneNum = {}						-- the lane the agent is currently occupying
	ai__baseX = {}							-- base x coord (return for regen or cast tele after idle reached)
	ai__baseY = {}							-- base x coord (return for regen or cast tele after idle reached)
	ai__totalNum = 0						-- total initiated agent profiles
	ai__followUnit = {}						-- unit the agent is currently following
	ai__regenPointX = {}					-- the location the agent retreats to in order to heal
	ai__regenPointY = {}					-- the location the agent retreats to in order to heal
	ai__controlPointTopX = {}				-- the furthest point for an agent profile per lane, mapped with ai__controlPointMapTop; ai__laneNum is the reference to grab the point stored here
	ai__controlPointMidX = {}				-- the furthest point for an agent profile per lane, mapped with ai__controlPointMapMid; ai__laneNum is the reference to grab the point stored here
	ai__controlPointBotX = {}				-- the furthest point for an agent profile per lane, mapped with ai__controlPointMapBot; ai__laneNum is the reference to grab the point stored here
	ai__controlPointTopY = {}				-- the furthest point for an agent profile per lane, mapped with ai__controlPointMapTop; ai__laneNum is the reference to grab the point stored here
	ai__controlPointMidY = {}				-- the furthest point for an agent profile per lane, mapped with ai__controlPointMapMid; ai__laneNum is the reference to grab the point stored here
	ai__controlPointBotY = {}				-- the furthest point for an agent profile per lane, mapped with ai__controlPointMapBot; ai__laneNum is the reference to grab the point stored here
	ai__objPointX = {}						-- x,y of where objective is (gathers all agents to this point when obj is active)
	ai__objPointY = {}						-- x,y of where objective is (gathers all agents to this point when obj is active)
	ai__heroId = {}							-- the hero Id; used to map other systems e.g. ability profiles
	ai__flightPathX = {}					-- the position the agent will go to purchase a flight path to a lane
	ai__flightPathY = {}					-- the position the agent will go to purchase a flight path to a lane
	ai__stateCombatTimer = {}				-- combat timer that controls behavior events and cadence
	-- TODO: ai__abilityOrder = {}

	-- [[ trigger vars ---------------------------------]]
	ai__trigger__flee = {}				-- reference var for FLEE state trigger
	-- [[ ----------------------------------------------]]

	ai__STATE__INIT = 0 				-- initial state
	ai__STATE__TRANSIT = 1 				-- agent has been directed to move toward location (NON attack-move)
	ai__STATE__SITTER = 2				-- agent has been directed to sit at a base until a minion wave comes
	ai__STATE__REGEN = 3				-- agent has been directed to regenerate health
	ai__STATE__FLEE = 4					-- agent has been directed to retreat toward base direction a certain number of cells
	ai__STATE__ENGAGE = 5				-- agent has been directed to continuously attack an enemy target
	ai__STATE__IDLE = 6					-- agent has been directed to remain idle
	ai__STATE__TELEPORT = 7				-- agent has been directed to teleport back to base
	ai__STATE__POKE = 8					-- agent has been directed to run at a target to cast a spell
	ai__STATE__DEAD = 9					-- agent is currently respawning
	ai__STATE__PUSH = 10				-- agent is currently pushing a lane
	ai__STATE__FLIGHT = 11				-- agent is currently pushing a lane
	ai__STATE__COMBAT = 12				-- agent is in combat with a target
	ai__STATE__AWAITING__FP = 13		-- agent is idle and will next be sent to flight path
	ai__STATE__FP = 14					-- agent is moving to flight path
	ai__STATE__OBJ = 15					-- agent is targeting an objective point
	ai__STATE__WAVECLEAR = 16			-- agent is pushing and not near enemy heroes, so clear minions

	ai__STATE_STRINGS = {				-- for debug
		[0] = "INIT",
		[1] = "TRANSIT",
		[2] = "SITTER",
		[3] = "REGEN",
		[4] = "FLEE",
		[5] = "ENGAGE",
		[6] = "IDLE",
		[7] = "TELEPORT",
		[8] = "POKE",
		[9] = "DEAD",
		[10] = "PUSH",
		[11] = "FLIGHT",
		[12] = "COMBAT",
		[13] = "AWAITING_FP",
		[14] = "FP",
		[15] = "OBJ",
		[16] = "WAVECLEAR"
	}

	ai__laneOccupationHorde = {		-- occupied lanes by agent (number of active agent assigned to each lane)
		[0] = 0,
		[1] = 0,
		[2] = 0
	}
	ai__laneOccupationAlliance = {	-- occupied lanes by agent (number of active agent assigned to each lane)
		[0] = 0,
		[1] = 0,
		[2] = 0
	}
end

--[[ game data init functions (vars leveraging gg_ need to be declared after global init else they return 0.0 or nil)]]
function DAI__GrabXY()
	ai__controlPointMapTopX = {
		[0] = GetRectCenterX(gg_rct_minionsHordeTop),
		[1] = GetRectCenterX(gg_rct_laneHordeBase1),
		[2] = GetRectCenterX(gg_rct_laneHordeBase4),
		[3] = GetRectCenterX(gg_rct_laneAllianceBase4),
		[4] = GetRectCenterX(gg_rct_laneAllianceBase1),
		[5] = GetRectCenterX(gg_rct_minionsAllianceTop)
	}
	ai__controlPointMapMidX = {
		[0] = GetRectCenterX(gg_rct_minionsHordeMid),
		[1] = GetRectCenterX(gg_rct_laneHordeBase2),
		[2] = GetRectCenterX(gg_rct_laneHordeBase5),
		[3] = GetRectCenterX(gg_rct_laneAllianceBase5),
		[4] = GetRectCenterX(gg_rct_laneAllianceBase2),
		[5] = GetRectCenterX(gg_rct_minionsAllianceMid)
	}
	ai__controlPointMapBotX = {
		[0] = GetRectCenterX(gg_rct_minionsHordeBot),
		[1] = GetRectCenterX(gg_rct_laneHordeBase3),
		[2] = GetRectCenterX(gg_rct_laneHordeBase6),
		[3] = GetRectCenterX(gg_rct_laneAllianceBase6),
		[4] = GetRectCenterX(gg_rct_laneAllianceBase3),
		[5] = GetRectCenterX(gg_rct_minionsAllianceBot)
	}
	ai__controlPointMapTopY = {
		[0] = GetRectCenterY(gg_rct_minionsHordeTop),
		[1] = GetRectCenterY(gg_rct_laneHordeBase1),
		[2] = GetRectCenterY(gg_rct_laneHordeBase4),
		[3] = GetRectCenterY(gg_rct_laneAllianceBase4),
		[4] = GetRectCenterY(gg_rct_laneAllianceBase1),
		[5] = GetRectCenterY(gg_rct_minionsAllianceTop)
	}
	ai__controlPointMapMidY = {
		[0] = GetRectCenterY(gg_rct_minionsHordeMid),
		[1] = GetRectCenterY(gg_rct_laneHordeBase2),
		[2] = GetRectCenterY(gg_rct_laneHordeBase5),
		[3] = GetRectCenterY(gg_rct_laneAllianceBase5),
		[4] = GetRectCenterY(gg_rct_laneAllianceBase2),
		[5] = GetRectCenterY(gg_rct_minionsAllianceMid)
	}
	ai__controlPointMapBotY = {
		[0] = GetRectCenterY(gg_rct_minionsHordeBot),
		[1] = GetRectCenterY(gg_rct_laneHordeBase3),
		[2] = GetRectCenterY(gg_rct_laneHordeBase6),
		[3] = GetRectCenterY(gg_rct_laneAllianceBase6),
		[4] = GetRectCenterY(gg_rct_laneAllianceBase3),
		[5] = GetRectCenterY(gg_rct_minionsAllianceBot)
	}
end
--[[ ------------------------------------------------------]]


-- @n = player number / slot to fill with agent profile
-- @f = faction to generate hero for | 0 for horde, 1 for alliance
function DAI__GenerateProfile(n, f)
	math.randomseed( GetTimeOfDay()*10000000*bj_PI )
	local r = math.random(0,ai__neutralOdds__i) -- how often agent should pick neutral hero over faction hero
	local loc
	local loc2
	ai__factionNum[n] = f
	ai__combatFatigue[n] = false
	udg_aiPlayerIsAgent[n] = true -- GUI global ai identifier

	if (f == 0) then -- set spawn point
		loc = GetRectCenter(gg_rct_spawnHeroHorde)
		loc2 = GetRectCenter(gg_rct_flightMasterHorde1)
	elseif (f == 1) then
		loc = GetRectCenter(gg_rct_spawnHeroAlliance)
		loc2 = GetRectCenter(gg_rct_flightMasterAlliance1)
	end

	ai__baseX[n] = GetLocationX(loc)
	ai__baseY[n] = GetLocationY(loc)
	ai__flightPathX[n] = GetLocationX(loc2)
	ai__flightPathY[n] = GetLocationY(loc2)

	-- if neutral hero odds passed OR original faction table is empty, choose neutral; 0=horde, 1=alliance, 2=neutral
	if ((#ai__faction__heroes__neutral > 0 and r == ai__neutralOdds__i) or ((f == 0 and #ai__faction__heroes__horde == 0) or (f == 1 and #ai__faction__heroes__alliance == 0))) then
		ai__heroId[n] = DAI__RandomizedHeroId(2) -- grab a neutral heroId based on neutral odds
	else
		ai__heroId[n] = DAI__RandomizedHeroId(f)
	end

	udg_playerHero[n] = CreateUnitAtLoc(ConvertedPlayer(n), FourCC(ai__heroId[n]), loc, 270.0) -- simulate real player for existing GUI triggers
	LoadHero(udg_playerHero[n],n) -- load the hero triggers, controlled by LoadHero under Hero Abilities
	ai__playerNum[n] = n
	ai__state[n] = ai__STATE__INIT
	ai__totalNum = ai__totalNum + 1
	ai__debugTable[ai__totalNum] = n -- this won't match player slot index; used only for debug loops
	DAI__LaneSortGenerate(n,f)
	ai__stateTimer[n] = TimerStart(NewTimer(n), 0.66, true, function() -- initialize timer to contantly check agent state the rest of the game (lower time = more accuracy but less performance)
		DAI__StateEngine(n)
	end)

	local colorString = ''
	if n > 5 then -- alliance
		colorString = '|cff2c2ce9'
	else -- horde
		colorString = '|cffff2c2c'
	end

	local unitName = GetUnitName(udg_playerHero[n])
	SetPlayerName(ConvertedPlayer(n),colorString .. unitName .. ' (|r|cff00e9ffBot|r' .. colorString .. ')|r')

	ShowUnit(udg_playerShop[n], true)
	ShowUnit(udg_playerShopElite[n], true)
	
	LeaderboardUpdatePlayerName(n, "(" .. n .. ") " .. unitName, nil, true)
	LeaderboardUpdateEliminations(n)
	LeaderboardUpdateDeaths(n)
	LeaderboardUpdateXP(n)

	RemoveLocation(loc)
	RemoveLocation(loc2)

	-- set up tower flee listener
	ai__trigger__flee[n] = CreateTrigger()
	local func = function()
		local pNumb = GetConvertedPlayerId(GetOwningPlayer(udg_DamageEventTarget))
		ai__state[pNumb] = ai__STATE__FLEE
		DAI__MoveToControlPoint(pNumb, "move")
		TimerStart(NewTimer(),ai__combatFleeDuration__r,true,function()
			if (not DAI__StateIsNearHostileTowers(pNumb,600.0)) then
				ai__state[pNumb] = ai__STATE__IDLE
				ReleaseTimer()
			else
				DAI__MoveToControlPoint(pNumb, "move")
			end
		end)
	end
	TriggerRegisterVariableEvent( ai__trigger__flee[n], "udg_DamageEvent", EQUAL, 1.00 )
	TriggerAddCondition( ai__trigger__flee[n], Filter( function() return udg_DamageEventTarget == udg_playerHero[n]
			and ( IsUnitType(udg_DamageEventSource,UNIT_TYPE_STRUCTURE) or IsUnitType(udg_DamageEventSource,UNIT_TYPE_ANCIENT) )
			and udg_DamageEventAttackT ~= udg_ATTACK_TYPE_HERO
			and ai__state[n] ~= ai__STATE__FLEE
		end ) )
	TriggerAddAction(ai__trigger__flee[n],func)

end


-- @n = player number (int) under agent control
-- @f = faction number (0 = horde, 1 = alliance)
function DAI__LaneSortGenerate(n,f)
--DebugMsg( "attempting lane init for: " .. n )

	local laneCap = 0
	local x
	local y

	if (f == 0) then
		ai__controlPointTopX[n] = ai__controlPointMapTopX[2]
		ai__controlPointMidX[n] = ai__controlPointMapMidX[2]
		ai__controlPointBotX[n] = ai__controlPointMapBotX[2]
		ai__controlPointTopY[n] = ai__controlPointMapTopY[2]
		ai__controlPointMidY[n] = ai__controlPointMapMidY[2]
		ai__controlPointBotY[n] = ai__controlPointMapBotY[2]
		for lane = 0,2,1 do
			if (ai__laneOccupationHorde[lane] < ai__laneConfig__t[lane]) then
				ai__laneOccupationHorde[lane] = ai__laneOccupationHorde[lane] + 1
				ai__laneNum[n] = lane -- assign lane
				DAI__UpdateRegenPointToCP(n) -- update where the agent moves to in order to restore health
				--DebugMsg(ai__laneNum[n] .. " is assigned lane for " .. n)
				break
			end
		end
	elseif (f == 1) then
		ai__controlPointTopX[n] = ai__controlPointMapTopX[3]
		ai__controlPointMidX[n] = ai__controlPointMapMidX[3]
		ai__controlPointBotX[n] = ai__controlPointMapBotX[3]
		ai__controlPointTopY[n] = ai__controlPointMapTopY[3]
		ai__controlPointMidY[n] = ai__controlPointMapMidY[3]
		ai__controlPointBotY[n] = ai__controlPointMapBotY[3]
		for lane = 0,2,1 do
			if (ai__laneOccupationAlliance[lane] < ai__laneConfig__t[lane]) then
				ai__laneOccupationAlliance[lane] = ai__laneOccupationAlliance[lane] + 1
				ai__laneNum[n] = lane -- assign lane
				DAI__UpdateRegenPointToCP(n) -- update where the agent moves to in order to restore health
				break
			end
		end
	end

end


-- runs a series of functions that prioritize what the agent should be doing; this function controls the agent movement based on state returns
-- @n = player number to run state engine for
function DAI__StateEngine(n)

	--[[ AI NON-COMBAT STATE MANAGEMENT ]]
	if (IsUnitAliveBJ(udg_playerHero[n])) then

		if (ai__state[n] == ai__STATE__FP) then -- command agent to move toward and take FP to lane
			if (IsUnitInRangeXY( udg_playerHero[n], ai__flightPathX[n], ai__flightPathY[n], 320.0 ) ) then -- fake a FP purchase
				DAI__PurchaseFlightPath(n)
				ai__state[n] = ai__STATE__IDLE
			elseif (not IsUnitInRangeXY( udg_playerHero[n], ai__flightPathX[n], ai__flightPathY[n], 1750.0 )) then -- [debugger] if agent entered FP state outside of FP bounds, reset
				ai__state[n] = ai__STATE__IDLE
				DAI__MoveToControlPoint(n, "attack")
			else -- move toward
				DAI__MoveToFlightPoint(n, "move")
			end

		elseif (ai__state[n] == ai__STATE__AWAITING__FP and not DAI__StateHealthIsLow(n)) then -- if was commanded to holdposition but is now healthy, continue
			ai__state[n] = ai__STATE__FP

		else

			if (ai__state[n] ~= ai__STATE__COMBAT and ai__state[n] ~= ai__STATE__WAVECLEAR) then -- if objective is not in progress and not in combat, run lane behavior
				if (ai__state[n] == ai__STATE__TELEPORT) then
					if (DAI__StateIsSafe(n) or DAI__StateIsSafeToPush(n,0)) then -- if safe, do nothing and continue to teleport unless already at base (distance check)
						if (DistanceBetweenXY(GetUnitX(udg_playerHero[n]),GetUnitY(udg_playerHero[n]),ai__baseX[n],ai__baseY[n]) <= 500.0 and GetUnitLifePercent(udg_playerHero[n]) > ai__safeHealth__r) then -- if agent is healthy, reset to idle
							ai__state[n] = ai__STATE__IDLE
						end
					else -- if dangerous, cancel teleport and manually transit to regen point
						DAI__MoveToRegenPoint(n)
						if (not DAI__StateHealthIsLow(n)) then
							ai__state[n] = ai__STATE__IDLE
						end
					end

				else


					if (DAI__StateIsAtBase(n) and GetUnitLifePercent(udg_playerHero[n]) < ai__safeHealth__r and ai__state[n] ~= ai__STATE__AWAITING__FP) then
						IssueImmediateOrder(udg_playerHero[n], "holdposition")
						ai__state[n] = ai__STATE__AWAITING__FP -- prepare for FP

					elseif (DAI__StateIsAtBase(n) and GetUnitLifePercent(udg_playerHero[n]) > ai__safeHealth__r) then
						DAI__MoveToControlPoint(n, "attack")
						ai__state[n] = ai__STATE__FP -- command ai to go purchase a flight path to their lane

					elseif (DAI__StateHealthIsLow(n) and ai__state[n] ~= ai__STATE__REGEN) then -- retreat if health is low
						DAI__MoveToRegenPoint(n)
						ai__state[n] = ai__STATE__REGEN

					elseif (ai__state[n] == ai__STATE__REGEN) then -- wait for regen to complete, then make idle which will allow DAI__MoveToControlPoint to operate
						if (DAI__StateIsSafe(n) and not DAI__StateIsNearHostileTowers(n,0)
						and DistanceBetweenXY(GetUnitX(udg_playerHero[n]),GetUnitY(udg_playerHero[n]),ai__regenPointX[n],ai__regenPointY[n]) > ai__teleportRegenRange__r and not DAI__StateIsAtRegenPoint(n)) then -- teleport home if not near regen point
							DAI__TeleportHome(n)
							ai__state[n] = ai__STATE__TELEPORT
							TimerStart(NewTimer(n), 8.0, false, function() -- safety net if critical state error occurs
								if (ai__state[n] == ai__STATE__TELEPORT) then ai__state[n] = ai__STATE__IDLE end
								ReleaseTimer()
							end)
						elseif (not DAI__StateHealthIsLow(n, ai__lowHealth__r + 12.0) and DAI__StateIsSafeToPush(n,0)) then -- listen for a health restore to re-engage (e.g. a healer)
							ai__state[n] = ai__STATE__PUSH
							DAI__FollowNearbyMinion(n,0)
						elseif (not DAI__StateHealthIsLow(n, ai__lowHealth__r + 12.0) and DAI__StateIsNearEnemyHero(n)) then -- listen for a health restore to re-engage (e.g. a healer)
							ai__state[n] = ai__STATE__COMBAT
							ai__combatAttempts[n] = 0
						elseif (not DAI__StateIsAtRegenPoint(n)) then 
							DAI__MoveToRegenPoint(n)
						end
						if (GetUnitLifePercent(udg_playerHero[n]) > ai__safeHealth__r) then
							if (DAI__StateIsSafeToPush(n,2500.0)) then
								DAI__FollowNearbyMinion(n,2500.0)
								ai__state[n] = ai__STATE__PUSH
							else
								ai__state[n] = ai__STATE__IDLE
							end
							--DebugMsg("state engine: " .. n .. "; health restored, return to idle")
						elseif (not DAI__StateIsSafe(n) and DAI__StateIsAtRegenPoint(n)) then
							IssueImmediateOrder(udg_playerHero[n], "holdposition")
							--DebugMsg("state engine: " .. n .. "; threat detected nearby while REGEN, hold position")
						end

					elseif (udg_aiTargetObjective and not ai__ignoreObj[n] and ai__state[n] ~= ai__STATE__OBJ) then -- obj targeting in progress

						ai__state[n] = ai__STATE__OBJ -- toggle objective movement when obj active
						DAI__MoveToObjectivePoint(n, "attack")

					elseif (ai__state[n] == ai__STATE__OBJ and udg_aiTargetObjective == false) then -- obj targeting has ended

						DAI__MoveToRegenPoint(n)
						ai__state[n] = ai__STATE__REGEN -- if objective is over, send back to base to heal and resume lane pushing

					elseif (ai__state[n] == ai__STATE__OBJ) then -- do objective behavior

						if (DAI__StateIsNearEnemyHero(n) and not DAI__StateIsNearHostileTowers(n,500.0)) then
							if (not ai__combatFatigue[n]) then -- if agent has not engaged recently, engage
								ai__state[n] = ai__STATE__COMBAT
								ai__combatAttempts[n] = 0
							end
						else
							DAI__MoveToObjectivePoint(n, "move")
						end

					elseif (not DAI__StateIsSafeToPush(n,0) and ai__state[n] == ai__STATE__PUSH) then -- if push in progress and no longer safe, begin retreat
						DAI__MoveToControlPoint(n, "move")
						ai__state[n] = ai__STATE__TRANSIT
						--DebugMsg("state engine: " .. n .. "; push is no longer safe, running DAI__MoveToControlPoint")

					elseif (DAI__StateIsSafeToPush(n,0) and DAI__StateIsNearEnemyMinionCount(n, 0, 3) and ai__state[n] == ai__STATE__PUSH
					and not DAI__StateIsNearEnemyHero(n)) then -- if pushing and not near enemy hero, and near x minimum minions, engage minions
						if (not ai__combatFatigue[n]) then -- if agent has not engaged recently, engage
							ai__state[n] = ai__STATE__WAVECLEAR
							ai__combatAttempts[n] = 0
						end
						
					elseif ((DAI__StateIsSafeToPush(n,0) and ai__state[n] ~= ai__STATE__PUSH)) then -- initiate push down lane
						DAI__FollowNearbyMinion(n,0)
						ai__state[n] = ai__STATE__PUSH
						--DebugMsg("state engine: " .. n .. "; minion wave found, follow")

					elseif ai__state[n] == ai__STATE__PUSH and ai__followUnit[n] ~= nil and not IsUnitAliveBJ(ai__followUnit[n]) then -- is lane push follow unit dead?
						ai__followUnit[n] = nil
						if (DAI__StateIsSafeToPush(n,0)) then
							DAI__FollowNearbyMinion(n,0)
						else
							DAI__MoveToControlPoint(n, "attack")
							ai__state[n] = ai__STATE__TRANSIT
						end

					elseif (ai__state[n] == ai__STATE__PUSH
					and ai__followUnit[n] ~= nil
					and IsUnitAliveBJ(ai__followUnit[n])
					and DistanceBetweenXY(GetUnitX(udg_playerHero[n]),GetUnitY(udg_playerHero[n]),GetUnitX(ai__followUnit[n]),GetUnitY(ai__followUnit[n])) > ai__followWaveLeashRange__r ) then -- is lane push follow unit dead?
						IssueTargetOrder(udg_playerHero[n],"smart",ai__followUnit[n])

					elseif (DAI__StateIsNearEnemyHero(n) and ai__state[n] == ai__STATE__PUSH and not DAI__StateIsNearHostileTowers(n,550.0)) then
						if (not ai__combatFatigue[n]) then -- if agent has not engaged recently, engage
							ai__state[n] = ai__STATE__COMBAT
							ai__combatAttempts[n] = 0
						end

					elseif (ai__state[n] == ai__STATE__IDLE and not DAI__StateIsAtControlPoint(n)) then -- if caught idle somewhere else on map, go to CP
						DAI__MoveToControlPoint(n, "move")
						ai__state[n] = ai__STATE__TRANSIT

					elseif (ai__state[n] == ai__STATE__TRANSIT and not DAI__StateIsAtControlPoint(n)) then -- if CP transit in progress, keep moving
						DAI__MoveToControlPoint(n, "move")

					elseif (ai__state[n] == ai__STATE__TRANSIT and DAI__StateIsAtControlPoint(n)) then -- if sitting 
						ai__state[n] = ai__STATE__SITTER

					elseif (not DAI__StateIsSafeToPush(n,0) and (DAI__StateIsAtControlPoint(n) or DAI__StateIsAtRegenPoint(n))) then
						ai__state[n] = ai__STATE__IDLE

					end

				end -- end tele check block

			else -- if state is combat, do:

				--[[ AI COMBAT STATE MANAGEMENT ]]
				if ((ai__stateCombatTimer[n] == nil or TimerGetRemaining(ai__stateCombatTimer[n]) == 0.0) and ai__combatAttempts[n] == 0 and (ai__state[n] == ai__STATE__COMBAT or ai__state[n] == ai__STATE__WAVECLEAR)) then -- directly engage
					ai__combatAttempts[n] = 1
					ai__combatStartingHealthPerc[n] = GetUnitLifePercent(udg_playerHero[n])
					local isTargetHero -- true = target hero; false = minion
					if (ai__state[n] == ai__STATE__WAVECLEAR) then isTargetHero = false else isTargetHero = true end
					ai__stateCombatTimer[n] = NewTimer()
					TimerStart(ai__stateCombatTimer[n], ai__combatAbilityCadence__r, true, function()
						ai__combatAttempts[n] = ai__combatAttempts[n] + 1
						if (ai__combatAttempts[n] > ai__combatAttemptsAllowed
							or DAI__StateHealthIsLow(n)
							or not DAI__StateIsSafeToPush(n,0)
							or DAI__StateIsNearHostileTowers(n,650.0))
							or (ai__combatStartingHealthPerc[n] - GetUnitLifePercent(udg_playerHero[n]) >= ai__combatDisengageHealthPerc__r
							or (ai__state[n] ~= ai__STATE__COMBAT
							and ai__state[n] ~= ai__STATE__WAVECLEAR) )
						then -- if agent is in danger or combat window has ended, retreat
							-- if combat ending conditions raised, end combat
							DAI__MoveToControlPoint(n, "move")
							ai__combatFatigue[n] = true -- prevent further COMBAT states
							TimerStart(NewTimer(), ai__combatFatigueDuration__r, false, function()
								ai__combatFatigue[n] = false -- after engagement ends, allow COMBAT again
								if (DAI__StateHealthIsLow(n)) then
									DAI__MoveToRegenPoint(n, "move")
									ai__state[n] = ai__STATE__IDLE
								else
									DAI__MoveToControlPoint(n, "move")
									ai__state[n] = ai__STATE__IDLE
								end
								ReleaseTimer()
							end)
							ReleaseTimer()
							ai__stateCombatTimer[n] = nil
						else
							-- if combat ending conditions passed, initiate combat
							DAI__InitiateCombatBasic(n, isTargetHero)
						end
					end)
				else
					-- TODO: alternative state to command agent to dodge abilities, etc.
					-- This can be a listener instead of a state timer event
					--  --::: e.g. create a trigger for when damaged by hero or a hostile
					--  --::: spell is used at a point nearby, run checks on surroundings,
					--  --::: command agent to shuffle around or dodge, etc.
					--  --::: can use doltish profiles' ability type (point unit target etc.)
					-- -- ::: 
				end
				--[[----------------------------]]

			end -- end combat check block
		end -- end FP check block

	else
		ai__state[n] = ai__STATE__DEAD
	end -- end check if alive block

end


-- @x,y = location for Horde focus point
-- @x2,y2 = location for Alliance focus point
function DAI__StateObjectiveIsActive(x,y,x2,y2)

	-- set objective ability behavior
	ai__combatFatigueDuration__r = ai__combatFatigueDurationObj__r
	ai__combatAbilityCadence__r = ai__combatAbilityCadenceObj__r

	-- explicitly set agents to attack or defend for now until we get smarter later:
	for n = 1,5 do -- horde
		if (fp__factionMapHorde[2] >= ai__objCenterBasesReq__i) then -- only send if agents can safely get there, until we get smarter
			if (n == 1 or n == 2 or n == 3 or n == 4) then -- horde, send agents to attack
				ai__objPointX[n] = x
				ai__objPointY[n] = y
			elseif (n == 5) then -- horde, send agents to defend
				ai__objPointX[n] = x2
				ai__objPointY[n] = y2
			end
			ai__ignoreObj[n] = false
			ai__state[n] = ai__STATE__OBJ
		else
			ai__ignoreObj[n] = true
		end
	end

	for n = 6,10 do --alliance
		if (fp__factionMapAlliance[2] <= (5 - ai__objCenterBasesReq__i)) then -- only send if agents can safely get there, until we get smarter
			if (n == 6 or n == 7 or n == 8 or n == 9) then -- alliance, send agents to attack
				ai__objPointX[n] = x2
				ai__objPointY[n] = y2
			elseif (n == 10) then -- alliance, send agents to defend
				ai__objPointX[n] = x
				ai__objPointY[n] = y
			end
			ai__ignoreObj[n] = false
			ai__state[n] = ai__STATE__OBJ
		else
			ai__ignoreObj[n] = true
		end
	end

end


-- :: return to CP after objective ends
function DAI__StateObjectiveIsInactive()

	-- reset objective ability to lane behavior
	ai__combatFatigueDuration__r = ai__combatFatigueDurationD__r
	ai__combatAbilityCadence__r = ai__combatAbilityCadenceD__r

	for n = 1,10 do
		ai__state[n] = ai__STATE__REGEN
	end

end


-- @n = player number to initiate agent move
function DAI__MoveToObjectivePoint(n, s)
	DAI__Move(n,s,ai__objPointX[n],ai__objPointY[n])
end


-- sets the agent's point of return to restore health based on control point
-- @n = agent to update
function DAI__UpdateRegenPointToCP(n)
	ai__regenPointX[n] = ai__baseX[n]
	ai__regenPointY[n] = ai__baseY[n]
end


-- is the agent sitting and their assigned point?
-- @n = player number to run state check for
function DAI__StateIsAtControlPoint(n)
	local bool = false
	local distance
	if (ai__laneNum[n] == 0) then
		distance = DistanceBetweenXY(GetUnitX(udg_playerHero[n]),GetUnitY(udg_playerHero[n]),ai__controlPointTopX[n],ai__controlPointTopY[n])
	elseif (ai__laneNum[n] == 1) then
		distance = DistanceBetweenXY(GetUnitX(udg_playerHero[n]),GetUnitY(udg_playerHero[n]),ai__controlPointMidX[n],ai__controlPointMidY[n])
	elseif (ai__laneNum[n] == 2) then
		distance = DistanceBetweenXY(GetUnitX(udg_playerHero[n]),GetUnitY(udg_playerHero[n]),ai__controlPointBotX[n],ai__controlPointBotY[n])
	end
	if (distance <= 350.0) then
		bool = true
	end
	return bool
end


-- is the agent sitting and their assigned point?
-- @n = player number to run state check for
function DAI__StateIsAtRegenPoint(n)
	local bool = false
	if (DistanceBetweenXY(GetUnitX(udg_playerHero[n]),GetUnitY(udg_playerHero[n]),ai__regenPointX[n],ai__regenPointY[n]) <= 299.0) then
		bool = true
	end
	return bool
end


-- is the agent sitting at base?
-- @n = player number to run state check for
function DAI__StateIsAtBase(n)
	bool = false
	if (DistanceBetweenXY(GetUnitX(udg_playerHero[n]),GetUnitY(udg_playerHero[n]),ai__baseX[n],ai__baseY[n]) <= 450.0) then
		bool = true
	end
	return bool
end


-- find out if there are nearby allies to encourage agent to push forward
-- @n = player number to run state check for; returns true if greater than threshold
-- @range = optional range to look for
function DAI__StateIsSafeToPush(n, range)
	local g = CreateGroup()
	local x = GetUnitX(udg_playerHero[n])
	local y = GetUnitY(udg_playerHero[n])
	local size = 0
	local p = ConvertedPlayer(n)
	local bool = false
	local r = ai__isSafeToPushRange__r
	if (range > 0) then
		r = range
	end
	GroupEnumUnitsInRange(g, x, y, r, Condition( function() return IsUnitAlly(GetFilterUnit(),p) and (not IsUnitDeadBJ(GetFilterUnit())) and (not IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)) and (not IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO)) and (not IsUnitType(GetFilterUnit(),UNIT_TYPE_MECHANICAL)) and GetConvertedPlayerId(GetOwningPlayer(GetFilterUnit())) >= 13 end ) )
	size = BlzGroupGetSize(g)
	if (size >= ai__feelsSafeThreshold__i) then
		bool = true
	end
	DestroyGroup(g)
	return bool
end


-- find out if there are nearby hostile structures
-- @n = player number to run state check for; returns true if greater than threshold
-- @range = optional, overrides default range check (ai__isNearTowersRange__r)
function DAI__StateIsNearHostileTowers(n, range)
	local g = CreateGroup()
	local x = GetUnitX(udg_playerHero[n])
	local y = GetUnitY(udg_playerHero[n])
	local size = 0
	local p = ConvertedPlayer(n)
	local bool = false
	local r = ai__isNearTowersRange__r
	if (range ~= nil and range > 0.0) then
		r = range
	end
	GroupEnumUnitsInRange(g, x, y, r, Condition( function() return IsUnitEnemy(GetFilterUnit(),p) and (not IsUnitDeadBJ(GetFilterUnit())) and (IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)) end ) )
	size = BlzGroupGetSize(g)
	if (size > 0) then
		bool = true
	end
	DestroyGroup(g)
	return bool
end


-- find out if there are nearby enemy heroes
-- @n = player number to run state check for; returns true if greater than threshold
function DAI__StateIsNearEnemyHero(n)
	local g = CreateGroup()
	local x = GetUnitX(udg_playerHero[n])
	local y = GetUnitY(udg_playerHero[n])
	local size = 0
	local p = ConvertedPlayer(n)
	local bool = false
	GroupEnumUnitsInRange(g, x, y, ai__isNearEnemyHeroRange__r, Condition( function() return IsUnitEnemy(GetFilterUnit(),p) and (not IsUnitDeadBJ(GetFilterUnit())) and (IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO)) end ) )
	size = BlzGroupGetSize(g)
	if (size > 0) then
		bool = true
	end
	DestroyGroup(g)
	return bool
end


-- find out if there are nearby enemy minions
-- @n = player number to run state check for; returns true if greater than threshold
function DAI__StateIsNearEnemyMinionCount(n, range, count)
	local g = CreateGroup()
	local x = GetUnitX(udg_playerHero[n])
	local y = GetUnitY(udg_playerHero[n])
	local size = 0
	local p = ConvertedPlayer(n)
	local bool = false
	local r = ai__isNearEnemyMinionRange__r
	local c = ai__isNearEnemyMinionCount__i
	if (count ~= nil and count > 0) then
		c = count
	end
	if (range ~= nil and range > 0.0) then
		r = range
	end
	GroupEnumUnitsInRange(g, x, y, r, Condition( function() return IsUnitEnemy(GetFilterUnit(),p) and (not IsUnitDeadBJ(GetFilterUnit())) and (not IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO)) end ) )
	size = BlzGroupGetSize(g)
	if (size > c) then
		bool = true
	end
	DestroyGroup(g)
	return bool
end


-- find out if there are nearby ally heroes
-- @n = player number to run state check for; returns true if greater than threshold
function DAI__StateIsNearAllyHero(n)
	local g = CreateGroup()
	local x = GetUnitX(udg_playerHero[n])
	local y = GetUnitY(udg_playerHero[n])
	local size = 0
	local p = ConvertedPlayer(n)
	local bool = false
	GroupEnumUnitsInRange(g, x, y, ai__isNearAllyHeroRange__r, Condition( function() return IsUnitAlly(GetFilterUnit(),p) and (not IsUnitDeadBJ(GetFilterUnit())) and (IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO)) end ) )
	size = BlzGroupGetSize(g)
	if (size > 0) then
		bool = true
	end
	DestroyGroup(g)
	return bool
end


-- find out if there are nearby allies to encourage agent to push forward
-- @n = player number to run state check for; returns true if greater than threshold
-- @range = optional range to search for
function DAI__FollowNearbyMinion(n, range)
	local g = CreateGroup()
	local x = GetUnitX(udg_playerHero[n])
	local y = GetUnitY(udg_playerHero[n])
	local size = 0
	local p = ConvertedPlayer(n)
	local bool = false
	local r = ai__isSafeToPushRange__r
	if (range ~= nil and range > 0.0) then
		r = range
	end
	GroupEnumUnitsInRange(g, x, y, r, Condition( function() return IsUnitAlly(GetFilterUnit(),p) and (not IsUnitDeadBJ(GetFilterUnit())) and (not IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)) and (not IsUnitType(GetFilterUnit(),UNIT_TYPE_SUMMONED)) and (not IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO)) and (not IsUnitType(GetFilterUnit(),UNIT_TYPE_MECHANICAL)) and GetConvertedPlayerId(GetOwningPlayer(GetFilterUnit())) >= 13 end ) )
	size = BlzGroupGetSize(g)
	if (size > 0) then
		ai__followUnit[n] = GroupPickRandomUnit(g)
		IssueTargetOrder(udg_playerHero[n],"smart",ai__followUnit[n])
		bool = true
	end
	DestroyGroup(g)
	return bool
end


-- find out if there are nearby enemies
-- @n = player number to run state check for; returns true if 0 nearby enemies
function DAI__StateIsSafe(n)
	local g = CreateGroup()
	local x = GetUnitX(udg_playerHero[n])
	local y = GetUnitY(udg_playerHero[n])
	local size = 0
	local p = ConvertedPlayer(n)
	local bool = true
	GroupEnumUnitsInRange(g, x, y, ai__isSafeRange__r, Condition( function() return IsUnitEnemy(GetFilterUnit(),p) and (not IsUnitDeadBJ(GetFilterUnit())) and (not IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)) end ) )
	size = BlzGroupGetSize(g)
	if (size > 0) then
		bool = false
	end
	DestroyGroup(g)
	return bool
end


-- @n = player number to tele home for
function DAI__TeleportHome(n)
	IssuePointOrder(udg_playerHero[n],"massteleport",ai__baseX[n],ai__baseY[n])
end


-- @i = agent player num
-- @l = lane num (0 = top, 1 = mid, 2 = bot)
-- returns x, y
function DAI__GetControlPointXY(n, l)
	local x
	local y
	if (l == 0) then
		x = ai__controlPointTopX[n]
		y = ai__controlPointTopY[n]
	elseif (l == 1) then
		x = ai__controlPointMidX[n]
		y = ai__controlPointMidY[n]
	elseif (l == 2) then
		x = ai__controlPointBotX[n]
		y = ai__controlPointBotY[n]
	else
		return false
	end
	return x, y
end


-- @n = player number to initiate agent move
function DAI__MoveToControlPoint(n, s)
	local x
	local y
	local l = ai__laneNum[n]
	x,y = DAI__GetControlPointXY(n, l)
	DAI__Move(n,s,x,y)
end


-- @n = player number to initiate agent move
function DAI__MoveToFlightPoint(n, s)
	IssuePointOrder(udg_playerHero[n], s, ai__flightPathX[n], ai__flightPathY[n])
end


-- @n = player number to initiate agent move
function DAI__MoveToRegenPoint(n)
	local x = ai__regenPointX[n]
	local y = ai__regenPointY[n]
	DAI__Move(n,"move",x,y)
end



-- since not possible to command to purchase, "fake" a purchase
-- @n = player number for agent to buy FP
function DAI__PurchaseFlightPath(n)
	local itemId
	if (udg_aiTargetObjective == true) then
		itemId = FourCC('I004')
	else
		if (ai__laneNum[n] == 0) then -- top
			itemId = FourCC('I002')
		elseif (ai__laneNum[n] == 1) then -- mid
			itemId = FourCC('I004')
		elseif (ai__laneNum[n] == 2) then -- bot
			itemId = FourCC('I003')
		end
	end
	UnitAddItemById(udg_playerHero[n],itemId)
end


-- begin auto attack a target
-- @n = player number to command
-- @unit = unit to attack
function DAI__AttackTarget(n, unit)
	IssueTargetOrder(udg_playerHero[n],"attack",unit)
end


-- @a unit = unit to direct
-- @n int = player number (int) under agent control
-- @x int = x coord to move to
-- @y int = y coord to move to
-- @s string = movement type to initiate
function DAI__Move(n,s,x,y)
	IssuePointOrder(udg_playerHero[n], s, x, y)
end


-- updates active agent control points when base structures die
-- flightPath points are map-specific points updated to successive bases; we lazily reference them
function DAI__UpdateControlPoints()
	for n = 1,10,1 do
		if (ai__regenPointX[n] ~= ai__baseX[n] and ai__regenPointY[n] ~= ai__baseY[n]) then -- don't update if regen point has been set to home for assigned lane
			if (ai__factionNum[n] == 0) then
				ai__controlPointTopX[n] = GetLocationX(udg_flightPathFurthestHorde[1])
				ai__controlPointTopY[n] = GetLocationY(udg_flightPathFurthestHorde[1])
				ai__controlPointMidX[n] = GetLocationX(udg_flightPathFurthestHorde[2])
				ai__controlPointMidY[n] = GetLocationY(udg_flightPathFurthestHorde[2])
				ai__controlPointBotX[n] = GetLocationX(udg_flightPathFurthestHorde[3])
				ai__controlPointBotY[n] = GetLocationY(udg_flightPathFurthestHorde[3])
			elseif (ai__factionNum[n] == 1) then
				ai__controlPointTopX[n] = GetLocationX(udg_flightPathFurthestAlliance[1])
				ai__controlPointTopY[n] = GetLocationY(udg_flightPathFurthestAlliance[1])
				ai__controlPointMidX[n] = GetLocationX(udg_flightPathFurthestAlliance[2])
				ai__controlPointMidY[n] = GetLocationY(udg_flightPathFurthestAlliance[2])
				ai__controlPointBotX[n] = GetLocationX(udg_flightPathFurthestAlliance[3])
				ai__controlPointBotY[n] = GetLocationY(udg_flightPathFurthestAlliance[3])
			end
			DAI__UpdateRegenPointToCP(n)
		else -- if regen point is home, set control point to new minion spawn points (near main core)
			if (ai__factionNum[n] == 0) then
				ai__controlPointTopX[n] = GetLocationX(udg_spawnPointHorde[0])
				ai__controlPointTopY[n] = GetLocationY(udg_spawnPointHorde[0])
				ai__controlPointMidX[n] = GetLocationX(udg_spawnPointHorde[1])
				ai__controlPointMidY[n] = GetLocationY(udg_spawnPointHorde[1])
				ai__controlPointBotX[n] = GetLocationX(udg_spawnPointHorde[2])
				ai__controlPointBotY[n] = GetLocationY(udg_spawnPointHorde[2])
			elseif (ai__factionNum[n] == 1) then
				ai__controlPointTopX[n] = GetLocationX(udg_spawnPointAlliance[0])
				ai__controlPointTopY[n] = GetLocationY(udg_spawnPointAlliance[0])
				ai__controlPointMidX[n] = GetLocationX(udg_spawnPointAlliance[1])
				ai__controlPointMidY[n] = GetLocationY(udg_spawnPointAlliance[1])
				ai__controlPointBotX[n] = GetLocationX(udg_spawnPointAlliance[2])
				ai__controlPointBotY[n] = GetLocationY(udg_spawnPointAlliance[2])
			end
		end
	end
end


-- if all bases in a lane are dead, sets agent control point to home base (to return when low health etc)
-- @l = lane to run control point check for
function DAI__SetControlPointHome(l, f)
	for n = 1,10,1 do
		if (ai__laneNum[n] == l and ai__factionNum[n] == f) then -- pass the faction of the lane to update
			ai__regenPointX[n] = ai__baseX[n]
			ai__regenPointY[n] = ai__baseY[n]
			if (l == 0 and ai__factionNum[n] == 0) then
				ai__controlPointTopX[n] = GetLocationX(udg_spawnPointHorde[0])
				ai__controlPointTopY[n] = GetLocationY(udg_spawnPointHorde[0])
			elseif (l == 1 and ai__factionNum[n] == 0) then
				ai__controlPointMidX[n] = GetLocationX(udg_spawnPointHorde[1])
				ai__controlPointMidY[n] = GetLocationY(udg_spawnPointHorde[1])
			elseif (l == 2 and ai__factionNum[n] == 0) then
				ai__controlPointBotX[n] = GetLocationX(udg_spawnPointHorde[2])
				ai__controlPointBotY[n] = GetLocationY(udg_spawnPointHorde[2])
			elseif (l == 0 and ai__factionNum[n] == 1) then
				ai__controlPointTopX[n] = GetLocationX(udg_spawnPointAlliance[0])
				ai__controlPointTopY[n] = GetLocationY(udg_spawnPointAlliance[0])
			elseif (l == 1 and ai__factionNum[n] == 1) then
				ai__controlPointMidX[n] = GetLocationX(udg_spawnPointAlliance[1])
				ai__controlPointMidY[n] = GetLocationY(udg_spawnPointAlliance[1])
			elseif (l == 2 and ai__factionNum[n] == 1) then
				ai__controlPointBotX[n] = GetLocationX(udg_spawnPointAlliance[2])
				ai__controlPointBotY[n] = GetLocationY(udg_spawnPointAlliance[2])
			end
		end
	end
end


-- @f = faction int to run randomizer for, returns heroId for a hero from that faction
function DAI__RandomizedHeroId(f)
	local heroId
	local i = 0
	local r = 0

	if (f == 0) then
		r = math.random(1, #ai__faction__heroes__horde)
		repeat
			heroId = ai__faction__heroes__horde[r]
			i=i+1
		until(heroId ~= nil or i == 124)
	elseif (f == 1) then
		r = math.random(1, #ai__faction__heroes__alliance)
		repeat
			heroId = ai__faction__heroes__alliance[r]
			i=i+1
		until(heroId ~= nil or i == 124)
	elseif (f == 2) then
		r = math.random(1, #ai__faction__heroes__neutral)
		repeat
			heroId = ai__faction__heroes__neutral[r]
			i=i+1
		until(heroId ~= nil or i == 124)
	else
		return false
	end
	--DAI__RemoveHeroId(heroId, f)
	--DebugMsg( "hero id randomized for faction " .. f .. " is: " .. heroId )
	return heroId
end


-- @heroId = heroId to compare against all other players
function DAI__IsHeroUnique(heroId)
	for i = 1,10,1 do
		if (heroId == udg_ZplayerHeroId[i]) then
			return false
		end
	end
	return true
end


-- @heroId = hero Id string to remove from possible heroes array
-- @f = faction to remove hero from (0 = horde, 1 = alliance, 2 = neutral)
function DAI__RemoveHeroId(heroId, f)
	local int = 0
	if (f == 0) then
		table.remove(ai__faction__heroes__horde,GetTableIndexByValue(ai__faction__heroes__horde,heroId))
	elseif (f == 1) then
		table.remove(ai__faction__heroes__alliance,GetTableIndexByValue(ai__faction__heroes__alliance,heroId))
	elseif (f == 2) then
		table.remove(ai__faction__heroes__neutral,GetTableIndexByValue(ai__faction__heroes__neutral,heroId))
	else
		return false
	end
	--DebugMsg( "hero id removed: " .. heroId )
	--int = #ai__faction__heroes__horde
	--DebugMsg( "horde size is now: " .. int )
	--int = #ai__faction__heroes__alliance
	--DebugMsg( "alliance size is now: " .. int )
	--int = #ai__faction__heroes__neutral
	--DebugMsg( "neutral size is now: " .. int )
end


-- @n = player number (int) under agent control
-- @amount = optional amount to check, returns if under this amount (e.g. 30 = 30%)
function DAI__StateHealthIsLow(n, amountPercent)
	local a = ai__lowHealth__r
	if (amountPercent ~= nil and amountPercent ~= 0.0) then
		a = amountPercent
	end
	if (GetUnitLifePercent(udg_playerHero[n]) <= a) then
	--DebugMsg("set state for " .. n .. " to REGEN")
		return true
	else
		return false
	end
end


function PrintMe()
	local i = 0
	local int
	for i = 1,10,1 do
		int = tostring(ai__STATE_STRINGS[ai__state[i]])
		DebugMsg("state for " .. tostring(i) .. " is: " .. int)
	end
end


-- run this to generate agent for absent players
function GenerateAI()
	local d = 0
	local f = 0
	--[[ run init functions (have to declare after global init)]]
	DAI__GrabXY()
	--[[ ------------------------------------------------------]]
	TimerStart(NewTimer(d, f), .50, true, function() -- run a timer to properly set lua randomseed based on game time and to prevent stack bugs when framerate sticks
		d = d + 1
		if (d == 6) then
			f = 1 -- increment faction
		end
		if (udg_gamePlayerEmptyComp[d] == true) then -- to prevent desync, we check in map init for empty slots or comps
			DAI__GenerateProfile(d,f)
		end
		if (d >= 10)then
			ReleaseTimer()
			--DebugMsg("generate exit")
		end
	end)
end


-- generate a single agent manually
-- @n = player
-- @heroId = optional hero id to general specific hero (NOT IMPLEMENTED YET)
function GenerateSingleAI(n, heroId)
	DAI__GrabXY()
	local f = 0
	if (n >= 6) then
		f = 1
	end
	DAI__GenerateProfile(n,f)
end
