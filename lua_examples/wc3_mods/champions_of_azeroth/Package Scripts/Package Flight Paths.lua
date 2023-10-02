--[[--------------------------------------------------------]]
-- OVERVIEW OF MATRIX USAGE:
-- top: 0 1 [2] {3} 4 5
-- mid: 0 1 [2] {3} 4 5
-- bot: 0 1 [2] {3} 4 5
-- [] = furthest horde FP point
-- {} = furthest alliance FP point
--
-- when a base is destroyed, we fetch the assigned base in each given lane with fp__factionMapHorde/Alliance
-- changing the delta accordingly, e.g. top base for horde destroyed now changes the top mapping via increment/decrement
-- for each respective faction:
-- top: 0 [1] {2} 3 4 5
--[[--------------------------------------------------------]]

function FlightPathDebugHelper(pInt)
	TimerStart(NewTimer(pInt),6.0,false,function()
		if (IsUnitAliveBJ(udg_flightPathOwner[pInt])) then
			local unit = udg_playerHero[pInt]
			ShowUnit(unit, true)
			SetUnitInvulnerable(unit, false)
			PauseUnit(unit, false)
			SetUnitVertexColorBJ(unit,100,100,100,0)
			RemoveUnit(udg_flightPathOwner[pInt])
			unit = nil
		end
		ReleaseTimer()
	end)
end


