-- overlord v1.0
function OverlordInit(unit, i)
	OverlordItemsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNFelGuardBlue.blp'
	LeaderboardUpdateHeroIcon(i)
	udg_overlordUnit = unit
	HeroTriggersOverlord()
end


function OverlordItemsInit(pInt)

	LUA_VAR_OVERLORDITEMBOOL = {}

	-- raw code and descriptions
	local itemTable = {
		"I024", -- 1 (Q) Seething Wrathstone 
		"I026", -- 2 (W) Legion Shield Beacon 
		"I027", -- 3 (E) Overwhelming Gauntlets 
		"I028", -- 4 (Trait) Oozing Cleaver 
		"I029", -- 5 (Q) Key of Cauterizing Flame 
		"I06Z", -- 6 (W) Legion Horn of Command -- not working
		"I070", -- 7 (E) Overwhelming Pauldrons
		"I071", -- 8 (Trait) Blistering Felstone
		"I06V", -- 9 (Q) Key of Condensed Flame
		"I06W", -- 10 (W) Cloak of Fel Absorption
		"I06X" -- 11 (E) Overwhelming Belt
	}
	local itemTableUlt = {
		"I06Y", -- 12 (Q) Hellfire Trinket
		"I073", -- 13 (W) Amalgamated Felstone
		"I074", -- 14 (E) Trinket of Overwhelming Power
		"I072", -- 15 (Stats) Felforged Plating
		"I076", -- 16 (R1) Wyrmtongue Engineering Crew
		"I075" -- 17 (R2) Gorefiend's Terror
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I06V")) then IncUnitAbilityLevel(udg_overlordUnit,FourCC("A03T"))
		elseif (itemId == FourCC("I06W")) then IncUnitAbilityLevel(udg_overlordUnit,FourCC("A03U"))
		elseif (itemId == FourCC("I06X")) then IncUnitAbilityLevel(udg_overlordUnit,FourCC("A03V"))
		elseif (itemId == FourCC("I06X")) then HeroAddStatTimer(udg_overlordUnit, 0, 1, 45.0, 12)
		elseif (itemId == FourCC("I075")) then LUA_VAR_OVERLORDITEM_I_17 = 0
		end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,LUA_VAR_OVERLORDITEMBOOL,itemTableUlt)

end


