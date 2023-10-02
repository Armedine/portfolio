function ShamanInit(unit, i)
	ShamanItemsInit(i)
	ShamanAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNShaman.blp'
	LeaderboardUpdateHeroIcon(i)
	EnableTrigger( gg_trg_Shaman_Duplication )
	EnableTrigger( gg_trg_Shaman_Magma )
	EnableTrigger( gg_trg_Shaman_Lightning_Shield )
	EnableTrigger( gg_trg_Shaman_Bloodlust )
	EnableTrigger( gg_trg_Shaman_Overcharge )
	EnableTrigger( gg_trg_Shaman_Thundercrash )
    udg_shamanUnit = unit
end

function ShamanItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I00C", -- Pulsating Magma Stone (Q)
		"I00D", -- Electrified Ether (W)
		"I00E", -- Overloaded Crystal (E)
		"I00G", -- Amplified Ward (F)
		"I00F", -- Static Charm (Q)
		"I02X", -- Volatile Lava Globule (Q)
		"I02Y", -- Magnetized Plating (W)
		"I02Z", -- Voltaic Hammer (E)
		"I030", -- Claws of Surging Energy (F)
		"I033", -- Stoneclaw Ossuary (W)
		"I035" -- Mana-Binding Aether (E)
	}
	-- elite items added at level 14
	local itemTableUlt = {
		"I006", -- Scorching Slag (Q)
		"I036", -- Scepter of Rolling Thunder (W)
		"I034", -- Gauntlets of Overwhelming Power (E)
		"I037", -- Hood of Echoing Elements (F)
		"I032", -- Thunder King's Talisman (R)
		"I031" -- Mandokir's Talisman (R)
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I00G")) then IncUnitAbilityLevel(udg_shamanUnit,FourCC("A031"))
		elseif (itemId == FourCC("I02X")) then IncUnitAbilityLevel(udg_shamanUnit,FourCC("A036"))
		elseif (itemId == FourCC("I031")) then UnitRemoveAbility(udg_shamanUnit,FourCC("A034")) UnitAddAbility(udg_shamanUnit,FourCC("A01C"))
			-- BlzSetUnitAbilityCooldown( udg_shamanUnit, FourCC('A034'), 0, 45.00 )BlzSetUnitAbilityManaCost( udg_shamanUnit, FourCC('A034'), 0, 0 )
		elseif (itemId == FourCC("I036")) then IncUnitAbilityLevel(udg_shamanUnit,FourCC("A030"))
		end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,udg_shamanItemBool,itemTableUlt)

end

function ShamanAbilsInit(pInt)

	Shaman_Thundercrash = CreateTrigger()

	local Shaman_Thundercrash_f = function()

		local u = GetTriggerUnit()
		local x = GetLocationX(GetSpellTargetLoc())
		local y = GetLocationY(GetSpellTargetLoc())
		local i = 0
		local r = 200.0
		local scale = 1.0
		local d = GetHeroStatBJ(bj_HEROSTAT_INT, u, true)*2.5
		if (udg_shamanItemBool[16]) then
			r = 260.0
			scale = 1.15
			d = d*1.5
		end

		DestroyEffect(AddSpecialEffect('Abilities\\Weapons\\Bolt\\BoltImpact.mdl',x,y))

		TimerStart(NewTimer(),0.75,true,function() -- timer building up to effect
			DestroyEffect(AddSpecialEffect('Abilities\\Weapons\\Bolt\\BoltImpact.mdl',x,y))
			i = i +1
			if (i >= 3) then -- 2.25 reached, run spell effect
				local g = CreateGroup()
				DestroyEffect(AddSpecialEffect('war3mapImported\\LightningWrath.mdx',x,y))
				BlzSetSpecialEffectScale( GetLastCreatedEffectBJ(), scale )
				DamagePackageDealAOE(u, x, y, r, d, false, false, '', '', 'Abilities\\Weapons\\Bolt\\BoltImpact.mdl', 1.25)
				GroupEnumUnitsInRange(g, x, y, r, Condition( function() return
					IsUnitEnemy(GetFilterUnit(),GetOwningPlayer(u))
					and IsUnitAliveBJ(GetFilterUnit())
					and (not IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE))
					and (not IsUnitType(GetFilterUnit(),UNIT_TYPE_MAGIC_IMMUNE)) end ) )
				if (not IsUnitGroupEmptyBJ(g)) then
					local u2 = FirstOfGroup(g)
					local id = 0
			 		repeat
			 			id = GetUnitUserData(u2)
			 			if (IsUnitInGroup(u2, udg_shamanShieldDebuffGroup)) then
							udg_shamanShieldUnitStack[id] = udg_shamanShieldUnitStack[id] + 5
							udg_shamanShieldUnitDuration[id] = 0.0
							--DestroyEffect(udg_shamanShieldDebuffEffect[id])
							--udg_shamanShieldDebuffEffect[id] = AddSpecialEffectTarget('Abilities\\Spells\\Items\\AIlb\\AIlbTarget.mdl', u2, 'overhead')
						end
						GroupRemoveUnit(g,u2)
						u2 = FirstOfGroup(g)
					until (u2 == nil)
				end
				DestroyGroup(g)
				ReleaseTimer()
			end
		end)

		local u = nil
		local x = nil
		local y = nil
		local i = nil
		local d = nil

	end

	TriggerRegisterPlayerUnitEvent(Shaman_Thundercrash,Player(pInt - 1),EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(Shaman_Thundercrash, Filter( function() return GetSpellAbilityId() == FourCC('A04G') end ) )
	TriggerAddAction(Shaman_Thundercrash,Shaman_Thundercrash_f)

end
