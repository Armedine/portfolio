---@class UnitSquad
---Keeps units inside an empty container unit to act a unified squad.
UnitSquad = {
    -- configurable:
    container_unit_id = FourCC('h000'),
    -- instantiated:
    squad_id = nil,
    units = nil,
    -- global:
    locust_id = FourCC('aloc'),
    all_squads = {},
    ids = 0,
}
UnitSquad.__index = UnitSquad


function UnitSquad:new_squad(units_table)
    local o = setmetatable({}, self)
    o.container = CreateUnit(owner, self.container_unit_id, x, y, 270.0)
    o.units = SyncedTable.create()
    for _,u in ipairs(units_table) do
        o.units[#o.units+1] = unit
        UnitAddAbility(u, self.locust_id)
    end
    self.ids = self.ids + 1
    o.new_squad_table = self.ids
    return o
end


function UnitSquad:for_all_units(func)
    for _,u in pairs(self.units) do
        if u then
            func(u)
        end
    end
end


---Kills all units in a squad.
function UnitSquad:kill()
    UnitSquad:for_all_units(KillUnit)
end


---Remove units in a squad from the game.
function UnitSquad:remove_units()
    UnitSquad:for_all_units(RemoveUnit)
end


---Remove a unit squad and its units from the game.
---
---If the squad can be revived or reinstated after death, do not run this on the squad.
function UnitSquad:destroy()
    self:remove_units()
    self.all_squads[self.squad_id] = nil
    -- net-safe table re-sort:
    local new_squad_table, new_id = {}, 0
    for id = 1,self.ids do
        if self.all_squads[id] then
            new_id = new_id + 1
            table.insert(new_squad_table, self.all_squads[new_id])
            self.all_squads[id].squad_id = new_id
        end
    end
    self.ids = new_id
    self.all_squads = new_squad_table
end


function UnitSquad:initialize_state_timer()
    self.timer = CreateTimer()
    TimerStart(self.timer, 0.06, true, function()

    end)
end


-- squad cohesion:


---Issue an order to every unit in a squad
---@param order_id any
---@param _x any
---@param _y any
function UnitSquad:issue_order(order_id, _x, _y)
    UnitSquad:for_all_units(function()
        if _x and _y then
            IssuePointOrderById(u, order_id, x, y)
        else
            IssueImmediateOrderById(u, order_id)
        end
    end)
end


function UnitSquad:initialize_movement_listener()
    self.trig_movement = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(self.trig_movement, EVENT_PLAYER_UNIT_ISSUED_ORDER)
    TriggerAddAction(self.trig_movement, function()
        -- it is a squad container?:
        if GetUnitTypeId(GetTriggerUnit()) == self.container_unit_id then
            -- mimic the command for each containing unit:

        end
    end)
end
