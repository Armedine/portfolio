-- @sourceUnit = unit to deal damage FROM
-- @targetUnit = unit to deal damage FOR
-- @amountReal = amount to deal
-- @attackTypeInt = leave as 0 for default or set attack type (Spell, Hero, etc. use damage engine vars e.g. udg_ATTACK_TYPE_HERO)
-- @damageTypeInt = leave as 0 for default or set damage type (Normal, etc. use damage engine vars e.g. udg_DAMAGE_TYPE_NORMAL)
-- @healBool = is the effect healing or damage (true for healing)
-- @effectString (optional) = the special effect to create at origin
-- @effectScaleReal (optional) = scale effect
-- @zReal (optional) = scale Z offset
-- :: note: Should no longer add arguments to this function since in GUI there is a custom script string cap
function DamagePackageDealDirect(sourceUnit, targetUnit, amountReal, attackTypeInt, damageTypeInt, healBool, effectString, effectScaleReal, zReal)
	local aType = 0
	local dType = 0

	if (attackTypeInt ~= nil and attackTypeInt ~= 0) then
		aType = attackTypeInt
	else
		aType = ATTACK_TYPE_NORMAL
	end
	if (damageTypeInt ~= nil and damageTypeInt ~= 0) then
		dType = damageTypeInt
	else
		dType = DAMAGE_TYPE_NORMAL
	end

	if (healBool) then
		mvp.IncrementHealing(GetConvertedPlayerId(GetOwningPlayer(sourceUnit)), amountReal)
		SetUnitLifeBJ(targetUnit, GetWidgetLife(targetUnit) + amountReal )
		ArcingTextTag( "|cff32ff32+" .. R2I(amountReal) .. "|r", targetUnit)
	else
		UnitDamageTargetBJ(sourceUnit,targetUnit,amountReal, aType, dType)
	end
	if (effectString ~= nil and effectScaleReal ~= nil and zReal ~= nil) then
		DamagePackageSpecialEffect(targetUnit, effectString, effectScaleReal, zReal)
	elseif (effectString ~= nil and effectScaleReal ~= nil) then
		DamagePackageSpecialEffect(targetUnit, effectString, effectScaleReal, 1.0)
	elseif (effectString ~= nil) then
		DamagePackageSpecialEffect(targetUnit, effectString, 1.0, 0)
	end
end


-- :: deal damage to enemy targets in a radius; or, set healBool to 'true' to heal allies 
-- v1.0:
-- @sourceUnit = unit to deal damage FROM
-- @x,y = position to measure radius from
-- @rangeReal = area effect radius to check for
-- @amountReal = amount of damage to deal to target (pass in as var)
-- @healBool = is the effect healing or damage (true for healing, inverses damage amount)
-- @dummyBool = does the effect need to generate a spell dummy?
-- @dummyIdString = the spell id for the spell dummy (when set to true) to use on the damaged target e.g. 'e00d'
-- @dummyString = the order string for the spell dummy to use on the picked target
-- @effectString = optional string to use to create a special effect at unit position (feet)
-- @effectScaleReal = optional scale real (e.g. 0.50)
-- v2.0:
-- (** CANNOT BE RE-ORDERED IN FRONT OF v1.0 TO KEEP BACKWARDS-COMPATIBLE***)
-- @structureBool = should the ability damage structures
-- @excludeUnit = optional unit to exclude from damage (i.e. for abilities that have a bonus AoE effect when target is damaged)
function DamagePackageDealAOE(sourceUnit, x, y, rangeReal, amountReal, healBool, dummyBool, dummyIdString, dummyString, effectString, effectScaleReal, structureBool, excludeUnit)
	local g = CreateGroup()
	local i = 0
	local aType = ATTACK_TYPE_NORMAL
	local p = GetOwningPlayer(sourceUnit)
	local u

	if (healBool) then -- set to negative to inflict healing
		GroupEnumUnitsInRange(g, x, y, rangeReal, Condition( function()
			if DamagePackageAllyFilter(GetFilterUnit(), p) then
				mvp.IncrementHealing(GetConvertedPlayerId(GetOwningPlayer(sourceUnit)), amountReal)
				return true
			end
		end ) )
	elseif (structureBool) then
		GroupEnumUnitsInRange(g, x, y, rangeReal, Condition( function() return DamagePackageEnemyAndStructureFilter(GetFilterUnit(), p) end ) )
	else
		GroupEnumUnitsInRange(g, x, y, rangeReal, Condition( function() return DamagePackageEnemyFilter(GetFilterUnit(), p) end ) )
	end
	if (not IsUnitGroupEmptyBJ(g)) then
		u = FirstOfGroup(g)
		if (excludeUnit ~= nil) then
			GroupRemoveUnit(g, excludeUnit)
		end
	 	repeat
		  	i = i + 1
		    if (effectString ~= nil and effectString ~= '') then
		    	local loc = GetUnitLoc(u)
		    	local effect = AddSpecialEffectLoc(effectString, loc)
		    	BlzSetSpecialEffectScale( effect, effectScaleReal )
		    	DestroyEffect(effect)
		    	RemoveLocation(loc)
		    end
		    if (healBool) then
		    	SetUnitLifeBJ(u, GetWidgetLife(u) + amountReal )
		    	ArcingTextTag( "|cff32ff32+" .. R2I(amountReal) .. "|r", u)
		    else
		    	UnitDamageTargetBJ(sourceUnit,u,amountReal, aType, DAMAGE_TYPE_NORMAL)
		    end
		    if (dummyBool) then
		    	local loc2 = GetUnitLoc(u)
		    	local d = DamagePackageCreateDummy(p, 'e003', x, y)
		    	UnitApplyTimedLifeBJ( 1.75, FourCC('BTLF'), d )
		    	UnitAddAbility( d, FourCC(dummyIdString) )
		    	IssueTargetOrder( d, dummyString, u )
		    	RemoveLocation(loc2)
		    end
		    GroupRemoveUnit(g, u)
		    u = FirstOfGroup(g)
	  	until (u == nil or i == 36) -- prevent infinite loop due to reforged handle ID bug
	end

	DestroyGroup(g)