function FlightPathListenerGenerate()

	LUA_VAR_FP_OFFSET = 190.0

	udg_flightPathFurthestHorde[1] = Location(GetRectCenterX(gg_rct_laneHordeBase4) + LUA_VAR_FP_OFFSET, GetRectCenterY(gg_rct_laneHordeBase4) - LUA_VAR_FP_OFFSET)
	udg_flightPathFurthestHorde[2] = Location(GetRectCenterX(gg_rct_laneHordeBase5) + LUA_VAR_FP_OFFSET, GetRectCenterY(gg_rct_laneHordeBase5) - LUA_VAR_FP_OFFSET)
	udg_flightPathFurthestHorde[3] = Location(GetRectCenterX(gg_rct_laneHordeBase6) + LUA_VAR_FP_OFFSET, GetRectCenterY(gg_rct_laneHordeBase6) - LUA_VAR_FP_OFFSET)
	udg_flightPathFurthestAlliance[1] = Location(GetRectCenterX(gg_rct_laneAllianceBase4) - LUA_VAR_FP_OFFSET, GetRectCenterY(gg_rct_laneAllianceBase4) + LUA_VAR_FP_OFFSET)
	udg_flightPathFurthestAlliance[2] = Location(GetRectCenterX(gg_rct_laneAllianceBase5) - LUA_VAR_FP_OFFSET, GetRectCenterY(gg_rct_laneAllianceBase5) + LUA_VAR_FP_OFFSET)
	udg_flightPathFurthestAlliance[3] = Location(GetRectCenterX(gg_rct_laneAllianceBase6) - LUA_VAR_FP_OFFSET, GetRectCenterY(gg_rct_laneAllianceBase6) + LUA_VAR_FP_OFFSET)

	fp__trigger = {}

	fp__regions = {
		-- top
		[1] = gg_rct_laneHordeBaseMain1,
		[2] = gg_rct_laneHordeBase1,
		[3] = gg_rct_laneHordeBase4,
		[4] = gg_rct_laneAllianceBase4,
		[5] = gg_rct_laneAllianceBase1,
		[6] = gg_rct_laneAllianceBaseMain1,
		-- mid
		[7] = gg_rct_laneHordeBaseMain2,
		[8] = gg_rct_laneHordeBase2,
		[9] = gg_rct_laneHordeBase5,
		[10] = gg_rct_laneAllianceBase5,
		[11] = gg_rct_laneAllianceBase2,
		[12] = gg_rct_laneAllianceBaseMain2,
		-- bot
		[13] = gg_rct_laneHordeBaseMain3,
		[14] = gg_rct_laneHordeBase3,
		[15] = gg_rct_laneHordeBase6,
		[16] = gg_rct_laneAllianceBase6,
		[17] = gg_rct_laneAllianceBase3,
		[18] = gg_rct_laneAllianceBaseMain3
	}

	fp__regions__top = {
		[0] = gg_rct_laneHordeBaseMain1,
		[1] = gg_rct_laneHordeBase1,
		[2] = gg_rct_laneHordeBase4,
		[3] = gg_rct_laneAllianceBase4,
		[4] = gg_rct_laneAllianceBase1,
		[5] = gg_rct_laneAllianceBaseMain1
	}

	fp__regions__mid = {
		[0] = gg_rct_laneHordeBaseMain2,
		[1] = gg_rct_laneHordeBase2,
		[2] = gg_rct_laneHordeBase5,
		[3] = gg_rct_laneAllianceBase5,
		[4] = gg_rct_laneAllianceBase2,
		[5] = gg_rct_laneAllianceBaseMain2
	}

	fp__regions__bot = {
		[0] = gg_rct_laneHordeBaseMain3,
		[1] = gg_rct_laneHordeBase3,
		[2] = gg_rct_laneHordeBase6,
		[3] = gg_rct_laneAllianceBase6,
		[4] = gg_rct_laneAllianceBase3,
		[5] = gg_rct_laneAllianceBaseMain3
	}

	fp__PointMapTopX = {
		[0] = GetRectCenterX(gg_rct_laneHordeBaseMain1),
		[1] = GetRectCenterX(gg_rct_laneHordeBase1),
		[2] = GetRectCenterX(gg_rct_laneHordeBase4),
		[3] = GetRectCenterX(gg_rct_laneAllianceBase4),
		[4] = GetRectCenterX(gg_rct_laneAllianceBase1),
		[5] = GetRectCenterX(gg_rct_laneAllianceBaseMain1)
	}
	fp__PointMapMidX = {
		[0] = GetRectCenterX(gg_rct_laneHordeBaseMain2),
		[1] = GetRectCenterX(gg_rct_laneHordeBase2),
		[2] = GetRectCenterX(gg_rct_laneHordeBase5),
		[3] = GetRectCenterX(gg_rct_laneAllianceBase5),
		[4] = GetRectCenterX(gg_rct_laneAllianceBase2),
		[5] = GetRectCenterX(gg_rct_laneAllianceBaseMain2)
	}
	fp__PointMapBotX = {
		[0] = GetRectCenterX(gg_rct_laneHordeBaseMain3),
		[1] = GetRectCenterX(gg_rct_laneHordeBase3),
		[2] = GetRectCenterX(gg_rct_laneHordeBase6),
		[3] = GetRectCenterX(gg_rct_laneAllianceBase6),
		[4] = GetRectCenterX(gg_rct_laneAllianceBase3),
		[5] = GetRectCenterX(gg_rct_laneAllianceBaseMain3)
	}
	fp__PointMapTopY = {
		[0] = GetRectCenterY(gg_rct_laneHordeBaseMain1),
		[1] = GetRectCenterY(gg_rct_laneHordeBase1),
		[2] = GetRectCenterY(gg_rct_laneHordeBase4),
		[3] = GetRectCenterY(gg_rct_laneAllianceBase4),
		[4] = GetRectCenterY(gg_rct_laneAllianceBase1),
		[5] = GetRectCenterY(gg_rct_laneAllianceBaseMain1)
	}
	fp__PointMapMidY = {
		[0] = GetRectCenterY(gg_rct_laneHordeBaseMain2),
		[1] = GetRectCenterY(gg_rct_laneHordeBase2),
		[2] = GetRectCenterY(gg_rct_laneHordeBase5),
		[3] = GetRectCenterY(gg_rct_laneAllianceBase5),
		[4] = GetRectCenterY(gg_rct_laneAllianceBase2),
		[5] = GetRectCenterY(gg_rct_laneAllianceBaseMain2)
	}
	fp__PointMapBotY = {
		[0] = GetRectCenterY(gg_rct_laneHordeBaseMain3),
		[1] = GetRectCenterY(gg_rct_laneHordeBase3),
		[2] = GetRectCenterY(gg_rct_laneHordeBase6),
		[3] = GetRectCenterY(gg_rct_laneAllianceBase6),
		[4] = GetRectCenterY(gg_rct_laneAllianceBase3),
		[5] = GetRectCenterY(gg_rct_laneAllianceBaseMain3)
	}
	fp__factionMapHorde = {
		[1] = 2,
		[2] = 2,
		[3] = 2
	}
	fp__factionMapAlliance = {
		[1] = 3,
		[2] = 3,
		[3] = 3
	}

	 -- units eligible to create an outpost for:
	local boolExpr = Filter( function()
	return IsUnitType(GetTriggerUnit(),UNIT_TYPE_STRUCTURE)
		and ( GetUnitTypeId(GetTriggerUnit()) == FourCC('n002')
		or GetUnitTypeId(GetTriggerUnit()) == FourCC('h002')
		or GetUnitTypeId(GetTriggerUnit()) == FourCC('n001')
		or GetUnitTypeId(GetTriggerUnit()) == FourCC('o002')
		or GetUnitTypeId(GetTriggerUnit()) == FourCC('o003')
		or GetUnitTypeId(GetTriggerUnit()) == FourCC('o004')
		or GetUnitTypeId(GetTriggerUnit()) == FourCC('h00E')
		or GetUnitTypeId(GetTriggerUnit()) == FourCC('o018') )
	end )

	-- listener funcs
	local fp__func = function()
		local laneInt
		local unitId
		local capturingPlayer
		local u = GetTriggerUnit()
		local x
		local y
		local pInt = GetConvertedPlayerId(GetOwningPlayer(u))


		-- optimize max loop size by seeing which regions to check
		if (pInt == 13) then -- alliance destroyed horde
			unitId = FourCC('h00E') -- outpost to build
			capturingPlayer = Player(13)
		else -- horde destroyed alliance
			unitId = FourCC('o018')
			capturingPlayer = Player(12)
		end

		-- find out where base was destroyed
		for i = 1,18 do
			x = GetRectCenterX(fp__regions[i])
			y = GetRectCenterY(fp__regions[i])
			if (IsUnitInRangeXY(u, x, y, 300.0)) then
				x = GetRectCenterX(fp__regions[i])
				y = GetRectCenterY(fp__regions[i])
				if (i < 7) then -- top
					laneInt = 1
				elseif (i > 6 and i < 13) then -- mid
					laneInt = 2
				elseif (i > 12 and i < 19) then -- bot
					laneInt = 3
				end
				break
			else
				x = nil
				y = nil
			end
		end

		FlightPathUpdate(laneInt, pInt)

		RemoveUnit(u)
		SpellPackClearArea(x,y,335.0)
		local u2 = CreateUnit(capturingPlayer, unitId, x, y, 270.0)
		BlzSetUnitMaxHP(u2, math.floor(BlzGetUnitMaxHP(u2) * udg_objRampReal)) -- make bases stronger as game progresses to control for game length
		local dmg = math.floor(BlzGetUnitBaseDamage(u2, 0) * 1.33)
		BlzSetUnitBaseDamage(u2, dmg, 0)
		SetUnitLifePercentBJ(u2, 100.0)
		PauseUnit(u2, true)

		-- queue build eye candy and 6 sec delay
		SetUnitAnimation(u2, "birth")
		SetUnitTimeScalePercent (u2, 500.0)
		TimerStart(NewTimer(u2),6.0,false,function()
			if (IsUnitAliveBJ(u2)) then
				PauseUnit(u2, false)
				SetUnitTimeScalePercent (u2, 100.0)
				SetUnitAnimation(u2, "stand")
				ResetUnitAnimation(u2)
			end
			u2 = nil
			ReleaseTimer()
		end)

		if (udg_aiIsEnabled and udg_objInProgress) then -- if obj in progress and ai is active, update obj engagement statuses
			DAI__StateObjectiveIsActive(
				GetRectCenterX(gg_rct_objectiveSpawnRiver1),
				GetRectCenterY(gg_rct_objectiveSpawnRiver1),
				GetRectCenterX(gg_rct_objectiveSpawnRiver2),
				GetRectCenterY(gg_rct_objectiveSpawnRiver2) )
		end
		FlightPathBaseInvul(laneInt, pInt)
		DestroyEffect(AddSpecialEffect('Objects\\Spawnmodels\\Human\\HCancelDeath\\HCancelDeath.mdl',x,y))

		u = nil
		x = nil
		y = nil
		laneInt = nil
		unitId = nil
		capturingPlayer = nil

	end

	for i = 1,2 do
		fp__trigger[i] = CreateTrigger()
		-- alliance destroys horde base listeners
		TriggerRegisterPlayerUnitEvent(fp__trigger[i], Player(11 + i), EVENT_PLAYER_UNIT_DEATH, nil)
		TriggerAddCondition(fp__trigger[i], boolExpr)
		TriggerAddAction(fp__trigger[i], fp__func)
	end

