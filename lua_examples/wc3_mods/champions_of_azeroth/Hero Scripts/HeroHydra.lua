function HydraInit(unit, i)
	HydraItemsInit(i)
	HydraAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNHydra.blp'
	LeaderboardUpdateHeroIcon(i)
	udg_hydraUnit = unit
	EnableTrigger( gg_trg_Hydra_Fire )
	EnableTrigger( gg_trg_Hydra_Frost )
	EnableTrigger( gg_trg_Hydra_Acid )
	EnableTrigger( gg_trg_Hydra_Maw )
	EnableTrigger( gg_trg_Hydra_Geyser )
end

function HydraItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I02I", -- 1 (Q) Abyssal Slagstone
		"I02J", -- 2 (W) Abyssal Floestone
		"I02K", -- 3 (E) Abyssal Venomstone
		"I02L", -- 4 (Trait) Deepfathom Lure
		"I07J", -- 5 (Q) Vial of Cauterizing Fire
		"I07K", -- 6 (W) Vial of Gushing Waters
		"I07L", -- 7 (E) Vial of Corrosive Solids
		"I02M", -- 8 (Mana) Heart of the Sea
		"I07M", -- 9 (Q) Scales of the Salamander
		"I07N", -- 10 (W) Scales of the Whiptail
		"I07O" -- 11 (E) Scales of the Anole
	}
	local itemTableUlt = {
		"I07P", -- 12 (Q) Gahz'rilla's Fortitude
		"I07Q", -- 13 (W) Gahz'rilla's Insight
		"I07R", -- 14 (E) Gahz'rilla's Zeal
		"I07T", -- 15 (Trait) Aku'mai's Lens
		"I07U", -- 16 (R1) Gahz'rilla's Endurance
		"I07S" -- 17 (R2) Gahz'rilla's Maw
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I00G")) then IncUnitAbilityLevel(udg_hydraUnit,FourCC("A031"))
		elseif (itemId == FourCC("I07M")) then IncUnitAbilityLevel(udg_hydraUnit,FourCC("A03D"))
		elseif (itemId == FourCC("I07N")) then IncUnitAbilityLevel(udg_hydraUnit,FourCC("A03E"))
		elseif (itemId == FourCC("I07O")) then IncUnitAbilityLevel(udg_hydraUnit,FourCC("A03F"))
		elseif (itemId == FourCC("I07P")) then HeroAddStatTimer(udg_hydraUnit, 0, 1, 45.0, 12)
		elseif (itemId == FourCC("I07Q")) then HeroAddStatTimer(udg_hydraUnit, 2, 1, 45.0, 12)
		elseif (itemId == FourCC("I07R")) then HeroAddStatTimer(udg_hydraUnit, 1, 1, 45.0, 10) end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,udg_hydraItemBool,itemTableUlt)

end

function HydraAbilsInit(pInt)

	Hydra_Song = CreateTrigger()

	local Hydra_Song_f = function()
		udg_hydraSongBool = true
		TimerStart(NewTimer(),8.0,false,function()
			udg_hydraSongBool = false
			ReleaseTimer()
		end)
		if (udg_hydraItemBool[16]) then
			DamagePackageAddMana(GetTriggerUnit(),30,true)
		end
	end

	TriggerRegisterPlayerUnitEvent(Hydra_Song,Player(pInt - 1),EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(Hydra_Song, Filter( function() return GetSpellAbilityId() == FourCC('A062') end ) )
	TriggerAddAction(Hydra_Song,Hydra_Song_f)

end
