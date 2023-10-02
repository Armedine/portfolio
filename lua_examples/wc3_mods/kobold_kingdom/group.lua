g = {}


function g:init()
    self.debug    = false
    self.__index  = self
    self.stack    = {}
    self.temp     = false
    self.tempg    = CreateGroup()
    g_type_none   = 0
    g_type_dmg    = 1
    g_type_heal   = 2
    g_type_ally   = 3
    g_type_buff   = 4
    g_type_debuff = 5
end


function g:new(p, gtype)
    local o = {}
    setmetatable(o, self)
    o.size  = 0     -- group size when loooping.
    o.loop  = 0     -- index position when looping.
    o.grp   = CreateGroup()
    o.p     = p or nil
    if gtype then
        o:settype(gtype)
    else
        o.type = g_type_none
    end
    g.stack[o] = o
    if g.debug then print(utils.tablelength(self.stack)) end
    return o
end


function g:newbyrect(p, gtype, rect)
    local o = g:new(p, gtype)
    if o.filter then
        GroupEnumUnitsInRect(o.grp, rect, Filter(function() return o.filter() end))
    else
        GroupEnumUnitsInRect(o.grp, rect, nil)
    end
    return o
end


function g:newbyunitloc(p, gtype, unit, r)
    local o = g:new(p, gtype)
    if o.filter then
        GroupEnumUnitsInRange(o.grp, GetUnitX(unit), GetUnitY(unit), r, Filter(function() return o.filter() end))
    else
        GroupEnumUnitsInRange(o.grp, GetUnitX(unit), GetUnitY(unit), r, Filter(function() return true end))
    end
    return o
end


function g:newbyxy(p, gtype, x, y, r)
    local o = g:new(p, gtype)
    if o.filter then
        GroupEnumUnitsInRange(o.grp, x, y, r, Filter(function() return o.filter() end))
    else
        GroupEnumUnitsInRange(o.grp, x, y, r, Filter(function() return true end))
    end
    return o
end


function g:newbyrandom(count, sourcegrp)
    local grp = g:new()
    DestroyGroup(grp.grp)
    grp.grp = GetRandomSubGroup(count, sourcegrp.grp)
    return grp
end


function g:newbytable(t)
    local o = g:new()
    for _,unit in ipairs(t) do
        o:add(unit)
    end
    return o
end


-- @typestr = "dmg" for only enemies, "heal" or "ally" for only allies, "none" for no filter.
function g:settype(gtype)
    self.type = gtype
    if self.type == g_type_dmg then
        self.filter = function() return g:fenemy(self.p) end
    elseif self.type == g_type_heal then
        self.filter = function() return g:fally(self.p) end
    elseif self.type == g_type_ally then
        self.filter = function() return g:fally(self.p) end
    elseif self.type == g_type_buff then
        self.filter = function() return g:fally(self.p) end
    elseif self.type == g_type_debuff then
        self.filter = function() return g:fenemy(self.p) end
    elseif self.type == g_type_none then
        self.filter = function() return true end
    end
end


function g:action(func)
    self:sort()
    self.brk  = false -- passable flag to end loop.
    self.size = self:getsize()
    if self.size > 0 then
        for i = 0, self.size-1 do
            if not self.brk then
                self.unit = BlzGroupUnitAt(self.grp, i)
                self.loop = i
                func() -- run action on self.unit
            else
                break
            end
        end
    end
    return self
end


function g:sort()
    self.size = self:getsize()
    BlzGroupAddGroupFast(self.grp, self.tempg)
    GroupClear(self.grp)
    BlzGroupAddGroupFast(self.tempg, self.grp)
    GroupClear(self.tempg)
end


function g:attackmove(x, y)
    self:action(function()
        utils.issatkxy(self.unit, x, y)
    end)
end


function g:add(unit)
    GroupAddUnit(self.grp, unit)
end


function g:remove(unit)
    GroupRemoveUnit(self.grp, unit)
end


function g:clear()
    self:action(function()
        self:remove(self.unit)
    end)
end


function g:destroy()
    DestroyGroup(self.grp)
    if self.stack[self] then self.stack[self] = nil end
    self.grp = nil
    utils.tablecollapse(self.stack)
    if g.debug then print(utils.tablelength(self.stack)) end
end


function g:indexunit(x)
    return BlzGroupUnitAt(self.grp, x)
end


function g:verifyalive()
    utils.debugfunc(function()
        self:action(function()
            if self.unit and (IsUnitType(self.unit, UNIT_TYPE_DEAD) or GetUnitTypeId(self.unit) == 0) then
                self:remove(self.unit)
            end
        end)
        if self.temp and self:getsize() == 0 then
            self:destroy()
        end
    end, "verifyalive")
end


function g:getsize()
    return BlzGroupGetSize(self.grp)
end


function g:completepurge()
    self:action(function()
        if not (utils.pnum(utils.powner(self.unit)) < kk.maxplayers+1 
            and IsUnitType(self.unit, UNIT_TYPE_HERO)) and not GetUnitTypeId(self.unit) ~= buffy.dummyid then
                if map.mission.cache and map.mission.cache.boss and GetUnitTypeId(self.unit) == FourCC(map.mission.cache.boss.bossid) then
                    if map.manager.success then
                        -- do nothing to preserve death of unit.
                    else
                        -- player failed, allow boss removal during map cleanup.
                        RemoveUnit(self.unit)
                    end
                else
                    RemoveUnit(self.unit)
                end
            end
    end)
    self:destroy()
end


function g:hasunit(unit)
    bool = false
    self:action(function()
        if self.unit == unit then
            self.brk = true
            bool = true
        end
    end)
    return bool
end


function g:e()
    return GetEnumUnit()
end


-- @return filter unit.
function g:f()
    return GetFilterUnit()
end


-- @p = does this player own the filter unit.
function g:fp(p)
    return p == GetOwningPlayer(GetFilterUnit())
end


-- @p = is filter unit an enemy of this player.
function g:fenemy(p)
    return IsPlayerEnemy(p, GetOwningPlayer(GetFilterUnit())) and utils.isalive(GetFilterUnit())
end


-- @p = is filter unit an ally of this player.
function g:fally(p)
    return IsPlayerAlly(p, GetOwningPlayer(GetFilterUnit())) and utils.isalive(GetFilterUnit()) and utils.powner(GetFilterUnit()) ~= Player(25)
end


-- @effect = play this effect on every unit in the group.
function g:playeffect(speffect)
    self:action(function()
        if utils.isalive(self.unit) then
            speffect:playu(self.unit)
        end
    end)
end