end


-- @lane = lane to update
-- @pInt = faction player number that lost a base; 13 or 14
function FlightPathUpdate(laneInt, pInt)

	local newX
	local newY

	if (pInt == 14) then -- alliance base destroyed, increment lane towards alliance base
		fp__factionMapHorde[laneInt] = fp__factionMapHorde[laneInt] + 1
		fp__factionMapAlliance[laneInt] = fp__factionMapAlliance[laneInt] + 1
	else -- horde base destroyed, decrement laneInt towards horde base
		fp__factionMapHorde[laneInt] = fp__factionMapHorde[laneInt] - 1
		fp__factionMapAlliance[laneInt] = fp__factionMapAlliance[laneInt] - 1
	end

	-- update lane locations

		if (fp__factionMapHorde[laneInt] ~= -1) then -- if not all bases in lane are destroyed
			if (laneInt == 1) then -- top
				newX = fp__PointMapTopX[fp__factionMapHorde[laneInt]] + LUA_VAR_FP_OFFSET
				newY = fp__PointMapTopY[fp__factionMapHorde[laneInt]] - LUA_VAR_FP_OFFSET
			elseif (laneInt == 2) then -- mid
				newX = fp__PointMapMidX[fp__factionMapHorde[laneInt]] + LUA_VAR_FP_OFFSET
				newY = fp__PointMapMidY[fp__factionMapHorde[laneInt]] - LUA_VAR_FP_OFFSET
			elseif (laneInt == 3) then -- bot
				newX = fp__PointMapBotX[fp__factionMapHorde[laneInt]] + LUA_VAR_FP_OFFSET
				newY = fp__PointMapBotY[fp__factionMapHorde[laneInt]] - LUA_VAR_FP_OFFSET
			end
		else
			newX = GetRectCenterX(gg_rct_flightPathLastHorde)
			newY = GetRectCenterY(gg_rct_flightPathLastHorde)
		end
		RemoveLocation(udg_flightPathFurthestHorde[laneInt])
		udg_flightPathFurthestHorde[laneInt] = Location(newX,newY)
		
		if (fp__factionMapAlliance[laneInt] ~= 6) then
			if (laneInt == 1) then
				newX = fp__PointMapTopX[fp__factionMapAlliance[laneInt]] - LUA_VAR_FP_OFFSET
				newY = fp__PointMapTopY[fp__factionMapAlliance[laneInt]] + LUA_VAR_FP_OFFSET
			elseif (laneInt == 2) then
				newX = fp__PointMapMidX[fp__factionMapAlliance[laneInt]] - LUA_VAR_FP_OFFSET
				newY = fp__PointMapMidY[fp__factionMapAlliance[laneInt]] + LUA_VAR_FP_OFFSET
			elseif (laneInt == 3) then
				newX = fp__PointMapBotX[fp__factionMapAlliance[laneInt]] - LUA_VAR_FP_OFFSET
				newY = fp__PointMapBotY[fp__factionMapAlliance[laneInt]] + LUA_VAR_FP_OFFSET
			end
		else
			newX = GetRectCenterX(gg_rct_flightPathLastAlliance)
			newY = GetRectCenterY(gg_rct_flightPathLastAlliance)
		end
		RemoveLocation(udg_flightPathFurthestAlliance[laneInt])
		udg_flightPathFurthestAlliance[laneInt] = Location(newX,newY)

