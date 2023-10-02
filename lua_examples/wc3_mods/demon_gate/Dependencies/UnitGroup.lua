---@diagnostic disable: duplicate-set-field
---@class UnitGroup
-- UnitGroup by Planetary @ hiveworkshop.com
-- A simple tool that turns unit groups into tables.
UnitGroup = {
    stack   = {},
    temp    = false,
    tempg   = CreateGroup(),
    -- global filter types:
    G_TYPE_NONE   = 0,   -- get all units, no conditions.
    G_TYPE_DMG    = 1,   -- get units the group owner can damage (enemy).
    G_TYPE_HEAL   = 2,   -- get units the group owner can heal (ally).
    G_TYPE_ALLY   = 3,   -- same as _HEAL, but could be modified later.
    G_TYPE_BUFF   = 4,   -- ``
    G_TYPE_DEBUFF = 5,   -- get units the group owner can debuff (enemy).
    -- dynamically defined:
    p = nil,       -- owner of the group.
    unit    = nil, -- GetFilterUnit reference
}
UnitGroup.__index = UnitGroup


--- create a group as a table for manipulation with other natives
---@param p? player      -- owner of this unit group.
---@param gtype? number  -- the group type to determine filters (see self.G_TYPE_ globals above).
---@return UnitGroup
function UnitGroup:new(p, gtype)
    local o = {}
    setmetatable(o, self)
    o.size  = 0     -- group size when loooping.
    o.loop  = 0     -- index position when looping.
    o.grp   = CreateGroup()
    o.p     = p or nil
    if gtype then
        o:set_type(gtype)
    else
        o.type = self.G_TYPE_NONE
    end
    UnitGroup.stack[o] = o
    return o
end


--- create a group using a rect.
---@param p player
---@param gtype number
---@param rect rect
---@return UnitGroup
function UnitGroup:new_from_rect(p, gtype, rect)
    local o = UnitGroup:new(p, gtype)
    if o.filter then
        GroupEnumUnitsInRect(o.grp, rect, Filter(function() return o.filter() end))
    else
        GroupEnumUnitsInRect(o.grp, rect, nil)
    end
    return o
end


--- create a group of units in range of a target unit.
---@param p player
---@param gtype number
---@param unit unit
---@param range number
---@return UnitGroup
function UnitGroup:new_from_unit_xy(p, gtype, unit, range)
    local o = UnitGroup:new(p, gtype)
    if o.filter then
        GroupEnumUnitsInRange(o.grp, GetUnitX(unit), GetUnitY(unit), range, Filter(function() return o.filter() end))
    else
        GroupEnumUnitsInRange(o.grp, GetUnitX(unit), GetUnitY(unit), range, Filter(function() return true end))
    end
    return o
end


--- create a group of units in range of a point (x/y).
---@param p player
---@param gtype number
---@param x number
---@param y number
---@param range number
---@return UnitGroup
function UnitGroup:new_from_xy(p, gtype, x, y, range)
    local o = UnitGroup:new(p, gtype)
    if o.filter then
        GroupEnumUnitsInRange(o.grp, x, y, range, Filter(function() return o.filter() end))
    else
        GroupEnumUnitsInRange(o.grp, x, y, range, Filter(function() return true end))
    end
    return o
end


--- select a random count of units as a new group from a source group.
---@param count number
---@param sourcegrp UnitGroup
---@return UnitGroup
function UnitGroup:new_from_random(count, sourcegrp)
    local grp = UnitGroup:new()
    DestroyGroup(grp.grp)
    grp.grp = GetRandomSubGroup(count, sourcegrp.grp)
    return grp
end


function UnitGroup:new_from_table(t)
    local o = UnitGroup:new()
    for _,unit in ipairs(t) do
        o:add(unit)
    end
    return o
end


