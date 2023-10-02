function HeadhunterInit(unit, i)
	LUA_VAR_HEADHUNTER_UNIT = unit
	LUA_VAR_HEADHUNTER_ITEMBOOL = {}
	HeadhunterItemsInit(i)
	HeadhunterAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNHeadhunter.blp'
	LeaderboardUpdateHeroIcon(i)
end

function HeadhunterItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I09Y", -- 1 (Q) Absorption Stone
		"I0A1", -- 2 (W) Jammin' Health Manual
		"I0A4", -- 3 (E) Bear Trap
		"I0A7", -- 4 (Trait) Hexing Elixir
		"I09Z", -- 5 (Q) Feathered Javelin
		"I0A2", -- 6 (W) Jungle Stompers
		"I0A5", -- 7 (E) Vial of Fiery Voodoo
		"I0A8", -- 8 (Trait) Trinket of Zandalar
		"I0A0", -- 9 (Q) Explosive Tip
		"I0A3", -- 10 (W) Bottled Mojo
		"I0A6" -- 11 (E) Trap Launcher
	}
	local itemTableUlt = {
		"I0A9", -- 12 (Q) Gonk's Piercing Talon
		"I0AA", -- 13 (W) Akunda's Voltaic Grasp
		"I0AB", -- 14 (E) Krag'wa's Hexing Maw
		"I0AC", -- 15 (Trait) Bwonsamdi's Devilish Pact
		"I0AD", -- 16 (R1) Jani's Poaching Treasure
		"I0AE" -- 17 (R2) Shadra's Venomous Spline
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if itemId == FourCC("I0A6") then IncUnitAbilityLevel(LUA_VAR_HEADHUNTER_UNIT,FourCC("A06X"))
		elseif itemId == FourCC("I0A3") then IncUnitAbilityLevel(LUA_VAR_HEADHUNTER_UNIT,FourCC("A06Y"))

		elseif itemId == FourCC("I0A7") then
			LUA_VAR_HEADHUNTER_ATK = 0
			local func = function()
				LUA_VAR_HEADHUNTER_ATK = LUA_VAR_HEADHUNTER_ATK + 1
				if LUA_VAR_HEADHUNTER_ATK >= 3 then
					local dmg = GetHeroStatBJ(bj_HEROSTAT_AGI, udg_DamageEventSource, true)*0.50
					UnitDamageTargetBJ(udg_DamageEventSource, udg_DamageEventTarget, dmg, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL)
					DamagePackageDummyTarget(udg_DamageEventSource,'A074','hex',udg_DamageEventTarget)
					LUA_VAR_HEADHUNTER_ATK = 0
				end
			end
			trig = CreateTrigger()
			local cond = function() return
				udg_DamageEventSource == udg_playerHero[pInt]
				and udg_DamageEventAttackT == udg_ATTACK_TYPE_HERO
				and not udg_IsDamageSpell
			end
			SpellPackCreateDamageTrigger(trig,func,pInt,cond,"udg_DamageEvent")

		elseif itemId == FourCC("I0AA") then
			LUA_VAR_HEADHUNTER_ATK2 = 0
			local func = function()
				LUA_VAR_HEADHUNTER_ATK2 = LUA_VAR_HEADHUNTER_ATK2 + 1
				if LUA_VAR_HEADHUNTER_ATK2 >= 4 then
					local dmg = GetHeroStatBJ(bj_HEROSTAT_AGI, udg_DamageEventSource, true)*1.25
					UnitDamageTargetBJ(udg_DamageEventSource, udg_DamageEventTarget, dmg, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL)
					DamagePackageDummyTarget(udg_DamageEventSource,'A04B','slow',udg_DamageEventTarget)
					SpellPackLightningEffect(udg_DamageEventSource,nil,nil,udg_DamageEventTarget)
					LUA_VAR_HEADHUNTER_ATK2 = 0
				end
			end
			trig = CreateTrigger()
			local cond = function() return
				udg_DamageEventSource == udg_playerHero[pInt]
				and udg_DamageEventAttackT == udg_ATTACK_TYPE_HERO
				and not udg_IsDamageSpell
			end
			SpellPackCreateDamageTrigger(trig,func,pInt,cond,"udg_DamageEvent")

		elseif itemId == FourCC("I0AC") then HeroAddStat(udg_playerHero[pInt], 1, LUA_VAR_HEADHUNTER_TROPHY_GAINED)
				DestroyEffect(AddSpecialEffect('Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl',
					GetUnitX(udg_playerHero[pInt]), GetUnitY(udg_playerHero[pInt])))
				LUA_VAR_HEADHUNTER_PACT_GAINED = 0.0 + LUA_VAR_HEADHUNTER_TROPHY_GAINED
		end
	end
	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,LUA_VAR_HEADHUNTER_ITEMBOOL,itemTableUlt)

