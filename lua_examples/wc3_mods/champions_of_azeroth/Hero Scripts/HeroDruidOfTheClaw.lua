function DruidClawInit(unit, i)
	LUA_VAR_DRUIDCLAW_UNIT = unit
	LUA_VAR_DRUIDCLAW_ITEMBOOL = {}
	DruidClawItemsInit(i)
	DruidClawAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNDruidOfTheClaw.blp'
	LeaderboardUpdateHeroIcon(i)
	LUA_TRG_DRUIDCLAW_MAX_MANA = ItemShopSetManaCap(i, 100)
end

function DruidClawItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I090", -- 1 (Q) Blooming Rod
		"I091", -- 2 (W) Bear Armor
		"I092", -- 3 (E) Living Bark
		"I093", -- 4 (Trait) Moon Stone
		"I096", -- 5 (Q) Mending Rod
		"I094", -- 6 (W) Medallion of the Claw
		"I098", -- 7 (E) Vengeful Druid Claws
		"I095", -- 8 (Trait) Warden's Dagger
		"I099", -- 9 (Q) Trinket of Channeling
		"I097", -- 10 (W) Bark Stompers
		"I09A" -- 11 (E) Talisman of the Claw
	}
	local itemTableUlt = {
		"I09C", -- 12 (Q) Malorne's Trinket of Life
		"I09B", -- 13 (W) Ursol's Trinket of Rage
		"I09D", -- 14 (E) Tortolla's Trinket of Fortitude
		"I09E", -- 15 (Trait) Uroc's Trinket of Rending
		"I09F", -- 16 (R1) Ashamane's Trinket of Ferocity
		"I09G" -- 17 (R2) Aessina's Trinket of Lifeblood
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I099")) then IncUnitAbilityLevel(LUA_VAR_DRUIDCLAW_UNIT,FourCC("A06H"))
		elseif (itemId == FourCC("I09A")) then IncUnitAbilityLevel(LUA_VAR_DRUIDCLAW_UNIT,FourCC("A06K"))
		elseif (itemId == FourCC("I09B")) then IncUnitAbilityLevel(LUA_VAR_DRUIDCLAW_UNIT,FourCC("A06I"))
		elseif (itemId == FourCC("I093")) then DestroyTrigger(LUA_TRG_DRUIDCLAW_MAX_MANA)
			LUA_TRG_DRUIDCLAW_MAX_MANA = ItemShopSetManaCap(GetConvertedPlayerId(GetOwningPlayer(LUA_VAR_DRUIDCLAW_UNIT)), 125)
		end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,LUA_VAR_DRUIDCLAW_ITEMBOOL,itemTableUlt)

end

