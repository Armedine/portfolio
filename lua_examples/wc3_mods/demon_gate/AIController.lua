---@class AIController
AIController = {

}
AIController.__index = AIController


function AIController:new()
    local o = setmetatable({}, self)
    return o
end


-- TODO:
-- * enemy waves should have an army strength that determines the mixture of possible units.

-- * group enemy types in EnemyGroup that can be added to the enemy army composition dynamically
    -- e.g. the wave strength is 10, ghouls are 2 food, therefore 5 ghouls are possible

-- * ai behaviour definitions and mechanics in AIController
    -- ranged: tries to stay behind allied units
    -- melee: has a chance of short reposition when under 10% health.
    -- caster: has a long reposition before re-engaging when wounded below 75%; uses abilities based on spell_id and spell_timer.

    -- standard: nothing special, obeys attack behavior type
    -- captain: tries to stay among a group of allies to provide an aura or benefit
    -- assassin: tries to target nearby hero units.
    -- afraid: has a long flee when damaged.
    -- aggressive: does not disengage once it finds a target.
    