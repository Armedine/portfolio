function AcolyteInit(unit, i)
	AcolyteItemsInit(i)
	AcolyteAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNAcolyte.blp'
	LeaderboardUpdateHeroIcon(i)
	EnableTrigger( gg_trg_Acolyte_Blight_Tumor_Activate )
	EnableTrigger( gg_trg_Acolyte_Blight_Structure_Destroyed )
	EnableTrigger( gg_trg_Acolyte_Ritual )
	EnableTrigger( gg_trg_Acolyte_Desecrate )
	EnableTrigger( gg_trg_Acolyte_Citadel )
	EnableTrigger( gg_trg_Acolyte_Unit_Trained)
	udg_acolyteUnit = unit
	--DisplayTextToForce( GetPlayersAll(), "Debug: Acolyte Initialized")
end

function AcolyteItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I011", -- 1 Summoning Stone (B)
		"I012", -- 2 Dagger of Spite (W)
		"I013", -- 3 Corked Nightmares (E)
		"I014", -- 4 Rod of Necromancy (Active)
		"I016", -- 5 Deathly Sneakers (Passive)
		"I04P", -- 6 Corrosive Dagger Hilt (W)
		"I04L", -- 7 Book of Reanimation (E)
		"I04O", -- 8 Scourge Knell (B,Item)
		"I04S", -- 9 Potion of Undeath (B)
		"I04Q", -- 10 Chipped Skull (W)
		"I04M" -- 11 Book of Noxious Death (E)
	}
	local itemTableUlt = {
		"I015", -- 12 Nerubian Hive Crystal (B)
		"I04T", -- 13 Hood of the Shadow Council (W)
		"I04N", -- 14 Book of Grasping Nightmares (E)
		"I04U", -- 15 Scourge Invasion Portal (Trait)
		"I04K", -- 16 Unholy Juggernaut Plating (R1)
		"I04R", -- 17 Crown of the Lich King (R2)
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC('I015')) then
			if (IsUnitAlly(udg_acolyteUnit,Player(12))) then -- unlock research for faction owner
				SetPlayerTechResearchedSwap( FourCC('R009'), 1, Player(12) ) -- horde
			else
				SetPlayerTechResearchedSwap( FourCC('R009'), 1, Player(13) ) -- alliance
			end
		elseif (itemId == FourCC('I04U')) then
			TimerStart(NewTimer(),18.0,true,function()
				SetPlayerState(GetOwningPlayer(udg_acolyteUnit), PLAYER_STATE_RESOURCE_LUMBER,
					GetPlayerState(GetOwningPlayer(udg_acolyteUnit),PLAYER_STATE_RESOURCE_LUMBER) + 1)
			end)
		elseif (itemId == FourCC("I04T")) then
			IncUnitAbilityLevel(udg_acolyteUnit,FourCC("A01F"))
		end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,udg_acolyteItemBool,itemTableUlt)

end

function AcolyteAbilsInit(pInt)

	Acolyte_Transform = CreateTrigger()

	local Acolyte_Transform_f = function()

		local caster = GetTriggerUnit()
		local target = GetSpellTargetUnit()
		local id = GetUnitTypeId(target)

		if (id == FourCC('u007') or id == FourCC('u008') or id == FourCC('u009') or id == FourCC('u00A') or id == FourCC('u00B')) then -- eligible minions
			
			local hp = GetHeroStatBJ(bj_HEROSTAT_INT, caster, true)*5.5
			local atk = GetHeroStatBJ(bj_HEROSTAT_INT, caster, true)*1.65
			local x = GetUnitX(target)
			local y = GetUnitY(target)

			SetUnitExploded(target,true)
			KillUnit(target)

			local u = CreateUnit(GetOwningPlayer(caster), FourCC('u00E'), x, y, 270.0)
			local mhp = BlzGetUnitMaxHP(u)

			DestroyEffect( AddSpecialEffect('Units\\Undead\\Abomination\\AbominationExplosion.mdl',x,y))
			DestroyEffect( AddSpecialEffect('Objects\\Spawnmodels\\Undead\\UDeathSmall\\UDeathSmall.mdl',x,y))

			if (udg_acolyteItemBool[16]) then
				BlzSetUnitBaseDamage( u, math.floor(atk*1.25), 0 )
				BlzSetUnitMaxHP( u, math.floor(mhp + hp*1.75) )
				UnitApplyTimedLifeBJ( 30.0, FourCC('BTLF'), u )
			else
				BlzSetUnitBaseDamage( u, math.floor(atk), 0 )
				BlzSetUnitMaxHP( u, math.floor(mhp + hp) )
				UnitApplyTimedLifeBJ( 24.0, FourCC('BTLF'), u )
			end
			
			SetUnitLifePercentBJ(u, 100.0)

			u = nil

		else
			TimerStart(NewTimer(),0.33,false,function()
				BlzEndUnitAbilityCooldown( udg_acolyteUnit, FourCC('A044') )
				ReleaseTimer()
			end)
			DisplayTimedTextToPlayer(GetOwningPlayer(caster),0,0,1.5,'|cffffc800Invalid target, choose an undead minion!|r')
		end

		caster = nil
		target = nil

	end

	TriggerRegisterPlayerUnitEvent(Acolyte_Transform,Player(pInt - 1),EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(Acolyte_Transform, Filter( function() return GetSpellAbilityId() == FourCC('A044') end ) )
	TriggerAddAction(Acolyte_Transform,Acolyte_Transform_f)

end
