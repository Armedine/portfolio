function PriestInit(unit, i)
	PriestItemsInit(i)
	PriestAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNPriest.blp'
	LeaderboardUpdateHeroIcon(i)
	EnableTrigger( gg_trg_Priest_Heal )
	EnableTrigger( gg_trg_Priest_Corrupt_Mind )
	EnableTrigger( gg_trg_Priest_Shadow_Swap )
	EnableTrigger( gg_trg_Priest_Mana_Reset )
	EnableTrigger( gg_trg_Priest_Shadow_Form )
	EnableTrigger( gg_trg_Priest_Visions )
	udg_priestUnit = unit
	udg_heroCanRegenMana[i] = false
	LUA_TRG_PRIEST_MAX_MANA = ItemShopSetManaCap(i, 100)
end

function PriestItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I01K", -- 1 (Q) Lightweight Triage Manual 
		"I01L", -- 2 (W) Nightmare Catcher 
		"I01M", -- 3 (Mana) Irradiated Arcana 
		"I01N", -- 4 (F) Cultist Attire 
		"I01O", -- 5 (Q) Clutch Healing Salve 
		"I05J", -- 6 (W) Spiteful Visions
		"I05L", -- 7 (E) Glyph of Infusion
		"I05M", -- 8 (Trait) Orb of Dubious Dealings
		"I05N", -- 9 (Q) Gem of Warding
		"I05K", -- 10 (W) Phantasm Charm
		"I05O" -- 11 (E) Pendant of Atonement
	}
	local itemTableUlt = {
		"I05Q", -- 12 (Q) Veteran's Triage Satchel
		"I05R", -- 13 (W) Doomsday Pact
		"I05S", -- 14 (E) Scroll of Restitution
		"I05T", -- 15 (Passive) Libram of Ancient Mana
		"I05U", -- 16 (R1) Libram of Holy Fire
		"I05P" -- 17 (R2) Libram of Shadows
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I01L")) then
			IncUnitAbilityLevel(udg_priestUnit,FourCC("A017"))
		elseif (itemId == FourCC("I01M")) then
			DestroyTrigger(LUA_TRG_PRIEST_MAX_MANA)
			LUA_TRG_PRIEST_MAX_MANA = ItemShopSetManaCap(GetConvertedPlayerId(GetOwningPlayer(udg_priestUnit)), 120)
		elseif (itemId == FourCC("I01N")) then
			IncUnitAbilityLevel(udg_priestUnit,FourCC("A01A"))
		elseif (itemId == FourCC("I05T")) then
			TimerStart(NewTimer(),4.0,true,function() DamagePackageAddMana(udg_priestUnit,1,true) end)
		end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,udg_priestItemBool,itemTableUlt)

end

function PriestAbilsInit(pInt)

	Priest_HolyFire = CreateTrigger()

	local Priest_HolyFire_f = function()

		local caster = GetTriggerUnit()
		local target = GetSpellTargetUnit()
		local g = CreateGroup()
		local x = GetUnitX(target)
		local y = GetUnitY(target)
		if (udg_priestItemBool[16]) then
			DamagePackageRestoreHealth(target,50,true,nil,caster)
		else
			DamagePackageRestoreHealth(target,25,true,nil,caster)
		end

		GroupEnumUnitsInRange(g, x, y, 500.0, Condition( function() return
			IsUnitAlly(GetFilterUnit(),GetOwningPlayer(caster))
			and IsUnitAliveBJ(GetFilterUnit())
			and IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO)
			and not IsUnitType(GetFilterUnit(),UNIT_TYPE_ANCIENT) end ) )
		if (not IsUnitGroupEmptyBJ(g)) then
			local u = FirstOfGroup(g)
			local i = 0
		 	repeat
		 		DamagePackageDummyTarget(u,'A05L','innerfire')
		 		DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Orc\\SpiritLink\\SpiritLinkZapTarget.mdl',GetUnitX(u),GetUnitY(u)))
			    GroupRemoveUnit(g, u)
			    u = FirstOfGroup(g)
			    i = i + 1
		  	until (u == nil or i == 10) -- prevent infinite loop
		end

		DestroyGroup(g)

	end

	TriggerRegisterPlayerUnitEvent(Priest_HolyFire,Player(pInt - 1),EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(Priest_HolyFire, Filter( function() return GetSpellAbilityId() == FourCC('A05K') end ) )
	TriggerAddAction(Priest_HolyFire,Priest_HolyFire_f)

end
