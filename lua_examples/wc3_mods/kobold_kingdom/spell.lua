spell     = {}


function spell:init()
    -- init templates:
    casttype_instant = 1  -- instant cast, no target
    casttype_unit    = 2  -- target a unit
    casttype_point   = 3  -- target a location
    casttype_missile = 4  -- target location to shoot projectile
    casttype_lob     = 5  -- target location with targeting image
    self.interrupt   = {}
    self.hppotid     = FourCC('A01O')
    self.manapotid   = FourCC('A01P')
    self.__index     = self
    for pnum = 1,kk.maxplayers do
        self.interrupt[pnum] = false
    end
end


function spell:new(casttype, p, abilcode, _eventtype)
    -- initialize a spell for a player.
    local o = {}
    local e = _eventtype or EVENT_PLAYER_UNIT_SPELL_EFFECT
    setmetatable(o, self)
    o.casttype = casttype
    o.p        = p
    o.code     = abilcode
    o.trig     = CreateTrigger()
    o.cdtimer  = NewTimer()
    o.caster   = nil
    o.target   = nil
    o.casterx  = nil
    o.castery  = nil
    o.targetx  = nil
    o.targety  = nil
    o.actions  = {}
    o:addlistener(e)
    if utils.pnum(p) <= kk.maxplayers then
        o.pobj     = kobold.player[p]
    end
    return o
end


