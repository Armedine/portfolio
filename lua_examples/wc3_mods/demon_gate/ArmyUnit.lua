---@class ArmyUnit
---Globally configures spawned army units.
ArmyUnit = {
    icon = nil,
    unit_id = nil,
    squad_size = 1,
    health = 250.0,
    mana = 0.0,
    attack = 5.0,
    attack_rate = 2.0,
    armor = 0.0,
    faction_stack = {},
    stack = {},
    id_lookup = {},
    -- unit default scaling:
    health_scale = 1.0,
    mana_scale = 1.0,
    attack_scale = 1.0,
    attack_rate_scale = 1.0,
}
ArmyUnit.__index = ArmyUnit


---Create a new army unit type.
---@param unit_id string
---@param army_power integer
---@param faction_id integer
---@param unit_name string
---@param rarity_id integer
---@return ArmyUnit
function ArmyUnit:new(unit_id, army_power, faction_id, unit_name, rarity_id, _squad_size)
    local o = setmetatable({}, self)
    o.unit_id = FourCC(unit_id)
    o.unit_name = unit_name
    o.rarity_id = rarity_id
    o.faction_id = faction_id
    o.army_power = army_power
    o.squad_size = _squad_size or self.squad_size
    if not self.faction_stack[faction_id] then
        self.faction_stack[faction_id] = {}
    end
    self.faction_stack[faction_id][#self.faction_stack[faction_id]+1] = o
    self.stack[#self.stack+1] = o
    self.id_lookup[o.unit_id] = o
    return o
end


function ArmyUnit:set_icon(path)
    self.icon = path
    return self
end


---Get an ArmyUnit object from a unit's unit id.
---@param unit_id integer
---@return ArmyUnit
function ArmyUnit:get_by_id(unit_id)
    return self.id_lookup[unit_id]
end


---(Not implemented because natives do not work) Delete the [Faction Name] organization tag from the unit's world editor name.
---@param u unit
---@return ArmyUnit
function ArmyUnit:remove_faction_from_name(u)
    BlzSetUnitName(u, string.gsub(GetUnitName(u), "%[.+%] ", ""))
    return self
end


---Units are based on a 100-health, 5-attack, and 2.0 attack rate template that scales with individual settings and additional global multipliers.
---@param health_scale number -- 1.0-based (e.g. 0.5 for 50%)
---@param mana_scale number -- 1.0-based (e.g. 0.5 for 50%)
---@param attack_scale? number -- 1.0-based (e.g. 0.5 for 50%)
---@param attack_rate_scale? number -- 1.0-based (e.g. 0.5 for 50%)
function ArmyUnit:set_stats(health_scale, mana_scale, attack_scale, attack_rate_scale)
    self.health_scale = health_scale
    self.mana_scale = mana_scale
    self.attack_scale = attack_scale or self.attack_rate
    self.attack_rate_scale = attack_rate_scale or self.attack_rate_scale
    self.health = math.floor(self.health_scale*self.health)
    self.mana = math.floor(self.mana_scale*self.mana)
    self.attack = math.floor(self.attack_scale*self.attack)
    return self
end


function ArmyUnit:has_mana(value)
    self.mana = value or 25.0
    return self
end


---Create an individual army unit.
---@param p player -- owner of new unit.
---@param x number -- at this x.
---@param y number -- `` y.
---@param _effect? GameEffect -- plays this special effect at @x,@y.
---@param _ignore_roster? boolean -- set to true if this unit is not a new army unit.
---@return unit
function ArmyUnit:create_unit(p, x, y, _effect, _ignore_roster)
    local new_unit = CreateUnit(p, self.unit_id, x, y, 270.)
    ArmyUnit:remove_faction_from_name(new_unit)
    InitializeUnitState(new_unit, self.health, self.mana, self.attack, self.attack_rate, self.armor, true)
    SetState(new_unit, "max_life", GameController:get_setting("player_health"), true)
    if _effect then
        _effect:play_at_unit(new_unit)
    end
    -- player settings:
    if not _ignore_roster then
        PlayerController:get_player(p).army_controller:add_roster_unit(new_unit)
    end
    PlayerController:get_player(p):set_faction_color(new_unit)
    -- wrap-up:
    SetState(new_unit, "all", 1.0, true)
    SetUnitUseFood(new_unit, false)
    SetPlayerStateBJ(p, PLAYER_STATE_RESOURCE_FOOD_USED, GetPlayerState(p, PLAYER_STATE_RESOURCE_FOOD_USED) + 1)
    return new_unit
end


---Create an army unit squad.
---@param p player -- owner of new unit.
---@param x number -- at this x.
---@param y number -- `` y.
---@param _effect? GameEffect -- plays this special effect at @x,@y.
---@param _ignore_roster? boolean -- set to true if this unit is not a new army unit.
---@return table<unit>
function ArmyUnit:place_squad(p, x, y, _effect, _ignore_roster)
    local t = {}
    for idx = 1,self.squad_size do
        t[idx] = self:create_unit(p, x, y, _effect, _ignore_roster)
        if PlayerController:get_player(p) and PlayerController:get_player(p).hero and IsUnitAlive(PlayerController:get_player(p).hero) then
            IssueOrderMoveToXY(t[idx], GetUnitXY(PlayerController:get_player(p).hero))
        else
            IssueOrderMoveToXY(t[idx], 0, 1024)
        end
    end
    return t
end


---Create an individual unit type.
---@param p player -- owner of new unit.
---@param x number -- at this x.
---@param y number -- `` y.
---@param _effect? GameEffect -- plays this special effect at @x,@y.
---@param _ignore_roster? boolean -- set to true if this unit is not a new army unit.
---@return table<unit>
function ArmyUnit:place_one(p, x, y, _effect, _ignore_roster)
    return self:create_unit(p, x, y, _effect, _ignore_roster)
end
