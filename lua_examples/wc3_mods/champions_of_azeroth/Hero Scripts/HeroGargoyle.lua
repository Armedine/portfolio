function GargoyleInit(unit, i)
	GargoyleItemsInit(i)
	GargoyleAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNGargoyle.blp'
	LeaderboardUpdateHeroIcon(i)
	EnableTrigger( gg_trg_Gargoyle_Blade )
	EnableTrigger( gg_trg_Gargoyle_Clutch )
	EnableTrigger( gg_trg_Gargoyle_Stone_Form )
	EnableTrigger( gg_trg_Gargoyle_Ancient_Statue )
	EnableTrigger( gg_trg_Gargoyle_Vampiric_Claws )
	udg_gargoyleUnit = unit
	--DisplayTextToForce( GetPlayersAll(), "Debug: Gargoyle Initialized")
end

function GargoyleItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I00W", -- 1 Necrotic Orb (Q)
		"I00X", -- 2 Preying Claws (W)
		"I00Y", -- 3 Hardened Carapace (E)
		"I00Z", -- 4 Vampiric Maw (Trait)
		"I010", -- 5 Caustic Orb (Q)
		"I048", -- 6 Deathgrip Appendage (W)
		"I04B", -- 7 Spire Membrane (E)
		"I04C", -- 8 Mana-Eater Fangs (Trait)
		"I04A", -- 9 Freezing Orb (Q)
		"I049", -- 10 Lunging Wings (W)
		"I04E" -- 11 Dimensional Rind (E)
	}
	local itemTableUlt = {
		"I04D", -- 12 Maleficent Orb (Q)
		"I04F", -- 13 Devilish Talons (W)
		"I04G", -- 14 Indomitable Husk (E)
		"I04H", -- 15 Impish Pact (Stat Passive)
		"I04J", -- 16 Bottle of Echoing Terror (R1)
		"I04I", -- 17 Unholy Monster Garb (R2)
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I00Y")) then IncUnitAbilityLevel(udg_gargoyleUnit,FourCC("A043"))
		elseif (itemId == FourCC("I04D")) then IncUnitAbilityLevel(udg_gargoyleUnit,FourCC("A00T"))
		elseif (itemId == FourCC("I04F")) then IncUnitAbilityLevel(udg_gargoyleUnit,FourCC("A00S"))
		elseif (itemId == FourCC("I04H")) then HeroAddStatTimer(udg_gargoyleUnit, 1, 1, 45.0, 15) end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,udg_gargoyleItemBool,itemTableUlt)

end

function GargoyleAbilsInit(pInt)

	Gargoyle_Unholy_Screech = CreateTrigger()

	local Gargoyle_Unholy_Screech_f = function()

		local caster = GetTriggerUnit()
		local x = GetUnitX(caster)
		local y = GetUnitY(caster)

		DamagePackageDummyAoE(caster, 'A051', 'silence', nil, x, y, x, y, nil)

		if (udg_gargoyleItemBool[16]) then
			LUA_VAR_G_US_EFFECT = AddSpecialEffect('Abilities\\Weapons\\DragonHawkMissile\\DragonHawkMissile.mdl',x,y)
			TimerStart(NewTimer(),3.0,false,function()
				DamagePackageDummyAoE(caster, 'A051', 'silence', nil, x, y, x, y, nil)
				DestroyEffect(LUA_VAR_G_US_EFFECT)
				LUA_VAR_G_US_EFFECT = nil
				ReleaseTimer()
			end)
		end

	end

	TriggerRegisterPlayerUnitEvent(Gargoyle_Unholy_Screech,Player(pInt - 1),EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(Gargoyle_Unholy_Screech, Filter( function() return GetSpellAbilityId() == FourCC('A050') end ) )
	TriggerAddAction(Gargoyle_Unholy_Screech,Gargoyle_Unholy_Screech_f)

end
