function SpiritWalkerInit(unit, i)
	LUA_VAR_SPIRITWALKER_UNIT = unit
	LUA_VAR_SPIRITWALKER_ITEMBOOL = {}
	SpiritWalkerItemsInit(i)
	SpiritWalkerAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNSpiritWalker.blp'
	LeaderboardUpdateHeroIcon(i)
end

function SpiritWalkerItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I09H", -- 1 (Q) Bottled Spirits
		"I09I", -- 2 (W) Radiant Mana Gem
		"I09J", -- 3 (E) Spirit Treads
		"I09K", -- 4 (Trait) Conduction Pipe
		"I09L", -- 5 (Q) Wand of a Protection
		"I09P", -- 6 (W) Key of Vitality
		"I09Q", -- 7 (E) Ancestral Chopper
		"I09W", -- 8 (Trait) Energized Herbs
		"I09M", -- 9 (Q) Amulet of Mending
		"I09N", -- 10 (W) Glyph of Vitality
		"I09O" -- 11 (E) Ancestral Charm
	}
	local itemTableUlt = {
		"I09S", -- 12 (Q) Cairne's Echoing Medallion
		"I09X", -- 13 (W) Cairne's Triumphant Will
		"I09R", -- 14 (E) Cairne's Ancestral Pendant
		"I09T", -- 15 (Trait) Cairne's Enchanted Bulwark
		"I09V", -- 16 (R1) Cairne's Shattered Totem
		"I09U" -- 17 (R2) Cairne's Imbued Tramplers
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I09K")) then IncUnitAbilityLevel(LUA_VAR_SPIRITWALKER_UNIT,FourCC("A06P"))
		elseif (itemId == FourCC("I09M")) then IncUnitAbilityLevel(LUA_VAR_SPIRITWALKER_UNIT,FourCC("A06R"))
		elseif (itemId == FourCC("I09N")) then IncUnitAbilityLevel(LUA_VAR_SPIRITWALKER_UNIT,FourCC("A06Q"))
		elseif (itemId == FourCC("I09O")) then IncUnitAbilityLevel(LUA_VAR_SPIRITWALKER_UNIT,FourCC("A06S"))
		elseif (itemId == FourCC("I09T")) then
			HeroAddStatTimer(LUA_VAR_SPIRITWALKER_UNIT, 0, 1, 45.0, 7)
			HeroAddStatTimer(LUA_VAR_SPIRITWALKER_UNIT, 2, 1, 45.0, 7)
		end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,LUA_VAR_SPIRITWALKER_ITEMBOOL,itemTableUlt)

end

