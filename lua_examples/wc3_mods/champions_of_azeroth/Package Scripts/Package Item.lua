local LUA_VAR_ITEM_BOUNTY_INDEX = 0
local LUA_TRG_ITEM_BOUNTY = {}
local LUA_TRG_ITEM_BOUNTY_COMPLETIONS = {}

-- :: generates a quest for a unit to slay a target unit
-- @bountyHolderUnit = unit or hero that gets awarded
-- @targetUnit = unit or hero to eliminate
-- @awardRange = required distance between holder and target to run award func
-- @awardFunc = pass in the custom function or helper function to award upon completion
-- @bountyString = the name of the bounty displayed to player
function ItemBountyCreateUnitElimQuest(bountyHolderUnit, targetUnit, awardRange, awardFunc, bountyString)

    LUA_VAR_ITEM_BOUNTY_INDEX = LUA_VAR_ITEM_BOUNTY_INDEX + 1

    LUA_TRG_ITEM_BOUNTY[LUA_VAR_ITEM_BOUNTY_INDEX] = CreateTrigger()

    DisplayTimedTextToForce( GetPlayersMatching( Condition( function() return GetFilterPlayer() == GetOwningPlayer(bountyHolderUnit) end ) ), 6.5, '(|cff8080ffItem Bounty|r) Defeat the marked enemy |cffffc800' .. GetUnitName(targetUnit) .. '|r to earn an award from |cffffc800' .. bountyString .. '|r' )

    local func = function()
        local loc = GetUnitLoc(GetTriggerUnit())
        local loc2 = GetUnitLoc(bountyHolderUnit)
        if (DistanceBetweenPoints(loc, loc2) <= awardRange) then
            awardFunc()
            DisplayTimedTextToForce( GetPlayersMatching( Condition( function() return GetFilterPlayer() == GetOwningPlayer(bountyHolderUnit) end ) ), 2.5, '(|cff8080ffItem Bounty|r) Marked enemy defeated! Award granted for: |cffffc800' .. bountyString .. '|r' )
        end
        DestroyTrigger(LUA_TRG_ITEM_BOUNTY[LUA_VAR_ITEM_BOUNTY_INDEX])
        RemoveLocation(loc)
        RemoveLocation(loc2)
    end

    TriggerRegisterPlayerUnitEventSimple(LUA_TRG_ITEM_BOUNTY[LUA_VAR_ITEM_BOUNTY_INDEX], GetOwningPlayer(targetUnit), EVENT_PLAYER_UNIT_DEATH)
    TriggerAddCondition(LUA_TRG_ITEM_BOUNTY[LUA_VAR_ITEM_BOUNTY_INDEX], Condition( function() return GetTriggerUnit() == targetUnit end ))
    TriggerAddAction(LUA_TRG_ITEM_BOUNTY[LUA_VAR_ITEM_BOUNTY_INDEX], func)

end