end


-- :: damage a target over time
-- @unit = unit that owns damage
-- @target = unit that takes damage
-- @amount = amount of damage to deal per interval
-- @duration = how long the effect lasts
-- @effect = special effect each interval
-- @timerPeriod = [optional] override how often damage is dealt (default = 1 sec)
-- @delayedBool = [optional] override timer type (e.g. conver to a delayed damage effect)
function DamagePackageDealOverTime(unit, target, amount, duration, effect, timerPeriod, periodicBool)
	local i = 0
	local cadence = timerPeriod or 1.0
	local isPeriodic = periodicBool or true
	TimerStart(NewTimer(), cadence, isPeriodic, function()
		if IsUnitAliveBJ(target) and isPeriodic then
			UnitDamageTargetBJ(unit, target, math.floor(amount), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL)
			DestroyEffect(AddSpecialEffect(effect, GetUnitX(target), GetUnitY(target)))
			i = i + 1
			if i >= duration then ReleaseTimer() end
		else
			ReleaseTimer()
		end
	end)
end


-- :: filter for enemy targets, default with no structures
-- @unit - unit to filter
-- @player - is unit enemy of this player
function DamagePackageEnemyFilter(unit, player)
  return  IsUnitEnemy(unit,player)
          and (not IsUnitDeadBJ(unit))
          and (not IsUnitType(unit,UNIT_TYPE_STRUCTURE))
          and (not IsUnitType(unit,UNIT_TYPE_MAGIC_IMMUNE))
end


-- :: filter for enemy targets, allow structures
-- @unit - unit to filter
-- @player - is unit enemy of this player
function DamagePackageEnemyAndStructureFilter(unit, player)
  return  IsUnitEnemy(unit,player)
          and (not IsUnitDeadBJ(unit))
          and (not IsUnitType(unit,UNIT_TYPE_MAGIC_IMMUNE))
end


-- :: filter for enemy targets, no summons
-- @unit - unit to filter
-- @player - is unit enemy of this player
function DamagePackageEnemyNonSummonFilter(unit, player)
  return  IsUnitEnemy(unit,player)
          and (not IsUnitDeadBJ(unit))
          and (not IsUnitType(unit,UNIT_TYPE_MAGIC_IMMUNE))
          and (not IsUnitType(unit,UNIT_TYPE_SUMMONED))
end


