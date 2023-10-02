do
    kb = {
        --[[
            configurable:
        --]]
        colradius   = 32.0,     -- detect terrain collision
        tickrate    = 0.03,     -- timer cadence.
        defaultvel  = 20,       -- default velocity for basic kb calls.
        defaultdist = 500,      -- default distance ``.
        terraincol  = true,     -- set to false to ignore terrain.
        destroydest = true,     -- destroy dustructibles? (note: system collides with invul dest.).
        destradius  = 192.0,    -- search this range for dest.
        destplayeff = true,     -- play effect on dest. collision?
        arc         = false,    -- should unit do parabolic movement (toss or throw)?
        arch        = 375,      -- if arc enabled, how high?
        efftickrate = 6,        -- stagger effect creation.
        colfunc     = nil,      -- run on collision when set (NOTE: do not recursively run kb here, update existing one instead).
        updfunc     = nil,      -- `` on update.
        endfunc     = nil,      -- `` on end of kb path.
        interrupt   = false,    -- pass this flag to force-cancel a kb instance.
        effect      = 'Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl',
        desteff     = 'Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl',
        abil        = FourCC('Arav'),
        debug       = false,
        --[[
            non-configurable:
        --]]
        total       = 0,
        stack       = {},
    }
    kb.rect    = Rect(0, 0, kb.destradius, kb.destradius)
    kb.tmr     = NewTimer()
    kb.__index = kb
end


-- @unit    = unit to knock back.
-- @angle   = towards this angle.
-- [@_dist] = set a distance.
-- [@_dur]  = set a duration (required with @_dist!).
function kb:new(unit, angle, _dist, _dur)
    if unit and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and not IsUnitType(unit, UNIT_TYPE_ANCIENT) then
        local o = setmetatable({}, self)
        o.udex  = GetUnitUserData(unit)
        o.unit  = unit
        o.angle = angle
        o.dist  = _dist or kb.defaultdist
        o.dur   = _dur or nil
        o.tick  = 0
        o.trav  = 0
        if kb.stack[o.udex] then
            kb.stack[o.udex]:deletekb()
        end
        kb.stack[o.udex] = o
        if kb.total == 0 then
            TimerStart(kb.tmr, kb.tickrate, true, function()
                utils.debugfunc(function()
                    if not map.manager.sbactive then
                        for _,obj in pairs(kb.stack) do
                            obj:update()
                        end
                    else
                        for _,obj in pairs(kb.stack) do
                            obj:deletekb()
                        end
                    end
                end, "kb update")
                if kb.debug then print("running timer") end
            end)
        end
        kb.total = kb.total + 1
        if kb.debug then print("total kb instances: "..kb.total) end
        -- mark player being knocked back for external logic:
        if utils.pnum(utils.powner(o.unit)) <= kk.maxplayers then
            kobold.player[utils.powner(o.unit)].currentlykb = true
        end
        o:init()
        return o
    end
end


-- @unit    = unit to knock back.
-- @x,y     = from this origin coord.
-- [@_dist] = set a distance.
-- [@_dur]  = set a duration (required with @_dist!).
function kb:new_origin(unit, x, y, _dist, _dur)
    return kb:new(unit, utils.anglexy(x, y, GetUnitX(unit), GetUnitY(unit), _dist, _dur))
end


-- @grp     = get units to knock back.
-- @x,y     = from this origin coord.
-- [@_dist] = set a distance.
-- [@_dur]  = set a duration (required with @_dist!).
function kb:new_group(grp, x, y, _dist, _dur)
    grp:action(function()
        kb:new(grp.unit, utils.anglexy(x, y, GetUnitX(grp.unit), GetUnitY(grp.unit)), _dist, _dur)
    end)
end


-- @p       = for this player.
-- @x,y     = from this origin coord.
-- @r       = radius to search for.
-- [@_dist] = set a distance.
-- [@_dur]  = set a duration (required with @_dist!).
function kb:new_pgroup(p, x, y, r, _dist, _dur)
    local grp = g:newbyxy(p, g_type_dmg, x, y, r)
    grp:action(function()
        kb:new(grp.unit, utils.anglexy(x, y, GetUnitX(grp.unit), GetUnitY(grp.unit)), _dist, _dur)
    end)
    grp:destroy()
end


-- @grp     = get units to pull in.
-- @x,y     = toward this origin coord.
-- [@_dur]  = set a duration.
function kb:new_pullgroup(grp, x, y, _dur, _vel)
    local d = 0
    grp:action(function()
        d = utils.distxy(x, y, utils.unitx(grp.unit), utils.unity(grp.unit))
        kb:new(grp.unit, utils.anglexy(GetUnitX(grp.unit), GetUnitY(grp.unit), x, y), d, _dur)
    end)
end


function kb:init()
    if IsUnitType(self.unit, UNIT_TYPE_FLYING) then
        self.isflying = true
    end
    if utils.pnum(utils.powner(self.unit)) < kk.maxplayers then
        self.p = utils.powner(self.unit)
    end
    self.x = GetUnitX(self.unit)
    self.y = GetUnitY(self.unit)
    self.z = 0 -- only used when arc is set.
    if self.dur and self.dist then
        self.vel = (self.dist/self.dur)/(1.0/self.tickrate)
    else
        self.vel = self.defaultvel
    end
    self.tickmax = math.floor(self.dist/self.vel)
    if self:collision() then
        self:destroy()
        return
    end
    if self.pause then
        PauseUnit(self.unit, true)
    end
    if kb.debug then
        print("init debug:")
        print("self.unit = "..tostring(self.unit))
        print("self.x = "..self.x)
        print("self.y = "..self.y)
        print("self.vel = "..self.vel)
        print("self.dist = "..self.dist)
        print("self.tickmax = "..self.tickmax)
    end
