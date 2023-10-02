function HuntressInit(unit, i)
	HuntressItemsInit(i)
	HuntressAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNHuntress.blp'
	LeaderboardUpdateHeroIcon(i)
	EnableTrigger( gg_trg_Huntress_Starleap )
	EnableTrigger( gg_trg_Huntress_Time_of_Day_Activate )
	EnableTrigger( gg_trg_Huntress_Glaive_Net )
	EnableTrigger( gg_trg_Huntress_Cleanser )
	EnableTrigger( gg_trg_Huntress_Falling_Star )
	udg_huntressUnit = unit
end

function HuntressItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I01Z", -- 1 (Q) Solar-Tipped Glaive 
		"I021", -- 2 (Active) Telescopic Hunting Glass 
		"I020", -- 3 (E) Huntress Cloak 
		"I022", -- 4 (Trait) Feathered Armor 
		"I025", -- 5 (Passive) Spectral Bear Paw 
		"I06J", -- 6 (W) Hunting Call
		"I06K", -- 7 (Active) Shimmering Moonstone
		"I06L", -- 8 (Trait) Bouncing Glaive
		"I06M", -- 9 (Q) Lunar-Tipped Glaive
		"I06N", -- 10 (W) Mark of the Snowy Owl
		"I06O" -- 11 (E) Blackened Moonstone
	}
	local itemTableUlt = {
		"I06Q", -- 12 (Q) Glaive of the Third War
		"I06S", -- 13 (W) Mark of the Tracker
		"I06T", -- 14 (E) Fowling Guise
		"I06R", -- 15 (Stats) Exalted Sentinel Pact
		"I06U", -- 16 (R1) Starshatter Harness
		"I06P" -- 17 (R2) Radiant Star of Elune
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I020")) then IncUnitAbilityLevel(udg_huntressUnit,FourCC("A001"))
		elseif (itemId == FourCC("I022")) then SetPlayerTechResearchedSwap( FourCC('R004'), 1, GetOwningPlayer(udg_huntressUnit) )
		elseif (itemId == FourCC("I021")) then SetPlayerTechResearchedSwap( FourCC('R005'), 1, GetOwningPlayer(udg_huntressUnit) )
		elseif (itemId == FourCC("I025")) then SetPlayerTechResearchedSwap( FourCC('R006'), 1, GetOwningPlayer(udg_huntressUnit) )
		elseif (itemId == FourCC("I06L")) then SetPlayerTechResearchedSwap( FourCC('R00B'), 1, GetOwningPlayer(udg_huntressUnit) )
		elseif (itemId == FourCC("I06N")) then SetPlayerTechResearchedSwap( FourCC('R00C'), 1, GetOwningPlayer(udg_huntressUnit) )
		elseif (itemId == FourCC("I06R")) then HeroAddStatTimer(udg_huntressUnit, 1, 1, 45.0, 15)
		end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,udg_huntressItemBool,itemTableUlt)

end

function HuntressAbilsInit(pInt)

	Huntress_Owl = CreateTrigger()
	Huntress_Leap = CreateTrigger()

	local Huntress_Owl_f = function()

		local caster = GetTriggerUnit()
		local x = GetUnitX(caster)
		local y = GetUnitY(caster)
		local tarX = GetSpellTargetX()
		local tarY = GetSpellTargetY()

		if (udg_huntressItemBool[6]) then
			local g = CreateGroup()
			GroupEnumUnitsInRange(g, x, y, 800.0, Condition( function() return
				IsUnitEnemy(GetFilterUnit(),GetOwningPlayer(caster))
				and IsUnitAliveBJ(GetFilterUnit())
				and IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO) end ) )
			if (not IsUnitGroupEmptyBJ(g)) then
				DamagePackageDummyTarget(caster,'A045','bloodlust')
			end
			DestroyGroup(g)
		end

		if (udg_huntressItemBool[13]) then
			local x2
			local y2
			local u
			local facing = AngleBetweenPointsXY(x,y,tarX,tarY)
			x2,y2 = PolarProjectionXY(tarX,tarY,800.0,facing)
			u = CreateUnit(GetOwningPlayer(caster),FourCC('e001'),x2,y2,270.0)
			UnitApplyTimedLifeBJ( 30.0, FourCC('BTLF'), u )
			x2,y2 = PolarProjectionXY(tarX,tarY,1600.0,facing)
			u = CreateUnit(GetOwningPlayer(caster),FourCC('e001'),x2,y2,270.0)
			UnitApplyTimedLifeBJ( 30.0, FourCC('BTLF'), u )
		end

	end

	Huntress_Leap_Item_f = function()
		DestroyEffect(AddSpecialEffect('Objects\\Spawnmodels\\NightElf\\NEDeathSmall\\NEDeathSmall.mdl',GetUnitX(udg_huntressUnit), GetUnitY(udg_huntressUnit)))
		DamagePackageDealAOE(udg_huntressUnit, GetUnitX(udg_huntressUnit), GetUnitY(udg_huntressUnit), 200.0,
			GetHeroStatBJ(bj_HEROSTAT_AGI, udg_huntressUnit, true)*2.0, false, false, '', '',
			'Abilities\\Spells\\Undead\\AbsorbMana\\AbsorbManaBirthMissile.mdl', 1.33)
	end

	local Huntress_Leap_f = function()

		local x = GetSpellTargetX()
		local y = GetSpellTargetY()
		
		if (udg_huntressItemBool[16]) then
			if (not HeroLeapTargetPoint(GetTriggerUnit(),0.36,x,y,nil,Huntress_Leap_Item_f)) then
				DamagePackageAddMana(GetTriggerUnit(),50) -- returns false on invalid; if so, refund mana
			end
		else
			if (not HeroLeapTargetPoint(GetTriggerUnit(),0.36,x,y,nil,nil)) then
				DamagePackageAddMana(GetTriggerUnit(),50)
			end
		end

	end

	-- spectral owl (currently separate from GUI)
	TriggerRegisterPlayerUnitEvent(Huntress_Owl,Player(pInt - 1),EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(Huntress_Owl, Filter( function() return GetSpellAbilityId() == FourCC('A006') end ) )
	TriggerAddAction(Huntress_Owl,Huntress_Owl_f)

	TriggerRegisterPlayerUnitEvent(Huntress_Leap,Player(pInt - 1),EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(Huntress_Leap, Filter( function() return GetSpellAbilityId() == FourCC('A05X') end ) )
	TriggerAddAction(Huntress_Leap,Huntress_Leap_f)

end