function spell:addlistener(e)
    TriggerRegisterPlayerUnitEvent(self.trig, self.p, e, nil)
    self.actions[#self.actions+1] = function()
        self.caster = GetTriggerUnit()
        self.casterx,self.castery = utils.unitxy(self.caster)
    end
    if self.casttype == casttype_lob or self.casttype == casttype_point or self.casttype == casttype_missile then
        self.actions[#self.actions+1] = function()
            self.targetx,self.targety = utils.spellxy(self.target)
        end
    elseif self.casttype == casttype_unit then
        self.actions[#self.actions+1] = function()
            self.target = GetSpellTargetUnit()
            self.targetx,self.targety = utils.unitxy(self.target)
        end
    end
    TriggerAddAction(self.trig, function()
        utils.debugfunc( function()
            if GetSpellAbilityId() == self.code then
                for _,func in ipairs(self.actions) do
                    func()
                end
                if self.cdfunc then
                    self.cdfunc()
                end
                if kobold.player[self.p] then
                    if self.code == self.hppotid or self.code == self.manapotid then
                        self:pstatpotion(kobold.player[self.p])
                    else
                        self:pstatcastepic(kobold.player[self.p])
                        loot.ancient:raiseevent(ancient_event_ability, kobold.player[self.p])
                    end
                end
            end
        end, "spell action")
    end)
end


function spell:addaction(func)
    -- pass a single function or a table of functions.
    utils.debugfunc(function()
        self.actions[#self.actions+1] = func
    end, "spell actions")
end


function spell:pstatcastepic(pobj)
    local dmgid = 0
    
    for epicid = p_epic_arcane_mis,p_epic_phys_mis do
        dmgid = dmgid+1
        if math.random(0,100) < 30 then
            if pobj[epicid] > 0 then
                local mis = self:pmissileangle(self:range(800.0), mis_ele_stack2[dmgid], pobj[epicid])
                mis.angle = mis.angle - math.random(0,18) + math.random(0,18)
                mis:initpiercing()
                mis.vel = 24
                mis.dmgtype = dmg.type.stack[dmgid]
            end
        end
    end
    dmgid = 0
    for epicid = p_epic_arcane_aoe,p_epic_phys_aoe do
        dmgid = dmgid+1
        if math.random(0,100) < 25 then
            if pobj[epicid] > 0 then
                speff_expl_stack[dmgid]:play(self.casterx, self.castery, nil, 0.65)
                spell:gdmgxy(self.p, dmg.type.stack[dmgid], pobj[epicid], self.casterx, self.castery, self:radius(300.0))
            end
        end
    end
    if pobj[p_epic_heal_aoe] > 0 then
        if math.random(1,100) <= pobj[p_epic_heal_aoe] then
            local grp = g:newbyxy(self.p, g_type_heal, self.casterx, self.castery, self:radius(10000.0))
            grp:action(function()
                speff_pothp:playu(grp.unit, nil, nil, 0.6)
                utils.addlifep(grp.unit, 3.0, true, pobj.unit)
            end)
            grp:destroy()
        end
    end
    if pobj[p_epic_dmg_reduct] > 0 and not pobj.dmgreductflag then
        pobj.dmgreductflag = true
        self:enhanceresistpure(pobj[p_epic_dmg_reduct], 3.0, self.p)
        utils.timed(3.1, function() pobj.dmgreductflag = nil end)
    end
    if pobj[p_epic_demon] > 0 then
        if math.random(1,100) <= 15 then
            local x,y  = utils.projectxy(self.casterx, self.castery, 128, math.random(0,360))
            local unit = 
            ai:new(utils.unitatxy(pobj.p, x, y, 'n00J', utils.getface(self.caster)))
                :initcompanion(900.0, pobj[p_epic_demon], p_stat_shadow)
                :timed(12.0)
            speff_deathpact:play(x, y)
        end
    end
    if pobj[p_epic_aoe_stun] > 0 then
        if math.random(1,100) <= pobj[p_epic_aoe_stun] then
            speff_warstomp:playu(pobj.unit)
            local grp = g:newbyxy(self.p, g_type_dmg, self.casterx, self.castery, self:radius(300.0))
            spell:gbuff(grp, bf_stun, 2.0)
            grp:destroy()
        end
    end
end


function spell:pstatpotion(pobj)
    -- health potion effects:
    if self.code == self.hppotid then
        if pobj[p_potion_life] > 0 then
            speff_rejuv:attachu(pobj.unit, 10.0, 'origin', 0.7)
            utils.timedrepeat(1.0, 10, function()
                utils.addlifep(pobj.unit, pobj[p_potion_life]/10, true, pobj.unit)
            end)
        end
        if pobj[p_potion_fire_res] > 0 then
            speff_ember:attachu(pobj.unit, 6.0, 'chest', 0.7)
            self:enhanceresist(dmg_fire, pobj[p_potion_fire_res], 6.0, self.p, true)
        end
        if pobj[p_potion_frost_res] > 0 then
            speff_emberfro:attachu(pobj.unit, 6.0, 'chest', 0.7)
            self:enhanceresist(dmg_frost, pobj[p_potion_frost_res], 6.0, self.p, true)
        end
        if pobj[p_potion_nature_res] > 0 then
            speff_embernat:attachu(pobj.unit, 6.0, 'chest', 0.7)
            self:enhanceresist(dmg_nature, pobj[p_potion_nature_res], 6.0, self.p, true)
        end
        if pobj[p_potion_shadow_res] > 0 then
            speff_embersha:attachu(pobj.unit, 6.0, 'chest', 0.7)
            self:enhanceresist(dmg_shadow, pobj[p_potion_shadow_res], 6.0, self.p, true)
        end
        if pobj[p_potion_arcane_res] > 0 then
            speff_emberarc:attachu(pobj.unit, 6.0, 'chest', 0.7)
            self:enhanceresist(dmg_arcane, pobj[p_potion_arcane_res], 6.0, self.p, true)
        end
        if pobj[p_potion_phys_res] > 0 then
            speff_emberphy:attachu(pobj.unit, 6.0, 'chest', 0.7)
            self:enhanceresist(dmg_phys, pobj[p_potion_phys_res], 6.0, self.p, true)
        end
        if pobj[p_potion_aoe_stun] > 0 then
            speff_warstomp:playu(pobj.unit)
            local grp = g:newbyxy(self.p, g_type_dmg, self.casterx, self.castery, self:radius(300.0))
            spell:gbuff(grp, bf_stun, pobj[p_potion_aoe_stun])
            grp:destroy()
        end
        if pobj[p_potion_aoe_heal] > 0 then
            local grp = g:newbyxy(self.p, g_type_heal, self.casterx, self.castery, self:radius(1000.0))
            grp:action(function()
                if grp.unit ~= pobj.unit and utils.ishero(grp.unit) then
                    utils.addlifep(grp.unit, pobj[p_potion_aoe_heal], true, pobj.unit)
                    speff_pothp:playu(grp.unit)
                end
            end)
            grp:destroy()
        end
        if pobj[p_potion_aoe_slow] > 0 then
            speff_quake:playu(pobj.unit)
            local grp = g:newbyxy(self.p, g_type_dmg, self.casterx, self.castery, self:radius(300.0))
            spell:gbuff(grp, bf_slow, pobj[p_potion_aoe_slow])
            grp:destroy()
        end
    -- mana potion effects:
    else
        if pobj[p_potion_mana] > 0 then
            speff_erejuv:attachu(pobj.unit, 10, 'origin', 0.7)
            utils.timedrepeat(1.0, 10, function()
                utils.addmanap(pobj.unit, pobj[p_potion_mana]/10, true, pobj.unit)
            end)
        end
        if pobj[p_potion_fire_dmg] > 0 then
            speff_ember:attachu(pobj.unit, 6.0, 'chest', 0.7)
            self:enhancedmgtype(dmg_fire, pobj[p_potion_fire_dmg], 6.0, self.p)
        end
        if pobj[p_potion_frost_dmg] > 0 then
            speff_emberfro:attachu(pobj.unit, 6.0, 'chest', 0.7)
            self:enhancedmgtype(dmg_frost, pobj[p_potion_frost_dmg], 6.0, self.p)
        end
        if pobj[p_potion_nature_dmg] > 0 then
            speff_embernat:attachu(pobj.unit, 6.0, 'chest', 0.7)
            self:enhancedmgtype(dmg_nature, pobj[p_potion_nature_dmg], 6.0, self.p)
        end
        if pobj[p_potion_shadow_dmg] > 0 then
            speff_embersha:attachu(pobj.unit, 6.0, 'chest', 0.7)
            self:enhancedmgtype(dmg_shadow, pobj[p_potion_shadow_dmg], 6.0, self.p)
        end
        if pobj[p_potion_arcane_dmg] > 0 then
            speff_emberarc:attachu(pobj.unit, 6.0, 'chest', 0.7)
            self:enhancedmgtype(dmg_arcane, pobj[p_potion_arcane_dmg], 6.0, self.p)
        end
        if pobj[p_potion_phys_dmg] > 0 then
            speff_emberphy:attachu(pobj.unit, 6.0, 'chest', 0.7)
            self:enhancedmgtype(dmg_phys, pobj[p_potion_phys_dmg], 6.0, self.p)
        end
        if pobj[p_potion_aoe_mana] > 0 then
            local grp = g:newbyxy(self.p, g_type_heal, self.casterx, self.castery, self:radius(1000.0))
            grp:action(function()
                if grp.unit ~= pobj.unit and utils.ishero(grp.unit) then
                    utils.addmanap(grp.unit, pobj[p_potion_aoe_mana], true, pobj.unit)
                    speff_potmana:playu(grp.unit)
                end
            end)
            grp:destroy()
        end
    end
    -- either potion effects:
    if pobj[p_potion_dmgr] > 0 then
        self:enhanceresistpure(pobj[p_potion_dmgr], 6.0, self.p)
    end
    if pobj[p_potion_absorb] > 0 then
        dmg.absorb:new(pobj.unit, 6.0, { all = utils.maxlife(pobj.unit)*pobj[p_potion_absorb]/100 }, speff_eshield, nil)
    end
    if pobj[p_potion_armor] > 0 then
        speff_silrejuv:attachu(pobj.unit, 8.0, 'origin', 0.7)
        self:enhancepstat(p_stat_armor, math.floor(pobj[p_stat_armor]*(pobj[p_potion_armor]/100)), 8.0, self.p)
    end
    if pobj[p_potion_dodge] > 0 then
        speff_silrejuv:attachu(pobj.unit, 8.0, 'origin', 0.7)
        self:enhancepstat(p_stat_dodge, math.floor(pobj[p_stat_dodge]*(pobj[p_potion_dodge]/100)), 8.0, self.p)
    end
    if pobj[p_potion_lifesteal] > 0 then
        speff_redrejuv:attachu(pobj.unit, 8.0, 'origin', 0.7)
        self:enhancepstat(p_stat_elels, pobj[p_potion_lifesteal], 8.0, self.p)
        self:enhancepstat(p_stat_physls, pobj[p_potion_lifesteal], 8.0, self.p)
    end
    if pobj[p_potion_thorns] > 0 then
        speff_yelrejuv:attachu(pobj.unit, 8.0, 'origin', 0.7)
        self:enhancepstat(p_stat_thorns, pobj[p_potion_thorns], 8.0, self.p)
        self:enhancepstat(p_stat_thorns, math.floor(pobj[p_stat_thorns]*(pobj[p_potion_thorns]/100)), 8.0, self.p)
    end
end


-- @_caster,_@code = overrides when using 1-4 dummy abilities.
function spell:uiregcooldown(cdval, hotkeyid, _fillw, _fillh, _caster, _code)
    if cdval and cdval > 0 then
        local fillw, fillh       = _fillw  or 63,   _fillh or 63
        self.casterf, self.codef = _caster or nil, _code   or nil
        self.uislot   = kui.canvas.game.skill.skill[hotkeyid].cdfill
        self.uitxt    = kui.canvas.game.skill.skill[hotkeyid].cdtxt
        self.cd       = cdval
        self.cdactive = false
        self.cdfunc   = nil -- if reassigned, need to destroy previous function.
        fillw, fillh  = kui:px(fillw), kui:px(fillh)
        self.cdfunc   = function()
            local caster, code = self.casterf or self.caster, self.codef or self.code
            if not self.cdactive and BlzGetUnitAbility(caster, code) then
                self.cdactive = true
                local total   = BlzGetUnitAbilityCooldown(caster, code, 0)
                local counter = 0
                TimerStart(self.cdtimer, 0.05, true, function()
                    if self.cdactive and BlzGetUnitAbility(caster, code) then
                        counter = counter + 0.05
                        if self:islocalp(caster) then
                            self.uitxt:settext(math.ceil(total-counter))
                            self.uislot:setsize((1-counter/total)*fillw, (1-counter/total)*fillh)
                        end
                        if counter >= total then
                            self.cdactive = false
                            if self:islocalp(caster) then self.uislot:hide() self.uitxt:settext("") end
                            PauseTimer(self.cdtimer)
                        end
                    else
                        if self:islocalp(caster) then self.uislot:hide() self.uitxt:settext("") end
                        PauseTimer(self.cdtimer)
                    end
                end)
                if self:islocalp(caster) then self.uislot:show() self.uitxt:settext(math.ceil(total)) end
            else
                self.cdactive = false
                if self:islocalp(caster) then self.uislot:hide() self.uitxt:settext("") end
                PauseTimer(self.cdtimer)
            end
        end
    end
end


function spell:islocalp(caster)
    return utils.powner(caster) == utils.localp()
end


function spell:radius(val)
    return math.floor(val*(1+kobold.player[self.p][p_stat_abilarea]/100))
end


function spell:range(val)
    return math.floor(val*(1+kobold.player[self.p][p_stat_mislrange]/100))
end


function spell:targetxy()
    return self.targetx, self.targety
end


-- @p = damage owner
function spell:tdmg(p, t, dmgtype, amount)
    dmgtype:pdeal(p, amount, t)
    dmgtype.effect:playu(t)
end


function spell:theal(p, t, amount, _suppresseff)
    if utils.powner(t) ~= Player(PLAYER_NEUTRAL_PASSIVE) then
        local amount = amount*(1+kobold.player[p][p_stat_healing]/100)
        if not _suppresseff then
            speff_lightheal:attachu(t, 0.0, 'origin')
        end
        utils.addlifeval(t, amount, true, kobold.player[p].unit)
        kobold.player[p].score[4] = kobold.player[p].score[4] + amount
    end
end


-- damage a group.
-- @p = damage owner
function spell:gdmg(p, grp, dmgtype, amount, _func)
    grp:action(function()
        if utils.isalive(grp.unit) then
            dmgtype:pdeal(p, amount, grp.unit)
            dmgtype.effect:playu(grp.unit)
            if _func then
                _func(grp.unit)
            end
        end
    end)
end


-- damage a temp group then recycle it
-- @p = damage owner
function spell:gdmgxy(p, dmgtype, amount, x, y, r, _func)
    local grp = g:newbyxy(p, g_type_dmg, x, y, r)
    grp:action(function()
        if utils.isalive(grp.unit) then
            dmgtype:pdeal(p, amount, grp.unit)
            dmgtype.effect:playu(grp.unit)
            if _func then
                _func(grp.unit)
            end
        end
    end)
    grp:destroy()
end


-- damage a temp group for neutral aggressive then recycle it.
function spell:creepgdmgxy(owner, dmgtype, amount, x, y, r, _func)
    local grp = g:newbyxy(Player(PLAYER_NEUTRAL_AGGRESSIVE), g_type_dmg, x, y, r)
    grp:action(function()
        if utils.isalive(grp.unit) then
            dmgtype:dealdirect(owner, grp.unit, amount)
            dmgtype.effect:playu(grp.unit)
            if _func then
                _func(grp.unit)
            end
        end
    end)
    grp:destroy()
end


-- heal a temp group then recycle it
-- @p = heal owner
function spell:ghealxy(p, amount, x, y, r, _func)
    local grp = g:newbyxy(p, g_type_heal, x, y, r)
    grp:action(function()
        if utils.isalive(grp.unit) and utils.powner(grp.unit) ~= Player(PLAYER_NEUTRAL_PASSIVE) then
            spell:theal(p, grp.unit, amount)
            if _func then
                _func(grp.unit)
            end
        end
    end)
    grp:destroy()
end


function spell:gbuff(grp, bf_type, dur, _preventstacking)
    grp:action(function()
        bf_type:apply(grp.unit, dur, _preventstacking or nil)
    end)
end


-- @unit        = unit to move.
-- @range       = intended max distance (to calc slide time).
-- @dur         = duration to get to x,y.
-- @x,y         = target point to leap to.
-- @functakeoff = function to run when effect starts.
-- @funcland    = function to run when effect ends.
-- returns boolean
function spell:slide(unit, range, dur, x, y, functakeoff, funcland)
    local unit      = unit -- declare so var isn't anonymous during timer.
    local x1,y1     = x,y
    local x2,y2     = utils.unitxy(unit)
    local angle     = utils.anglexy(x2,y2,x1,y1)
    local dist      = utils.distxy(x1,y1,x2,y2)
    local dur       = dur*dist/range
    local vel       = dist/(dur/0.03)
    local i         = dur/0.03
    local id        = GetSpellAbilityId() -- store for timer
    local pnum      = utils.pnum(utils.powner(unit))
    if not IsTerrainPathable(x1,y1,PATHING_TYPE_WALKABILITY) then -- pathable, allow (pathing function returns opposite bool)
        SetUnitFacing(unit, angle) SetUnitPathing(unit, false) ResetUnitAnimation(unit) SetUnitAnimationByIndex(unit, 2)
        if functakeoff ~= nil then functakeoff() end
        TimerStart(NewTimer(),0.03,true,function() -- leap
            utils.debugfunc(function()
                if i > 0 and IsUnitAliveBJ(unit) and not spell.interrupt[pnum] and not kobold.player[utils.powner(unit)].downed then
                    i = i-1
                    x2,y2 = utils.projectxy(x2, y2, vel, angle)
                    utils.setxy(unit, x2, y2)
                else
                    spell.interrupt[pnum] = false
                    if IsUnitAliveBJ(unit) and funcland ~= nil then utils.debugfunc(funcland, "funcland") end
                    ResetUnitAnimation(unit) SetUnitPathing(unit, true) ReleaseTimer()
                end
            end, "slide timer")
        end)
        return true
    else -- not pathable, reset abil cd
        utils.palert(utils.powner(unit), 'Target area is unreachable!')
        TimerStart(NewTimer(), 0.5,false, function() BlzEndUnitAbilityCooldown(unit, id) end)
        return false
    end
end


-- get the caster's angle to the target unit or point location of a spell.
function spell:angletotarget()
    return utils.anglexy(self.casterx, self.castery, self.targetx, self.targety)
end


-- get the caster's angle to the target unit or point location of a spell.
function spell:disttotarget()
    return utils.distxy(self.casterx, self.castery, self.targetx, self.targety)
end


-- if a spell is cast at a point, but the effect distance is fixed in that direction, get that distance.
function spell:fixeddistxy(dist)
    return utils.projectxy(self.casterx, self.castery, dist, self:angletotarget())
end


-- reduce @unit's armor (primary damage resistance) by @x for @dur sec.
function spell:armorpenalty(unit, x, dur, _speffect)
    local x, unit = x, unit
    if _speffect then
        _speffect:attachu(unit, dur)
    end
    BlzSetUnitArmor(unit, BlzGetUnitArmor(unit) - x)
    utils.timed(dur, function() if unit then BlzSetUnitArmor(unit, BlzGetUnitArmor(unit) + x) end end)
end


-- boost a player stat for a period.
-- @dmgtypeid = 1-6 damage id number.
function spell:enhancepstat(p_stat, val, dur, _p, _ignorebuff)
    local p, val = _p or self.p, val
    kobold.player[p][p_stat] = kobold.player[p][p_stat] + val
    utils.timed(dur, function()
        kobold.player[p][p_stat] = kobold.player[p][p_stat] - val
        tooltip:updatecharpage(p)
    end)
    tooltip:updatecharpage(p)
    kobold.player[p]:updateallstats()
    if not _ignorebuff and val > 0 then
        buffy:new_p_stat_indicator(p, p_stat, dur)
    end
end


-- boost a player's bonus damage for a period
-- @dmgtypeid = 1-6 damage id number.
function spell:enhancedmgtype(dmgtypeid, val, dur, _p, _ignorebuff)
    local p, val = _p or self.p, val
    local s = p_dmg_lookup[dmgtypeid]
    kobold.player[p][s] = kobold.player[p][s] + val
    utils.timed(dur, function()
        kobold.player[p][s] = kobold.player[p][s] - val
        tooltip:updatecharpage(p)
    end)
    tooltip:updatecharpage(p)
    if not _ignorebuff and val > 0 then
        buffy:new_p_stat_indicator(p, p_dmg_lookup[dmgtypeid], dur)
    end
end


-- boost a player's elemental resistance for a period.
-- @dmgtypeid = 1-6 damage id number.
function spell:enhanceresist(dmgtypeid, val, dur, _p, _showeffect, _ignorebuff)
    local p, val = _p or self.p, val
    local s = p_resist_lookup[dmgtypeid]
    kobold.player[p][s] = kobold.player[p][s] + val
    utils.timed(dur, function()
        kobold.player[p][s] = kobold.player[p][s] - val
        tooltip:updatecharpage(p)
    end)
    if _showeffect then sp_armor_boost[dmgtypeid]:attachu(kobold.player[p].unit, dur) end
    tooltip:updatecharpage(p)
    if not _ignorebuff and val > 0 then
        buffy:new_p_stat_indicator(p, p_resist_lookup[dmgtypeid], dur)
    end
end


-- boost ALL elemental resistance for a period (performance-minded).
-- @dmgtypeid = 1-6 damage id number.
function spell:enhanceresistall(val, dur, _p, _ignorebuff)
    local p, val = _p or self.p, val
    for dmgid = 1,6 do
        kobold.player[p][p_resist_lookup[dmgid]] = kobold.player[p][p_resist_lookup[dmgid]] + val
    end
    utils.timed(dur, function()
        for dmgid = 1,6 do
            kobold.player[p][p_resist_lookup[dmgid]] = kobold.player[p][p_resist_lookup[dmgid]] - val
        end
        tooltip:updatecharpage(p)
    end)
    tooltip:updatecharpage(p)
    if not _ignorebuff and val > 0 then
        buffy:add_indicator(p, "Enhanced Resistances", "ReplaceableTextures\\CommandButtons\\BTN3M3.blp", dur, "Increased elemental resistances")
    end
end


-- add an additional damage reduction effect on top of standard resistances
-- *note: this is always applied as the first step in dmg engine.
function spell:enhanceresistpure(val, dur, _p, _ignorebuff)
    local p, val = _p or self.p, val
    spell:enhancepstat(p_stat_dmg_reduct, val, dur, p, _ignorebuff or nil)
    tooltip:updatecharpage(p)
end


--[[
    wrapper functions for spells to create missiles:
--]]

function spell:pmissilepierce(dist, speffect, dmg)
    local mis = self:pmissiletargetxy(dist, speffect, dmg)
    mis:initpiercing()
    return mis
end


-- send toward caster's facing angle.
-- @_angle  = [optional] override the angle
function spell:pmissileangle(dist, speffect, dmg, _angle)
    local a = _angle or GetUnitFacing(self.caster)
    local mis = missile:create_angle(a, self:getmissilerange(dist), self.caster, speffect.effect, dmg)
    return mis
end


-- send towards the targetx and targety of the spell cast.
function spell:pmissiletargetxy(dist, speffect, dmg)
    local a = utils.anglexy(utils.unitx(self.caster), utils.unity(self.caster), self.targetx, self.targety)
    local mis = missile:create_angle(a, self:getmissilerange(dist), self.caster, speffect.effect, dmg)
    return mis
end


-- spawn a missile outside of a spell but using spell data (e.g. a summoned unit's missile).
function spell:pmissile_custom_unitxy(unit, dist, tarx, tary, speffect, dmg)
    local a = utils.anglexy(utils.unitx(unit), utils.unity(unit), tarx, tary)
    local mis = missile:create_angle(a, self:getmissilerange(dist), unit, speffect.effect, dmg)
    return mis
end


-- a custom origin and target point, without player data injected.
function spell:pmissile_custom_xy(ownerunit, originx, originy, tarx, tary, speffect, dmg)
    local a   = utils.anglexy(originx, originy, tarx, tary)
    local mis = missile:create_angle(a, utils.distxy(originx, originy, tarx, tary), ownerunit, speffect.effect, dmg)
    return mis
end


-- @_tarx,@_tary = override spell cast point if needed.
-- send towards the targetx and targety of the spell cast.
function spell:pmissilearc(speffect, dmg, _tarx, _tary)
    local tarx = _tarx or self.targetx
    local tary = _tary or self.targety
    local mis  = missile:create_arc(tarx, tary, self.caster, speffect.effect, dmg)
    return mis
end


function spell:getmissilerange(dist)
    if kobold.player[self.p][p_stat_mislrange] > 0 then
        return dist*(1+kobold.player[self.p][p_stat_mislrange]/100)
    end
    return dist
end