function DruidClawAbilsInit(pInt)

	DruidClaw_Trait = CreateTrigger()
	DruidClaw_Rejuvenation = CreateTrigger()
	DruidClaw_Roar = CreateTrigger()
	DruidClaw_Earthward = CreateTrigger()
	DruidClaw_Guardian = CreateTrigger()
	DruidClaw_Seed = CreateTrigger()
	DruidClaw_Maul = CreateTrigger()
	DruidClaw_Thrash = CreateTrigger()
	DruidClaw_Form = CreateTrigger()

	LUA_VAR_DRUIDCLAW_REJUV_TIMER = {}
	LUA_VAR_DRUIDCLAW_EARTHWARD_TIMER = {}
	LUA_VAR_DRUIDCLAW_EARTHWARD_TRIG = {}

	local DruidClaw_Form_f = function()
		local caster = GetTriggerUnit()
		local typeId = GetUnitTypeId(caster)
		if (LUA_VAR_DRUIDCLAW_ITEMBOOL[2]) then
			DamagePackageDummyTarget(caster,'A04J','innerfire')
		end
		-- abils get overwritten by form changes, so we have to do something tacky/persistent when exiting forms:
		if (LUA_VAR_DRUIDCLAW_ITEMBOOL[9] and typeId == FourCC('O01D')) then
			TimerStart(NewTimer(),0.45,false,function() IncUnitAbilityLevel(LUA_VAR_DRUIDCLAW_UNIT,FourCC("A06H")) ReleaseTimer() end)
		end
		if (LUA_VAR_DRUIDCLAW_ITEMBOOL[11] and typeId == FourCC('O01D')) then
			TimerStart(NewTimer(),0.45,false,function() IncUnitAbilityLevel(LUA_VAR_DRUIDCLAW_UNIT,FourCC("A06K")) ReleaseTimer() end)
		end
		if (LUA_VAR_DRUIDCLAW_ITEMBOOL[15] and typeId == FourCC('O01C')) then
			TimerStart(NewTimer(),0.45,false,function() UnitRemoveBuffBJ( FourCC('Brej'), caster ) ReleaseTimer() end)
		end
	end

	local DruidClaw_Rejuvenation_f = function()
		local target = GetSpellTargetUnit()
		local ID = GetUnitUserData(target)
		local caster = GetTriggerUnit()
		local healing = 1.25
		if (LUA_VAR_DRUIDCLAW_ITEMBOOL[5]) then
			healing = healing*1.1
		end
		if (LUA_VAR_DRUIDCLAW_REJUV_TIMER[ID] ~= nil) then ReleaseTimer(LUA_VAR_DRUIDCLAW_REJUV_TIMER[ID]) end
		LUA_VAR_DRUIDCLAW_REJUV_TIMER[ID] = NewTimer()
		TimerStart(LUA_VAR_DRUIDCLAW_REJUV_TIMER[ID],1.0,true,function()
			if (UnitHasBuffBJ(target,FourCC('Brej')) and IsUnitAliveBJ(target)) then
				DamagePackageRestoreHealth(target,healing,true,'_')
			else
				if (LUA_VAR_DRUIDCLAW_ITEMBOOL[1]) then
					DamagePackageRestoreHealth(target,GetHeroStatBJ(bj_HEROSTAT_INT, caster, true)*0.50,false,'_',caster)
				end
				ReleaseTimer()
			end
		end)
		if (LUA_VAR_DRUIDCLAW_ITEMBOOL[1]) then
			DamagePackageRestoreHealth(target,GetHeroStatBJ(bj_HEROSTAT_INT, caster, true)*0.50,false,'_',caster)
		end
		if (LUA_VAR_DRUIDCLAW_ITEMBOOL[12]) then
			local seedDummy = DamagePackageCreateDummy(GetOwningPlayer(caster),'e00S',GetUnitX(target),GetUnitY(target),270.0, 3.1)
			local seedHeal = GetHeroStatBJ(bj_HEROSTAT_INT, caster, true)*1.50
			TimerStart(NewTimer(),3.0,false,function()
				DamagePackageDealAOE(caster, GetUnitX(seedDummy), GetUnitY(seedDummy),
					300.0, seedHeal, true, false, '', '', 'Abilities\\Spells\\Other\\AcidBomb\\BottleMissile.mdl', 1.0)
				DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Other\\AcidBomb\\BottleMissile.mdl',GetUnitX(seedDummy),GetUnitY(seedDummy)))
				RemoveUnit(seedDummy)
				ReleaseTimer()
			end)
		end
	end

	local DruidClaw_Roar_f = function()
		local caster = GetTriggerUnit()
		local g = CreateGroup()
		GroupEnumUnitsInRange(g,GetUnitX(caster),GetUnitY(caster),600.0, Filter(function() return
			IsUnitAlly(GetFilterUnit(),GetOwningPlayer(caster))
			and IsUnitAliveBJ(GetFilterUnit())
			and IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO)
			and GetFilterUnit() ~= caster end ) )
		GroupUtilsAction(g,function()
			DamagePackageAddMana(LUA_FILTERUNIT,10.0,true)
			DestroyEffect(AddSpecialEffect('Abilities\\Weapons\\Bolt\\BoltImpact.mdl',GetUnitX(LUA_FILTERUNIT),GetUnitY(LUA_FILTERUNIT)))
			if (LUA_VAR_DRUIDCLAW_ITEMBOOL[10] and UnitHasBuffBJ(LUA_FILTERUNIT,FourCC('Brej'))) then
				DamagePackageDummyTarget(LUA_FILTERUNIT,'A029','bloodlust')
			end
		end)
		DestroyGroup(g)
		if (GetUnitTypeId(caster) == FourCC('O01D')) then
			DamagePackageAddMana(caster,10.0,true)
		else
			DamagePackageRestoreHealth(caster,10.0,true,'_',caster)
		end
		if (LUA_VAR_DRUIDCLAW_ITEMBOOL[6]) then
			BlzEndUnitAbilityCooldown(caster,FourCC('A06L'))
		end
	end

	DruidClaw_Earthward_Listener_f = function()
		DamagePackageRestoreHealth(udg_DamageEventTarget,0.75,true,'_',udg_playerHero[pInt])
		if (LUA_VAR_DRUIDCLAW_ITEMBOOL[7]) then
			UnitDamageTargetBJ(udg_DamageEventTarget,udg_DamageEventSource,
				GetHeroStatBJ(bj_HEROSTAT_STR, udg_playerHero[pInt], true)*0.20,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)
		end
	end

	local DruidClaw_Earthward_f = function()
		local caster = GetTriggerUnit()
		local target = GetSpellTargetUnit()
		local ID = GetUnitUserData(target)
		local dur = 8.0
		if (LUA_VAR_DRUIDCLAW_ITEMBOOL[11]) then dur = dur + 4.0 end
		local cond = function() return
			IsUnitEnemy(udg_DamageEventSource,GetOwningPlayer(target))
			and not IsUnitType(udg_DamageEventSource,UNIT_TYPE_ANCIENT)
			and udg_DamageEventTarget == target
		end

		if (LUA_VAR_DRUIDCLAW_EARTHWARD_TIMER[ID] ~= nil) then ReleaseTimer(LUA_VAR_DRUIDCLAW_EARTHWARD_TIMER[ID]) end
		LUA_VAR_DRUIDCLAW_EARTHWARD_TIMER[ID] = NewTimer()
		if (LUA_VAR_DRUIDCLAW_EARTHWARD_TRIG[ID] ~= nil) then DestroyTrigger(LUA_VAR_DRUIDCLAW_EARTHWARD_TRIG[ID]) end
		LUA_VAR_DRUIDCLAW_EARTHWARD_TRIG[ID] = CreateTrigger()

		SpellPackCreateDamageTrigger(LUA_VAR_DRUIDCLAW_EARTHWARD_TRIG[ID],DruidClaw_Earthward_Listener_f,1,cond,"udg_DamageEvent")

		TimerStart(LUA_VAR_DRUIDCLAW_EARTHWARD_TIMER[ID],dur,false,function()
			DestroyTrigger(LUA_VAR_DRUIDCLAW_EARTHWARD_TRIG[ID])
			if (LUA_VAR_DRUIDCLAW_ITEMBOOL[14]) then
				DamagePackageRestoreHealth(target,dur,true,nil,caster)
			end
			ReleaseTimer()
		end)

		if (LUA_VAR_DRUIDCLAW_ITEMBOOL[3]) then
			DamagePackageDummyTarget(target,'A04J','innerfire')
		end
	end

	local DruidClaw_Guardian_f = function()
		local caster = GetTriggerUnit()
		local i = 0
		if (GetUnitTypeId(caster) == FourCC('O01C')) then -- if not bear form yet, activate it
			BlzEndUnitAbilityCooldown(caster,FourCC('A06J'))
			IssueImmediateOrder(caster,'bearform')
		end
		TimerStart(NewTimer(),0.5,true,function()
			DamagePackageAddMana(caster,-7.0,false)
			i = i + 1
			if (not UnitHasBuffBJ(caster,FourCC('B01S')) or not IsUnitAliveBJ(caster)) then
				ReleaseTimer()
			elseif (GetUnitManaPercent(caster) < 1.00) then
				UnitRemoveBuffBJ( FourCC('B01S'), caster )
			elseif (math.fmod(i,2) == 0) then
				BlzEndUnitAbilityCooldown(caster,FourCC('A06L'))
			end
		end)
	end

	local DruidClaw_Seed_f = function()
		local caster = GetTriggerUnit()
		local target = GetSpellTargetUnit()
		local healing = 30.0
		if (LUA_VAR_DRUIDCLAW_ITEMBOOL[17]) then
			healing = 60.0
		end
		local i = 0
		TimerStart(NewTimer(),0.15,true,function()
			i = i + 1
			if (not IsUnitAliveBJ(target)) then
				ReleaseTimer()
			elseif (i >= 20) then
				DamagePackageRestoreHealth(target,healing,true,nil,caster)
				ReleaseTimer()
			elseif (GetUnitLifePercent(target) < 15.0) then
				DamagePackageRestoreHealth(target,healing*2.0,true,'Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl',caster)
				DestroyEffect(AddSpecialEffect('Abilities\\Spells\\NightElf\\MoonWell\\MoonWellCasterArt.mdl',GetUnitX(target),GetUnitY(target)))
				ReleaseTimer()
			end
		end)
	end

	local DruidClaw_Maul_f = function()
		local caster = GetTriggerUnit()
		local target = GetSpellTargetUnit()
		local dmg = GetHeroStatBJ(bj_HEROSTAT_STR, caster, true)*1.75
		if (LUA_VAR_DRUIDCLAW_ITEMBOOL[15]) then
			dmg = dmg*1.15
		end
		if (UnitHasBuffBJ(caster,FourCC('B01S'))) then
			local g = CreateGroup()
			dmg = dmg*1.15
			local healing = dmg
			if (LUA_VAR_DRUIDCLAW_ITEMBOOL[16]) then
				healing = healing*2.0
			end
			GroupEnumUnitsInRange(g,GetUnitX(caster),GetUnitY(caster),600.0, Filter(function() return
				DamagePackageAllyFilter(GetFilterUnit(),GetOwningPlayer(caster)) end ) )
			GroupUtilsAction(g,function()
				DamagePackageRestoreHealth(LUA_FILTERUNIT,healing,false,'Abilities\\Weapons\\Bolt\\BoltImpact.mdl',caster)
			end)
			DestroyGroup(g)
		end
		UnitDamageTargetBJ(caster,target,dmg,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)
	end

	local DruidClaw_Thrash_f = function()
		local caster = GetTriggerUnit()
		local target = GetSpellTargetUnit()
		local dmg = GetHeroStatBJ(bj_HEROSTAT_STR, caster, true)*2.00
		if (LUA_VAR_DRUIDCLAW_ITEMBOOL[15]) then
			dmg = dmg*1.15
		end
		UnitDamageTargetBJ(caster,target,dmg,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)
		DamagePackageDummyTarget(caster,'A045','bloodlust')
		if (LUA_VAR_DRUIDCLAW_ITEMBOOL[8]) then
			DamagePackageDummyTarget(caster,'A04B','slow',target)
			DamagePackageAddMana(caster,5,false)
		end
	end

	SpellPackCreateTrigger(DruidClaw_Rejuvenation,DruidClaw_Rejuvenation_f,pInt,'A06H')
	SpellPackCreateTrigger(DruidClaw_Roar,DruidClaw_Roar_f,pInt,'A06I')
	SpellPackCreateTrigger(DruidClaw_Earthward,DruidClaw_Earthward_f,pInt,'A06K')
	SpellPackCreateTrigger(DruidClaw_Guardian,DruidClaw_Guardian_f,pInt,'A06O')
	SpellPackCreateTrigger(DruidClaw_Seed,DruidClaw_Seed_f,pInt,'A06N')
	SpellPackCreateTrigger(DruidClaw_Maul,DruidClaw_Maul_f,pInt,'A06L')
	SpellPackCreateTrigger(DruidClaw_Thrash,DruidClaw_Thrash_f,pInt,'A06M')
	SpellPackCreateTrigger(DruidClaw_Form,DruidClaw_Form_f,pInt,'A06J')

end