-- :: filter for allied targets
-- @unit - unit to filter
-- @player - is unit enemy of this player
function DamagePackageAllyFilter(unit, player)
  return  not IsUnitEnemy(unit,player)
          and (not IsUnitDeadBJ(unit))
          and (not IsUnitType(unit,UNIT_TYPE_STRUCTURE))
end


-- :: create a dummy and have it cast a spell at a location
-- @sourceUnit = owner of dummy
-- @dummyIdString = the spell id for the spell dummy (when set to true) to use on the damaged target e.g. 'e00d'
-- @dummyOrderString = the order string for the spell dummy to use on the picked target
-- @damageAmount = optional; if the dummy should have its damage overridden by a new value, set this value to that amount
-- @x,y = optional; location where the dummy is created
-- @x2,y2 = optional; location to cast dummy effect (set to 0 or leave empty if it is insant/stomp)
-- @overrideDuration = optional; if the dummy effect lasts longer than 3.0 sec (e.g. very long missile), set a custom duration for the damage override listener to exist
function DamagePackageDummyAoE(sourceUnit, dummyIdString, dummyOrderString, damageAmount, x, y, x2, y2, overrideDuration)
	local d
	if (x == nil or y == nil) then
		local defaultX = GetUnitX(sourceUnit)
		local defaultY = GetUnitY(sourceUnit)
		d = DamagePackageCreateDummy(GetOwningPlayer(sourceUnit), 'e003', defaultX, defaultY)
	else
		d = DamagePackageCreateDummy(GetOwningPlayer(sourceUnit), 'e003', x, y)
	end

	if (damageAmount ~= nil) then
		local trig = CreateTrigger()
		local dur = 3.0
		local func = function()
			udg_DamageEventAmount = damageAmount
		end
		if (overrideDuration ~= nil and overrideDuration > 0) then
			dur = overrideDuration
		end
		TriggerRegisterVariableEvent( trig, "udg_DamageModifierEvent", EQUAL, 1.00 )
		TriggerAddCondition(trig,Filter( function() return udg_DamageEventSource == d and udg_DamageEventAmount < 2.00 and udg_DamageEventAmount > 0
			and udg_IsDamageSpell end))
		TriggerAddAction(trig,func)
		TimerStart(NewTimer(trig),dur,false,function()
			DestroyTrigger(trig)
			ReleaseTimer()
		end)
	end

	UnitApplyTimedLifeBJ( 1.75, FourCC('BTLF'), d )
	UnitAddAbilityBJ( FourCC(dummyIdString), d )
	if (x == nil or y == nil or x2 == nil or y2 == nil) then
		IssueImmediateOrder ( d, dummyOrderString )
	else
		IssuePointOrder ( d, dummyOrderString, x2, y2 )
	end

end


-- :: create a dummy that casts an ability on self or target
-- @unit = owner of the dummy
-- @abilityId = e.g. "A00A"
-- @orderString = order string to use ability on unit
-- @targetUnit = (optional) target of the ability; if nil, dummy casts on self aka @unit
function DamagePackageDummyTarget(unit,abilityId,orderString,targetUnit)
	local x = GetUnitX(unit)
	local y = GetUnitY(unit)
	local d = DamagePackageCreateDummy(GetOwningPlayer(unit), 'e003', x, y)
	UnitApplyTimedLifeBJ( 0.75, FourCC('BTLF'), d )
	UnitAddAbility( d, FourCC(abilityId) )
	if (targetUnit == nil) then
		IssueTargetOrder( d, orderString, unit )
	else
		SetUnitX(d,GetUnitX(targetUnit))
		SetUnitY(d,GetUnitY(targetUnit))
		IssueTargetOrder( d, orderString, targetUnit )
	end
end


-- :: create a special effect at origin of unit
-- @unit = location of this unit
-- @effectString = effect to create (escape it e.g. \ becomes \\)
-- @scale (optional) = default 1.0, increase scale to this real amount
-- @z (optional) = increase Z of effect by real amount; defaults to 0
function DamagePackageSpecialEffect(unit, effectString, effectScaleReal, zReal)
	local x = GetUnitX(unit)
	local y = GetUnitY(unit)
	local z = BlzGetUnitZ(unit)
	local effect = AddSpecialEffect(effectString, x, y)
	if (effectScaleReal ~= nil) then
		BlzSetSpecialEffectScale(effect, effectScaleReal)
	end
	if (zReal ~= nil) then
		BlzSetSpecialEffectZ(effect, z + zReal)
	else
		BlzSetSpecialEffectZ(effect, z)
	end
	DestroyEffect(effect)
