-- TESH.scrollpos=205
-- TESH.alwaysfold=0

---@param x real
---@param y real
---@return boolean
function K2DItemCheckXY(x, y)
	SetItemPosition(udg_K2DItem, x, y)
	return GetWidgetX(udg_K2DItem) == x and GetWidgetY(udg_K2DItem) == y
end


---@param x real
---@param y real
---@return boolean
function K2DItemCheckAxis(x, y)
	local x2 = x * udg_K2DRadius[udg_UDex]
	local y2 = y * udg_K2DRadius[udg_UDex]
	x = udg_K2DX + x2
	y = udg_K2DY + y2
	if K2DItemCheckXY(x, y) and not IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY) then
		x = udg_K2DX - x2
		y = udg_K2DY - y2
		return K2DItemCheckXY(x, y) and not IsTerrainPathable(x, y, PATHING_TYPE_WALKABILITY)
	end
	return false
end

---@return boolean
function K2DItemCheck()
	local result = K2DItemCheckXY(udg_K2DX, udg_K2DY)
	
	-- Only perform additional pathing checks if the unit has a larger collision.
	if result and udg_Knockback2DRobustPathing > 0 and udg_K2DRadius[udg_UDex] > 0 then
		
		-- Check horizontal axis of unit to make sure nothing is going to collide
		result = K2DItemCheckAxis(udg_K2DCosH[udg_UDex], udg_K2DSinH[udg_UDex])
		
		-- Check vertical axis of unit to ensure nothing will collide
		result = result and K2DItemCheckAxis(udg_K2DCos[udg_UDex], udg_K2DSin[udg_UDex])
		
		if result and udg_Knockback2DRobustPathing == 2 and udg_K2DRadius[udg_UDex] > 16 then
			
			-- Check diagonal axis of unit if more thorough pathing is desired
			result = K2DItemCheckAxis(udg_K2DCosD1[udg_UDex], udg_K2DSinD1[udg_UDex])
			result = result and K2DItemCheckAxis(udg_K2DCosD2[udg_UDex], udg_K2DSinD2[udg_UDex])
		end
	end
	
	-- Reset item so it won't interfere with the map
	SetItemPosition(udg_K2DItem, udg_K2DMaxX, udg_K2DMaxY)
	SetItemVisible(udg_K2DItem, false)
	
	return result
end

---@return boolean
function K2DItemFilter()
	-- Check for visible items, temporarily hide them and add them to the filter.
	if IsItemVisible(GetFilterItem()) then
		SetItemVisible(GetFilterItem(), false)
		return true
	end
	return false
end

---@return nothing
function K2DItemCode()
	-- Perform the item-pathing check only once, then unhide those filtered items
	if not udg_K2DItemsFound then
		udg_K2DItemsFound = true
		udg_K2DItemOffset = K2DItemCheck()
	end
	SetItemVisible(GetEnumItem(), true)
end

---@return nothing
function K2DKillDest()
	local x
	local y
	-- Handle destruction of debris
	bj_destRandomCurrentPick = GetEnumDestructable()
	if GetWidgetLife(bj_destRandomCurrentPick) > 0.405 and IssueTargetOrder(udg_K2DDebrisKiller, udg_Knockback2DTreeOrDebris, bj_destRandomCurrentPick) then
		x = GetWidgetX(bj_destRandomCurrentPick) - udg_K2DX
		y = GetWidgetY(bj_destRandomCurrentPick) - udg_K2DY
		if x * x + y * y <= udg_K2DDestRadius[udg_UDex] then
			KillDestructable(bj_destRandomCurrentPick)
		end
	end
end

---@return nothing
function K2DEnumDests()
	MoveRectTo(udg_K2DRegion, udg_K2DX, udg_K2DY)
	if udg_K2DKillTrees[udg_UDex] then
		SetUnitX(udg_K2DDebrisKiller, udg_K2DX)
		SetUnitY(udg_K2DDebrisKiller, udg_K2DY)
		EnumDestructablesInRect(udg_K2DRegion, nil, K2DKillDest)
	end
end


