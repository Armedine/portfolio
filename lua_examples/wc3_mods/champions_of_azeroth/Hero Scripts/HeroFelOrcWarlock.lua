function FelOrcWarlockInit(unit, i)
	FelOrcWarlockItemsInit(i)
	FelOrcWarlockAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNChaosWarlock.blp'
	LeaderboardUpdateHeroIcon(i)
	EnableTrigger( gg_trg_Fel_Orc_Warlock_Bolt )
	EnableTrigger( gg_trg_Fel_Orc_Warlock_Bolt_Listener )
	EnableTrigger( gg_trg_Fel_Orc_Warlock_Eradicate )
	EnableTrigger( gg_trg_Fel_Orc_Warlock_Seed )
	EnableTrigger( gg_trg_Fel_Orc_Warlock_Armor_Listener )
    udg_felOrcWarlockUnit = unit
	udg_heroCanRegenMana[i] = false
    SetUnitManaPercentBJ(unit, 0.0)
end

function FelOrcWarlockItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I02N", -- 1 (Q) Festering Fel Bauble
		"I02O", -- 2 (W) Cloak of Consuming Magic
		"I02P", -- 3 (E) Unstable Fel Orb
		"I02Q", -- 4 (R) Fel Potion
		"I02R", -- 5 (Q) Starved Soul Dagger
		"I07V", -- 6 (W) Trinket of Dampening
		"I07W", -- 7 (E) Memento of Chaos
		"I07Y", -- 8 (Trait) Wandering Soul
		"I080", -- 9 (Q) Vengeful Aldor Spirit
		"I07Z", -- 10 (W) Boon of the Manaseeker
		"I07X" -- 11 (E) Memento of Destruction
	}
	local itemTableUlt = {
		"I082", -- 12 (Q) Skull of Gul'dan
		"I084", -- 13 (W) Mantle of Gul'dan
		"I081", -- 14 (E) Offering of Gul'dan
		"I083", -- 15 (Stats) Desecrated Soul
		"I086", -- 16 (R1) Blood of Mannoroth
		"I085" -- 17 (R2) Heart of Mannoroth
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I02N")) then IncUnitAbilityLevel(udg_felOrcWarlockUnit,FourCC("A02D"))
		elseif (itemId == FourCC("I02O")) then IncUnitAbilityLevel(udg_felOrcWarlockUnit,FourCC("A02C"))
		elseif (itemId == FourCC("I02R")) then SetPlayerTechResearchedSwap( FourCC('R007'), 1, GetOwningPlayer(udg_felOrcWarlockUnit) )
		elseif (itemId == FourCC("I07Y")) then
			TimerStart(NewTimer(),12.0,true,function()
				if (GetWidgetLife(udg_felOrcWarlockUnit) > .405) then
					local rand = math.random(1,100)
					DamagePackageAddMana(udg_felOrcWarlockUnit,rand,false)
				end
			end)
		elseif (itemId == FourCC("I083")) then HeroAddStatTimer(udg_felOrcWarlockUnit, 2, 1, 45.0, 10)
		end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,udg_felOrcWarlockItemBool,itemTableUlt)

end

function FelOrcWarlockAbilsInit(pInt)

	FelOrcWarlock_Despoil = CreateTrigger()

	local FelOrcWarlock_Despoil_f = function()

		local i = 0
		local caster = GetTriggerUnit()
		local damage = math.floor(BlzGetUnitMaxHP(caster)*.10)

		if (udg_felOrcWarlockItemBool[16]) then
			damage = math.floor(damage*.70)
		end

		TimerStart(NewTimer(),1.0,true,function()
			i = i + 1
			DamagePackageAddMana(caster,75,false)
			DamagePackageDealDirect(caster, caster, damage, 0, 0, false, 'Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilSpecialArt.mdl')
			if ( i >= 6) then
				ReleaseTimer()
			end
		end)

	end

	TriggerRegisterPlayerUnitEvent(FelOrcWarlock_Despoil,Player(pInt - 1),EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(FelOrcWarlock_Despoil, Filter( function() return GetSpellAbilityId() == FourCC('A064') end ) )
	TriggerAddAction(FelOrcWarlock_Despoil,FelOrcWarlock_Despoil_f)

end
