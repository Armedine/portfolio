function REPLACEMEInit(unit, i)
	LUA_VAR_REPLACEME_UNIT = unit
	LUA_VAR_REPLACEME_ITEMBOOL = {}
	REPLACEMEItemsInit(i)
	REPLACEMEAbilsInit(i)
	udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNTuskaarBlack.blp'
	LeaderboardUpdateHeroIcon(i)
end

function REPLACEMEItemsInit(pInt)

	-- raw code and descriptions
	local itemTable = {
		"", -- 1 (Q) 
		"", -- 2 (W) 
		"", -- 3 (E) 
		"", -- 4 (Trait) 
		"", -- 5 (Q) 
		"", -- 6 (W) 
		"", -- 7 (E) 
		"", -- 8 (Trait) 
		"", -- 9 (Q) 
		"", -- 10 (W) 
		"" -- 11 (E) 
	}
	local itemTableUlt = {
		"", -- 12 (Q) 
		"", -- 13 (W) 
		"", -- 14 (E) 
		"", -- 15 (Trait) 
		"", -- 16 (R1) 
		"" -- 17 (R2) 
	}

	-- non-itemBool custom effects
	local conditionsFunc = function(itemId)
		--if (itemId == FourCC("I00G")) then IncUnitAbilityLevel(LUA_VAR_REPLACEME_UNIT,FourCC("A031")) end
	end

	ItemShopGenerateShop(pInt,itemTable,conditionsFunc,LUA_VAR_REPLACEME_ITEMBOOL,itemTableUlt)

end

function REPLACEMEAbilsInit(pInt)

	REPLACEME_TrigName1 = CreateTrigger()
	REPLACEME_TrigName2 = CreateTrigger()
	REPLACEME_TrigName3 = CreateTrigger()
	REPLACEME_TrigName4 = CreateTrigger()
	REPLACEME_TrigName5 = CreateTrigger()
	REPLACEME_TrigName6 = CreateTrigger()

	local REPLACEME_TrigName1_f = function()
	end

	local REPLACEME_TrigName2_f = function()
	end

	local REPLACEME_TrigName3_f = function()
	end

	local REPLACEME_TrigName4_f = function()
	end

	local REPLACEME_TrigName5_f = function()
	end

	local REPLACEME_TrigName6_f = function()
	end

	SpellPackCreateTrigger(REPLACEME_TrigName1,REPLACEME_TrigName1_f,pInt,'A06J')
	SpellPackCreateTrigger(REPLACEME_TrigName2,REPLACEME_TrigName2_f,pInt,'A06J')
	SpellPackCreateTrigger(REPLACEME_TrigName3,REPLACEME_TrigName3_f,pInt,'A06J')
	SpellPackCreateTrigger(REPLACEME_TrigName4,REPLACEME_TrigName4_f,pInt,'A06J')
	SpellPackCreateTrigger(REPLACEME_TrigName5,REPLACEME_TrigName5_f,pInt,'A06J')
	SpellPackCreateTrigger(REPLACEME_TrigName6,REPLACEME_TrigName6_f,pInt,'A06J')

end