function HeroTriggersOverlord()

	Overlord_Cleave = CreateTrigger()
	Overlord_Wrath = CreateTrigger()
	Overlord_Pact = CreateTrigger()
	Overlord_Brutalize = CreateTrigger()
	Overlord_Sentinax = CreateTrigger()
	Overlord_Terror = CreateTrigger()
	LUA_VAR_OVERLORDCLEAVECOUNT = 0


	local Overlord_Wrath_f = function()
		local i = 0
		local ticks = 24 -- number of ticks (duration = ticks * 0.25)
		local originLoc = GetSpellTargetLoc()
		local x = GetLocationX(originLoc)
		local y = GetLocationY(originLoc)
		local radius = 150.0
		local damageBonus = 0.03
		local unit = GetTriggerUnit()
		local damage = GetHeroStatBJ(bj_HEROSTAT_STR, unit, true)*.25
		local p = GetOwningPlayer(unit)
		if (LUA_VAR_OVERLORDITEMBOOL[1]) then
			ticks = 32
			damage = damage*1.1
		end
		if (LUA_VAR_OVERLORDITEMBOOL[12]) then
			damageBonus = damageBonus + .025
		end

		TimerStart(NewTimer(),0.25, true, function()
			if (ModuloInteger(i,6) == 0) then
				local effect = AddSpecialEffect('war3mapImported\\Conflagrate Green.mdx', x, y)
				DestroyEffect(effect)
			end
			i = i + 1
			local g = CreateGroup()
			GroupEnumUnitsInRange(g, x, y, radius, Condition( function() return
				IsUnitEnemy(GetFilterUnit(),p)
				and IsUnitAliveBJ(GetFilterUnit())
				and not IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)
				and not IsUnitType(GetFilterUnit(),UNIT_TYPE_MAGIC_IMMUNE) end ) )
			if (not IsUnitGroupEmptyBJ(g)) then
				local u = FirstOfGroup(g)
				local i2 = 0
			 	repeat
			 		UnitDamageTargetBJ(unit,u,damage, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL)
			 		if (IsUnitType(u,UNIT_TYPE_HERO) and not IsUnitType(u,UNIT_TYPE_ANCIENT)) then
				 		damage = damage + (damage*damageBonus)
				 	end
				 	if (LUA_VAR_OVERLORDITEMBOOL[5]) then
				 		DamagePackageRestoreHealth(unit,damage*.15,false,'_',unit)
				 	end
				    GroupRemoveUnit(g, u)
				    u = FirstOfGroup(g)
				    i2 = i2 + 1
			  	until (u == nil or i2 == 24) -- prevent infinite loop
			end
			if (i >= ticks) then
				ReleaseTimer()
			end
		end)
		RemoveLocation(originLoc)
		--RemoveLocation(loc)
	end

	local Overlord_Pact_f = function()
		local u = GetTriggerUnit()
		local t = GetSpellTargetUnit()
		DamagePackageDummyTarget(u,'A03U','spiritlink')
		if (LUA_VAR_OVERLORDITEMBOOL[2]) then
			DamagePackageDummyTarget(u,'A00O','innerfire')
			DamagePackageDummyTarget(t,'A00O','innerfire')
		end
		if (LUA_VAR_OVERLORDITEMBOOL[6]) then
			DamagePackageDummyTarget(u,'A042','bloodlust')
			DamagePackageDummyTarget(t,'A042','bloodlust')
		end
		if (LUA_VAR_OVERLORDITEMBOOL[13]) then
			local i = 0
			TimerStart(NewTimer(i),1.0,true,function()
				DamagePackageRestoreHealth(udg_overlordUnit,4,true,'Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdl',udg_overlordUnit)
				i = i+1
				if (i >= 5) then
					ReleaseTimer()
				end
			end)
		end
	end

	local Overlord_Brutalize_f = function()
		local u = GetTriggerUnit()
		local t = GetSpellTargetUnit()
		local loc = GetUnitLoc(u)
		local loc2 = GetUnitLoc(t)
		local angle = AngleBetweenPoints(loc,loc2)-180.0
		local travelDistance = DistanceBetweenPoints(loc,loc2)+200.0
		if (IsUnitEnemy(t) and LUA_VAR_OVERLORDITEMBOOL[3]) then
			travelDistance = travelDistance + 100
		end
		local endLoc = PolarProjectionBJ(loc,travelDistance,angle)
		local velocity = travelDistance/9.0
		local distance = 0.0
		local i = 0
		local damage = GetHeroStatBJ(bj_HEROSTAT_STR, u, true)*1.25
		if (LUA_VAR_OVERLORDITEMBOOL[7]) then
			damage = damage*1.25
		end
		SetUnitPathing(t, false)
		SetUnitPathing(u, false)
		PauseUnit(u,true)
		PauseUnit(t,true)
		SetUnitAnimation(u,"spell")
		local x = GetLocationX(loc2)
		local y = GetLocationY(loc2)
		TimerStart(NewTimer(),0.04,true,function()
			if (i <= 9 and IsUnitAliveBJ(t) and IsUnitAliveBJ(u)) then
				i = i+1
				distance = distance + velocity
				local pLoc = Location(x,y)
				local arrivalLoc = PolarProjectionBJ(pLoc,distance,angle)
				SetUnitPositionLoc(t,arrivalLoc)
				RemoveLocation(pLoc)
				RemoveLocation(arrivalLoc)
			else
				local x2 = GetUnitX(t)
				local y2 = GetUnitY(t)
				local effect = AddSpecialEffect('Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl',x2,y2)
				if (IsUnitEnemy(t,GetOwningPlayer(u))) then
					UnitDamageTargetBJ(u,t,damage,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)
					if (LUA_VAR_OVERLORDITEMBOOL[3]) then
						DamagePackageDummyTarget(u,'A03H','thunderbolt',t)
					end
					if (LUA_VAR_OVERLORDITEMBOOL[7]) then
						if (LUA_VAR_OVERLORDITEMBOOL[3]) then -- if stun item is true, apply the slow after it
							TimerStart(NewTimer(),1.0,false,function() DamagePackageDummyTarget(u,'A04B','slow',t) ReleaseTimer() end)
						else
							DamagePackageDummyTarget(u,'A04B','slow',t)
						end
					end
					if (LUA_VAR_OVERLORDITEMBOOL[14]) then
						UnitDamageTargetBJ(u,t,math.floor(BlzGetUnitMaxHP(t)*.1),ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)
					end
				else
					DamagePackageDummyTarget(t,'A00O','innerfire')
				end
				DestroyEffect(effect)
				PauseUnit(u,false)
				PauseUnit(t,false)
				ResetUnitAnimation(u)
				SetUnitPathing(t, true)
				SetUnitPathing(u, true)
				ReleaseTimer()
			end
		end)
		RemoveLocation(loc)
		RemoveLocation(loc2)
		RemoveLocation(endLoc)
	end

	local Overlord_Sentinax_f = function()

		local caster, tarX, tarY, casterX, casterY = SpellPackSetupTargetAbil()
		local i = 6
		local dmg = GetHeroStatBJ(bj_HEROSTAT_STR, caster, true)*1.0
		if (LUA_VAR_OVERLORDITEMBOOL[16]) then
			i = i + 2
			dmg = dmg*1.25
		end
		local a, x2, y2, r = 0
		local radius = 350.0
		local effectRadius = 235.0

		UnitApplyTimedLifeBJ( i+1, FourCC('BTLF'), CreateUnit(GetOwningPlayer(caster),FourCC('e004'),tarX,tarY,270.0) ) -- visibility dummy

		PolledWait(1.0) -- inaccurate wait to allow reaction times

		TimerStart(NewTimer(),1.0,true,function()
			if (i <= 0) then
				ReleaseTimer()
			else
				for loop = 1,4 do
					a = math.random() * 2 * 3.141 -- simplify pi to save on calc time
					r = effectRadius * math.sqrt(math.random())
					x2 = tarX + (r * math.cos(a))
					y2 = tarY + (r * math.sin(a))
					DestroyEffect(AddSpecialEffect('Units\\Demon\\Infernal\\InfernalBirth.mdl',x2,y2))
				end
				DamagePackageDealAOE(caster, tarX, tarY, radius, dmg, false, false, '', '', 'Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdl', 1.0)
				i = i - 1
			end
		end)

	end

	local Overlord_Terror_f = function ()
		local g = CreateGroup()
		local caster = GetSpellAbilityUnit()
		local casterX = GetUnitX(caster)
		local casterY = GetUnitY(caster)
		if (LUA_VAR_OVERLORDITEMBOOL[17]) then
			LUA_VAR_OVERLORDITEM_I_17 = 0
		end

		GroupEnumUnitsInRange(g, casterX, casterY, 600.0, Condition( function() return
			IsUnitEnemy(GetFilterUnit(),GetOwningPlayer(caster))
			and IsUnitAliveBJ(GetFilterUnit())
			and (not IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE))
			and (not IsUnitType(GetFilterUnit(),UNIT_TYPE_MAGIC_IMMUNE)) end ) )
		GroupUtilsAction(g, function()
				local x = GetUnitX(LUA_FILTERUNIT)
				local y = GetUnitY(LUA_FILTERUNIT)
				DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Other\\HowlOfTerror\\HowlCaster.mdl', x, y))
			end)
		DestroyGroup(g)
	end

	local Overlord_Cleave_f = function()
		local damageMult = 1.25
		local requiredAttacks = 3
		if (LUA_VAR_OVERLORDITEMBOOL[4]) then
			damageMult = 1.88 -- str dmg done
			requiredAttacks = 4 -- attacks before cleave activates
		end
		LUA_VAR_OVERLORDCLEAVECOUNT = LUA_VAR_OVERLORDCLEAVECOUNT + 1 -- add attack count
		if (LUA_VAR_OVERLORDCLEAVECOUNT > requiredAttacks) then
			LUA_VAR_OVERLORDCLEAVECOUNT = 0 -- reset
			local casterX = GetUnitX(udg_DamageEventSource)
			local casterY = GetUnitY(udg_DamageEventSource)
			local tarX,tarY = PolarProjectionXY(casterX, casterY, 125.00, GetUnitFacing(udg_DamageEventSource))
			local dmg = GetHeroStatBJ(bj_HEROSTAT_STR, udg_DamageEventSource, true)*damageMult
			local effect = 'Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdl'
			LuaMissile.create(udg_DamageEventSource, tarX, tarY, 400.0, 0.50, dmg, 100.0, false, false, false,
			    nil, nil, effect, effect, 30.0, 1.50, nil, nil, nil)
			if (LUA_VAR_OVERLORDITEMBOOL[8]) then
				DamagePackageRestoreHealth(udg_overlordUnit,8,true)
			end
			if (LUA_VAR_OVERLORDITEMBOOL[17]) then
				LUA_VAR_OVERLORDITEM_I_17 = LUA_VAR_OVERLORDITEM_I_17 + 1
				if (LUA_VAR_OVERLORDITEM_I_17 >= 2) then
					BlzEndUnitAbilityCooldown( udg_overlordUnit, FourCC('A03W') )
					LUA_VAR_OVERLORDITEM_I_17 = 0
				end
			end
		end
	end

	local playerOwner = GetOwningPlayer(udg_overlordUnit)

	TriggerRegisterPlayerUnitEvent(Overlord_Wrath,playerOwner,EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(Overlord_Wrath, Filter( function() return GetSpellAbilityId() == FourCC('A03T') end ) )
	TriggerAddAction(Overlord_Wrath,Overlord_Wrath_f)

	TriggerRegisterPlayerUnitEvent(Overlord_Pact,playerOwner,EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(Overlord_Pact, Filter( function() return GetSpellAbilityId() == FourCC('A03U') and GetTriggerUnit() == udg_overlordUnit end ) )
	TriggerAddAction(Overlord_Pact,Overlord_Pact_f)

	TriggerRegisterPlayerUnitEvent(Overlord_Brutalize,playerOwner,EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(Overlord_Brutalize, Filter( function() return GetSpellAbilityId() == FourCC('A03V') end ) )
	TriggerAddAction(Overlord_Brutalize,Overlord_Brutalize_f)

	TriggerRegisterPlayerUnitEvent(Overlord_Terror,playerOwner,EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(Overlord_Terror, Filter( function() return GetSpellAbilityId() == FourCC('A03W') end ) )
	TriggerAddAction(Overlord_Terror,Overlord_Terror_f)

	TriggerRegisterPlayerUnitEvent(Overlord_Sentinax,playerOwner,EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(Overlord_Sentinax, Filter( function() return GetSpellAbilityId() == FourCC('A05Z') end ) )
	TriggerAddAction(Overlord_Sentinax,Overlord_Sentinax_f)

	TriggerRegisterVariableEvent( Overlord_Cleave, "udg_DamageModifierEvent", EQUAL, 1.00 )
	TriggerAddCondition(Overlord_Cleave, Filter( function() return (GetUnitTypeId(udg_DamageEventSource) == FourCC('O016')
			and udg_DamageEventAttackT == udg_ATTACK_TYPE_HERO
			and udg_DamageEventAmount > 1.00)
		end ) )
	TriggerAddAction(Overlord_Cleave,Overlord_Cleave_f)

end
