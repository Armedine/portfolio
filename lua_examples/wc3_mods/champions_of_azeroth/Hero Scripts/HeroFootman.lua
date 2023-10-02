function FootmanInit(unit, i)
	FootmanItemsInit(i)
	FootmanAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNFootman.blp'
	LeaderboardUpdateHeroIcon(i)
	EnableTrigger( gg_trg_Footman_Shield_Bash )
	EnableTrigger( gg_trg_Footman_Charge )
	EnableTrigger( gg_trg_Footman_War_Banner )
    udg_footmanChargeHashtable = InitHashtable()
	udg_heroCanRegenMana[i] = false
	udg_footmanUnit = unit
	LUA_TRG_FOOTMAN_MAX_MANA = ItemShopSetManaCap(i, 100)
end

function FootmanItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I01P", -- 1 (Q) Shield of Malice 
		"I01Q", -- 2 (W) Gnomish Barrier Generator 
		"I01R", -- 3 (E) Deafening Blastcannon 
		"I01S", -- 4 (Trait) Socketed Belt
		"I01T", -- 5 (Q) Regenerative Dragonmail 
		"I05V", -- 6 (W) Gnomish Acceleration Device
		"I05W", -- 7 (E) Studded Assault Armor
		"I05X", -- 8 (Trait) Replenishment Flask
		"I05Y", -- 9 (Q) Spiked Shield Cover
		"I05Z", -- 10 (W) Gnomish Inverted Magnet
		"I060" -- 11 (E) Studded Assault Boots
	}
	local itemTableUlt = {
		"I061", -- 12 (Q) Garth's Dragonfire Enchantment
		"I062", -- 13 (W) Garth's Trinket of Defiance
		"I063", -- 14 (E) Garth's Gauntlets of Heroism
		"I064", -- 15 (Trait) Garth's Medallion of Courage
		"I066", -- 16 (R1) Horn of the Fallen King
		"I065" -- 17 (R2) Banner of Stormwind
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I060")) then IncUnitAbilityLevel(udg_footmanUnit,FourCC("A003"))
		elseif (itemId == FourCC("I064")) then HeroAddStatTimer(udg_footmanUnit, 0, 1, 45.0, 15)
		elseif (itemId == FourCC("I063")) then LUA_VAR_FM_INT = 0 end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,udg_footmanItemBool,itemTableUlt)

end

function FootmanAbilsInit(pInt)

	Footman_Pain = CreateTrigger()
	Footman_Pain_Listener = CreateTrigger()

	FootmanItem14_f = function() -- 14 (E) Garth's Gauntlets of Heroism
		if (LUA_VAR_FM_INT == 1) then -- on 2nd use, do nothing, reset state, allow CD
			LUA_VAR_FM_INT = 0
		else -- on first use, refund mana cost and reset CD
			LUA_VAR_FM_INT = 1
			FootmanItem14_f2()
			TimerStart(NewTimer(),5.0,false,function() -- if not used a 2nd time within CD period, reset the use loop
				if (LUA_VAR_FM_INT == 1) then
					LUA_VAR_FM_INT = 0
				end
				ReleaseTimer()
			end)
		end
	end

	FootmanItem14_f2 = function() -- reset the cd of heroic charge
		DamagePackageAddMana(udg_footmanUnit, 25, false)
		DestroyEffect( AddSpecialEffect( 'Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl', GetUnitX(udg_footmanUnit), GetUnitY(udg_footmanUnit) ) )
		TimerStart(NewTimer(),0.21,false,function()
			BlzEndUnitAbilityCooldown(udg_footmanUnit,FourCC('A003'))
			ReleaseTimer()
		end)
	end

	local Footman_Pain_f = function()

		local dur = 6.0

		if (udg_footmanItemBool[16]) then
			dur = dur + 2.0
		end

		EnableTrigger(Footman_Pain_Listener)

		TimerStart(NewTimer(),dur,false,function() DisableTrigger(Footman_Pain_Listener) ReleaseTimer() end)

	end

	TriggerRegisterPlayerUnitEvent(Footman_Pain,Player(pInt - 1),EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(Footman_Pain, Filter( function() return GetSpellAbilityId() == FourCC('A05P') end ) )
	TriggerAddAction(Footman_Pain,Footman_Pain_f)

	TriggerRegisterVariableEvent( Footman_Pain_Listener, "udg_DamageModifierEvent", EQUAL, 1.00 )
	TriggerAddCondition(Footman_Pain_Listener, Filter( function() return 
		udg_DamageEventTarget == udg_footmanUnit
		and not udg_IsDamageSpell
		end ) )
	TriggerAddAction(Footman_Pain_Listener, function()
		local pInt = GetConvertedPlayerId(GetOwningPlayer(udg_DamageEventSource))
		if (pInt > 12) then
			udg_DamageEventAmount = udg_DamageEventAmount*.25
		else
			udg_DamageEventAmount = udg_DamageEventAmount*.50
		end
	end)

	DisableTrigger(Footman_Pain_Listener)

end
