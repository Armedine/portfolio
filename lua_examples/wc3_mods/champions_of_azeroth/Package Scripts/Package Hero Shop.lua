-- Items are stored in a variable called nameItemBool[]
-- In each hero init is a table of raw codes that correspond to the itemBool position.
-- In hero spell triggers, reference nameItemBool[] to implement spell effects.
-- i.e. if the item table for Shaman has index 1 set to 'A001' and the spell it alters is Magma Burst,
-- then shamanItemBool[1] becomes true and can be used in Magma Burst to do its effects.

LUA_VAR_ITEM_TABLE = {}
LUA_VAR_ITEM_TABLE_ULT = {}

-- @pInt = player to generate trigger for (1-10)
-- @func = function to run when an item is picked up by the player
function ItemShopGenerateTrigger(pInt,func)

	local trig = CreateTrigger()
	TriggerRegisterPlayerUnitEventSimple(trig, Player(pInt-1), EVENT_PLAYER_UNIT_PICKUP_ITEM)
	TriggerAddCondition(trig, Condition( function() return GetTriggerUnit() == udg_playerHero[pInt] end))
	TriggerAddAction(trig,func)

end


-- @pInt = player to generate a shop for (1-10)
-- @t = pass in the item table array e.g. {'A001','A002', .. }
-- @f = custom effects function controlled in hero init script
-- @bool = udg_ item bool unique to the hero which gets set to true
-- @t2 = ultimates table
function ItemShopGenerateShop(pInt, t, f, bool, t2)

	ItemShopCreateShops(pInt)

	LUA_VAR_ITEM_TABLE[pInt] = t -- set up global table for base items
	if (t2 ~= nil) then
		LUA_VAR_ITEM_TABLE_ULT[pInt] = t2 -- ult items
	end

	for i = 1,#LUA_VAR_ITEM_TABLE[pInt] do
		if (LUA_VAR_ITEM_TABLE[pInt][i] ~= "") then
			AddItemToStock(udg_playerShop[pInt],FourCC(LUA_VAR_ITEM_TABLE[pInt][i]),1,1)
		end
	end

	local func = function()
		if (GetItemType(GetManipulatedItem()) == ITEM_TYPE_PERMANENT) then
			local itemId = GetItemTypeId(GetManipulatedItem())
			local p = GetConvertedPlayerId(GetOwningPlayer( GetTriggerUnit() ))
			RemoveItemFromStock(udg_playerShop[p], itemId)
			RemoveItemFromStock(udg_playerShopElite[p], itemId)

			for n = 1,#LUA_VAR_ITEM_TABLE[pInt] do
				if (FourCC(LUA_VAR_ITEM_TABLE[pInt][n]) == itemId) then
					bool[n] = true
					f(itemId)
				end
			end
		end
	end

	ItemShopGenerateTrigger(pInt,func)

	if (udg_aiPlayerIsAgent[pInt]) then -- if Doltish AI agent, add possible items
		ai__profileItemTable[pInt] = LUA_VAR_ITEM_TABLE[pInt]
	end

end


-- @pInt = player to limit max mana for throughout the game
-- @int = maximum mana
function ItemShopSetManaCap(pInt, int)
	
	local trig = CreateTrigger()

	BlzSetUnitMaxMana( udg_playerHero[pInt], int )

	TriggerRegisterPlayerUnitEventSimple(trig, Player(pInt-1), EVENT_PLAYER_HERO_LEVEL)
	TriggerRegisterPlayerUnitEventSimple(trig, Player(pInt-1), EVENT_PLAYER_UNIT_PICKUP_ITEM)
	TriggerAddCondition(trig, Condition( function() return GetTriggerUnit() == udg_playerHero[pInt] or GetManipulatingUnit() == udg_playerHero[pInt] end))
	TriggerAddAction(trig, function () BlzSetUnitMaxMana( udg_playerHero[pInt], int ) end)

	return trig
end


-- @pInt = player to add ultimate items for (from LUA_VAR_ITEM_TABLE_ULT)
function ItemShopAddUltItems(pInt)
	for i = 1,#LUA_VAR_ITEM_TABLE_ULT[pInt] do
		AddItemToStock(udg_playerShopElite[pInt],FourCC(LUA_VAR_ITEM_TABLE_ULT[pInt][i]),1,1)
		table.insert(LUA_VAR_ITEM_TABLE[pInt],LUA_VAR_ITEM_TABLE_ULT[pInt][i])
	end
end


-- @pInt = player to add ultimate items for (from LUA_VAR_ITEM_TABLE_ULT)
function ItemShopAddTomeItems(pInt)
	AddItemToStock(udg_playerShopElite[pInt],FourCC('I02A'),1,1)
	AddItemToStock(udg_playerShopElite[pInt],FourCC('I02B'),1,1)
	AddItemToStock(udg_playerShopElite[pInt],FourCC('I02C'),1,1)
end


-- @pInt = player to remove ultimate items for (from LUA_VAR_ITEM_TABLE_ULT)
function ItemShopRemoveUltItems(pInt)
	for i = 1,#LUA_VAR_ITEM_TABLE_ULT[pInt] do
		RemoveItemFromStock(udg_playerShopElite[pInt],FourCC(LUA_VAR_ITEM_TABLE_ULT[pInt][i]),1,1)
	end
end


-- @pInt = player to create item shops for (making UI buttons be last in priority)
function ItemShopCreateShops(pInt)
	local normId
	local eliteId
	local u
	local u2
	if (pInt < 6) then -- horde ids
		normId = FourCC('E00L')
		eliteId = FourCC('E00M')
	else -- alliance ids
		normId = FourCC('E00O')
		eliteId = FourCC('E00N')
	end
	local x = GetLocationX(udg_gameStartShopPoint[pInt])
	local y = GetLocationY(udg_gameStartShopPoint[pInt])
	u = CreateUnit(Player(pInt-1),normId,x,y,270.0)
	udg_playerShop[pInt] = u

	x = GetLocationX(udg_gameStartShopPointElite[pInt])
	y = GetLocationY(udg_gameStartShopPointElite[pInt])
	u2 = CreateUnit(Player(pInt-1),eliteId,x,y,270.0)
	udg_playerShopElite[pInt] = u2
	SetUnitVertexColor(u2, 100, 100, 100, 75)

	u = nil
	u2 = nil
end
