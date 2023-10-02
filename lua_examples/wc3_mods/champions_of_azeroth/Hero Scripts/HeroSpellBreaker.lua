function SpellBreakerInit(unit, i)
	SpellBreakerItemsInit(i)
	SpellBreakerAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNSpellBreaker.blp'
	LeaderboardUpdateHeroIcon(i)
	EnableTrigger( gg_trg_Spell_Breaker_Absorb )
	EnableTrigger( gg_trg_Spell_Breaker_Reflect )
	EnableTrigger( gg_trg_Spell_Breaker_Aura )
	EnableTrigger( gg_trg_Spell_Breaker_Shatter )
	EnableTrigger( gg_trg_Spell_Breaker_Reduction )
	udg_spellBreakerUnit = unit
	udg_heroCanRegenMana[i] = true
	--DisplayTextToForce( GetPlayersAll(), "Debug: Spell Breaker Initialized")
end

function SpellBreakerItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I01F", -- 1 (Q) Vexing Sphere 
		"I01G", -- 2 (W) Revitalizing Mana Crystal 
		"I01H", -- 3 (E) Overcharged Prism 
		"I01I", -- 4 (Runes) Mage Hunter Garb
		"I01J", -- 5 (Q) Alacritous Bauble
		"I057", -- 6 (W) Swordbreaker Shield
		"I058", -- 7 (E) Empty Absorption Vial
		"I059", -- 8 (Runes) Mana Shackles
		"I05A", -- 9 (Q) Acceleration Sphere
		"I05D", -- 10 (W) Manabreaker Shield
		"I05E" -- 11 (Runes) Mage Hunter Boots
	}
	local itemTableUlt = {
		"I05F", -- 12 (Q) Magnetic Sphere
		"I05G", -- 13 (W) Crown of the Anti-Mage
		"I05H", -- 14 (E) Thalassian Gauntlets
		"I05I", -- 15 (Active) Mage Hunter Dagger
		"I05C", -- 16 (R1) Quel'dorei Containment Pen
		"I05B" -- 17 (R2) Hymn of the Quel'dorei
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I01I")) then udg_spellBreakerMaxRuneDur = 7.0
		elseif (itemId == FourCC("I05A")) then IncUnitAbilityLevel(udg_spellBreakerUnit,FourCC("A02G"))
		elseif (itemId == FourCC("I05G")) then IncUnitAbilityLevel(udg_spellBreakerUnit,FourCC("A02H")) end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,udg_spellBreakerItemBool,itemTableUlt)

end

function SpellBreakerAbilsInit(pInt)

	SpellBreaker_Prison = CreateTrigger()

	local SpellBreaker_Prison_f = function()

		local caster = GetTriggerUnit()
		local target = GetSpellTargetUnit()
		local pStat = BlzGetUnitIntegerField(target, UNIT_IF_PRIMARY_ATTRIBUTE)
		local dur = 3.0
		local ticks = 12
		local abilId
		local i = 0
		local effect1
		local effect2
		local dmg = GetHeroStatBJ(bj_HEROSTAT_STR, caster, true)*.25

		local x = GetUnitX(target)
		local y = GetUnitY(target)

		local u = CreateUnit(GetOwningPlayer(caster),FourCC('e00P'),x,y,270.0)

		if (pStat == 2) then -- if intelligence, increase duration
			dur = 4.0
			abilId = 'A05B'
			ticks = 16
			effect = AddSpecialEffectTarget('Abilities\\Spells\\Other\\Drain\\ManaDrainCaster.mdl',target,'overhead')
		else
			abilId = 'A05A'
			effect = AddSpecialEffectTarget('Abilities\\Spells\\Other\\Drain\\DrainCaster.mdl',target,'overhead')
		end

		UnitApplyTimedLifeBJ( dur, FourCC('BTLF'), u )

		DamagePackageDummyAoE(udg_spellBreakerUnit, abilId, 'silence', nil, GetUnitX(target), GetUnitY(target), GetUnitX(target), GetUnitY(target), nil)

		TimerStart(NewTimer(),0.25,true,function()
			if (i >= ticks or not IsUnitAliveBJ(u) or not IsUnitAliveBJ(target)) then
				DestroyEffect(effect)
				KillUnit(u)
				ReleaseTimer()
			else
				if (not IsUnitInRangeXY(target,x,y,300.0)) then
					SetUnitX(target,x)
					SetUnitY(target,y)
					DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Other\\Charm\\CharmTarget.mdl',x,y))
				end
				if (udg_spellBreakerItemBool[16]) then
					DamagePackageDealDirect(udg_spellBreakerUnit, target, dmg, 0, 0, false, 'Abilities\\Weapons\\BlackKeeperMissile\\BlackKeeperMissile.mdl')
				end
				i = i + 1
			end
		end)

	end

	TriggerRegisterPlayerUnitEvent(SpellBreaker_Prison,Player(pInt - 1),EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(SpellBreaker_Prison, Filter( function() return GetSpellAbilityId() == FourCC('A059') end ) )
	TriggerAddAction(SpellBreaker_Prison,SpellBreaker_Prison_f)

end
