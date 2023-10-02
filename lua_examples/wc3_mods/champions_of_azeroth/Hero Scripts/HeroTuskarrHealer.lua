function TuskarrHealerInit(unit, i)
	TuskarrHealerItemsInit(i)
	TuskarrHealerAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNTuskaarBlack.blp'
	LeaderboardUpdateHeroIcon(i)
	udg_tuskarrHealerUnit = unit
	EnableTrigger( gg_trg_Tuskarr_Healer_Glaciate )
	EnableTrigger( gg_trg_Tuskarr_Healer_Spike )
	EnableTrigger( gg_trg_Tuskarr_Healer_Spore )
	EnableTrigger( gg_trg_Tuskarr_Healer_Riptide )
	EnableTrigger( gg_trg_Tuskarr_Healer_Spirit )
end

function TuskarrHealerItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I02D", -- 1 (Q) Sticky Tar
		"I02E", -- 2 (W) Explosive Fungus
		"I02F", -- 3 (E) Shamanistic Water
		"I02G", -- 4 (F) Hyper-Condensed Blizzard
		"I02H", -- 5 (Active) Frisky Sprinters
		"I077", -- 6 (W) Quick-Bonding Enzymes
		"I078", -- 7 (E) Gushing Potion
		"I079", -- 8 (Trait) Ice Cooler
		"I07A", -- 9 (Q) Enchanted Fishing Line
		"I07B", -- 10 (W) Fishscale Armor
		"I07C" -- 11 (E)  Fishing, for Dummies Pt. 1
	}
	local itemTableUlt = {
		"I07D", -- 12 (Q) Fish Cannon
		"I07E", -- 13 (W) Bottomless Fish Net
		"I07F", -- 14 (E) Fishing, for Dummies Pt. 2
		"I07G", -- 15 (Trait) Cauterizing Ice Pack
		"I07I", -- 16 (R1) Northrend Ice Cube
		"I07H" -- 17 (R2) Whalebelly's Tusk
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I00G")) then IncUnitAbilityLevel(udg_tuskarrHealerUnit,FourCC("A03M"))
		elseif (itemId == FourCC("I07C")) then IncUnitAbilityLevel(udg_tuskarrHealerUnit,FourCC("A03J"))
		elseif (itemId == FourCC("I07D")) then IncUnitAbilityLevel(udg_tuskarrHealerUnit,FourCC("A03K"))
		elseif (itemId == FourCC("I07E")) then IncUnitAbilityLevel(udg_tuskarrHealerUnit,FourCC("A03L"))
		elseif (itemId == FourCC("I07F")) then IncUnitAbilityLevel(udg_tuskarrHealerUnit,FourCC("A03J")) end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,udg_tuskarrHealerItemBool,itemTableUlt)

end

function TuskarrHealerAbilsInit(pInt)

	TuskarrHealer_Wall = CreateTrigger()

	local TuskarrHealer_Wall_f = function()

		local dumX = {}
		local dumY = {}

		local caster, tarX, tarY, casterX, casterY = SpellPackSetupTargetAbil()
		local facing = AngleBetweenPointsXY(casterX,casterY,tarX,tarY)
		local dur = 6.0
		local d

		if (udg_tuskarrHealerItemBool[16]) then
			dur = dur + 3.0
		end

		dumX[1],dumY[1] = PolarProjectionXY(tarX,tarY,144,facing-90)
		dumX[2],dumY[2] = PolarProjectionXY(tarX,tarY,72,facing-90)
		dumX[3],dumY[3] = PolarProjectionXY(tarX,tarY,24,facing)
		dumX[4],dumY[4] = PolarProjectionXY(tarX,tarY,72,facing+90)
		dumX[5],dumY[5] = PolarProjectionXY(tarX,tarY,144,facing+90)

		-- clear collision + a min cell of ~16 to account for hero pathing size:

		for i = 1,5 do
			SpellPackClearArea(dumX[i],dumY[i],48.0)
			d = DamagePackageCreateDummy(GetOwningPlayer(caster), 'e005', dumX[i], dumY[i], facing, dur)
		end

		dumX = nil
		dumY = nil

	end

	TriggerRegisterPlayerUnitEvent(TuskarrHealer_Wall,Player(pInt - 1),EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(TuskarrHealer_Wall, Filter( function() return GetSpellAbilityId() == FourCC('A061') end ) )
	TriggerAddAction(TuskarrHealer_Wall,TuskarrHealer_Wall_f)

end
