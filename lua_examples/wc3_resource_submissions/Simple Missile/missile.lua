missile = {}


function missile:init()
    self.__index = self
    --[[
        missile instance configurables:
    --]]
    self.height  = 96    -- default z height.
    self.radius  = 60    -- how wide to search to collide.
    self.vel     = 14    -- default velocity.
    self.pitch   = 0     -- 
    self.offset  = 0     -- origin distance to project from x and y.
    self.locku   = nil   -- set this to a unit to enable homing.
    self.effect  = nil   -- special effect for missile.
    self.model   = nil   -- special effect model.
    self.angle   = nil   -- missile travel angle.
    self.dist    = nil   -- distance to travel.
    self.trav    = nil   -- distance traveled so far.
    self.x       = nil   -- missile current x coord.
    self.y       = nil   -- `` y coord.
    self.z       = nil   -- `` z coord.
    self.ox      = nil   -- origin coord.
    self.oy      = nil   -- ``
    self.oz      = nil   -- ``
    self.func    = nil   -- function to run on every update.
    self.time    = nil   -- use a travel time instead of travel distance.
    self.elapsed = nil   -- self.time converted to timer ticks required.
    self.collide = true  -- destroy on collision.
    self.colfunc = nil   -- function to run on collision.
    self.expl    = false -- deal area-effect damage/healing.
    self.explr   = 300   -- explosion radius.
    self.arc     = false -- should missile arc?
    self.arch    = 300   -- if enabled, how high?
    self.heal    = false -- heal allies on collision instead.
    self.coleff  = nil   -- play this effect on struck units.
    self.maxdist = 3000  -- default max missile travel range.
    --[[
        missile class settings:
    --]]
    missile.stack   = {}
    self.tmr     = NewTimer()
    self.cad     = 0.04
    self.acc     = 3     -- how accurate are updates? (bigger = performant; scales with missile total).
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


function missile:create_timedxy(tarx, tary, dur, unit, model, dmg)
    -- determine angle by @tarx,@tary target coord, lasts @dur seconds.
    local mis = missile:create_targetxy(tarx, tary, unit, model, dmg)
    mis.time  = time
    mis:initduration()
    return mis
end


function missile:create_arc(tarx, tary, unit, model, dmg)
    -- determine angle by @tarx,@tary target coord.
    local mis   = missile:create_targetxy(tarx, tary, unit, model, dmg)
    mis.arc     = true
    mis.expl    = true
    mis.collide = false
    return mis
end


function missile:create_targetxy(tarx, tary, unit, model, dmg)
    -- determine angle by @tarx,@tary target coord.
    local ux, uy = utils.unitxy(unit)
    local angle  = utils.anglexy(ux, uy, tarx, tary)
    local mis    = missile:create_angle(angle, utils.distxy(ux, uy, tarx, tary), unit, model, dmg)    
    return mis
end


function missile:create_angle(angle, dist, unit, model, dmg)
    -- send a missile towards a specified angle.
    local mis = missile:new(unit)
    mis.x, mis.y = utils.unitxy(unit)
    mis.dist = dist
    mis.dmg, mis.angle, mis.model = dmg, angle, model
    mis:launch()
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
        self.ox, self.ox = utils.projectxy(self.ox, self.oz, self.offset, self.angle)
    end
    -- initialize missile:
    self.sradius = self.radius
    self.trav    = 0
    self.p       = utils.powner(self.owner)
    self.effect  = AddSpecialEffect(self.model, self.x, self.y)
    self.oz      = self:getheight()
    self.ox, self.oy = self.x, self.y
    -- check if timer should be rebooted:
    if missile.total == 0 then
        TimerStart(self.tmr, self.cad, true, function()
            if missile.total <= 0 then
                missile.total = 0
                PauseTimer(self.tmr)
            else
                for _,mis in pairs(missile.stack) do
                    mis:update()
                end
            end
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


function missile:initduration()
    if self.time then
        self.elapsed = math.floor(self.time/self.cad)
        self.dist    = self.maxdist
    end
end


function missile:update()
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
        if self.z == 0.0 then
            self.z = self:getheight()
        end
        self.z = (4*self.arch/self.dist)*(self.dist - self.trav)*(self.trav/self.dist)
    elseif self.tick == 0 then
        self.z = self:getheight()
    end
    -- reposition missile effect:
    BlzSetSpecialEffectYaw(self.effect, self.angle*bj_DEGTORAD)
    BlzSetSpecialEffectX(self.effect, self.x)
    BlzSetSpecialEffectY(self.effect, self.y)
    BlzSetSpecialEffectZ(self.effect, self.z)
    -- check for update accuracy:
    if self.tick == self.acc then
        self.tick = 0
        if self.arc and self.z + self.height < self:getheight() then
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
    if self:foundcollision() or self.trav >= self.dist then
        self:destroy()
    elseif (self.elapsed and self.elapsed <= 0) or self.trav >= self.dist then
        self:destroy()
    end
end


function missile:getheight()
    return GetTerrainCliffLevel(self.x, self.y)*128 - 256 + self.height
end


function missile:foundcollision()
    if self.collide and self.tick == 0 then
        local grp = g:newbyxy(self.p, g_type_dmg, self.x, self.y, self.radius)
        if grp:getsize() > 0 then
            self.hitu = grp:indexunit(0)
            grp:destroy()
            if self.colfunc then
                self.colfunc(self)
            end
            return true
        end
        grp:destroy()
    end
    return false
end


function missile:explodemissile()
    local grp = g:newbyxy(self.p, g_type_dmg, self.x, self.y, self.explr)
    grp:action(function()
        self:dealdmg(grp.unit)
    end)
    grp:destroy()
end


function missile:dealdmg(target)
    if self.heal then
        UnitDamageTarget(self.owner, target, -self.dmg, true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
    else
        UnitDamageTarget(self.owner, target, self.dmg, true, false, ATTACK_TYPE_CHAOS, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WHOKNOWS)
    end
    if self.coleff then
        utils.speffect(self.coleff, utils.unitxy(target))
    end
end


function missile:destroy()
    if self.hitu and not self.expl then
        self:dealdmg(self.hitu)
    elseif self.expl then
        self:explodemissile()
    end
    if self.total > 500 then
        -- if we're in bananas count territory, render death effect off screen.
        BlzSetSpecialEffectZ(self.effect, 3500.0)
    end
    DestroyEffect(self.effect)
    for _,v in pairs(self) do
        v = nil
    end
    missile.total       = missile.total - 1
    missile.stack[self] = nil
    if missile.total == 0 or missile.total > self.buffer then
        missile:recycle()
    end
    if missile.printc then self:debugprint() end
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


local oldglobals = InitGlobals
function InitGlobals()
    utils.debugfunc(function()
        oldglobals()
        g:init()
        missile:init()
        print("Issue attack order = basic missile.")
        print("Issue patrol order = arcing missile.")
        print("Issue move order = 50 spiraling missiles (stress test).")
        print("Issue stop order = 50 arcing missiles (stress test).")
    end, "InitGlobals")
end
