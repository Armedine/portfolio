missile = {}


function missile:init()
    self.__index = self
    --[[
        missile instance configurables:
    --]]
    self.height  = 80    -- default z height.
    self.radius  = 80    -- how wide to search to collide.
    self.vel     = 20    -- default velocity.
    self.pitch   = 0     -- 
    self.offset  = 30    -- origin distance to project from x and y.
    self.locku   = nil   -- set this to a unit to enable homing.
    self.effect  = nil   -- special effect for missile.
    self.model   = nil   -- special effect model.
    self.zbuff   = 64    -- to prevent whacky death anims underground.
    self.angle   = nil   -- missile travel angle.
    self.cangle  = nil   -- `` for custom effect rotation.
    self.dist    = 1000  -- distance to travel.
    self.trav    = nil   -- distance traveled so far.
    self.x       = nil   -- missile current x coord.
    self.y       = nil   -- `` y coord.
    self.z       = nil   -- `` z coord.
    self.func    = nil   -- function to run on every update.
    self.time    = nil   -- use a travel time instead of travel distance.
    self.elapsed = nil   -- self.time converted to timer ticks required.
    self.collide = true  -- destroy on collision.
    self.colfunc = nil   -- function to run on collision.
    self.explfunc= nil   -- `` on explosion.
    self.expl    = false -- deal area-effect damage/healing.
    self.explr   = 300   -- explosion radius.
    self.pierce  = false -- should the missile piece targets?
    self.arc     = false -- should missile arc?
    self.arch    = 300   -- if enabled, how high?
    self.heal    = false -- heal allies on collision instead.
    self.coleff  = nil   -- play this effect on struck units.
    self.maxdist = 5000  -- default max missile travel range.
    self.reflect = false -- the missile will play again to its origin point.
    --[[
        missile class settings:
    --]]
    missile.stack   = {}
    self.tmr     = NewTimer()
    self.cad     = 0.03
    self.acc     = 1     -- how accurate are updates? (bigger = performant; scales with missile total).
    self.total   = 0     -- total missile instances.
    self.tick    = 0     -- the current timer tick loop (for collision accuracy).
    self.buffer  = 11    -- on missile destroy, run table clean if total > buffer.
    self.sacc    = self.acc     -- cached accuracy; don't edit.
    self.sradius = self.radius  -- cached radius; don't edit.
    --[[
        toggles:
    --]]
    self.debug   = false -- print debug counts, etc.
    self.printc  = false -- simple debug (print instance count).
end


--[[
    basic missile creation functions:
--]]


function missile:create_timedxy(tarx, tary, dur, unit, model, damage)
    -- determine angle by @tarx,@tary target coord, lasts @dur seconds.
    local mis = missile:create_targetxy(tarx, tary, unit, model, damage)
    mis.time  = dur
    mis:initduration()
    return mis
end


function missile:create_arc(tarx, tary, unit, model, damage, _explfunc, _time)
    -- determine angle by @tarx,@tary target coord.
    local mis    = missile:create_targetxy(tarx, tary, unit, model, damage)
    mis.arc      = true
    mis.expl     = true
    mis.collide  = false
    mis.explfunc = _explfunc or nil
    if _time then
        mis.time = _time
        mis:initduration()
    end
    return mis
end


function missile:create_arc_in_radius(centerx, centery, unit, model, damage, dmgtype, count, dist, _time, _hitradius, _height)
    -- creates arcing artillery missiles in a radius around @centerx/@centery.
    local sa,a,x,y = math.random(0,360),360/count,0,0
    for i = 1,count do
        x,y         = utils.projectxy(utils.unitx(unit),utils.unity(unit),dist,sa)
        local mis   = missile:create_targetxy(x, y, unit, model, damage)
        mis.arc     = true
        mis.expl    = true
        mis.collide = false
        mis.dmgtype = dmgtype
        mis.radius  = _hitradius or self.radius
        mis.height  = _height or self.height
        sa = sa + a
        if _time then
            mis.time = _time
            mis:initduration()
        end
    end
end


function missile:create_in_radius(centerx, centery, unit, model, damage, dmgtype, count, dist, _time, _hitradius, _height, _collides, _velocity, _explodes)
    -- creates standard line missiles in a radius around @centerx/@centery; pierces by default.
    local sa,a,x,y = math.random(0,360),360/count,0,0
    for i = 1,count do
        x,y         = utils.projectxy(centerx,centery,dist,sa)
        local mis   = missile:create_targetxy(x, y, unit, model, damage)
        mis.dmgtype = dmgtype
        mis.collide = _collides or false
        mis.expl    = _explodes or false
        mis.radius  = _hitradius or self.radius
        mis.height  = _height or self.height
        mis.vel     = _velocity or self.vel
        sa = sa + a
        if _time then
            mis.time = _time
            mis:initduration()
        end
    end
