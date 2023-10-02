-- Knockback v2.1 by Planetary @ hiveworkshop.com
-- A very primitive knockback system for bootstrapping Lua maps in WC3 Reforged.
-- Latest game version supported: 1.34

Knockback = {
    --configurable:
    colradius   = 32.0,     -- detect terrain collision
    tickrate    = 0.03,     -- timer cadence.
    defaultvel  = 20,       -- default velocity for basic kb calls.
    defaultdist = 500,      -- default distance ``.
    destroydest = true,     -- destroy dustructibles? (note: destructibles that should be invulnerable should have their life set very high e.g. 999,999.).
    destplayeff = true,     -- play effect on dest. collision?
    destradius  = 192.0,    -- search this range for dest.
    destmaxlife = 99999.0,  -- destructibles will only die if they have less than this life amount (else, they are considered invulnerable).
    efftickrate = 6,        -- stagger effect creation.
    colfunc     = nil,      -- run on collision when set (NOTE: do not recursively run kb here, update existing one instead).
    updfunc     = nil,      -- `` on update.
    interrupt   = false,    -- pass this flag to force-cancel a kb instance.
    effect      = 'Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl',
    desteff     = 'Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl',
    abil        = FourCC('Arav'),
    --non-configurable:
    total       = 0,
    stack       = {},
    r_dest      = nil,
    -- misc:
    debug       = false,    -- will spam debug information at you during kb update timers.
}
Knockback.rect    = Rect(0, 0, Knockback.destradius, Knockback.destradius)
Knockback.tmr     = CreateTimer()
Knockback.__index = Knockback


--- initiate a knockback instance for a single unit.
---@param unit unit     -- target unit
---@param angle number    -- direction
---@param _dist? number   -- distance
---@param _dur? number    -- duration to complete over @_dist
---@return table        -- the knockback instance
function Knockback:new(unit, angle, _dist, _dur)
    if unit and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) then
        local o = setmetatable({}, self)
        o.udex  = GetUnitUserData(unit)
        o.unit  = unit
        o.angle = angle
        o.dist  = _dist or Knockback.defaultdist
        o.dur   = _dur or nil
        o.tick  = 0
        o.trav  = 0
        if IsUnitType(unit, UNIT_TYPE_FLYING) then
            o.isflying = true
        end
        Knockback.stack[o] = o
        if Knockback.total == 0 then
            TimerStart(Knockback.tmr, Knockback.tickrate, true, function()
                debugfunc(function()
                    for _,obj in pairs(Knockback.stack) do
                        obj:update()
                    end
                end, "kb update")
                if Knockback.debug then print("running timer") end
            end)
        end
        Knockback.total = Knockback.total + 1
        if Knockback.debug then print("total kb instances: "..Knockback.total) end
        o:init()
        return o
    end
end


--- initiate a knockback for a target unit from an origin point (pushing them away from that origin)
---@param unit unit
---@param x number
---@param y number
---@param _dist? number
---@param _dur? number
---@return table
function Knockback:new_origin(unit, x, y, _dist, _dur)
    return Knockback:new(unit, AngleFromXY(x, y, GetUnitX(unit), GetUnitY(unit)), _dist, _dur)
end


--- initiate knockback for a group of units
---@param grp UnitGroup
---@param x number
---@param y number
function Knockback:new_group(grp, x, y)
    grp:action(function()
        Knockback:new(grp.unit, AngleFromXY(x, y, GetUnitX(grp.unit), GetUnitY(grp.unit)))
    end)
end


function Knockback:init()
    self.x = GetUnitX(self.unit)
    self.y = GetUnitY(self.unit)
    if self.dur and self.dist then
        self.vel = (self.dist/self.dur)/(1.0/self.tickrate)
    else
        self.vel = self.defaultvel
    end
    self.tickmax = math.floor(self.dist/self.vel)
    if self.pause then
        PauseUnit(self.unit, true)
    end
    if Knockback.debug then
        print("init debug:")
        print("self.unit = "..tostring(self.unit))
        print("self.x = "..self.x)
        print("self.y = "..self.y)
        print("self.vel = "..self.vel)
        print("self.dist = "..self.dist)
        print("self.tickmax = "..self.tickmax)
    end
end


