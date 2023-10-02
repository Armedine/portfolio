---@class EnemyGroup
EnemyGroup = {
    required_difficulty = 1,    -- what minimum difficulty is required?
    mutator_eligible = true,    -- can mutators affect units in this group?
    minion = {
        undead = {
            starter = {},
            midgame = {},
            endgame = {}
        },
        demon = {
            starter = {},
            midgame = {},
            endgame = {}
        },
        beast = {
            starter = {},
            midgame = {},
            endgame = {}
        },
        spectral = {
            starter = {},
            midgame = {},
            endgame = {}
        },
        other = {
            starter = {},
            midgame = {},
            endgame = {}
        },
    },
    elite = {
        undead = {
            starter = {},
            midgame = {},
            endgame = {}
        },
        demon = {
            starter = {},
            midgame = {},
            endgame = {}
        },
        beast = {
            starter = {},
            midgame = {},
            endgame = {}
        },
        spectral = {
            starter = {},
            midgame = {},
            endgame = {}
        },
        other = {
            starter = {},
            midgame = {},
            endgame = {}
        },
    },
    commander = {
        undead = {
            starter = {},
            midgame = {},
            endgame = {}
        },
        demon = {
            starter = {},
            midgame = {},
            endgame = {}
        },
        beast = {
            starter = {},
            midgame = {},
            endgame = {}
        },
        spectral = {
            starter = {},
            midgame = {},
            endgame = {}
        },
        other = {
            starter = {},
            midgame = {},
            endgame = {}
        },
    },
}
EnemyGroup.tribe_ids = {
    -- tribe_ids allows unit types to be constrained globally. However, it must remain as indexed pairs.
    [1] = "undead",
    -- Not yet implemented:
    -- [2] = "demon",
    -- [3] = "beast",
    -- [4] = "spectral",
    -- [5] = "other",
}


---Assigns a unit type to a pre-defined bucket for WaveControllers to use in unit selection.
---
---EnemyUnits are stored in: EnemyGroup[minion_type][tribe_type][game_state_type]
---@param enemy_unit EnemyUnit      -- unit to spawn for corresponding meta types.
---@param minion_type string        -- bucket: minion, elite, commander
---@param tribe_type string         -- bucket: undead, demon, beast, etc.
---@param game_state_type string    -- bucket: starter, midgame, endgame.
---@return EnemyGroup
function EnemyGroup:add_enemy_unit(enemy_unit, minion_type, tribe_type, game_state_type)
    local id = #EnemyGroup[minion_type][tribe_type][game_state_type]+1
    EnemyGroup[minion_type][tribe_type][game_state_type][id] = enemy_unit
    -- print("add unit:", enemy_unit, minion_type, tribe_type, game_state_type, "id="..tostring(id), #EnemyGroup[minion_type][tribe_type][game_state_type])
    return EnemyGroup
end


---Get a random group for a specific game state.
---@param minion_type string -- choose from: "minion", "elite", or "commander"
---@param game_state_type string -- choose from: "starter", "midgame", or "endgame"
function EnemyGroup:get_random_group(minion_type, game_state_type)
    local random_tribe_type_id = math.random(1,#EnemyGroup.tribe_ids)
    -- print("Getting random group:", random_tribe_type_id, minion_type, EnemyGroup.tribe_ids[random_tribe_type_id], game_state_type, "size:", #EnemyGroup[minion_type][EnemyGroup.tribe_ids[random_tribe_type_id]][game_state_type])
    return EnemyGroup[minion_type][EnemyGroup.tribe_ids[random_tribe_type_id]][game_state_type]
end