end


function missile:create_piercexy(tarx, tary, unit, model, damage)
    -- determine angle by @tarx,@tary target coord.
    local mis = missile:create_targetxy(tarx, tary, unit, model, damage)
    mis:initpiercing()
    return mis
end


-- sends a missile to a target point.
function missile:create_targetxy(tarx, tary, unit, model, damage)
    -- determine angle by @tarx,@tary target coord.
    local ux, uy = utils.unitxy(unit)
    local angle  = utils.anglexy(ux, uy, tarx, tary)
    local mis    = missile:create_angle(angle, utils.distxy(ux, uy, tarx, tary), unit, model, damage)
    return mis
end


-- sends a missile in target angle.
function missile:create_angle(angle, dist, unit, model, damage)
    -- send a missile towards a specified angle.
    local mis    = missile:new(unit)
    mis.x, mis.y = utils.unitxy(unit)
    mis.dist     = dist
    mis.dmg, mis.angle, mis.model = damage, angle, model
    mis:launch()
    return mis
end


-- sends a missile from a custom x,y starting point.
function missile:create_point(startx, starty, angle, distance, unit, model, damage, _arcing, _time)
    -- send a missile towards a specified angle.
    local mis    = missile:new(unit)
    mis.dist     = distance or 1000.0
    mis.x, mis.y = startx, starty
    if _arcing then
        mis.arc     = true
        mis.expl    = true
        mis.collide = false
    end
    mis.dmg, mis.angle, mis.model = damage, angle, model
    mis:launch()
    if _time then
        mis.time = time
        mis:initduration()
    end
    return mis
end


--[[
    missile class functions:
--]]


function missile:new(owner)
    local o = {}
    setmetatable(o, self)
    missile.stack[o] = o
    o.owner = owner
    return o
end


function missile:launch()
    -- optional properties:
    if self.arc then
        self.pitch = 0
    end
    if self.offset > 0 then
        self.x, self.y = utils.projectxy(self.x, self.y, self.offset, self.angle)
    end
    -- initialize missile:
    self.sradius = self.radius
    self.trav    = 0
    self.p       = utils.powner(self.owner)
    self.effect  = AddSpecialEffect(self.model, self.x, self.y)
    self.z       = self:getheight() + self.height
    -- check if timer should be rebooted:
    if missile.total == 0 then
        TimerStart(self.tmr, self.cad, true, function()
            utils.debugfunc(function()
                if missile.total <= 0 then
                    missile.total = 0
                    PauseTimer(self.tmr)
                else
                    for _,mis in pairs(missile.stack) do
                        mis:update()
                    end
                end
            end, "update timer")
        end)
    end
    -- increment totals, run performance check:
    missile.total = missile.total + 1
    if self.total > 100 then
        self.acc    = self.acc + math.floor(self.total/100)
        -- make radius scale up to help with reduced accuracy:
        self.radius = math.floor(self.radius*(1+(self.acc-self.sacc)*0.1))
    else
        self.acc = self.sacc
    end
    if missile.printc then self:debugprint() end
    self:update() -- (keep this last)
end


function missile:updatescale(scale)
    self.scale = scale
    BlzSetSpecialEffectScale(self.effect, scale)
end


function missile:initduration()
    if self.time and not self.arc then
        -- non-arcing missile:
        self.elapsed = math.floor(self.time/self.cad)
        self.dist    = self.maxdist
    elseif self.time and self.arc then
        -- arcing:
        -- ticks required = dist/vel/cadence
        self.vel     = math.max(2,math.floor(self.dist/self.time*self.cad))
        self.elapsed = nil
    end
end


function missile:initpiercing()
    self.pierce   = true
    self.collide  = false
    self.dmgtable = {}
end


function missile:initarcing()
    self.arc     = true
    self.expl    = true
    self.collide = false
end