end


function kb:update()
    if self.tick > 1 and self:collision() then
        self:destroy()
        return
    else
        self.tick = self.tick + 1
    end
    if self.updfunc then
        self.updfunc(self)
    end
    if self.p and kobold.player[self.p].downed then
        self:deletekb()
    elseif not self.interrupt and utils.isalive(self.unit) and self.tick < self.tickmax and self.trav < self.dist then
        self.trav = self.trav + self.vel
        self.x, self.y = utils.projectxy(self.x, self.y, self.vel, self.angle)
        -- special effect staggered play for performance/aesthetic:
        if self.effect and ModuloInteger(self.tick, self.efftickrate) == 0 then
            DestroyEffect(AddSpecialEffect(self.effect, self.x, self.y))
        end
        -- add/remove storm crow for pathing:
        UnitAddAbility(self.unit, self.abil)
        utils.setxy(self.unit, self.x, self.y)
        if self.arc then
            if not self.cachedh then self.cachedh = GetUnitFlyHeight(self.unit) end
            if self.z == 0.0 then
                self.z = self:getheight()
            end
            self.z = (4*self.arch/self.dist)*(self.dist - self.trav)*(self.trav/self.dist) -- + self:getheight()
            utils.setheight(self.unit, self.z)
        end
        UnitRemoveAbility(self.unit, self.abil)
    else
        self:deletekb()
    end
    if kb.debug and ModuloInteger(self.tick, 21) then
        print("attempting to update for unit index "..self.udex)
        print("self.unit = "..tostring(self.unit))
        print("self.x = "..self.x)
        print("self.y = "..self.y)
        print("self.vel = "..self.vel)
        print("self.dist = "..self.dist)
        print("self.tickmax = "..self.tickmax)
    end
end


-- conditional destroy.
function kb:destroy()
    -- hook self.delete to force remove or prevent removal (for advanced users):
    if self.delete then
        if self.arc then
            UnitAddAbility(self.unit, self.abil)
            utils.setheight(self.unit, self.cachedh)
            UnitRemoveAbility(self.unit, self.abil)
        end
        if self.endfunc then
            self.endfunc(self)
        end
        if self.pause then
            PauseUnit(self.unit, false)
        end
        for i,v in pairs(self) do
            v = nil
            i = nil
        end
        kb.stack[self.udex] = nil
        kb.total = kb.total - 1
        if kb.total <= 0 then
            kb.total = 0
            PauseTimer(kb.tmr)
        end
        if kb.total < 10 then
            -- recycle indeces when size is low:
            utils.tablecollapse(kb.stack)
        end
        -- mark player being knocked back for external logic:
        if utils.pnum(utils.powner(self.unit)) <= kk.maxplayers then
            kobold.player[utils.powner(self.unit)].currentlykb = false
        end
    elseif kb.debug then
        print("caution: self.delete hooked, instance not removed")
    end
    if kb.debug then print("total kb instances: "..kb.total) end
end


-- absolute destroy (use where finality is required).
function kb:deletekb()
    self.delete = true
    self:destroy()
end


function kb:collision()
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


function kb:terraincollision()
    if self.terraincol then
        self.offsetcheck = self.vel + self.colradius
        self.offsetx, self.offsety = utils.projectxy(self.x, self.y, self.offsetcheck, self.angle)
        if IsTerrainPathable(self.offsetx, self.offsety, PATHING_TYPE_WALKABILITY) then
            return true
        end
    end
    return false
end


function kb:destcollision()
    self:updaterect(self.offsetx, self.offsety)
    if self.destroydest then
        EnumDestructablesInRect(kb.rect, nil, function() self:hitdestdestroy() end)
    else
        EnumDestructablesInRect(kb.rect, nil, function() self:hitdestcollide() end)
    end
    if self.destcol then
        return true
    else
        return false
    end
end


-- destroy destructables.
function kb:hitdestdestroy()
    bj_destRandomCurrentPick = GetEnumDestructable()
    -- check destructable life to ignore any that are set to invulnerable:
    if GetWidgetLife(bj_destRandomCurrentPick) > 0.405 and GetWidgetLife(bj_destRandomCurrentPick) < 99999.0 then
        if self.destplayeff and self.desteff then
            DestroyEffect(AddSpecialEffect(self.desteff, GetWidgetX(bj_destRandomCurrentPick), GetWidgetY(bj_destRandomCurrentPick)))
        end
        SetWidgetLife(bj_destRandomCurrentPick, 0)
    elseif GetWidgetLife(bj_destRandomCurrentPick) > 99998.0 then
        self.destcol = true
    end
end


function kb:updaterect(x, y)
    local w = self.destradius/2
    SetRect(kb.rect, x - w, y - w, x + w, y + w)
end


-- find out if there is a nearby destructable to collide with.
function kb:hitdestcollide()
    bj_destRandomCurrentPick = GetEnumDestructable()
    if bj_destRandomCurrentPick and GetWidgetLife(bj_destRandomCurrentPick) > 0.405 then
        if IsUnitInRangeXY(
            self.unit,
            GetWidgetX(bj_destRandomCurrentPick),
            GetWidgetY(bj_destRandomCurrentPick),
            self.destradius)
        then
            self.destcol = true
        end
    end
end


function kb:getheight()
    if self.arc then
        return GetTerrainCliffLevel(self.x, self.y)*128 - 256
    else
        return GetTerrainCliffLevel(self.x, self.y)*128 - 256 + self.height
    end
end


function kb:reset()
    -- e.g. for recursive updates of a kb instance.
    self.trav    = 0
    self.tickmax = 0
    self.tick    = 0
    self.delete  = false
end