end


-- search up and down lanes for next bases and make invulnerable or vulnerable
-- @laneInt = search this lane
-- @pInt = base destroyed for
function FlightPathBaseInvul(laneInt, pInt)
	local g = CreateGroup()
	local g2 = CreateGroup()
	local direction = 1
	local x
	local y
	local u
	local u2
	local t
	local position = 0
	local oppInt = 13

	if (laneInt == 1) then -- fp__regions table offset
		t = fp__regions__top
	elseif (laneInt == 2) then -- fp__regions table offset
		t = fp__regions__mid
	elseif (laneInt == 3) then
		t = fp__regions__bot
	end

	if (pInt == 13) then -- find where in the matrix to search for
		oppInt = 14
		direction = -direction
		position = fp__factionMapHorde[laneInt] + 1 -- get the original position of the dying structure not the updated one
	else
		position = fp__factionMapAlliance[laneInt] - 1 -- get the original position of the dying structure not the updated one
	end

	-- make next base vulnerable for faction that lost a base
	if (position + direction >= 0 and position + direction <= 5) then -- do nothing if outside of matrix limits
		x = GetRectCenterX(t[position + direction])
		y = GetRectCenterY(t[position + direction])
		GroupEnumUnitsInRange(g, x, y, 50.0, Condition( function() return IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)
			and GetOwningPlayer(GetFilterUnit()) == Player(pInt - 1) end ) )
		u = FirstOfGroup(g)
		if (u ~= nil) then
			SetUnitInvulnerable(u, false)
		end
	end

	direction = -direction

	-- make next base invulnerable for faction that gained a base
	if (position + direction >= 0 and position + direction <= 5) then -- do nothing if outside of matrix limits
		x = GetRectCenterX(t[position + direction])
		y = GetRectCenterY(t[position + direction])
		GroupEnumUnitsInRange(g2, x, y, 50.0, Condition( function() return IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)
			and GetOwningPlayer(GetFilterUnit()) == Player(oppInt - 1) end ) )
		u2 = FirstOfGroup(g2)
		if (u2 ~= nil) then
			SetUnitInvulnerable(u2, true)
		end
		GroupRemoveUnit(g2,u2)
	end

	u = nil
	u2 = nil
	t = nil
	DestroyGroup(g)
	DestroyGroup(g2)

end
