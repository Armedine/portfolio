function WispInit(unit, i)
	WispItemsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNWisp.blp'
	LeaderboardUpdateHeroIcon(i)
	EnableTrigger( gg_trg_Wisp_Health_Listener )
	EnableTrigger( gg_trg_Wisp_Build )
	EnableTrigger( gg_trg_Wisp_Destroy )
	EnableTrigger( gg_trg_Wisp_Night )
	EnableTrigger( gg_trg_Wisp_Moonlight_Blast )
	EnableTrigger( gg_trg_Wisp_Star_Bomb )
	EnableTrigger( gg_trg_Wisp_Collapse )
	udg_WispUnit = unit
    udg_heroCanBecomeVulnerable[i] = false
	--DisplayTextToForce( GetPlayersAll(), "Debug: Wisp Initialized")
end

function WispItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"I01W", -- 1 (B) Serrated Glaive 
		"I01U", -- 2 (W) Concentrated Moonlight 
		"I01V", -- 3 (E) Fulminating Star Residue 
		"I01X", -- 4 (Trait) Staff of Elune 
		"I01Y", -- 5 (B) Evanescent Pauldrons 
		"I068", -- 6 (W) Lunar Beacon
		"I067", -- 7 (E) Ethereal Potion
		"I06C", -- 8 (Trait) Gust of Elune
		"I06E", -- 9 (B) Watcher Rod
		"I06D", -- 10 (W) Moon Rod
		"I069" -- 11 (E) Star Rod
	}
	local itemTableUlt = {
		"I06B", -- 12 (B) Sentinel Siege Weaponry
		"I06G", -- 13 (W) Remnant of Darnassus
		"I06H", -- 14 (E) Fallen Star
		"I06I", -- 15 (Active) Talisman of Teldrassil
		"I06A", -- 16 (R1) Scepter of the World Tree
		"I06F" -- 17 (R2) Congealed Dark Matter
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		if (itemId == FourCC("I068")) then IncUnitAbilityLevel(udg_WispUnit,FourCC("A01T"))
		elseif (itemId == FourCC("I06A")) then TimerStart(NewTimer(),8.0,true,function()
			AdjustPlayerStateBJ(1, GetOwningPlayer(udg_WispUnit), PLAYER_STATE_RESOURCE_LUMBER ) end)
		elseif (itemId == FourCC("I06B")) then SetPlayerTechResearchedSwap( FourCC('R00A'), 1, GetOwningPlayer(udg_WispUnit) )
		elseif (itemId == FourCC("I06H")) then IncUnitAbilityLevel(udg_WispUnit,FourCC("A01R")) end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,udg_wispItemBool,itemTableUlt)

end
