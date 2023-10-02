ai = {}
ai.miniboss = {}
ai.miniboss.__index = ai.miniboss
ai.stack = {}
ai.__index = ai


function ai:new(unit)
    local o = setmetatable({}, self)
    o.unit  = unit
    o.p     = utils.powner(unit)
    o.owner = kobold.player[o.p].unit
    self.stack[o] = o
    return o
end


-- initialize a simple follow timer for a companion unit.
-- @_dmg, = base weapon damage or spell damage to modify
-- @p_stat = if the unit should scale with player stats, link it.
-- @_abilid = if owner loses this ability, unsummon the unit.
function ai:initcompanion(leashrange, _dmg, _p_stat, _abilid)
    if self.unit then
        local aiunit = self.unit                 -- new handle for timer logic
        self.leashr  = leashrange or 800.0  -- forced move range (guaranteed positioning)
        self.leashm  = self.leashr*0.8      -- quick move range (standard movement)
        self.dmg     = _dmg or nil
        self.p_stat  = _p_stat or nil
        self.code    = _abilid or nil
        self.combat  = false -- controls attack-move ordering on spell damage.
        self.leashed = false -- set to true when unit is returning to owner.
        SetUnitMoveSpeed(self.unit, 522.0) -- for now, always make companions have max MS.
        self:update_damage() -- init unit damage
        self.tmr     = utils.timedrepeat(4.00, nil, function()
            utils.debugfunc(function()
                if aiunit and utils.isalive(aiunit) then
                    -- check for unit updates and ability swaps:
                    if self.code and not BlzGetUnitAbility(self.owner, self.code) then
                        self:releasecompanion()
                        ReleaseTimer()
                        return
                    end
                    -- check for leash if outside leash range:
                    if not self.leashed and self:getownerdist() > self.leashr then
                        self.leashed = true
                        utils.issmovexy(self.unit, utils.unitxy(self.owner))
                        self:follow(3.33)
                        -- check if companion should be moved (very far away or stuck):
                        self.leashtmr = utils.timed(2.63, function()
                            utils.debugfunc(function()
                                if aiunit and utils.isalive(aiunit) then
                                    self.leashed = false
                                    if self:getownerdist() > self.leashr then
                                        utils.setxy(self.unit, utils.unitxy(self.owner))
                                        speff_feral:play(utils.unitxy(self.owner))
                                        self:follow(1.66)
                                    end
                                else
                                    ReleaseTimer()
                                    return
                                end
                            end, "ai leash")
                        end)
                    elseif not self.combat and self:getownerdist() > self.leashm then
                        utils.issmovexy(self.unit, utils.unitxy(self.owner))
                        self:follow(2.5)
                    elseif not self.combat then
                        -- to prevent idle ranged units, issue random attack command near player
                        utils.issatkxy(self.unit, utils.unitprojectxy(self.owner, math.random(100, 300), math.random(0,360)))
                    end
                else
                    self:releasecompanion()
                    ReleaseTimer()
                    return
                end
            end, "ai leash")
        end)
        return self
    else
        assert(false, "error: did not run ai:initcompanion because self.unit did not exist")
    end
end


-- initiate follow order after a delay period (sec).
function ai:follow(delay)
    local aiunit = self.unit -- handle for timer.
    if self.followtmr then ReleaseTimer(self.followtmr) end
    self.followtmr = utils.timed(delay, function()
        if aiunit then
            if not self.combat then
                utils.smartmove(self.unit, self.owner)
            end
        else
            ReleaseTimer()
        end
    end)
end


function ai:update_damage()
    if self.dmg and self.p_stat then
        BlzSetUnitBaseDamage(self.unit, math.floor(self.dmg*(1+kobold.player[self.p][self.p_stat]/100)), 0)
    end
end


-- destroy an ai after a duration
function ai:timed(duration)
    utils.timed(duration, function()
        self:releasecompanion()
    end)
end


-- send a companion to attack on spell damage, etc.
function ai:engage(x, y, _unit)
    -- check if already engaged.
    if not self.combat then
        if _unit then
            utils.issatkunit(self.unit, _unit)
        else
            utils.issatkxy(self.unit, x, y)
        end
        self.combat = true
        utils.timed(6.0, function() self.combat = false end)
    end
end


function ai:getownerdist()
    return utils.distxy(utils.unitx(self.owner), utils.unity(self.owner), utils.unitx(self.unit), utils.unity(self.unit))
end


