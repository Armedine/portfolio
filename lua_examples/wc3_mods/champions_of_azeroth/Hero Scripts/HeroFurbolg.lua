function FurbolgInit(unit, i)
	LUA_VAR_FURBOLGUNIT = unit
	FurbolgItemsInit(i)
	FurbolgAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNFurbolg.blp'
	LeaderboardUpdateHeroIcon(i)
end

function FurbolgItemsInit(pInt)

	LUA_VAR_FURBOLGITEMBOOL = {}

	-- raw code and descriptions
	local itemTable = {
		"I08J", -- 1 (Q) Lost Spirit Stone
		"I08Q", -- 2 (W) Potion of Fury
		"I08P", -- 3 (E) Bifurcated Ring
		"I08R", -- 4 (Trait) Cured Star Moss
		"I08K", -- 5 (Q) Fungal Spider Ring
		"I08S", -- 6 (W) Potion of Binding
		"I08O", -- 7 (E) Mending Rod
		"I08T", -- 8 (Trait) Cured Riverbud
		"I08L", -- 9 (Q) Tome of Shamanism
		"I08M", -- 10 (W) Tome of Conscription
		"I08N" -- 11 (E) Tome of Protection
	}
	local itemTableUlt = {
		"I08V", -- 12 (Q) Mark of the Druid
		"I08W", -- 13 (W) Mark of the Beast
		"I08X", -- 14 (E) Mark of the Defender
		"I08U", -- 15 (Trait) Mark of the Grizzly
		"I08Z", -- 16 (R1) Mark of the Brute
		"I08Y" -- 17 (R2) Mark of the Ursa
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I08L")) then IncUnitAbilityLevel(LUA_VAR_FURBOLGUNIT,FourCC("A06A"))
		elseif (itemId == FourCC("I08M")) then IncUnitAbilityLevel(LUA_VAR_FURBOLGUNIT,FourCC("A06C"))
		elseif (itemId == FourCC("I08N")) then IncUnitAbilityLevel(LUA_VAR_FURBOLGUNIT,FourCC("A06B"))
		elseif (itemId == FourCC("I08T")) then LUA_VAR_FURBOLGFRENZYMULT = 0.20
		elseif (itemId == FourCC("I08U")) then LUA_VAR_FURBOLGSPIRITDMG = 0.25 LUA_VAR_FURBOLGSPIRITDURATION = 8.0 end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,LUA_VAR_FURBOLGITEMBOOL,itemTableUlt)

end