function missile:update()
    -- if owner was removed:
    if not self.owner then
        self:destroy()
        return
    end
    -- optional properties:
    if self.func then
        self.func(self)
    end
    if self.locku then
        self.angle = utils.anglexy(self.x, self.y, utils.unitxy(self.locku))
    end
    -- missile positioning:
    self.trav = self.trav + self.vel
    self.x, self.y = utils.projectxy(self.x, self.y, self.vel, self.angle)
    if self.arc then
        if self.z == 0.0 then -- init height if at 0.
            self.z = self:getheight() + self.height
        end
        self.z = (4*self.arch/self.dist)*(self.dist - self.trav)*(self.trav/self.dist) + self:getheight() + self.height
    elseif self.tick == 0 then
        self.z = self:getheight()
    end
    -- reposition missile effect:
    if not self.cangle then -- customangle can be controlled in the update function (i.e. for rotation or spin effects).
        BlzSetSpecialEffectYaw(self.effect, self.angle*bj_DEGTORAD)
    else
        BlzSetSpecialEffectYaw(self.effect, self.cangle*bj_DEGTORAD)
    end
    BlzSetSpecialEffectX(self.effect, self.x)
    BlzSetSpecialEffectY(self.effect, self.y)
    BlzSetSpecialEffectZ(self.effect, self.z)
    -- check for update accuracy:
    if self.tick == self.acc then
        self.tick = 0
        if self.arc and self.z < self:getheight() + self.zbuff then -- zbuff makes missile die slightly earlier to prevent underground death animations.
            self:destroy()
            return
        end
    else
        self.tick = self.tick + 1
    end
    -- initiate destroy check:
    if self.elapsed then
        self.elapsed = self.elapsed - 1
    end
    if self:foundcollision() and self.collide then
        self:destroy()
    elseif not self.arc then
        if self.trav >= self.dist then
            self:destroy()
        elseif (self.elapsed and self.elapsed <= 0) or self.trav >= self.dist then
            self:destroy()
        end
    end
end


function missile:getheight()
    if self.arc then
        return GetTerrainCliffLevel(self.x, self.y)*128 - 256
    else
        return GetTerrainCliffLevel(self.x, self.y)*128 - 256 + self.height
    end
end


function missile:foundcollision()
    if not self.arc and self.tick == 0 then
        local grp = g:newbyxy(self.p, g_type_dmg, self.x, self.y, self.radius)
        self.hitsize = grp:getsize()
        if self.hitsize > 0 then
            if (self.collide and not self.expl) or (self.pierce and self.expl) or self.pierce then
                for dex = 0,self.hitsize-1 do
                    self.hitu = grp:indexunit(dex)
                    if self.pierce and self.hitu then
                        if self.dmgtable and not self.dmgtable[utils.data(self.hitu)] then
                            if self.hitu then self:dealdmg(self.hitu) end
                            if self.colfunc then self.colfunc(self) end
                        end
                    elseif self.collide and self.hitu then
                        self:dealdmg(self.hitu)
                        if self.colfunc then self.colfunc(self) end
                        break
                    end
                end
            end
            grp:destroy()
            return true
        end
        grp:destroy()
    end
    return false
end


function missile:explodemissile()
    -- clear the damage limit table first:
    if self.dmgtable then self.dmgtable = nil end
    local grp = g:newbyxy(self.p, g_type_dmg, self.x, self.y, self.explr)
    grp:action(function()
        self:dealdmg(grp.unit)
    end)
    grp:destroy()
    if self.explfunc then
        self.explfunc(self)
    end
end


function missile:dealdmg(target)
    if self.pierce and self.dmgtable and self.dmgtable[utils.data(target)] then
        -- the unit was already struck, so do nothing.
        return
    else
        if self.heal then
            UnitDamageTarget(self.owner, target, -self.dmg, true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
        else
            if self.dmgtype and utils.pnum(self.p) < kk.maxplayers then
                self.dmgtype:pdeal(self.p, self.dmg, target)
            elseif self.dmgtype then
                self.dmgtype:dealdirect(self.owner, target, self.dmg)
            else
                UnitDamageTarget(self.owner, target, self.dmg, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
            end
        end
        if self.coleff then
            utils.speffect(self.coleff, utils.unitxy(target))
        end
        if self.pierce and self.dmgtable then
            self.dmgtable[utils.data(target)] = true
        end
    end
end


function missile:destroy()
    if self.expl then
        self:explodemissile()
    end
    if not self.reflect then
        if self.total > 500 then
            -- if we're in bananas count territory, render death effect off screen.
            BlzSetSpecialEffectZ(self.effect, 3500.0)
        end
        DestroyEffect(self.effect)
        for i,v in pairs(self) do
            v = nil
            i = nil
        end
        missile.total       = missile.total - 1
        missile.stack[self] = nil
        if missile.total == 0 or missile.total > self.buffer then
            missile:recycle()
        end
        if missile.printc then self:debugprint() end
    else
        self.reflect = false
        self.trav    = 0.0
        self.angle   = self.angle - 180.0
        if self.pierce then self.dmgtable = nil self.dmgtable = {} end
        if self.time then self:initduration() end
    end
end


function missile:recycle()
    utils.tablecollapse(missile.stack)
    if missile.debug then print("recycle buffer met, recycling") end
end


function missile:debugprint()
    ClearTextMessages()
    print("Instances: "..missile.total)
    print("Table size: "..utils.tablelength(missile.stack))
end