function ai:releasecompanion()
    speff_feral:play(utils.unitxy(self.unit))
    if self.followtmr then ReleaseTimer(self.followtmr) self.followtmr = nil end
    if self.leashtmr then ReleaseTimer(self.leashtmr) self.leashtmr = nil end
    if self.tmr then ReleaseTimer(self.tmr) self.tmr = nil end
    RemoveUnit(self.unit)
    for i,v in pairs(self) do v = nil i = nil end
    self.stack[self] = nil
end


function ai.miniboss:new(unit, castcadence, castanim, dropfrag, fragcount)
    local o         = setmetatable({}, self)
    o.spellfunc     = nil -- assign outside of scope
    o.unit          = unit
    o.castcadence   = castcadence
    o.castanim      = castanim
    o.spellelapsed  = 0
    o.moveelapsed   = 0
    o.fidgetcad     = 2.72
    o.fidgetdur     = 1.54
    o.castdur       = 1.03
    o.moving        = false
    o.casting       = false
    o.trackedunit   = kobold.player[Player(0)].unit
    local fragcount = fragcount
    utils.timedrepeat(0.33, nil, function(c)
        utils.debugfunc(function()
            if o and o.unit and utils.isalive(o.unit) and map.manager.activemap then
                if o:hero_within_range(1200) then
                    o.spellelapsed = o.spellelapsed + 0.33
                    o.moveelapsed = o.moveelapsed + 0.33
                    if not o.moving and not o.casting then
                        if o.spellelapsed >= o.castcadence then
                            o.spellelapsed = 0
                            o.casting = true
                            PauseUnit(o.unit, true)
                            SetUnitAnimation(o.unit, o.castanim)
                            o.spellfunc(o.unit)
                            utils.timed(o.castdur, function() PauseUnit(o.unit, false) o.casting = false end)
                        elseif o.moveelapsed > o.fidgetcad then
                            o.moveelapsed = 0
                            o.moving = true
                            local a,x,y = utils.angleunits(o.unit, o.trackedunit), utils.unitxy(o.unit)
                            x,y = utils.projectxy(x, y, math.random(150,300), a + math.randomneg(-30,30))
                            utils.issatkxy(o.unit, x, y)
                            utils.timed(o.fidgetdur, function() o.moving = false end)
                        end
                    end
                end
            elseif not map.manager.activemap and utils.isalive(o.unit) then
                RemoveUnit(o.unit)
            else
                if map.manager.activemap and dropfrag and not utils.isalive(o.unit) and map.manager.downp ~= map.manager.totalp then
                    local fragcount = math.max(1,fragcount + map.manager.diffid - 2)
                    if map.manager.diffid == 5 then fragcount = fragcount + 3 end
                    loot:generatelootmissile(utils.unitx(o.unit), utils.unity(o.unit), "I00F", fragcount or 1, nil, speff_fireroar, speff_fragment.effect)
                end
                o:release()
                ReleaseTimer()
            end
        end, "miniboss timer")
    end)
    -- boss units have no pathing:
    SetUnitPathing(o.unit, false)
    o:scale()
    ai.stack[o] = o
    return o
end


function ai.miniboss:hero_within_range(r)
    local check, grp = false, g:newbyxy(Player(PLAYER_NEUTRAL_AGGRESSIVE), g_type_dmg, utils.unitx(self.unit), utils.unity(self.unit), r)
    grp:action(function()
        if utils.ishero(grp.unit) then
            check = true
            grp.brk = true
        end
    end)
    grp:destroy()
    return check
end


function ai.miniboss:scale()
    BlzSetUnitMaxHP(self.unit,      math.floor(600*(1 + (map.mission.cache.level^1.12)*0.035) ) )
    BlzSetUnitBaseDamage(self.unit, math.floor(22*(1 + (map.mission.cache.level^1.12)*0.025) ), 0)
    if map.mission.cache and map.mission.cache.setting then
        BlzSetUnitMaxHP(self.unit,      math.ceil( BlzGetUnitMaxHP(self.unit)*map.mission.cache.setting[m_stat_health]) )
        BlzSetUnitBaseDamage(self.unit, math.ceil( BlzGetUnitBaseDamage(self.unit, 0)*map.mission.cache.setting[m_stat_attack]), 0 )
        BlzSetUnitIntegerField(self.unit, UNIT_IF_LEVEL, math.floor(map.mission.cache.level or 10))
    end
    utils.restorestate(self.unit)
end


function ai.miniboss:release()
    ai.stack[self] = nil
end