end


-- :: add mana to a unit
-- @unit = unit to add mana to
-- @amountReal = amount to restore
-- @bool = (optional) is the amount a percentage? e.g. 3 for 3%
function DamagePackageAddMana(unit,manaAmount,bool)
	local tag = ""
	if (manaAmount > 0) then tag = "+" end
	if (bool) then -- percent
		local mana = GetUnitState(unit,UNIT_STATE_MANA)
		local newVal = BlzGetUnitMaxMana(unit)*(manaAmount/100)
		mana = math.ceil(mana + newVal)
		SetUnitState( unit, UNIT_STATE_MANA, mana )
		ArcingTextTag( "|cff0064ff" .. tag .. R2I(newVal) .. "|r", unit)
	else -- raw value
		SetUnitState( unit, UNIT_STATE_MANA, GetUnitState(unit, UNIT_STATE_MANA) + manaAmount )
		ArcingTextTag( "|cff0064ff" .. tag .. R2I(manaAmount) .. "|r", unit)
	end
end


-- :: add health to a unit
-- @healUnit = unit to add health to
-- @amountReal = amount to restore
-- @percentBool = optional; is the amount a percentage? e.g. 3 for 3%
-- @effect = optional; special effect to play (leave empty for default effect, pass empty string e.g. '' or '_' for no effect)
-- @sourceUnit = optional; unit to award MVP score for healing
function DamagePackageRestoreHealth(healUnit,healthAmount,percentBool,effectString,sourceUnit)
	if healthAmount > 0 then
		local sourceUnit = sourceUnit or nil
		if not sourceUnit then -- attempt to catch general uses of spells if source is empty.
			sourceUnit = GetTriggerUnit()
		end
		local life = GetUnitState(healUnit,UNIT_STATE_LIFE)
		local scale = 1.0
		local str = effectString or 'Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl'
		local newVal
		if percentBool then -- percent
			newVal = BlzGetUnitMaxHP(healUnit)*(healthAmount/100)
			life = math.ceil(life + newVal)
			SetUnitState( healUnit, UNIT_STATE_LIFE, life )
			if newVal >= 1 then
				ArcingTextTag( "|cff32ff32+" .. R2I(newVal) .. "|r", healUnit)
			end
			if sourceUnit then DamagePackageHealingScore(sourceUnit, newVal) end
		else -- raw value
			life = math.ceil(life + healthAmount)
			SetUnitState( healUnit, UNIT_STATE_LIFE, life )
			ArcingTextTag( "|cff32ff32+" .. R2I(healthAmount) .. "|r", healUnit)
			if sourceUnit then DamagePackageHealingScore(sourceUnit, healthAmount) end
		end
		if str ~= '' and str ~= '_' then
			DestroyEffect(AddSpecialEffect(str,GetUnitX(healUnit), GetUnitY(healUnit)))
		end
	end
end


function DamagePackageHealingScore(u, a)
	mvp.IncrementHealing(GetConvertedPlayerId(GetOwningPlayer(u)), a)
end


function BasicDamageExpr(p)
	return IsUnitEnemy(GetFilterUnit(),p)
		and IsUnitAliveBJ(GetFilterUnit())
		and (not IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE))
		and (not IsUnitType(GetFilterUnit(),UNIT_TYPE_MAGIC_IMMUNE))
end


-- :: create a dummy without indexing it
-- facing = [optional] facing angle of dummy
-- dummyDuration = [optional] how long it persists (seconds)
-- returns unit
function DamagePackageCreateDummy(dummyPlayer, dummyId, dummyX, dummyY, facing, dummyDuration)
	local f
	local dur
	if (facing ~= nil) then f = math.floor(facing) else f = 270.0 end
	udg_UnitIndexerEnabled = false
	local dummyUnit = CreateUnit( dummyPlayer, FourCC(dummyId), dummyX, dummyY, f )
	udg_UnitIndexerEnabled = true
	if (dummyDuration ~= nil and dummyDuration > 0) then
		dur = dummyDuration
	else
		dur = 1.75
	end
	UnitApplyTimedLifeBJ( dur, FourCC('BTLF'), dummyUnit )
	return dummyUnit
end
