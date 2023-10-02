function CryptFiendInit(unit, i)
	CryptFiendItemsInit(i)
	HeroTriggersCryptFiend(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNCryptFiend.blp'
	LeaderboardUpdateHeroIcon(i)
	EnableTrigger( gg_trg_Crypt_Fiend_Weave )
	EnableTrigger( gg_trg_Crypt_Fiend_Silk_Surge )
	EnableTrigger( gg_trg_Crypt_Fiend_Cocoon )
	EnableTrigger( gg_trg_Crypt_Fiend_Burrow )
	EnableTrigger( gg_trg_Crypt_Fiend_Might_of_Nerub )
	EnableTrigger( gg_trg_Crypt_Fiend_Nerub )
    udg_cryptFiendUnit = unit
	--DisplayTextToForce( GetPlayersAll(), "Debug: Crypt Fiend Initialized")
end

function CryptFiendItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I00R", -- 1 Nerubian Threads (Q)
		"I00S", -- 2 Arachnid Ring of Detonation (W)
		"I00T", -- 3 Regenerative Fibers (E)
		"I00U", -- 4 Burrowing Claws (F)
		"I00V", -- 5 Wand of the Fallen Kingdom (Q)
		"I03X", -- 6 Arachnid Ring of Binding (W)
		"I043", -- 7 Corrosive Fibers (E)
		"I044", -- 8 Spawning Sac (F)
		"I03W", -- 9 Scroll of Ahn'Qiraj (Q)
		"I03Y", -- 10 Arachnid Ring of Corrosion (W)
		"I045" -- 11 Reverberating Fibers (E)
	}
	local itemTableUlt = {
		"I041", -- 12 Mantle of Yath'amon (Q)
		"I040", -- 13 Ix'lar's Noxious Gland (W)
		"I042", -- 14 Anub'esset's Husk (E)
		"I03Z", -- 15 Voru'kar's Talon (F)
		"I047", -- 16 Shell of Anub'arak (R1)
		"I046", -- 17 Crown of Anub'Rekhan (R2)
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I00U")) then IncUnitAbilityLevel(udg_cryptFiendUnit,FourCC("A024")) end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,udg_cryptFiendItemBool,itemTableUlt)

end


function HeroTriggersCryptFiend(pInt)

	CryptFiend_Webfield = CreateTrigger()

	local CryptFiend_Webfield_f = function()

		local caster = GetTriggerUnit()
		local x1 = GetSpellTargetX()
		local y1 = GetSpellTargetY()
		local p = GetOwningPlayer(caster)
		local x2
		local y2
		local u

		u = CreateUnit(p, FourCC('e00F'), x1, y1, 270.0) -- create center web
		UnitApplyTimedLifeBJ( 30.0, FourCC('BTLF'), u )

		if (udg_cryptFiendItemBool[16]) then
			u = CreateUnit(p, FourCC('u00D'), x1, y1, 270.0) -- create mender if item held
			UnitApplyTimedLifeBJ( 15.0, FourCC('B01D'), u )

			for i = 1,6 do -- create radius eggs w/ ult item
				x2,y2 = PolarProjectionXY(x1,y1,165.0,i*60)
				u = CreateUnit(p, FourCC('e00F'), x2, y2, 270.0)
				UnitApplyTimedLifeBJ( 30.0, FourCC('BTLF'), u )
			end

		else

			for i = 1,4 do -- create radius eggs w/o ult item
				x2,y2 = PolarProjectionXY(x1,y1,165.0,i*90-45)
				u = CreateUnit(p, FourCC('e00F'), x2, y2, 270.0)
				UnitApplyTimedLifeBJ( 30.0, FourCC('BTLF'), u )
			end

		end


		u = nil

	end

	TriggerRegisterPlayerUnitEvent(CryptFiend_Webfield,Player(pInt - 1),EVENT_PLAYER_UNIT_SPELL_EFFECT, nil)
	TriggerAddCondition(CryptFiend_Webfield, Filter( function() return GetSpellAbilityId() == FourCC('A04W') end ) )
	TriggerAddAction(CryptFiend_Webfield,CryptFiend_Webfield_f)

end