function SpiritWalkerAbilsInit(pInt)

	SpiritWalker_Link = CreateTrigger()
	SpiritWalker_Mend = CreateTrigger()
	SpiritWalker_Shield = CreateTrigger()
	SpiritWalker_Binding = CreateTrigger()
	SpiritWalker_Vigor = CreateTrigger()
	SpiritWalker_Stomp = CreateTrigger()
	SpiritWalker_Shield_Listener = CreateTrigger()

	LUA_VAR_SPIRITWALKER_SHIELD_TIMER = NewTimer()
	LUA_VAR_SPIRITWALKER_SHIELD_AMOUNT = 0

	local SpiritWalker_Link_f = function ()
		local caster = GetTriggerUnit()
		if (LUA_VAR_SPIRITWALKER_ITEMBOOL[8] and GetUnitLifePercent(caster) > 75.0) then
			DamagePackageAddMana(caster,50,false)
		end
	end

	local SpiritWalker_Mend_f = function()
		local caster = GetTriggerUnit()
		local target = GetSpellTargetUnit()
		local healing = GetHeroStatBJ(bj_HEROSTAT_INT, caster, true)*2.25
		if (LUA_VAR_SPIRITWALKER_ITEMBOOL[1]) then
			local g = CreateGroup()
			GroupEnumUnitsInRange(g,GetUnitX(caster),GetUnitY(caster),600.0,Filter(function() return
				UnitHasBuffBJ(GetFilterUnit(),FourCC('Bspl'))
				and IsUnitAlly(GetFilterUnit(),GetOwningPlayer(caster)) end) )
			local size = BlzGroupGetSize(g)
			if (size > 0) then
				healing = healing*(1 + size*0.1)
			end
			DestroyGroup(g)
		end
		DamagePackageRestoreHealth(target,healing,false,nil,caster)
		if (LUA_VAR_SPIRITWALKER_ITEMBOOL[12] and caster ~= target) then
			DamagePackageRestoreHealth(caster,healing,false,nil,caster)
		end
		if (LUA_VAR_SPIRITWALKER_ITEMBOOL[5]) then
			DamagePackageDummyTarget(caster,'A00O','innerfire')
		end
		DamagePackageDummyTarget(caster,'A06P','spiritlink',target)
	end

	local SpiritWalker_Shield_Listener_f = function()
		LUA_VAR_SPIRITWALKER_SHIELD_AMOUNT = LUA_VAR_SPIRITWALKER_SHIELD_AMOUNT - udg_DamageEventAmount
		if (LUA_VAR_SPIRITWALKER_SHIELD_AMOUNT > 0.0 and IsUnitAliveBJ(LUA_VAR_SPIRITWALKER_UNIT)) then
			mvp.IncrementAbsorbed(GetConvertedPlayerId(GetOwningPlayer(LUA_VAR_SPIRITWALKER_UNIT)), udg_DamageEventAmount)
			udg_DamageEventAmount = 0.0
			ArcingTextTag( "|cff00b1ffAbsorbed|r", udg_DamageEventTarget)
			if (LUA_VAR_SPIRITWALKER_ITEMBOOL[2]) then
				DamagePackageAddMana(LUA_VAR_SPIRITWALKER_UNIT,5,false)
			end
		elseif (not IsUnitAliveBJ(LUA_VAR_SPIRITWALKER_UNIT)) then
			DisableTrigger(SpiritWalker_Shield_Listener)
		else
			udg_DamageEventAmount = math.abs(LUA_VAR_SPIRITWALKER_SHIELD_AMOUNT)
			UnitRemoveBuffBJ( FourCC('B01T'), LUA_VAR_SPIRITWALKER_UNIT )
			DisableTrigger(SpiritWalker_Shield_Listener)
		end
	end

	local SpiritWalker_Shield_f = function()
		local caster = GetTriggerUnit()
		local dur = 6.0
		LUA_VAR_SPIRITWALKER_SHIELD_AMOUNT = GetHeroStatBJ(bj_HEROSTAT_INT, caster, true)*5.0
		if (LUA_VAR_SPIRITWALKER_ITEMBOOL[6]) then
			LUA_VAR_SPIRITWALKER_SHIELD_AMOUNT = LUA_VAR_SPIRITWALKER_SHIELD_AMOUNT*1.4
		end
		EnableTrigger(SpiritWalker_Shield_Listener)
		if (LUA_VAR_SPIRITWALKER_SHIELD_TIMER ~= nil) then ReleaseTimer(LUA_VAR_SPIRITWALKER_SHIELD_TIMER) end
		LUA_VAR_SPIRITWALKER_SHIELD_TIMER = NewTimer()
		TimerStart(LUA_VAR_SPIRITWALKER_SHIELD_TIMER,dur,false,function()
			DisableTrigger(SpiritWalker_Shield_Listener)
		end)
		if (LUA_VAR_SPIRITWALKER_ITEMBOOL[13]) then
			LUA_VAR_SPIRITWALKER_SHIELD_AMOUNT = LUA_VAR_SPIRITWALKER_SHIELD_AMOUNT*1.1
			local g = CreateGroup()
			GroupEnumUnitsInRange(g,GetUnitX(caster),GetUnitY(caster),600.0, Filter(function()
				if (IsUnitAlly(GetFilterUnit(),GetOwningPlayer(caster))
						and IsUnitAliveBJ(GetFilterUnit())
						and UnitHasBuffBJ(GetFilterUnit(),FourCC('Bspl'))) then
					DamagePackageRestoreHealth(GetFilterUnit(),10,true,nil,caster)
				end
				return false
			end ) )
			DestroyGroup(g)
		end
		
	end

	local SpiritWalker_Binding_f = function()
		local caster = GetTriggerUnit()
		local target = GetSpellTargetUnit()
		local dur = 3.0
		local dummyUnit = DamagePackageCreateDummy(GetOwningPlayer(caster), 'o01E', GetUnitX(caster), GetUnitY(caster), GetUnitFacing(caster), dur+0.21)
		local dmg = GetHeroStatBJ(bj_HEROSTAT_INT, caster, true)*1.75
		if (LUA_VAR_SPIRITWALKER_ITEMBOOL[14]) then
			dur = dur + 2.0
			dmg = dmg*1.3
		end
		local i = dur/0.2
		if (LUA_VAR_SPIRITWALKER_ITEMBOOL[3]) then
			SetUnitMoveSpeed(dummyUnit,225.0)
		end
		SetUnitVertexColorBJ(dummyUnit, 45, 45, 100, 50)
		TimerStart(NewTimer(),0.2,true,function()
			i = i - 1
			IssuePointOrder(dummyUnit,'move',GetUnitX(target),GetUnitY(target))
			if (i <= 0 or not IsUnitAliveBJ(target)) then
				DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Other\\Charm\\CharmTarget.mdl',GetUnitX(dummyUnit),GetUnitY(dummyUnit)))
				RemoveUnit(dummyUnit)
				ReleaseTimer()
			elseif (DistanceBetweenXY(GetUnitX(target),GetUnitY(target),GetUnitX(dummyUnit),GetUnitY(dummyUnit)) < 125.0) then
				if (LUA_VAR_SPIRITWALKER_ITEMBOOL[7]) then
					dmg = dmg*(1 + ((math.abs(i - dur/0.2)*0.2)*0.15))
				end
				UnitDamageTargetBJ(caster,target,dmg,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)
				DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl',GetUnitX(target),GetUnitY(target)))
				DamagePackageDummyTarget(caster,'A06V','ensnare',target)
				if (LUA_VAR_SPIRITWALKER_ITEMBOOL[3]) then
					DamagePackageDummyTarget(caster,'A029','bloodlust')
				end
				RemoveUnit(dummyUnit)
				ReleaseTimer()
			end
		end)
	end

	local SpiritWalker_Vigor_f = function()
		local caster = GetTriggerUnit()
		local dmg = GetHeroStatBJ(bj_HEROSTAT_INT, caster, true)*3.5
		local radius = 1000.0
		if (LUA_VAR_SPIRITWALKER_ITEMBOOL[16]) then
			dmg = dmg*1.3
			radius = radius*1.5
			DestroyEffect(AddSpecialEffect('Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl',GetUnitX(caster),GetUnitY(caster)))
		end
		local g = CreateGroup()
		GroupEnumUnitsInRange(g,GetUnitX(caster),GetUnitY(caster),radius, Filter(function() return
			IsUnitAlly(GetFilterUnit(),GetOwningPlayer(caster))
			and IsUnitAliveBJ(GetFilterUnit())
			and IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO) end ) )
		GroupUtilsAction(g,function()
			DamagePackageRestoreHealth(LUA_FILTERUNIT,dmg,false,
				'Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl',caster)
			DestroyEffect(AddSpecialEffect('Abilities\\Weapons\\Bolt\\BoltImpact.mdl',GetUnitX(LUA_FILTERUNIT),GetUnitY(LUA_FILTERUNIT)))
			DamagePackageDummyTarget(LUA_VAR_SPIRITWALKER_UNIT,'A05E','bloodlust',LUA_FILTERUNIT)
			DamagePackageDummyTarget(LUA_VAR_SPIRITWALKER_UNIT,'A06P','spiritlink',LUA_FILTERUNIT)
		end)
		DestroyGroup(g)
	end

	local SpiritWalker_Stomp_f = function()
		local caster = GetTriggerUnit()
		local dmg = GetHeroStatBJ(bj_HEROSTAT_INT, caster, true)*2.5
		local distance = 300.0
		if (LUA_VAR_SPIRITWALKER_ITEMBOOL[17]) then distance = distance + 100.0 end
		DamagePackageDealAOE(caster, GetUnitX(caster), GetUnitY(caster),
			300.0, dmg, false, false, '', '', 'Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl', 0.8)
		local collisionFunc = function(id)
			DamagePackageDummyTarget(LUA_KB_DATA[id].unit,'A04B','slow')
			DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl',GetUnitX(LUA_KB_DATA[id].unit),GetUnitY(LUA_KB_DATA[id].unit)))
			if (LUA_VAR_SPIRITWALKER_ITEMBOOL[17]) then
				DamagePackageDummyTarget(LUA_KB_DATA[id].unit,'A04O','thunderbolt')
				UnitDamageTargetBJ(caster,LUA_KB_DATA[id].unit,dmg*0.5,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)
			end
		end

		BasicKnockbackAreaPoint(caster,GetUnitX(caster),GetUnitY(caster),true,300.0,distance,false,0.33,collisionFunc,nil,nil)
	end

	local cond = function() return
		UnitHasBuffBJ(udg_DamageEventTarget,FourCC('Bspl'))
		and IsUnitAlly(udg_DamageEventTarget,GetOwningPlayer(LUA_VAR_SPIRITWALKER_UNIT))
	end

	SpellPackCreateDamageTrigger(SpiritWalker_Shield_Listener,SpiritWalker_Shield_Listener_f,1,cond,"udg_DamageModifierEvent")
	SpellPackCreateTrigger(SpiritWalker_Mend,SpiritWalker_Mend_f,pInt,'A06R')
	SpellPackCreateTrigger(SpiritWalker_Shield,SpiritWalker_Shield_f,pInt,'A06Q')
	SpellPackCreateTrigger(SpiritWalker_Binding,SpiritWalker_Binding_f,pInt,'A06S')
	SpellPackCreateTrigger(SpiritWalker_Vigor,SpiritWalker_Vigor_f,pInt,'A06T',EVENT_PLAYER_UNIT_SPELL_FINISH)
	SpellPackCreateTrigger(SpiritWalker_Stomp,SpiritWalker_Stomp_f,pInt,'A06U')
	SpellPackCreateTrigger(SpiritWalker_Link,SpiritWalker_Link_f,pInt,'A06P')

	DisableTrigger(SpiritWalker_Shield_Listener)

end
