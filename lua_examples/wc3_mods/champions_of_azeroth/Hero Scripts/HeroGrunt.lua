function GruntInit(unit, i)
	GruntItemsInit(i)
	GruntAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNGrunt.blp'
	LeaderboardUpdateHeroIcon(i)
	udg_gruntUnit = unit
	EnableTrigger( gg_trg_Grunt_Staggering_Smash )
	EnableTrigger( gg_trg_Grunt_Berserker_Rage )
	EnableTrigger( gg_trg_Grunt_Bloodletting )
	EnableTrigger( gg_trg_Grunt_Bloody_Brawler )
	udg_heroCanRegenMana[i] = false
	LUA_TRG_GRUNT_MAX_MANA = ItemShopSetManaCap(i, 20)
end

function GruntItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I00L", -- 1 Fiery War Axe (Q)
		"I00N", -- 2 Ragefire Coif (W)
		"I00O", -- 3 Blood Pact (E)
		"I00P", -- 4 Orc Joggers (F)
		"I00Q", -- 5 Spiked Pauldrons (Q)
		"I03M", -- 6 Ragefire Pendant (W)
		"I03O", -- 7 Enchanted Troll Charm (E)
		"I03P", -- 8 Burning Blade Banner (F)
		"I03Q", -- 9 Skullfire Shield (Q)
		"I03N", -- 10 Ragefire Spaulders (W)
		"I03S" -- 11 Blood Salve (Active)
	}
	local itemTableUlt = {
		"I03T", -- 12 Juggernaut Shako (Q)
		"I03U", -- 13 Ragefire Core (W)
		"I03R", -- 14 Sanguinary Orb (Passive)
		"I03V", -- 15 Bracers of Insatiable Thirst (F)
		"I03K", -- 16 Butcher's Cleaver (R1)
		"I03L" -- 17 The Rending Blade (R2)
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I00N")) then IncUnitAbilityLevel(udg_gruntUnit,FourCC("A00A"))
		elseif (itemId == FourCC("I00O")) then IncUnitAbilityLevel(udg_gruntUnit,FourCC("A00B")) end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,udg_gruntItemBool,itemTableUlt)

end

function GruntAbilsInit(pInt)

	Grunt_Execute = CreateTrigger()
	Grunt_Bloodthirst = CreateTrigger()
	Grunt_Bloodthirst_Listener = CreateTrigger()

	local Grunt_Execute_f = function()
		local caster = GetTriggerUnit()
		local target = GetSpellTargetUnit()
		local hp = BlzGetUnitMaxHP(caster)*.1
		local dmg = BlzGetUnitMaxHP(caster)*.15
		if (udg_gruntItemBool[17]) then
			dmg = dmg *1.333
		end
		DamagePackageDealDirect(caster, target, dmg, 0, 0, false, '')
		if (GetWidgetLife(target) < .405) then
			DamagePackageDealDirect(caster, caster, hp*1.5, 0, 0, true) -- heal if unit died
			DestroyEffect( AddSpecialEffect( 'Objects\\Spawnmodels\\Orc\\OrcLargeDeathExplode\\OrcLargeDeathExplode.mdl',GetUnitX(caster),GetUnitY(caster) ) )
			DamagePackageAddMana(caster,10,false)
			if (udg_gruntItemBool[17]) then
				BlzEndUnitAbilityCooldown(GetTriggerUnit(),FourCC('A04P'))
			end
		end
		DamagePackageDealDirect(caster, caster, hp, 0, 0, false, 'Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl')
		caster = nil
		target = nil
	end

	local Grunt_Bloodthirst_f = function()
		local caster = GetTriggerUnit()
		local hp = BlzGetUnitMaxHP(caster)*.1
		DamagePackageDealDirect(caster, caster, hp, 0, 0, false, 'Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl')
		BlzEndUnitAbilityCooldown(GetTriggerUnit(),FourCC('A00C'))
		if (udg_gruntItemBool[16]) then
			BlzEndUnitAbilityCooldown(GetTriggerUnit(),FourCC('A00B'))
			BlzEndUnitAbilityCooldown(GetTriggerUnit(),FourCC('A00G'))
		end
		EnableTrigger(Grunt_Bloodthirst_Listener)
		TimerStart(NewTimer(), 10.0, false, function()
			DisableTrigger(Grunt_Bloodthirst_Listener)
			ReleaseTimer()
			end)
		caster = nil
	end

	local Grunt_Bloodthirst_l_f = function()
		local x = GetUnitX(udg_DamageEventTarget)
		local y = GetUnitY(udg_DamageEventTarget)
		if (IsUnitInRangeXY(udg_gruntUnit,x,y,1000.0)) then
			TimerStart(NewTimer(),0.50,false,function() BlzEndUnitAbilityCooldown(udg_gruntUnit,FourCC('A00C')) ReleaseTimer() end )
			DestroyEffect( AddSpecialEffect( 'Objects\\Spawnmodels\\Orc\\OrcLargeDeathExplode\\OrcLargeDeathExplode.mdl',GetUnitX(udg_gruntUnit),GetUnitY(udg_gruntUnit) ) )
		end
	end

	TriggerRegisterPlayerUnitEvent(Grunt_Execute,Player(pInt - 1),EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(Grunt_Execute, Filter( function() return GetSpellAbilityId() == FourCC('A04P') end ) )
	TriggerAddAction(Grunt_Execute,Grunt_Execute_f)

	TriggerRegisterPlayerUnitEvent(Grunt_Bloodthirst,Player(pInt - 1),EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(Grunt_Bloodthirst, Filter( function() return GetSpellAbilityId() == FourCC('A04Q') end ) )
	TriggerAddAction(Grunt_Bloodthirst,Grunt_Bloodthirst_f)

	TriggerRegisterVariableEvent( Grunt_Bloodthirst_Listener, "udg_LethalDamageEvent", EQUAL, 1.00 )
	TriggerAddCondition(Grunt_Bloodthirst_Listener, Filter( function() return (udg_DamageEventTarget ~= udg_gruntUnit
		and IsUnitType(udg_DamageEventTarget,UNIT_TYPE_HERO)
		and IsUnitEnemy(udg_DamageEventTarget, GetOwningPlayer(udg_gruntUnit)) )
		end ) )
	TriggerAddAction(Grunt_Bloodthirst_Listener,Grunt_Bloodthirst_l_f)

	DisableTrigger(Grunt_Bloodthirst_Listener)

end