function Knockback:update()
    if self:collision() then
        self:destroy()
        return
    else
        self.tick = self.tick + 1
    end
    if self.updfunc then
        self.updfunc(self)
    end
    if not self.interrupt and IsUnitAlive(self.unit) and self.tick < self.tickmax and self.trav < self.dist then
        self.trav = self.trav + self.vel
        self.x, self.y = projectxy(self.x, self.y, self.vel, self.angle)
        -- special effect staggered play for performance/aesthetic:
        if ModuloInteger(self.tick, self.efftickrate) == 0 then
            DestroyEffect(AddSpecialEffect(self.effect, self.x, self.y))
        end
        -- add/remove storm crow for pathing:
        UnitAddAbility(self.unit, self.abil)
        setxy(self.unit, self.x, self.y)
        UnitRemoveAbility(self.unit, self.abil)
    else
        self.delete = true
        self:destroy()
    end
    if Knockback.debug and ModuloInteger(self.tick, 21) then
        print("attempting to update for unit index "..self.udex)
        print("self.unit = "..tostring(self.unit))
        print("self.x = "..self.x)
        print("self.y = "..self.y)
        print("self.vel = "..self.vel)
        print("self.dist = "..self.dist)
        print("self.tickmax = "..self.tickmax)
    end
end


function Knockback:destroy()
    -- hook self.delete to force remove or prevent removal:
    if self.delete then
        if self.pause then
            PauseUnit(self.unit, false)
        end
        for i,v in pairs(self) do
            v = nil
            i = nil
        end
        Knockback.stack[self] = nil
        Knockback.total = Knockback.total - 1
        if Knockback.total <= 0 then
            Knockback.total = 0
            PauseTimer(Knockback.tmr)
        end
        if Knockback.total < 10 then
            -- recycle indeces when size is low:
            table.collapse(Knockback.stack)
        end
    elseif Knockback.debug then
        print("caution: self.delete hooked, instance not removed")
    end
    if Knockback.debug then print("total kb instances: "..Knockback.total) end
end


function Knockback:collision()
    if not self.isflying and (self:terraincollision() or self:destcollision()) then
        -- hook delete in collision func to prevent deletion, etc.
        self.delete = true
        if self.colfunc then
            self.colfunc(self)
        end
        return true
    end
    return false
end


function Knockback:terraincollision()
    self.offsetcheck = self.vel + self.colradius
    self.offsetx, self.offsety = projectxy(self.x, self.y, self.offsetcheck, self.angle)
    if IsTerrainPathable(self.offsetx, self.offsety, PATHING_TYPE_WALKABILITY) then
        return true
    end
    return false
end


function Knockback:destcollision()
    self:updaterect(self.offsetx, self.offsety)
    if self.destroydest then
        EnumDestructablesInRect(Knockback.rect, nil, function() self:hitdestdestroy() end)
    else
        EnumDestructablesInRect(Knockback.rect, nil, function() self:hitdestcollide() end)
    end
    if self.destcol then
        return true
    else
        return false
    end
end


-- destroy destructables.
function Knockback:hitdestdestroy()
    self.r_dest = GetEnumDestructable()
    -- check destructable life to ignore any that are set to invulnerable:
    if GetWidgetLife(self.r_dest) > 0.405 and GetWidgetLife(self.r_dest) < self.destmaxlife and not IsDestructableInvulnerable(self.r_dest) then
        if self.destplayeff and self.desteff then
            DestroyEffect(AddSpecialEffect(self.desteff, GetWidgetX(self.r_dest), GetWidgetY(self.r_dest)))
        end
        SetWidgetLife(self.r_dest, 0)
    elseif GetWidgetLife(self.r_dest) >= self.destmaxlife or IsDestructableInvulnerable(self.r_dest) then
        self.destcol = true
    end
end


function Knockback:updaterect(x, y)
    local w = self.destradius/2
    SetRect(Knockback.rect, x - w, y - w, x + w, y + w)
end


-- find out if there is a nearby destructable to collide with.
function Knockback:hitdestcollide()
    self.r_dest = GetEnumDestructable()
    if self.r_dest and GetWidgetLife(self.r_dest) > 0.405 then
        if IsUnitInRangeXY(
            self.unit,
            GetWidgetX(self.r_dest),
            GetWidgetY(self.r_dest),
            self.destradius)
        then
            self.destcol = true
        end
    end
end


function Knockback:reset()
    -- e.g. for recursive updates of a kb instance.
    self.trav    = 0
    self.tickmax = 0
    self.tick    = 0
    self.delete  = false
end