function UnitGroup:set_type(gtype)
    self.type = gtype
    if self.type == self.G_TYPE_DMG then
        self.filter = function() return UnitGroup:fenemy(self.p) end
    elseif self.type == self.G_TYPE_HEAL then
        self.filter = function() return UnitGroup:fally(self.p) end
    elseif self.type == self.G_TYPE_ALLY then
        self.filter = function() return UnitGroup:fally(self.p) end
    elseif self.type == self.G_TYPE_BUFF then
        self.filter = function() return UnitGroup:fally(self.p) end
    elseif self.type == self.G_TYPE_DEBUFF then
        self.filter = function() return UnitGroup:fenemy(self.p) end
    elseif self.type == self.G_TYPE_NONE then
        self.filter = function() return true end
    end
end


function UnitGroup:action(func)
    self:sort()
    self.brk  = false -- passable flag to end loop.
    self.size = self:get_size()
    if self.size > 0 then
        for i = 0, self.size - 1 do
            if not self.brk then
                self.unit = BlzGroupUnitAt(self.grp, i)
                self.loop = i
                func(self.unit) -- run action on self.unit
            else
                break
            end
        end
    end
    return self
end


function UnitGroup:sort()
    self.size = self:get_size()
    BlzGroupAddGroupFast(self.grp, self.tempg)
    GroupClear(self.grp)
    BlzGroupAddGroupFast(self.tempg, self.grp)
    GroupClear(self.tempg)
    return self
end


function UnitGroup:attack_move(x, y)
    self:action(function()
        IssueOrderAttackMove(self.unit, x, y)
    end)
    return self
end


function UnitGroup:add(unit)
    GroupAddUnit(self.grp, unit)
    return self
end


function UnitGroup:remove(unit)
    GroupRemoveUnit(self.grp, unit)
    return self
end


function UnitGroup:clear()
    self:action(function()
        self:remove(self.unit)
    end)
    return self
end


function UnitGroup:destroy()
    DestroyGroup(self.grp)
    if self.stack[self] then self.stack[self] = nil end
    self.grp = nil
end


function UnitGroup:indexunit(x)
    return BlzGroupUnitAt(self.grp, x)
end


function UnitGroup:verifyalive()
    Try(function()
        self:action(function()
            if self.unit and (IsUnitType(self.unit, UNIT_TYPE_DEAD) or GetUnitTypeId(self.unit) == 0) then
                self:remove(self.unit)
            end
        end)
        if self.temp and self:get_size() == 0 then
            self:destroy()
        end
    end)
end


function UnitGroup:get_size()
    return BlzGroupGetSize(self.grp)
end


---Remove all units in the game from this group, with the option to run a function on each unit beforehand.
---@param func? function -- run this function first (passes in each unit as an argument).
function UnitGroup:delete_and_purge_units(func)
    self:action(function()
        if func then func(self.unit) end
        RemoveUnit(self.unit)
    end)
    self:destroy()
end


---Select all units on the map owned by a player and do something to them.
---@param p player         -- for this player
---@param func fun(u:unit) -- run this function for each unit
function UnitGroup:all_player_units(p, func)
    o = UnitGroup:new()
    GroupEnumUnitsInRect(o.grp, GetWorldBounds(), Filter(function() return UnitGroup:fp(p) end))
    if func then
        o:action(func)
    end
    o:destroy()
end


function UnitGroup:e()
    return GetEnumUnit()
end


-- @return filter unit.
function UnitGroup:f()
    return GetFilterUnit()
end


-- @p = does this player own the filter unit.
function UnitGroup:fp(p)
    return p == GetOwningPlayer(GetFilterUnit())
end


-- @p = is filter unit an enemy of this player.
function UnitGroup:fenemy(p)
    return IsPlayerEnemy(p, GetOwningPlayer(GetFilterUnit())) and IsUnitAlive(GetFilterUnit())
end


-- @p = is filter unit an ally of this player.
function UnitGroup:fally(p)
    return IsPlayerAlly(p, GetOwningPlayer(GetFilterUnit())) and IsUnitAlive(GetFilterUnit())
end
