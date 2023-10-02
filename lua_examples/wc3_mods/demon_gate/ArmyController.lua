---@class ArmyController
ArmyController = { player = nil, catalog_army_units = nil, hero = nil}
ArmyController.__index = ArmyController


---Create an army manager for a player.
---@param p player -- owner of army
---@return ArmyController
function ArmyController:new(p)
    local o = setmetatable({}, self)
    o.catalog_army_units = {}
    o.player = p
    return o
end


---Add a unit to a player's roster, allowing them to be managed at the end of rounds, etc.
---@param u unit
---@param _is_hero_unit? boolean
function ArmyController:add_roster_unit(u, _is_hero_unit)
    self.catalog_army_units[#self.catalog_army_units+1] = {
        unit = u,
        unit_id = GetUnitTypeId(u),
        is_hero = _is_hero_unit or false
    }
    PlayerController:get_player(self.player).army_manager:add_unit_frame(u)
end


---Heal all units in an army for a percentage of their max health.
---@param value number -- amount (1.0-based e.g. 0.5 is 50%)
---@param _play_effect? GameEffect -- play this effect
function ArmyController:heal_all_units(value, _play_effect)
    self:for_all_catalog_units(function(t)
        if IsUnitAlive(t.unit) then
            AddState(t.unit, "life", value, true)
            if _play_effect then
                _play_effect:play_at_unit(t.unit)
            end
        end
    end)
    if IsUnitAlive(self.hero) then
        AddState(self.hero, "life", value, true)
        if _play_effect then
            _play_effect:play_at_unit(self.hero)
        end
    end
end


---Create new copies of dead units.
---@param _play_effect? GameEffect -- play this effect
function ArmyController:revive_all_units(_play_effect)
    self:for_all_catalog_units(function(t)
        if not IsUnitAlive(t.unit) then
            if t.unit then
                RemoveUnit(t.unit)
            end
            t.unit = ArmyUnit:get_by_id(t.unit_id):place_one(self.player, 0, 1500.0, _play_effect, true)
            PlayerController:get_player(self.player).army_manager:replace_dead_unit(GetUnitTypeId(t.unit), t.unit)
            IssueOrderAttackMove(t.unit, 0, 1000.0)
        end
    end)
end


---Run a function for all unit tables in an army.
---@param func function
function ArmyController:for_all_catalog_units(func)
    for _,t in ipairs(self.catalog_army_units) do
        func(t)
    end
end