function FurbolgAbilsInit(pInt)

	Furbolg_Frenzy = CreateTrigger()
	Furbolg_SpiritBash = CreateTrigger()
	Furbolg_Roar = CreateTrigger()
	Furbolg_Barkskin = CreateTrigger()
	Furbolg_Fury = CreateTrigger()
	Furbolg_Might = CreateTrigger()

	LUA_VAR_FURBOLGFRENZYHITS = 0
	LUA_VAR_FURBOLGFRENZYTARGET = 0
	LUA_VAR_FURBOLGFRENZYTIMER = NewTimer()
	LUA_VAR_FURBOLGSPIRITGROUP = CreateGroup()
	LUA_VAR_FURBOLGFURYACTIVE = false
	LUA_VAR_FURBOLGFURYATTACKS = 0
	LUA_VAR_FURBOLGFRENZYBONUSDMG = 0
	LUA_VAR_FURBOLGFRENZYMULT = 0.10
	LUA_VAR_FURBOLGSPIRITDMG = 0.20
	LUA_VAR_FURBOLGSPIRITDURATION = 6.0

	local Furbolg_Frenzy_f = function()

		LUA_VAR_FURBOLGFRENZYHITS = LUA_VAR_FURBOLGFRENZYHITS + 1
		ReleaseTimer(LUA_VAR_FURBOLGFRENZYTIMER)
		LUA_VAR_FURBOLGFRENZYTIMER = NewTimer()
		TimerStart(LUA_VAR_FURBOLGFRENZYTIMER,3.0,false,function()
			LUA_VAR_FURBOLGFRENZYTARGET = 0
			LUA_VAR_FURBOLGFRENZYHITS = 0
			LUA_VAR_FURBOLGFRENZYBONUSDMG = 0
			ReleaseTimer()
		end)

		-- additional hits checking stored target:
		if (LUA_VAR_FURBOLGFRENZYHITS > 1 and LUA_VAR_FURBOLGFRENZYTARGET == udg_DamageEventTarget) then
			-- only allow up to 100% bonus damage:
			if (LUA_VAR_FURBOLGFRENZYBONUSDMG < 1.0) then
				 -- starts on 2nd attack, so subtract first (LUA_VAR_FURBOLGFRENZYMULT):
				LUA_VAR_FURBOLGFRENZYBONUSDMG = LUA_VAR_FURBOLGFRENZYHITS*LUA_VAR_FURBOLGFRENZYMULT - LUA_VAR_FURBOLGFRENZYMULT
			elseif (LUA_VAR_FURBOLGITEMBOOL[8] and LUA_VAR_FURBOLGFRENZYBONUSDMG >= 1.0) then
				DamagePackageAddMana(udg_DamageEventSource,2.5,true)
			end
			UnitDamageTargetBJ(udg_DamageEventSource,udg_DamageEventTarget,udg_DamageEventAmount*LUA_VAR_FURBOLGFRENZYBONUSDMG,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)
		-- if first hit, start timer and set target:
		else
			LUA_VAR_FURBOLGFRENZYTARGET = udg_DamageEventTarget
			LUA_VAR_FURBOLGFRENZYHITS = 1
			LUA_VAR_FURBOLGFRENZYBONUSDMG = 0
		end
		-- if ult active, do effects:
		if (LUA_VAR_FURBOLGFURYACTIVE) then
			LUA_VAR_FURBOLGFURYATTACKS = LUA_VAR_FURBOLGFURYATTACKS + 1
			if (LUA_VAR_FURBOLGFURYATTACKS > 0 and math.fmod(LUA_VAR_FURBOLGFURYATTACKS,2) == 0) then
				Furbolg_CreateLingeringSpirit_f(GetUnitX(udg_DamageEventSource),GetUnitY(udg_DamageEventSource),GetOwningPlayer(udg_DamageEventSource))
			end
		end
		-- item effects:
		if (LUA_VAR_FURBOLGITEMBOOL[16]
		and UnitHasBuffBJ(udg_DamageEventSource,FourCC('B01O'))
		and IsUnitType(udg_DamageEventTarget,UNIT_TYPE_HERO)
		and not IsUnitType(udg_DamageEventTarget,UNIT_TYPE_ANCIENT)) then
			UnitDamageTargetBJ(udg_DamageEventSource,udg_DamageEventTarget,BlzGetUnitMaxHP(udg_DamageEventSource)*.025,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)
		end
		if (LUA_VAR_FURBOLGITEMBOOL[6] and UnitHasBuffBJ(udg_DamageEventSource,FourCC('B01P'))) then
			DamagePackageDummyTarget(udg_DamageEventSource,'A04B','slow',udg_DamageEventTarget)
		end
	end

	-- create a lingering spirit for the Furbolg at x,y
	Furbolg_CreateLingeringSpirit_f = function(x,y,player)
		math.randomseed( GetTimeOfDay()*10000000*bj_PI )
		local randomN = math.random(0, 100)
		local pInt = GetConvertedPlayerId(player)
		local dummy = DamagePackageCreateDummy(player, 'n01F', x+randomN, y+randomN, 270.0, LUA_VAR_FURBOLGSPIRITDURATION+0.15)
		SetUnitVertexColorBJ(dummy, 75, 75, 100, 40)
		SpellPackSetUnitStats(udg_playerHero[pInt],dummy,0,LUA_VAR_FURBOLGSPIRITDMG,nil)
		GroupAddUnit(LUA_VAR_FURBOLGSPIRITGROUP,dummy)
		TimerStart(NewTimer(),LUA_VAR_FURBOLGSPIRITDURATION,false,function() DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Orc\\FeralSpirit\\feralspiritdone.mdl',
			GetUnitX(dummy),GetUnitY(dummy))) RemoveUnit(dummy) GroupRemoveUnit(LUA_VAR_FURBOLGSPIRITGROUP,dummy) dummy = nil
			if (LUA_VAR_FURBOLGITEMBOOL[4]) then
				DamagePackageRestoreHealth(udg_playerHero[pInt],2.0,true,
				'Abilities\\Spells\\Orc\\FeralSpirit\\feralspiritdone.mdl',udg_playerHero[pInt]) end
			ReleaseTimer() end)
		DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Orc\\FeralSpirit\\feralspiritdone.mdl',GetUnitX(dummy),GetUnitY(dummy)))
	end

	local Furbolg_SpiritBash_f = function()
		local caster, tarX, tarY, target, casterX, casterY = SpellPackSetupTargetUnitAbil()
		local dmg = GetHeroStatBJ(bj_HEROSTAT_STR, caster, true)*1.25
		DestroyEffect(AddSpecialEffect('Abilities\\Weapons\\GreenDragonMissile\\GreenDragonMissile.mdl',tarX,tarY))
		UnitDamageTargetBJ(caster,target,dmg,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)
		if (LUA_VAR_FURBOLGITEMBOOL[12]) then
			local endloop = 2
			-- if forest creature, triple the item bonus:
			if (GetOwningPlayer(target) == Player(24)) then
				endloop = endloop + 2
			end
			for i = 1,endloop do
				Furbolg_CreateLingeringSpirit_f(casterX,casterY,GetOwningPlayer(caster))
			end
		else
			Furbolg_CreateLingeringSpirit_f(casterX,casterY,GetOwningPlayer(caster))
		end
		if (LUA_VAR_FURBOLGITEMBOOL[1] and GetWidgetLife(target) < 0.41) then
			for i = 1,2 do
				Furbolg_CreateLingeringSpirit_f(casterX,casterY,GetOwningPlayer(caster))
			end
		end
		if (LUA_VAR_FURBOLGITEMBOOL[5] and GetUnitLifePercent(caster) < 50.0) then
			DamagePackageRestoreHealth(caster,8.0,true,'Abilities\\Spells\\Orc\\FeralSpirit\\feralspiritdone.mdl',caster)
		end
		GroupActionAttackUnit(LUA_VAR_FURBOLGSPIRITGROUP,target)
	end

	local Furbolg_Roar_f = function()
		local caster, casterX, casterY = SpellPackSetupInstantAbil()
		Furbolg_CreateLingeringSpirit_f(casterX,casterY,GetOwningPlayer(caster))
		DamagePackageDealAOE(caster, casterX, casterY, 600.0, 0.0, false, true, 'A009', 'slow', '', 1.0)
		if (LUA_VAR_FURBOLGITEMBOOL[2]) then
			DamagePackageDummyTarget(caster,'A045','bloodlust')
		end
		if (LUA_VAR_FURBOLGITEMBOOL[13]) then
			BlzEndUnitAbilityCooldown( caster, FourCC('A06A') )
			BlzEndUnitAbilityCooldown( caster, FourCC('A06B') )
		end
	end

	local Furbolg_Barkskin_f = function()
		local caster, tarX, tarY, target, casterX, casterY = SpellPackSetupTargetUnitAbil()
		Furbolg_CreateLingeringSpirit_f(tarX,tarY,GetOwningPlayer(caster))
		if (LUA_VAR_FURBOLGITEMBOOL[7]) then
			DamagePackageRestoreHealth(target,10.0,true,'Abilities\\Spells\\Orc\\FeralSpirit\\feralspiritdone.mdl',caster)
		end
		if (LUA_VAR_FURBOLGITEMBOOL[3] and caster ~= target) then
			DamagePackageDummyTarget(caster,'A06B','innerfire')
		end
		if (LUA_VAR_FURBOLGITEMBOOL[14] and caster ~= target) then
			local i = 0
			TimerStart(NewTimer(),1.0,true,function()
				DamagePackageAddMana(target,2.5,true)
				i = i + 1
				if (i == 6 or not IsUnitAliveBJ(target)) then
					ReleaseTimer()
				end
			end)
		end
		GroupActionRemoveDead(LUA_VAR_FURBOLGSPIRITGROUP) -- occasional just-in-case cleansing
	end

	local Furbolg_Fury_f = function()
		DamagePackageDummyTarget(GetTriggerUnit(),'A06F','bloodlust')
		LUA_VAR_FURBOLGFURYATTACKS = 0
		LUA_VAR_FURBOLGFURYACTIVE = true
		TimerStart(NewTimer(),12.0,false,function()
			LUA_VAR_FURBOLGFURYACTIVE = false
		end)
	end

	local Furbolg_Might_f = function()
		local caster, tarX, tarY, target, casterX, casterY = SpellPackSetupTargetUnitAbil()
		local dmg
		DestroyEffect(AddSpecialEffect('Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl',tarX,tarY))
		for i = 1,3 do
			Furbolg_CreateLingeringSpirit_f(casterX,casterY,GetOwningPlayer(caster))
		end
		BasicKnockback(target, AngleBetweenPointsXY(casterX, casterY, tarX, tarY), 200.0, false, 0.25, nil, nil)
		if (LUA_VAR_FURBOLGITEMBOOL[17]) then
			DamagePackageDummyTarget(caster,'A06G','thunderbolt',target)
			dmg = GetHeroStatBJ(bj_HEROSTAT_STR, caster, true)*2.5
		else
			DamagePackageDummyTarget(caster,'A03H','thunderbolt',target)
			dmg = GetHeroStatBJ(bj_HEROSTAT_STR, caster, true)*2.0
		end
		UnitDamageTargetBJ(caster,target,dmg,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)
	end

	local frenzy_boolexpr = function() return udg_DamageEventAttackT == udg_ATTACK_TYPE_HERO and udg_DamageEventSource == udg_playerHero[pInt] end

	SpellPackCreateDamageTrigger(Furbolg_Frenzy,Furbolg_Frenzy_f,pInt,frenzy_boolexpr,nil)
	SpellPackCreateTrigger(Furbolg_SpiritBash,Furbolg_SpiritBash_f,pInt,'A06A')
	SpellPackCreateTrigger(Furbolg_Roar,Furbolg_Roar_f,pInt,'A06C')
	SpellPackCreateTrigger(Furbolg_Barkskin,Furbolg_Barkskin_f,pInt,'A06B')
	SpellPackCreateTrigger(Furbolg_Fury,Furbolg_Fury_f,pInt,'A06E')
	SpellPackCreateTrigger(Furbolg_Might,Furbolg_Might_f,pInt,'A06D')

end
