---@class EnemyUnit
EnemyUnit = {
    -- globals:
    catalog = {},           -- stores a string lookup for units by "unit_name"
    -- metadata:
    name = nil,             -- In-game name.
    army_power = nil,       -- how much of a wave composition this unit takes up (synonymous to a unit's power level).
    unit_id = nil,          -- FourCC
    is_minion = true,       -- standard common-pick unit in waves.
    is_commander = false,   -- `` commanders
    is_elite = false,       -- `` elites.
    -- unit default stats:
    unit_health = 100.0,
    unit_mana = 0.0,
    unit_attack = 4.0,
    unit_attack_rate = 2.2,
    unit_armor = 0.0,
    -- unit default scaling:
    unit_health_scale = 1.0,
    unit_mana_scale = 1.0,
    unit_attack_scale = 1.0,
    unit_attack_rate_scale = 1.0,
    -- behavior:
    is_caster = false,
    is_melee = false,
    is_ranged = false,
    behavior_type = nil,
}
EnemyUnit.__index = EnemyUnit


---Create a new spawnable enemy type to use in enemy waves.
---@param name string -- unit name.
---@param unit_id string -- the four character code (NON-FourCC) string.
---@param army_power integer -- determines the strength of the unit and how many will spawn in a wave.
---@param behavior_type string -- pick from 'standard', 'aggresive', 'captain', 'assassin', 'afraid'.
---@return EnemyUnit
function EnemyUnit:new(name, unit_id, army_power, behavior_type)
    local o = setmetatable({}, self)
    o.name = name
    o.unit_id = FourCC(unit_id)
    o.army_power = army_power
    o.behavior_type = behavior_type or "standard"
    self.catalog[string.gsub(string.lower(name), " ", "_")] = o -- convert 'Unit Name' to 'unit_name'
    return o
end


function EnemyUnit:set_as_type(minion_type, tribe_type, game_state_type)
    if minion_type == "minion" then
        self.is_minion = true
    elseif minion_type == "elite" then
        self.is_elite = true
        self.is_minion = false
    elseif minion_type == "commander" then
        self.is_commander = true
        self.is_minion = false
    end
    -- print("Adding unit to group:", self.name, minion_type, tribe_type, game_state_type)
    EnemyGroup:add_enemy_unit(self, minion_type, tribe_type, game_state_type)
    return self
end


---Units are based on a 100-health, 5-attack, and 2.0 attack rate template that scales with individual settings and additional global multipliers.
---
---
---@param unit_health_scale number -- 1.0-based (e.g. 0.5 for 50%)
---@param unit_mana_scale number -- 1.0-based (e.g. 0.5 for 50%)
---@param unit_attack_scale? number -- 1.0-based (e.g. 0.5 for 50%)
---@param unit_attack_rate_scale? number -- 1.0-based (e.g. 0.5 for 50%)
function EnemyUnit:set_stats(unit_health_scale, unit_mana_scale, unit_attack_scale, unit_attack_rate_scale)
    self.unit_health_scale = unit_health_scale
    self.unit_mana_scale = unit_mana_scale
    self.unit_attack_scale = unit_attack_scale or self.unit_attack_scale
    self.unit_attack_rate_scale = unit_attack_rate_scale or self.unit_attack_rate_scale
    self.unit_health = math.floor(self.unit_health_scale*self.unit_health)
    self.unit_mana = math.floor(self.unit_mana_scale*self.unit_mana)
    self.unit_attack = math.floor(self.unit_attack_scale*self.unit_attack)
end


function EnemyUnit:set_as_melee()
    self.is_melee = true
    return self
end


function EnemyUnit:set_as_ranged()
    self.is_ranged = true
    return self
end


function EnemyUnit:set_as_caster()
    self.is_caster = true
    return self
end


---Run a function on a unit when they die.
---@param on_death_func function
function EnemyUnit:attach_on_death_event(on_death_func)
    -- TODO: should probably do a spell/event helper class so we can easily assign these in gamedata
    --       without it getting cluttered.
    if self.triggers then
        self.triggers["death"]:assign_action(on_death_func, self.name.."_death")
    else
        print_error("Load order for EnemyUnit is wrong, self.triggers is nil")
    end
    return self
end


function EnemyUnit:attach_missile_attack(u, missile_type)
    -- self.attack_missile = missile_type
    -- TODO: create a class for missile attacks that can be attached to units to replace their default attack.
    -- it needs velocity, maximum travel distance, if it arcs, damage, and damage type
    return self
end


---Spawn an enemy at this position, with option to do a special spawn-in decoration or effect.
---@param x integer -- coord.
---@param y integer -- ``
---@param _health_multiplier? number -- 1.0-based, additional scalar value.
---@param _attack_multiplier? number -- ``
function EnemyUnit:spawn(x, y, _health_multiplier, _attack_multiplier)
    local u = CreateUnit(GameController.demon_player, self.unit_id, x, y, AngleFromXY(x, y, 0, 1000.0))
    local unit_index = UnitIndexer:add_index(u)
    GameController.spawned_units_alive = GameController.spawned_units_alive + 1
    GameController.spawned_units_total = GameController.spawned_units_total + 1
    GameController.spawned_units_table[unit_index] = u
    -- initialize default stats:
    InitializeUnitState(u, self.unit_health, self.unit_mana, self.unit_attack, self.unit_attack_rate, self.unit_armor)
    -- additional stat scaling:
    -- SetState(u, "max_health", GameController:get_setting("players_present_health_scaling"), true)
    if _health_multiplier and _health_multiplier ~= 1.0 then
        SetState(u, "max_health", _health_multiplier, true)
    end
    SetUnitBaseDamageScaled(u, GameController:get_setting("players_present_damage_scaling"), 0)
    if _attack_multiplier and _attack_multiplier ~= 1.0 then
        SetUnitBaseDamageScaled(u, _attack_multiplier, 0)
    end
    -- wrap-up:
    SetState(u, "all", 1.0, true)
    SetUnitColor(u, PLAYER_COLOR_COAL)
    IssueOrderMoveToXY(u, 0.0, 1536.0) -- fix "patrol back" bug from only attack-moving.
    IssueOrderAttackMove(u, 0.0, 1536.0) -- portal center.
    NewEffect["fel_flamestrike"]:play(x, y)
    return u
end


-- Initialize:
-- More TODO here.
OnTrigInit(function()
    local trigger_list = { "death", "spell_effect", "attacked", "damaged" }
    EnemyUnit.triggers = {}
    for _, trig_type in ipairs(trigger_list) do
        EnemyUnit.triggers[trig_type] = TriggerHelper:new("unit", trig_type, Player(4))
    end
    trigger_list = nil
end)