end

function HeadhunterAbilsInit(pInt)

	Headhunter_Trophy 	= CreateTrigger()
	Headhunter_Javelin 	= CreateTrigger()
	Headhunter_Regen 	= CreateTrigger()
	Headhunter_Trap 	= CreateTrigger()
	Headhunter_Track 	= CreateTrigger()
	Headhunter_Venom 	= CreateTrigger()

	LUA_VAR_HEADHUNTER_TROPHY_COUNT 	= 0.0
	LUA_VAR_HEADHUNTER_TROPHY_GAINED 	= 0.0

	TriggerRegisterAnyUnitEventBJ(Headhunter_Trophy, EVENT_PLAYER_UNIT_DEATH)
	TriggerAddCondition(Headhunter_Trophy, Filter( function() return
		IsUnitEnemy(GetTriggerUnit(), GetOwningPlayer(udg_playerHero[pInt]))
		and (GetOwningPlayer(GetTriggerUnit()) == Player(24) or IsUnitType(GetTriggerUnit(),UNIT_TYPE_HERO))
		and not IsUnitType(GetTriggerUnit(),UNIT_TYPE_ANCIENT)
		and IsUnitAliveBJ(udg_playerHero[pInt])
		and DistanceBetweenXY(GetUnitX(udg_playerHero[pInt]),GetUnitY(udg_playerHero[pInt]),
			GetUnitX(GetTriggerUnit()),GetUnitY(GetTriggerUnit())) <= 1000.0 end ) )
	TriggerAddAction(Headhunter_Trophy, function()
		if GetOwningPlayer(GetTriggerUnit()) == Player(24) and GetUnitLevel(GetTriggerUnit()) > 4 then
			LUA_VAR_HEADHUNTER_TROPHY_COUNT = LUA_VAR_HEADHUNTER_TROPHY_COUNT + 0.25
		elseif IsUnitType(GetTriggerUnit(),UNIT_TYPE_HERO) then
			LUA_VAR_HEADHUNTER_TROPHY_COUNT = LUA_VAR_HEADHUNTER_TROPHY_COUNT + 0.50
		end
		if LUA_VAR_HEADHUNTER_TROPHY_COUNT >= 1.0 then
			DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Items\\AIam\\AIamTarget.mdl',
				GetUnitX(udg_playerHero[pInt]), GetUnitY(udg_playerHero[pInt])))
			HeroAddStat(udg_playerHero[pInt], 1, 1.0)
			if LUA_VAR_HEADHUNTER_ITEMBOOL[8] then HeroAddStat(udg_playerHero[pInt], 0, 1.0) end -- Zandalar Trinket
			LUA_VAR_HEADHUNTER_TROPHY_COUNT = LUA_VAR_HEADHUNTER_TROPHY_COUNT - 1.0
			LUA_VAR_HEADHUNTER_TROPHY_GAINED = LUA_VAR_HEADHUNTER_TROPHY_GAINED + 1.0
			if LUA_VAR_HEADHUNTER_ITEMBOOL[15] then -- Bwonsamdi
				HeroAddStat(udg_playerHero[pInt], 1, 1.0)
				DestroyEffect(AddSpecialEffect('Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl',
					GetUnitX(udg_playerHero[pInt]), GetUnitY(udg_playerHero[pInt])))
				LUA_VAR_HEADHUNTER_PACT_GAINED = LUA_VAR_HEADHUNTER_PACT_GAINED + 1.0
				if LUA_VAR_HEADHUNTER_PACT_TMR then ReleaseTimer(LUA_VAR_HEADHUNTER_PACT_TMR) end
				LUA_VAR_HEADHUNTER_PACT_TMR = NewTimer()
				TimerStart(LUA_VAR_HEADHUNTER_PACT_TMR,120.0,false,function()
					HeroRemoveStat(udg_playerHero[pInt], 1, LUA_VAR_HEADHUNTER_PACT_GAINED)
					LUA_VAR_HEADHUNTER_PACT_GAINED = 0.0
					SpellPackInvalidMsg(caster,'Bwonsamdi is displeased.')
					DestroyEffect(AddSpecialEffect('Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl',
						GetUnitX(udg_playerHero[pInt]), GetUnitY(udg_playerHero[pInt])))
				end)
			end
		end
	end)


	local Headhunter_Javelin_f = function()
		local caster, tarX, tarY, casterX, casterY = SpellPackSetupTargetAbil()
		local dmg 		 = GetHeroStatBJ(bj_HEROSTAT_AGI, caster, true)*2.0
		local range 	 = 1000.0
		local strMis 	 = 'abilities\\weapons\\huntermissile\\huntermissile.mdl'
		local strDmg 	 = 'Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl'
		local pierceBool = true
		if LUA_VAR_HEADHUNTER_ITEMBOOL[5] then dmg = dmg*1.1 range = range*1.1 end
		if LUA_VAR_HEADHUNTER_ITEMBOOL[12] then pierceBool = false end
		LUA_VAR_HEADHUNTER_JAV_EXP = false
		local func = function(u, o)
			if IsUnitType(u,UNIT_TYPE_HERO) and DistanceBetweenXY(casterX, casterY, GetUnitX(u), GetUnitY(u)) >= 500.0
				and not IsUnitType(u,UNIT_TYPE_ANCIENT) then
				BlzEndUnitAbilityCooldown(caster,FourCC('A032'))
				DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl',GetUnitX(caster), GetUnitY(caster)))
				if LUA_VAR_HEADHUNTER_ITEMBOOL[1] then DamagePackageAddMana(caster,40.0,false) end
			end
			if LUA_VAR_HEADHUNTER_ITEMBOOL[9] and not LUA_VAR_HEADHUNTER_JAV_EXP and GetConvertedPlayerId(GetOwningPlayer(u)) > 10 then
				LUA_VAR_HEADHUNTER_JAV_EXP = true -- only allow one explosion per use (when piercing)
				DamagePackageDealAOE(caster, GetUnitX(u), GetUnitY(u), 275.0, dmg*0.50, false, false,
					'', '', 'Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl', 0.75)
				DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl',GetUnitX(u), GetUnitY(u)))
			end
		end
		LuaMissile.create(caster, tarX, tarY, range, 1.5, dmg, 65.0, pierceBool, false, false,nil,func,strMis,strDmg,60.0,1.0,nil,nil,nil)
	end

	local Headhunter_Regen_f = function()
		local caster 	= GetTriggerUnit()
		local healing 	= 15.0 -- %
		local dur 		= 6.0
		local g 		= CreateGroup()
		GroupEnumUnitsInRange(g, GetUnitX(caster), GetUnitY(caster), 1600.0, Condition(function() return
			IsUnitAliveBJ(GetFilterUnit())
			and IsUnitEnemy(GetFilterUnit(),GetOwningPlayer(caster))
			and IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO) end ))
		local size = BlzGroupGetSize(g) or 0
		if size < 1 then
			healing = healing*2.0
			if LUA_VAR_HEADHUNTER_ITEMBOOL[2] then DamagePackageAddMana(caster,25,false) end
		end
		healing = healing/dur
		DestroyGroup(g)
		TimerStart(NewTimer(),1.0,true,function()
			dur = dur - 1
			DamagePackageRestoreHealth(caster, healing, true, 'Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl',caster)
			if dur <= 0 then ReleaseTimer() end
		end)
		if LUA_VAR_HEADHUNTER_ITEMBOOL[6] then DamagePackageDummyTarget(caster,'A05E','bloodlust') end
	end

	local Headhunter_Trap_f = function()
		local caster, tarX, tarY, casterX, casterY = SpellPackSetupTargetAbil()
		if not IsUnitType(caster,UNIT_TYPE_HERO) then caster = udg_playerHero[pInt] end -- since traps can be placed by dummies
		local dur 	 	= 90.0
		local armTime 	= 3.0
		local dmg 		= GetHeroStatBJ(bj_HEROSTAT_AGI, caster, true)*2.25 
		local trap 		= DamagePackageCreateDummy(GetOwningPlayer(caster),'e00U', tarX, tarY, 270.0, dur)
		local trig 		= CreateTrigger()
		if LUA_VAR_HEADHUNTER_ITEMBOOL[11] then armTime = armTime - 1.5 end
		if LUA_VAR_HEADHUNTER_ITEMBOOL[3] then dur = dur + 30 dmg = dmg*1.20 end
		SetUnitVertexColorBJ(trap, 100, 10, 10, 60)
		TimerStart(NewTimer(),armTime,false,function()
			SetUnitVertexColorBJ(trap, 100, 100, 100, 0)
			DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Orc\\FeralSpirit\\feralspiritdone.mdl',GetUnitX(trap), GetUnitY(trap)))
			TriggerRegisterUnitInRangeSimple( trig, 200.0, trap )
			TriggerAddCondition(trig, Filter( function() return
				(IsUnitEnemy(GetTriggerUnit(),GetOwningPlayer(caster)) or GetOwningPlayer(GetTriggerUnit()) == Player(24))
				and not IsUnitType(GetTriggerUnit(),UNIT_TYPE_DEAD)
				and not IsUnitType(GetTriggerUnit(),UNIT_TYPE_MAGIC_IMMUNE)
				and not IsUnitType(GetTriggerUnit(),UNIT_TYPE_ANCIENT) end ) )
			local tmr = NewTimer()
			TimerStart(tmr,dur,false,function() if trig then DestroyTrigger(trig) end ReleaseTimer() end)
			TriggerAddAction(trig, function()
				if IsUnitAliveBJ(trap) then
					local u = GetTriggerUnit()
					if GetOwningPlayer(GetTriggerUnit()) == Player(24) then
						dmg = dmg *1.25
					end
					TimerStart(NewTimer(),3.0,false,function() DamagePackageDummyTarget(caster,'A073','faeriefire',u) ReleaseTimer() end)
					if LUA_VAR_HEADHUNTER_ITEMBOOL[7] then
						DamagePackageDealAOE(caster, GetUnitX(trap), GetUnitY(trap), 250.0, dmg, false, false,
							'', '', 'Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl', 0.75)
						DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl',GetUnitX(trap), GetUnitY(trap)))
					else
						UnitDamageTargetBJ(caster,u,dmg, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL)
					end
					if LUA_VAR_HEADHUNTER_ITEMBOOL[14] then -- Krag'wa
						DamagePackageDummyTarget(caster,'A076','hex',u)
					else -- default root
						DamagePackageDummyTarget(caster,'A072','ensnare',u)
					end
					ReleaseTimer(tmr)
					if IsUnitType(u,UNIT_TYPE_HERO) then
						DisplayTimedTextToPlayer(GetOwningPlayer(caster), 0, 0, 2.0,
							'|cffffc800Trap activated by|r ' .. GetPlayerName(GetOwningPlayer(u)) .. '|cffffc800!|r')
						PingMinimapForPlayer(GetOwningPlayer(caster), GetUnitX(trap), GetUnitY(trap), 3.0)
					end
					DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdl',GetUnitX(u), GetUnitY(u)))
					KillUnit(trap)
				end
				DestroyTrigger(GetTriggeringTrigger())
			end)
			ReleaseTimer()
		end)
	end

	local Headhunter_Track_f = function()
		local caster, casterX, casterY = SpellPackSetupInstantAbil()
		local g = CreateGroup()
		local destroyDur = 6.0
		local p = GetOwningPlayer(caster)
		GroupEnumUnitsInRange(g, GetUnitX(caster), GetUnitY(caster), 1600.0, Condition(function() return
					IsUnitAliveBJ(GetFilterUnit())
					and IsUnitEnemy(GetFilterUnit(),p)
					and IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO)
					and not IsUnitType(GetFilterUnit(),UNIT_TYPE_ANCIENT) end ))
		local size = BlzGroupGetSize(g) or 0
		if size > 0 then
			local trackUnit = BlzGroupUnitAt(g,0)
			GroupUtilsAction(g,function()
				if GetUnitLifePercent(LUA_FILTERUNIT) < GetUnitLifePercent(trackUnit) then
					trackUnit = LUA_FILTERUNIT
				end
				if LUA_VAR_HEADHUNTER_ITEMBOOL[16] then -- Jani
					DamagePackageDummyAoE(caster, 'A06X', 'stasistrap', nil, GetUnitX(LUA_FILTERUNIT), GetUnitY(LUA_FILTERUNIT),
						GetUnitX(LUA_FILTERUNIT), GetUnitY(LUA_FILTERUNIT), nil)
				end
			end)
			DamagePackageDummyTarget(caster,'A05G','bloodlust')
			DisplayTimedTextToForce(GetPlayersAll(), 2.0,
				GetPlayerName(p) .. ' |cffffc800is tracking|r ' .. GetPlayerName(GetOwningPlayer(trackUnit)))
			PingMinimapForPlayer(p, GetUnitX(trackUnit), GetUnitY(trackUnit), 3.0)
			CreateMinimapIconOnUnitBJ(trackUnit, 255, 255, 90, 'UI\\Minimap\\Minimap-QuestObjectiveBonus.mdl', FOG_OF_WAR_MASKED)
			local icon = GetLastCreatedMinimapIcon()
			SetMinimapIconOrphanDestroy( icon, true )
			UnitShareVisionBJ( true, trackUnit, p )
			DamagePackageDummyTarget(caster,'A073','faeriefire',trackUnit)
			if GetUnitLifePercent(trackUnit) < 50.0 then
				destroyDur = destroyDur + 6.0
				TimerStart(NewTimer(),5.9,false,function()
					if IsUnitAliveBJ(caster) and IsUnitAliveBJ(trackUnit) then
						DamagePackageDummyTarget(caster,'A05G','bloodlust')
						DamagePackageDummyTarget(caster,'A073','faeriefire',trackUnit)
					else
						UnitShareVisionBJ( false, trackUnit, p )
					end
					ReleaseTimer()
				end)
			end
			TimerStart(NewTimer(),destroyDur,false,function()
				if icon then
					DestroyMinimapIcon(icon)
				end
				UnitShareVisionBJ( false, trackUnit, p )
				ReleaseTimer()
			end)
		else
			SpellPackInvalidMsg(caster,'There were no nearby targets to track!')
		end
		DestroyGroup(g)
	end

	local Headhunter_Venom_f = function()
		local caster, tarX, tarY, casterX, casterY = SpellPackSetupTargetAbil()
		local dmg = GetHeroStatBJ(bj_HEROSTAT_AGI, caster, true)*2.0
		local strMis = 'abilities\\weapons\\wyvernspear\\wyvernspearmissile.mdl'
		local strDmg = 'Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl'
		local func = function(u, o)
			if GetUnitLifePercent(u) < 50.0 then
				DamagePackageDummyTarget(caster,'A009','slow',u)
				UnitDamageTargetBJ(caster,u,dmg*0.50, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL)
				DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Other\\AcidBomb\\BottleMissile.mdl',GetUnitX(u), GetUnitY(u)))
				if LUA_VAR_HEADHUNTER_ITEMBOOL[17] then
					DamagePackageDealOverTime(caster, u, dmg/6.0, 6.0, 'Abilities\\Spells\\Other\\AcidBomb\\BottleImpact.mdl')
				end
			end
		end
		LuaMissile.create(caster, tarX, tarY, 1000.0, 1.5, dmg, 75.0, true, false, false,nil,func,strMis,strDmg,60.0,1.0,nil,nil,nil)
	end

	SpellPackCreateTrigger(Headhunter_Javelin,Headhunter_Javelin_f,pInt,'A032')
	SpellPackCreateTrigger(Headhunter_Regen,Headhunter_Regen_f,pInt,'A06Y')
	SpellPackCreateTrigger(Headhunter_Trap,Headhunter_Trap_f,pInt,'A06X')
	SpellPackCreateTrigger(Headhunter_Track,Headhunter_Track_f,pInt,'A06Z')
	SpellPackCreateTrigger(Headhunter_Venom,Headhunter_Venom_f,pInt,'A070')

end
