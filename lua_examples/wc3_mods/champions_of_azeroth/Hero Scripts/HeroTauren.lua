function TaurenInit(unit, i)
	TaurenItemsInit(i)
	TaurenAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNTauren.blp'
	LeaderboardUpdateHeroIcon(i)
	EnableTrigger( gg_trg_Tauren_Iron_Hide )
	EnableTrigger( gg_trg_Tauren_Ground_Slam )
	EnableTrigger( gg_trg_Tauren_Charge )
	EnableTrigger( gg_trg_Tauren_Tectonic_Shift )
	EnableTrigger( gg_trg_Tauren_Pulverize )
	EnableTrigger( gg_trg_Tauren_Pulverize_Activate )
	udg_taurenChargeHashtable = InitHashtable()
	udg_taurenUnit = unit
	--DisplayTextToForce( GetPlayersAll(), "Debug: Tauren Initialized")
end

function TaurenItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I00H", -- Tremor Gauntlets (Q)
		"I00I", -- Hallowed Totem (W)
		"I00J", -- Thunderhooves(E)
		"I00K", -- Tauren Warbanner (Active)
		"I00M", -- Siege Boulder (Q)
		"I038", -- Arcanite Totem Casting (W)
		"I03A", -- Battering Ram (E)
		"I03B", -- Reflective Dragonhide (Trait)
		"I03C", -- Trollskin Armor (Q)
		"I03E", -- Bonebreaker Studs (W)
		"I03I" -- Bullish Sprinters (E)
	}
	local itemTableUlt = {
		"I03F", -- Earthshaker Crown (Q)
		"I03D", -- Bellowing Totem (W)
		"I03H", -- Onslaught Bracers (E)
		"I03G", -- Curiass of Relentless Destruction (Trait)
		"I03J", -- Hammer of Khaz'goroth (R)
		"I039" -- Darkmoon Card: Earthquake (R)
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I00H")) then IncUnitAbilityLevel(udg_taurenUnit,FourCC("A01O"))
		elseif (itemId == FourCC("I03A")) then IncUnitAbilityLevel(udg_taurenUnit,FourCC("A01W"))
		elseif (itemId == FourCC("I03J")) then Tauren_spiritL = 2
		elseif (itemId == FourCC("I00I") or itemId == FourCC("I03D")) then
			udg_taurenPulverizeRequired = udg_taurenPulverizeRequired - 1
		end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,udg_taurenItemBool,itemTableUlt)

end


function TaurenAbilsInit(pInt)

	Tauren_SpiritStampede = CreateTrigger()

	Tauren_spiritX = {} 			-- spirit create points
	Tauren_spiritY = {}
	Tauren_spiritU = {} 			-- spirit unit
	Tauren_spiritX2 = {} 			-- spirit move points
	Tauren_spiritY2 = {}
	Tauren_spiritKB = {} 			-- was unit knocked back already? if so, don't allow additional
	Tauren_spiritL = 1				-- what level is the ult
	Tauren_spiritG = CreateGroup() 	-- KB check group

	local Tauren_SpiritStampede_f = function()

		local caster = GetTriggerUnit()
		local tarX = GetSpellTargetX() -- cast loc
		local tarY = GetSpellTargetY()
		local casterX = GetUnitX(caster)
		local casterY = GetUnitY(caster)
		local distance = 800*Tauren_spiritL
		local cadence = 0.5/Tauren_spiritL
		local facing = AngleBetweenPointsXY(casterX,casterY,tarX,tarY)
		local p = GetOwningPlayer(caster)
		local ticks = 4/cadence
		local dmg = GetHeroStatBJ(bj_HEROSTAT_STR, caster, true)*.25
		if (Tauren_spiritL == 2) then dmg = dmg*1.15 end

		Tauren_spiritX[1],Tauren_spiritY[1] = PolarProjectionXY(casterX,casterY,125,facing-90)
		Tauren_spiritX[2],Tauren_spiritY[2] = PolarProjectionXY(casterX,casterY,250,facing-90)
		Tauren_spiritX[3],Tauren_spiritY[3] = PolarProjectionXY(casterX,casterY,32,facing)
		Tauren_spiritX[4],Tauren_spiritY[4] = PolarProjectionXY(casterX,casterY,125,facing+90)
		Tauren_spiritX[5],Tauren_spiritY[5] = PolarProjectionXY(casterX,casterY,250,facing+90)
		
		for i = 1,5 do
			Tauren_spiritU[i] = CreateUnit(p, FourCC('o019'), Tauren_spiritX[i], Tauren_spiritY[i], facing)
			Tauren_spiritX2[i],Tauren_spiritY2[i] = PolarProjectionXY(GetUnitX(Tauren_spiritU[i]),GetUnitY(Tauren_spiritU[i]),distance,facing) -- move point
			SetUnitMoveSpeed(Tauren_spiritU[i],195*Tauren_spiritL)
			DestroyEffect( AddSpecialEffect('Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl',Tauren_spiritX[i],Tauren_spiritY[i]) )
			IssuePointOrderById(Tauren_spiritU[i], 851986, Tauren_spiritX2[i], Tauren_spiritY2[i]) -- move order
			SetUnitVertexColorBJ(Tauren_spiritU[i], 45, 45, 100, 35)
			UnitApplyTimedLifeBJ( 4.25, FourCC('BTLF'), Tauren_spiritU[i] )
		end

		local kbg = CreateGroup() -- temp group
		local u -- temp unit

		TimerStart(NewTimer(),cadence,true,function()
			local int = 0
			for i2 = 1,5 do
				tarX = GetUnitX(Tauren_spiritU[i2])
				tarY = GetUnitY(Tauren_spiritU[i2])
				DestroyEffect( AddSpecialEffect('Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl',tarX,tarY) )
				DamagePackageDealAOE(udg_taurenUnit, tarX, tarY, 175.0, dmg, false, false, '', '', 'Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl', 1.0)
				GroupEnumUnitsInRange(kbg, tarX, tarY, 175.0, Condition( function() return BasicDamageExpr(p) end ) )
				if (not IsUnitGroupEmptyBJ(kbg)) then
					u = FirstOfGroup(kbg)
					repeat -- initiate kb
						if (not IsUnitInGroup(u,Tauren_spiritG)) then
							GroupAddUnit(Tauren_spiritG,u)
							BasicKnockback(u, facing, 300.0, false, 0.66, nil, nil)
							GroupRemoveUnit(kbg, u)
							u = FirstOfGroup(kbg)
						end
						int = int + 1
					until (u == nil or int > 16)
				end
			end
			ticks = ticks - 1 -- every cadence, reduce toward 0
			if (ticks <= 0) then
				for i3 = 1,5 do
					RemoveUnit(Tauren_spiritU[i3])
					Tauren_spiritU[i3] = nil
				end
				DestroyGroup(kbg)
				GroupClear(Tauren_spiritG) -- units can receive kb again on next cast
				ReleaseTimer()
			end
		end)

	end

	TriggerRegisterPlayerUnitEvent(Tauren_SpiritStampede,Player(pInt - 1),EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(Tauren_SpiritStampede, Filter( function() return GetSpellAbilityId() == FourCC('A04N') end ) )
	TriggerAddAction(Tauren_SpiritStampede,Tauren_SpiritStampede_f)

end