---@param x real
---@param y real
---@return boolean
function Knockback2DCheckXY(x, y)
	udg_K2DX = x + udg_K2DVelocity[udg_UDex] * udg_K2DCos[udg_UDex]
	udg_K2DY = y + udg_K2DVelocity[udg_UDex] * udg_K2DSin[udg_UDex]
	if udg_K2DSimple[udg_UDex] then
		-- A "pull" effect or a missile system does not require complex pathing.
		if udg_K2DX <= udg_K2DMaxX and udg_K2DX >= udg_K2DMinX and udg_K2DY <= udg_K2DMaxY and udg_K2DY >= udg_K2DMinY then
			K2DEnumDests()
			return true
		end
		return false
	elseif udg_K2DFlying[udg_UDex] then
		return not IsTerrainPathable(udg_K2DX, udg_K2DY, PATHING_TYPE_FLYABILITY)
	elseif not IsTerrainPathable(udg_K2DX, udg_K2DY, PATHING_TYPE_WALKABILITY) then
		K2DEnumDests()
		udg_K2DItemOffset = false
		EnumItemsInRect(udg_K2DRegion, Filter(K2DItemFilter), K2DItemCode)
		if udg_K2DItemsFound then
			-- If items were found, the check was already performed.
			udg_K2DItemsFound = false
		else
			-- Otherwise, perform the check right now.
			udg_K2DItemOffset = K2DItemCheck()
		end
		return udg_K2DItemOffset
	end
	return udg_K2DAmphibious[udg_UDex] and not IsTerrainPathable(udg_K2DX, udg_K2DY, PATHING_TYPE_FLOATABILITY)
end


---@param angle real
---@return nothing
function Knockback2DApplyAngle(angle)
	angle = ModuloReal(angle, udg_Radians_Turn)
	udg_K2DCos[udg_UDex] = Cos(angle)
	udg_K2DSin[udg_UDex] = Sin(angle)
	udg_K2DAngle[udg_UDex] = angle
	if udg_Knockback2DRobustPathing > 0 then
		angle = ModuloReal(angle + udg_Radians_QuarterTurn, udg_Radians_Turn)
		udg_K2DCosH[udg_UDex] = Cos(angle)
		udg_K2DSinH[udg_UDex] = Sin(angle)
		if udg_Knockback2DRobustPathing == 2 and udg_K2DRadius[udg_UDex] > 16 then
			angle = ModuloReal(angle + udg_Radians_QuarterPi, udg_Radians_Turn)
			udg_K2DCosD1[udg_UDex] = Cos(angle)
			udg_K2DSinD1[udg_UDex] = Sin(angle)
			angle = ModuloReal(angle + udg_Radians_QuarterTurn, udg_Radians_Turn)
			udg_K2DCosD2[udg_UDex] = Cos(angle)
			udg_K2DSinD2[udg_UDex] = Sin(angle)
		end
	end
end

