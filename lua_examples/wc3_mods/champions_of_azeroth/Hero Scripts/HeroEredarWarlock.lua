function EredarWarlockInit(unit, i)
	EredarWarlockItemsInit(i)
	EredarWarlockAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNEredarWarlockPurple.blp'
	LeaderboardUpdateHeroIcon(i)
	udg_eredarWarlockUnit = unit
	EnableTrigger( gg_trg_Eredar_Warlock_Summons )
	EnableTrigger( gg_trg_Eredar_Warlock_Invasion_Activate )
	EnableTrigger( gg_trg_Eredar_Warlock_Invasion_Gate )
	EnableTrigger( gg_trg_Eredar_Warlock_Demonic_Pact )
	EnableTrigger( gg_trg_Eredar_Warlock_Orb )
	TriggerExecute (gg_trg_Eredar_Warlock_Generate_Objectives)
end

function EredarWarlockItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I02S", -- 1 (Q) Shawl of the Burning Legion
		"I02T", -- 2 (W) Book of Summoning
		"I02U", -- 3 (E) Demonic Harness
		"I02V", -- 4 (R) Onslaught Scepter
		"I02W", -- 5 (Q) Cranium of the Covenant
		"I08B", -- 6 (W) Fel Armaments
		"I08C", -- 7 (E) Fel-Infused Marrow
		"I08A", -- 8 (Trait) Mobile Invasion Rune
		"I088", -- 9 (Q) Channeling Orb
		"I089", -- 10 (W) Nether Crystal
		"I087" -- 11 (E) Summoning Pact
	}
	local itemTableUlt = {
		"I08D", -- 12 (Q) Orb of Ultimate Destruction
		"I08E", -- 13 (W) Orb of Ruinous Invasion
		"I08F", -- 14 (E) Orb of Absolute Control
		"I08H", -- 15 (Trait) Forge Camp Portal Device
		"I08I", -- 16 (R1) Libram of the Burning Legion
		"I08G" -- 17 (R2) Forge Camp Platemail
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I02T")) then udg_eredarWarlockDemonPoolMax = 12
		elseif (itemId == FourCC("I088")) then IncUnitAbilityLevel(udg_eredarWarlockUnit,FourCC("A013"))
		elseif (itemId == FourCC("I089")) then IncUnitAbilityLevel(udg_eredarWarlockUnit,FourCC("A010"))
		elseif (itemId == FourCC("I087")) then IncUnitAbilityLevel(udg_eredarWarlockUnit,FourCC("A011"))
		elseif (itemId == FourCC("I08A")) then IncUnitAbilityLevel(udg_eredarWarlockUnit,FourCC("A00Z"))
		end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,udg_eredarWarlockItemBool,itemTableUlt)

end

function EredarWarlockAbilsInit(pInt)

	EredarWarlock_Mark = CreateTrigger()

	local EredarWarlock_Mark_f = function()

		local caster, tarX, tarY, casterX, casterY = SpellPackSetupTargetAbil()
		local dummy = DamagePackageCreateDummy(GetOwningPlayer(caster),'e00R',casterX,casterY,GetUnitFacing(caster),3.25)

		local angle = AngleBetweenPointsXY(casterX,casterY,tarX,tarY)
		local moveX,moveY = PolarProjectionXY(casterX,casterY,800.0,angle)
		local i = 0
		local baseX
		local baseY
		local newOwner
		local enemyOwner
		local g = CreateGroup()
		local currentX
		local currentY
		local u
		local pColor

		SetUnitMoveSpeed(dummy,200.0) -- move 600 units over 3 sec
		IssuePointOrder(dummy,"move",moveX,moveY)

		if (GetConvertedPlayerId(GetOwningPlayer(caster)) > 5) then
			newOwner = Player(13) -- alliance
			enemyOwner = Player(12)
			baseX = GetRectCenterX(gg_rct_coreHorde)
			baseY = GetRectCenterY(gg_rct_coreHorde)
			pColor = PLAYER_COLOR_NAVY
		else
			newOwner = Player(12) -- horde
			enemyOwner = Player(13)
			baseX = GetRectCenterX(gg_rct_coreAlliance)
			baseY = GetRectCenterY(gg_rct_coreAlliance)
			pColor = PLAYER_COLOR_MAROON
		end



		TimerStart(NewTimer(),0.25,true,function()
			i = i + 1
			currentX = GetUnitX(dummy)
			currentY = GetUnitY(dummy)
			DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl',currentX,currentY))
			GroupEnumUnitsInRange(g, currentX, currentY, 200.0, Condition( function() return DamagePackageEnemyFilter(GetFilterUnit(), GetOwningPlayer(caster))
				and GetOwningPlayer( GetFilterUnit() ) == enemyOwner
				and not IsUnitType(GetFilterUnit(),UNIT_TYPE_SUMMONED)
				and not IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO) end ) )
			if (not IsUnitGroupEmptyBJ(g)) then
				u = FirstOfGroup(g)
				local loop = 0
			 	repeat
				  	loop = loop + 1
				  	DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl',GetUnitX(u),GetUnitY(u)))
				  	SetUnitOwner(u,newOwner)
				  	SetUnitColor(u,pColor)
				  	UnitAddType(u,UNIT_TYPE_SUMMONED)
				  	UnitApplyTimedLifeBJ( 24.0, FourCC('BTLF'), u )
				  	if (udg_eredarWarlockItemBool[16]) then
				  		DamagePackageDummyTarget(u,'A068','innerfire')
				  	end
				  	IssuePointOrder(u,"attack",baseX,baseY)
				    GroupRemoveUnit(g, u)
				    u = FirstOfGroup(g)
			  	until (u == nil or loop >= 10)
			end
			if (i >= 12) then
				RemoveUnit(u)
				u = nil
				DestroyGroup(g)
				ReleaseTimer()
			end
		end)

	end

	TriggerRegisterPlayerUnitEvent(EredarWarlock_Mark,Player(pInt - 1),EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(EredarWarlock_Mark, Filter( function() return GetSpellAbilityId() == FourCC('A067') end ) )
	TriggerAddAction(EredarWarlock_Mark,EredarWarlock_Mark_f)

end
