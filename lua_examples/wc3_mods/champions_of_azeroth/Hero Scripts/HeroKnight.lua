function KnightInit(unit, i)
	KnightItemsInit(i)
	KnightAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNKnight.blp'
	LeaderboardUpdateHeroIcon(i)
	EnableTrigger( gg_trg_Knight_Joust )
	EnableTrigger( gg_trg_Knight_Blood )
	EnableTrigger( gg_trg_Knight_Voidwalker )
	EnableTrigger( gg_trg_Knight_Conch )
	EnableTrigger( gg_trg_Knight_Hunter )
	udg_knightUnit = unit
	udg_heroCanRegenMana[i] = true
	--DisplayTextToForce( GetPlayersAll(), "Debug: Knight Initialized")
end

function KnightItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I017", -- 1 Explosive Lance (Q)
		"I018", -- 2 Inoculated Blood (W)
		"I019", -- 3 Echoing Scripture (E)
		"I01A", -- 4 Tavern Leftovers (Trait)
		"I01B", -- 5 Sharpening Stone (Q)
		"I04V", -- 6 Alacrity Admixture (W)
		"I04W", -- 7 Glowing Witcher Bounty (E)
		"I04X", -- 8 Tavern Bounty Board (Trait)
		"I04Z", -- 9 Reinforced Lance Stock (Q)
		"I054", -- 10 (W) Flask of Arcana
		"I055" -- 11 (Active) Sightly Ward
	}
	local itemTableUlt = {
		"I050", -- 12 (Q) Helm of the Bandit Lord 
		"I052", -- 13 (Passive) Curiass of the Dragon Lord 
		"I051", -- 14 (E) Mantle of the Void Lord 
		"I053", -- 15 (Trait) Deed of the Tavern Lord 
		"I056", -- 16 (R1) Club of the Magnataur Lord
		"I04Y" -- 17 (R2) Buccaneer Cap of the Pirate Lord
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I04W")) then IncUnitAbilityLevel(udg_knightUnit,FourCC("A038"))
		elseif (itemId == FourCC("I050")) then IncUnitAbilityLevel(udg_knightUnit,FourCC("A03A"))
		elseif (itemId == FourCC("I052")) then HeroAddStatTimer(udg_knightUnit, 0, 1, 45.0, 12) end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,udg_knightItemBool,itemTableUlt)

end

function KnightAbilsInit(pInt)

	Knight_Tusk = CreateTrigger()

	local Knight_Tusk_f = function()

		local caster = GetTriggerUnit()
		local target = GetSpellTargetUnit()
		local damage = GetHeroStatBJ(bj_HEROSTAT_STR, caster, true)*1.75
		local pInt = GetConvertedPlayerId(GetOwningPlayer(target))

		if (pInt > 14) then
			damage = damage*2.0
		end

		UnitDamageTargetBJ(caster, target, damage, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL)

		if (udg_knightItemBool[16] and pInt > 14 and GetWidgetLife(target) <= .405) then -- reset CD item true
			PolledWait(0.20) -- hacky fix to wait for spell effect to register completely
			BlzEndUnitAbilityCooldown(caster,FourCC('A058'))
			DestroyEffect(AddSpecialEffect('Abilities\\Spells\\NightElf\\Taunt\\TauntCaster.mdl',GetUnitX(caster),GetUnitY(caster)))
		end

		caster = nil
		target = nil

	end

	TriggerRegisterPlayerUnitEvent(Knight_Tusk,Player(pInt - 1),EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(Knight_Tusk, Filter( function() return GetSpellAbilityId() == FourCC('A058') end ) )
	TriggerAddAction(Knight_Tusk,Knight_Tusk_f)

end