---@return nothing
function Knockback2DLooper()
	local i = 0
	local u
	local x
	local y
	
	PauseUnit(udg_K2DDebrisKiller, false)
	
	while true do
		i = udg_K2DNext[i]
		if i == 0 then break end
		udg_UDex = i
		udg_K2DTimeLeft[i] = udg_K2DTimeLeft[i] - udg_K2DTimeout
		udg_K2DDistanceLeft[i] = udg_K2DDistanceLeft[i] - udg_K2DVelocity[i]
		u = udg_UDexUnits[i]
		
		if udg_K2DTimeLeft[i] > 0.00 then
			if udg_K2DTimeLeft[i] < udg_K2DHeightThreshold[i] and udg_K2DHeightThreshold[i] ~= 0.00 then
				SetUnitFlyHeight(u, GetUnitDefaultFlyHeight(u), GetUnitFlyHeight(u) - GetUnitDefaultFlyHeight(u) / udg_K2DHeightThreshold[i])
				udg_K2DHeightThreshold[i] = 0.00
			end
			if udg_K2DPause[i] then
				x = udg_K2DLastX[i]
				y = udg_K2DLastY[i]
			else
				x = GetUnitX(u)
				y = GetUnitY(u)
			end
			
			if not Knockback2DCheckXY(x, y) then
				if not udg_K2DFreeze[i] and IsTriggerEnabled(udg_K2DImpact[i]) and TriggerEvaluate(udg_K2DImpact[i]) then
					TriggerExecute(udg_K2DImpact[i])
				end
				if udg_K2DBounce[i] then
					Knockback2DApplyAngle(udg_Radians_Turn - udg_K2DAngle[i])
					if not Knockback2DCheckXY(x, y) then
						Knockback2DApplyAngle(udg_K2DAngle[i] + bj_PI)
						if not Knockback2DCheckXY(x, y) then
							Knockback2DApplyAngle(udg_Radians_Turn - udg_K2DAngle[i])
							udg_K2DX = x
							udg_K2DY = y
						end
					end
				else
					udg_K2DX = x
					udg_K2DY = y
					udg_K2DFreeze[i] = true
				end
			end
			SetUnitX(u, udg_K2DX)
			SetUnitY(u, udg_K2DY)
			udg_K2DLastX[i] = udg_K2DX
			udg_K2DLastY[i] = udg_K2DY
			if udg_K2DFXModel[i] ~= "" then
				udg_K2DFXTimeLeft[i] = udg_K2DFXTimeLeft[i] - udg_K2DTimeout
				if udg_K2DFXTimeLeft[i] <= 0.00 then
					udg_K2DFXTimeLeft[i] = udg_K2DFXRate[i]
					if udg_K2DFlying[i] then
						DestroyEffect(AddSpecialEffectTarget(udg_K2DFXModel[i], u, "origin"))
					else
						DestroyEffect(AddSpecialEffect(udg_K2DFXModel[i], udg_K2DX, udg_K2DY))
					end
				end
			end
			if udg_K2DCollision[i] >= 0.00 then
				udg_Knockback2DSource = u
				GroupEnumUnitsInRange(bj_lastCreatedGroup, udg_K2DX, udg_K2DY, 200.00, nil)
				GroupRemoveUnit(bj_lastCreatedGroup, u)
				while true do
					udg_Knockback2DUnit = FirstOfGroup(bj_lastCreatedGroup)
					if udg_Knockback2DUnit == nil then break end
					GroupRemoveUnit(bj_lastCreatedGroup, udg_Knockback2DUnit)
					
					if IsUnitInRange(udg_Knockback2DUnit, u, udg_K2DCollision[i]) and udg_K2DFlying[i] == IsUnitType(udg_Knockback2DUnit, UNIT_TYPE_FLYING) and ( not IsUnitType(udg_Knockback2DUnit, UNIT_TYPE_STRUCTURE)) and not IsUnitType(udg_Knockback2DUnit, UNIT_TYPE_DEAD) and (udg_K2DUnbiasedCollision[i] or IsUnitAlly(udg_Knockback2DUnit, GetOwningPlayer(u))) and TriggerEvaluate(gg_trg_Knockback_2D) then
						udg_Knockback2DAngle = bj_RADTODEG * Atan2(GetUnitY(udg_Knockback2DUnit) - udg_K2DY, GetUnitX(udg_Knockback2DUnit) - udg_K2DX)
						udg_Knockback2DDistance = udg_K2DDistanceLeft[i]
						udg_Knockback2DBounces = udg_K2DBounce[i]
						udg_Knockback2DCollision = udg_K2DCollision[i]
						if udg_K2DHeight[i] ~= 0.00 then
							udg_Knockback2DHeight = GetUnitFlyHeight(u) - GetUnitDefaultFlyHeight(u)
						end
						udg_Knockback2DLoopFX = udg_K2DFXModel[i]
						udg_Knockback2DTime = udg_K2DTimeLeft[i]
						udg_Knockback2DUnbiasedCollision = udg_K2DUnbiasedCollision[i]
						TriggerExecute(gg_trg_Knockback_2D)
						udg_Knockback2DSource = u	-- in case of a recursive knockback
					end
				end
			end
			udg_K2DVelocity[i] = udg_K2DVelocity[i] - udg_K2DFriction[i]
		else
			TriggerExecute(gg_trg_Knockback_2D_Destroy)
		end
	end
	u = nil
	
	-- Disable dummy after the loop finishes so it doesn't interfere with the map
	PauseUnit(udg_K2DDebrisKiller, true)
end
-- ===========================================================================
---@return nothing
function StartKnockback2DTimer()
	TimerStart(udg_K2DTimer, udg_K2DTimeout, true, Knockback2DLooper)
end

---@return nothing
function InitTrig_Knockback_2D_System()
end
