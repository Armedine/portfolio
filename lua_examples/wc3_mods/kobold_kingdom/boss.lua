boss = {}


function boss:init()
    -- globals:
    self.__index        = self
    self.stack          = {}

    -- build boss metadata (used for ALL bosses!)
    self:buildbosses()

    -- assign audio from init table:
    self:init_sounds()

    -- build boss health bar frames:
    bossfr = kui.frame:newbytype("BACKDROP", bossfr)
    bossfr:setbgtex("war3mapImported\\boss-panel-icon-header.blp")
    bossfr:setsize(kui:px(315), kui:px(103))
    bossfr:setfp(fp.t, fp.t, kui.worldui, 0, -kui:px(12))
    bossfr.hpbar = kui.frame:newbysimple("BossHealthBar", kui.canvas.gameui)
    bossfr.hpbar:setfp(fp.c, fp.t, kui.worldui, 0.0, -kui:px(124))
    bossfr.hpbar:setlvl(2)
    bossfr.hptxt = bossfr:createtext("0/0", nil, true)
    bossfr.hptxt:setallfp(bossfr.hpbar)
    bossfr.bossname = bossfr:createbtntext("Test Boss Name")
    bossfr.bossname:setsize(kui:px(300), kui:px(28))
    bossfr.bossname:setfp(fp.c, fp.c, bossfr.hpbar, 0, kui:px(28))
    -- simple bars don't follow parent visibility:
    bossfr.hidefunc = function() bossfr.hpbar:hide() end
    bossfr.showfunc = function() bossfr.hpbar:show() end
    -- `` intro slide-in frames:
    bossslidetext1 = kui.canvas:createheadertext("Test Sliding Text", nil, true)
    bossslidetext1:setsize(kui:px(500), kui:px(40))
    bossslidetext1:setfp(fp.t, fp.c, kui.canvas, 0, -kui:px(50))
    bossslidetext1:hide()
    bossslidetext2 = kui.canvas:createbtntext("Test Sliding Text", nil, true)
    bossslidetext2:setsize(kui:px(500), kui:px(28))
    bossslidetext2:setfp(fp.t, fp.c, kui.canvas, 0, -kui:px(100))
    bossslidetext2:hide()
    bossfr:hide()

    --[[
        **********************
        ******boss class******
        **********************
    --]]

    -- two spell groups:
    -- 'basic' are spammed, should not be too threatening.
    -- 'power' are threatening, happen less often.
    self.spellbook      = {     -- stores spell functions.
        basic = {}, power = {}, channel = {}, ultimate = {}
    }
    self.spellticks     = {     -- stores timer position to run certain spells.
        basic = 0, power = 0, channel = 0, ultimate = 0
    }
    self.spellcadence   = {     -- when to cast specific spell types.
        basic = 2.5, power = 12.5, channel = 16.0, ultimate = 24.0
    }
    -- intro can be any sound, basic and power should be an audible combat noise, channel should be a charge-up dialogue, ultimate is controlled globally.
    self.bossaudio     = {     -- play this audio for certain events.
        intro = nil, basic = nil, power = nil, channel = nil
    }
    -- general features:
    self.trackedunit    = nil   -- move and cast spells in conjunction with this unit.
    self.centerx        = 0     -- x center of where boss leashes to.
    self.centery        = 1000  -- `` y.
    self.casteffect     = ''    -- cast special effect.
    self.casteffectsc   = 1.0   -- `` scale
    self.waxchunk       = 20.0  -- x% health to award wax canisters.
    self.waxcount       = 3     -- `` how many wax canisters drop.
    -- spells features:
    self.casttime       = 1.0   -- speed to cast an ability and prevent other actions.
    self.iscasting      = false -- tracks whether cast is in progress
    self.pausespells    = false -- pause abilities?
    self.ultdelayspells = true  -- does the ultimate delay other spell timers (to prevent overlap)?
    self.randomspells   = true  -- are abilities randomly picked?
    -- movement features:
    self.collides       = false -- does boss collide with objects (kept updated within ai timer).
    self.moves          = true  -- boss is able to move at all.
    self.leash          = 1200   -- move toward player if outside of this range.
    self.movecadence    = 0.77  -- how often to check for movement updates (lower = more erratic).
    self.ismoving       = false -- tracks if currently moving.
    self.moveduration   = 1.45  -- how long the boss spends moving before re-evaluating.
    self.moveticks      = 0     -- track timer ticks
    self.melee          = false -- boss tries to stay in melee range.
    -- evasive movement features:
    self.evasive        = true  -- does ai move about randomly?
    self.evasivecadence = 3.0   -- how often to check for evasion.
    self.evasiveangle   = 80    -- angle to evade from tracked unit.
    self.evadetime      = 1.42  -- how long an evade lasts.
    -- minion features:
    self.hasminions     = true  -- enables a move check in the ai timer for idle minions.
end


function boss:new(unit, bossid)
    local o = setmetatable({}, self)
    -- override any features assigned to the boss via the metadata table:
    for id,t in pairs(self.bosst) do
        if id == bossid then
            for field,val in pairs(t) do
                o[field] = val
            end
        end
    end
    o.shadowspells = {} -- store unlocked darkness spells that are triggered by candle light.
    o.shadowticks  = 0.33 -- `` track how often to cast
    o.castindex = { basic = 0, power = 0, channel = 0, ultimate = 0 }  -- tracks spell category order when randomspells is false.
    o.unit = unit
    o.bossid = bossid
    SetHeroLevel(o.unit, math.max(10,map.mission.cache.level))
    BlzFrameSetText(bossfr.bossname.fh, o.name)
    o:scale_health()
    o:start_update_hp_bar()
    if o.playercolor then SetUnitColor(o.unit, GetPlayerColor(o.playercolor)) end
    self.stack[o] = o
    return o
end


function boss:run_intro_scene()
    local dur      = 4.9
    local alpha    = 0
    local swoopdur = 0.9
    local swoopend = math.ceil(swoopdur/0.03)
    local alphainc = math.ceil(255/(swoopdur/0.03)) -- load to full alpha over x sec.
    local ystart1, ystart2 = kui.position.centery - kui:px(60), kui.position.centery - kui:px(95)
    local xstart1, xstart2, xspeed = kui.position.centerx - kui:px(400), kui.position.centerx + kui:px(400), kui:px(12)
    BlzEnableSelections(false, false)
    PauseAllUnitsBJ(true)
    -- grant vision of boss to players:
    utils.playerloop(function(p) UnitShareVisionBJ(true, self.unit, p) end)
    utils.timed(1.0, function()
        utils.debugfunc(function()
            utils.playerloop(function(p)
                ReleaseTimer(kobold.player[p].permtimer)
                kui:hidegameui(p)
                map.manager.candlebar:hide()
            end)
            bossslidetext1:show()
            bossslidetext1:settext(self.name)
            bossslidetext1:setalpha(0)
            bossslidetext2:show()
            bossslidetext2:settext(self.subtitle)
            bossslidetext2:setalpha(0)
            utils.playsoundall(kui.sound.bossintro)
            utils.timedrepeat(0.03, dur/0.03, function(c)
                utils.debugfunc(function()
                    utils.playerloop(function(p) CameraSetupApplyForPlayer(true, gg_cam_bossViewCam, p, 0.9) end)
                    alpha = alpha + alphainc
                    BlzFrameSetAlpha(bossslidetext1.fh, math.min(255, alpha))
                    BlzFrameSetAlpha(bossslidetext2.fh, math.min(255, alpha))
                    xstart1, xstart2 = xstart1 + xspeed, xstart2 - xspeed
                    bossslidetext1:setabsfp(fp.c, xstart1, ystart1)
                    bossslidetext2:setabsfp(fp.c, xstart2, ystart2)
                    if c == swoopend then xspeed = kui:px(0.6) map.mission.cache.boss:play_sound('intro') end
                end, "boss intro 2nd timer")
            end, function()
                utils.debugfunc(function()
                    PauseAllUnitsBJ(false)
                    BlzEnableSelections(true, false)
                    utils.playerloop(function(p)
                        kui:showgameui(p, true)
                        map.manager.candlebar:show()
                        CameraSetupApplyForPlayer(true, gg_cam_gameCameraTemplate, p, 0.66)
                        utils.permselect(kobold.player[p].unit, p, kobold.player[p])
                        SelectUnitForPlayerSingle(kobold.player[p].unit, p)
                    end)
                    candle.current = candle.total + candle.bossb -- set wax to boss duration.
                    bossslidetext1:hide()
                    bossslidetext2:hide()
                    bossfr:show()
                    self:init_boss_ai()
                end, "boss intro wrap-up")
            end)
        end, "boss intro 1st timer")
    end)
end


function boss:init_boss_ai()
    for i,v in pairs(self.spellticks) do
        self.spellticks[i] = 0
    end
    self.debug          = false
    self.trackedunit    = kobold.player[Player(0)].unit
    self.waxthresh      = 100.0
    self.castcheckrate  = 0.33
    if not boss_dev_mode then candle:load() end
    if map.manager.diffid == 5 then
        self.castcheckrate = 0.45
        self.channeltime   = self.channeltime*0.8
        self.casttime      = self.casttime*0.8
    end
    -- -- --
    if self.moves then
        self.tmr = TimerStart(NewTimer(), 0.33, true, function()
            utils.debugfunc(function()
                if self.unit and utils.isalive(self.unit) and (boss_dev_mode or map.manager.activemap) then
                    self.moveticks  = self.moveticks  + 0.33
                    self:checkwax()
                    self:checkshadow()
                    -- check move conditions every full second:
                    if self.moveticks > self.movecadence and not self.ismoving and not self.iscasting then
                        -- update collision detection:
                        if self.collides then
                            SetUnitPathing(self.unit, true)
                        else
                            SetUnitPathing(self.unit, false)
                        end
                        -- check leash range
                        if self.debug then print("?: checking leash") end
                        if utils.distunits(self.trackedunit, self.unit) > self.leash then
                            if self.debug then print("-> leash range exceeded") end
                            self:move_to_xy(utils.unitxy(self.trackedunit))
                            self.moveticks = 0
                            return
                        -- if evasive, make ai move about.
                        elseif self.evasive and self.moveticks > self.evasivecadence then
                            if self.debug then print("?: checking if should evade") end
                            -- get random angle direction:
                            local a   = self.evasiveangle
                            if math.random(1,2) == 1 then a = -1*a end
                            local a2  = utils.angleunits(self.unit, self.trackedunit) + a
                            local x,y = utils.unitprojectxy(self.unit, 1000, a2)
                            -- see if outside of arena, if so, reverse angle of movement toward center:
                            -- if utils.distxy(x, y, self.centerx, self.centery) > 1536 then
                                -- if self.debug then print("-> outside of arena detected") end
                                -- self:move_to_xy(self.centerx, self.centery)
                            -- else
                                if self.debug then print("-> evade") end
                                -- occasionally do a longer evade:
                                if math.random(1,4) == 1 then
                                    self:move_to_xy(x, y, self.evadetime*1.33)
                                else
                                    self:move_to_xy(x, y, self.evadetime)
                                end
                            -- end
                            -- if minions, move them toward tracked unit so they don't idle:
                            if self.hasminions then
                                local grp = g:newbyunitloc(Player(24), g_type_ally, self.unit, 3000.0)
                                grp:action(function() if grp.unit ~= self.unit then utils.issatkxy(grp.unit, utils.unitxy(self.trackedunit)) end end)
                                grp:destroy()
                            end
                            self.moveticks = 0
                            return
                        end
                    end
                    for abilitytype,tick in pairs(self.spellticks) do
                        if not self.iscasting then
                            self.spellticks[abilitytype] = self.spellticks[abilitytype] + self.castcheckrate
                        end
                    end
                    -- check spell conditions:
                    if self.debug then print("?: checking if should cast") end
                    if not self.iscasting and not self.ismoving then
                        -- see if timer has reached spell cast point for each spell category:
                        for abilitytype,tick in pairs(self.spellticks) do
                            if tick > self.spellcadence[abilitytype] then
                                -- cast basic ability:
                                self:start_casting(abilitytype)
                                self.spellticks[abilitytype] = 0
                                return
                            end
                        end
                    else
                        if self.debug then print("-> should not cast") end
                    end
                else
                    -- if boss was defeated:
                    if not utils.isalive(self.unit) and map.manager.downp ~= map.manager.totalp then
                        -- clear area of boss units:
                        map.grid:clearunits(0.0, 0.0, 6400.0, true)
                        -- run victory items:
                        ResetUnitAnimation(self.unit)
                        SetUnitAnimation(self.unit, 'death')
                        self:play_death_effect()
                        utils.playsoundall(kui.sound.bossdefeat)
                        PauseTimer(self.candletmr)
                        map.manager.candlebar:hide()
                        alert:new(color:wrap(color.tooltip.good,self.name).." has been vanquished!", 6.0)
                        map.mission.cache:objstep(12.5)
                        if self.bossid == "N01R" then
                            map.block:spawnore(4*map.manager.diffid, 7, utils.unitx(self.unit), utils.unity(self.unit))
                        else
                            map.block:spawnore(3*map.manager.diffid, self.dmgtypeid, utils.unitx(self.unit), utils.unity(self.unit))
                        end
                        -- unlock badges:
                        badge:earn(kobold.player[Player(0)], self.badge_id)
                        if map.manager.diffid == 5 and kobold.player[Player(0)].level >= 60 then
                            badge:earn(kobold.player[Player(0)], self.badge_id_tyran)
                            local total_defeated = 0
                            for id = 13,17 do
                                if kobold.player[Player(0)].badge[id] == 1 and kobold.player[Player(0)].badgeclass[badge:get_class_index(id, kobold.player[Player(0)].charid)] == 1 then
                                    total_defeated = total_defeated + 1
                                    if total_defeated == 5 then
                                        badge:earn(kobold.player[Player(0)], 18)
                                    end
                                end
                            end
                        end
                    end
                    -- cleanup:
                    bossfr:hide()
                    StopSound(kui.sound.bossmusic, false, true)
                    -- delete after all map wrapup logic has referenced this object:
                    utils.timed(20.0, function() self.castindex = nil self.shadowspells = nil self.stack[self] = nil end)
                    ReleaseTimer()
                end
            end, "boss ai timer")
        end)
    else
        -- TODO: what if boss is a stationary unit?
    end
end


function boss:play_death_effect()
    local x,y = utils.unitxy(self.unit)
    utils.timedrepeat(0.24, 18, function()
        utils.speffect(area_storm_stack[self.bosst[self.bossid].dmgtypeid].effect, utils.projectxy(x, y, math.random(100,260), math.random(0,360)))
    end)
end


function boss:move_to_xy(x, y, _dur)
    if self.debug then print("-> move to",x,y,"over",_dur or self.moveduration,"sec") end
    self.ismoving = true
    utils.issmovexy(self.unit, x, y)
    utils.timed(_dur or self.moveduration, function() utils.stop(self.unit) self.ismoving = false end)
end


function boss:start_update_hp_bar()
    if self.tmr then ReleaseTimer(self.tmr) end
    self.tmr = TimerStart(NewTimer(),0.15,true,function()
        utils.debugfunc(function()
            if self.unit and utils.isalive(self.unit) then
                BlzFrameSetValue(bossfr.hpbar.fh, math.ceil(GetUnitLifePercent(self.unit)))
                BlzFrameSetText(bossfr.hptxt.fh, math.floor(GetUnitState(self.unit, UNIT_STATE_LIFE)) .."/" ..math.floor(GetUnitState(self.unit, UNIT_STATE_MAX_LIFE)))
            else
                BlzFrameSetValue(bossfr.hpbar.fh, 0)
                ReleaseTimer()
            end
        end, "update bars")
    end)
end


-- @abilitytype = "basic" or "power" or "channel"
-- @_castdur = override default cast duration.
function boss:start_casting(abilitytype, _castdur)
    utils.debugfunc(function()
        local ct = _castdur or self.casttime
        if self.debug then print("issued to cast",abilitytype,"ability with cast time",ct) end
        self.iscasting = true
        utils.stop(self.unit)
        utils.faceunit(self.unit, self.trackedunit)
        if abilitytype == "channel" then
            SetUnitAnimation(self.unit, 'channel')
            ct = self.channeltime
            speff_channel:attachu(self.unit, self.channeltime, 'origin', 2.0)
        elseif abilitytype == "basic" then
            SetUnitAnimation(self.unit, 'attack')
        else
            SetUnitAnimation(self.unit, 'spell')
        end
        utils.timed(ct, function()
            utils.debugfunc(function()
                self:end_casting(abilitytype)
                self:spell_cast(abilitytype)
            end, "start_casting timer")
        end)
        -- channel finish specific effects:
        if abilitytype == 'channel' then
            self:play_sound(abilitytype)
        end
        -- if ultimate, delay other abilities so they do not overlap:
        if abilitytype == 'ultimate' and self.ultdelayspells then
            self.spellticks['basic'] = self.spellticks['basic'] - self.spellcadence['basic']
            self.spellticks['power'] = self.spellticks['power'] - self.spellcadence['power']
            self.spellticks['channel'] = self.spellticks['channel'] - self.channeltime
        end
    end, "start_casting")
end

-- @abilitytype = 'basic', 'power', or 'channel'
function boss:spell_cast(abilitytype)
    if self.debug then print('attempting to self:spell_cast for ability type',abilitytype) end
    if not self.pausespells then
        if self.randomspells then
            self.spellbook[abilitytype][math.random(1,#self.spellbook[abilitytype])](self)
        else -- ordered
            if self.spellbook[abilitytype][self.castindex[abilitytype] + 1] then
                self.castindex[abilitytype] = self.castindex[abilitytype] + 1
            else
                self.castindex[abilitytype] = 1
            end
            self.spellbook[abilitytype][self.castindex[abilitytype]](self)
        end
    end
end


function boss:end_casting(abilitytype)
    if self.debug then print("finished casting") end
    self.iscasting = false
    ResetUnitAnimation(self.unit)
    if self.casteffect then
        self.casteffect:play(utils.unitx(self.unit), utils.unity(self.unit), nil, self.casteffectsc)
    end
    if abilitytype ~= 'channel' then
        self:play_sound(abilitytype)
    else
        -- self:play_sound('basic')
    end
end


function boss:init_sounds()
    for bossid,_ in pairs(boss.bosst) do
        boss.bosst[bossid].bossaudio = {}
        for soundkey,sound in pairs(kui.sound.boss[bossid]) do
            boss.bosst[bossid].bossaudio[soundkey] = sound
        end
    end
end


function boss:play_sound(soundkey)
    if soundkey == 'intro' then
        utils.playsoundall(self.bosst[self.bossid].bossaudio[soundkey])
    elseif soundkey == 'ultimate' then
        utils.playsoundall(kui.sound.boss.ultimate)
    else
        StopSound(self.bosst[self.bossid].bossaudio[soundkey], false, false)
        PlaySoundOnUnitBJ(self.bosst[self.bossid].bossaudio[soundkey], 80.0, self.unit)
    end
end


function boss:get_dmg(damage)
    if map.manager.activemap then
        return map.mission.cache.setting[m_stat_attack]*damage*(1 + (map.mission.cache.level^1.125)*0.03)
    else
        return damage
    end
end


function boss:heal_value(amount)
    utils.addlifeval(self.unit, amount, false)
end


function boss:heal_percent(percent)
    utils.addlifep(self.unit, percent, false)
end


function boss:deal_area_dmg(damage, x, y, r, _hitfunc)
    local grp = g:newbyxy(Player(24), g_type_dmg, x, y, r)
    local damage = self:get_dmg(damage)
    grp:action(function()
        if utils.isalive(grp.unit) then
            dmg.type.stack[self.dmgtypeid]:dealdirect(self.unit, grp.unit, damage)
            if _hitfunc then
                _hitfunc(grp.unit)
            end
        end
    end)
    grp:destroy()
end


function boss:scale_health()
    local newhp = utils.life(self.unit)*map.mission.cache.setting[m_stat_health]
    newhp = newhp*(1 + (map.mission.cache.level^1.1)*0.02)
    if map.mission.cache.level >= 60 then
        newhp = newhp*1.1
    end
    utils.setnewunithp(self.unit, math.floor(newhp), true)
    utils.restorestate(self.unit)
    BlzSetUnitArmor(self.unit, 5)
    if map.mission.cache then
        BlzSetUnitArmor(self.unit, math.ceil( BlzGetUnitArmor(self.unit)+((map.mission.cache.setting[m_stat_enemy_res]-1)*100)) )
    end
end


-- create a visual rune marker at @x,@y that lasts for @dur to highlight landing locations etc.
function boss:marker(x, y, dur)
    local e = speff_bossmark3:play(x, y, dur or nil, 1.15)
    BlzSetSpecialEffectTimeScale(e, 300)
    BlzSetSpecialEffectZ(e, BlzGetLocalSpecialEffectZ(e))
    BlzSetSpecialEffectColorByPlayer(e, Player(0)) -- make it red.
    return e
end


function boss:awardbosschest()
    utils.looplocalp(function()
        kui.canvas.game.bosschest:show()
        for i = 1,5 do kui.canvas.game.bosschest.chest.gem[i]:hide() end
        kui.canvas.game.bosschest.chest.gem[map.manager.prevbiomeid]:show()
    end)
end


-- check if boss has lost a percentage of health, then drop wax.
function boss:checkwax()
    if utils.getlifep(self.unit) < self.waxthresh - self.waxchunk and candle.current > 0 then
        self.waxthresh = self.waxthresh - self.waxchunk
        self:spawnwax(self.waxcount)
    end
end


-- spawn wax canisters in a radius around the boss.
function boss:spawnwax(count)
    local x,y = utils.unitxy(self.unit)
    local size,tangle,incangle,x2,y2 = nil,math.random(0,360),360/count,0,0
    if map.manager.diffid == 5 then size = "medium" end
    for i = 1,count do
        x2,y2 = utils.projectxy(x, y, math.random(650,750), tangle)
        local mis = missile:create_arc(x2, y2, self.unit, 'Abilities\\Weapons\\FaerieDragonMissile\\FaerieDragonMissile.mdl', 0)
        mis.explfunc = function(mis) if map.manager.activemap then candle:spawnwax(mis.x, mis.y, size) end end
        tangle = tangle + incangle
    end
end


--[[
    ********************************************************
    ******************** darkness powers *******************
    ********************************************************
--]]


-- see if a shadow spell should be cast
function boss:checkshadow()
    utils.debugfunc(function()
        if #self.shadowspells > 0 and self.shadowticks > 15.0 then
            for i = 1,3 do
                if self.shadowspells[i] then utils.timed(i, function() self.shadowspells[i](self) end) end
            end
            self.shadowticks = 0
        else
            self.shadowticks = self.shadowticks + 0.33
        end
    end, "checkshadow")
end


function boss:assign_darkness_spell(waveid)
    if waveid == 1 then
        self.shadowspells[1] = function(bossobj) bossobj:darkness_shadow_mortar() end
    elseif waveid == 2 then
        self.shadowspells[2] = function(bossobj) bossobj:darkness_shadow_minions() end
    elseif waveid == 3 then
        self.shadowspells[3] = function(bossobj) bossobj:darkness_shadow_bomb() end
    end
end


-- establish origin point of a darkness spell from center of map to tracked unit location:
function boss:init_darkness_spell()
    local x1,y1 = utils.unitxy(self.trackedunit)
    local a     = utils.anglexy(0, 0, x1, y1)
    local x2,y2 = utils.projectxy(0, 0, math.random(150,1000), a + math.randomneg(-4,4))
    return x1, y1, x2, y2, a
end


function boss:darkness_shadow_mortar()
    local x,y = utils.unitxy(self.unit)
    speff_stormshad:play(x,y)
    self:spell_artillery(34, mis_voidball, 1.0, 1.72, 0.18, math.random(16,18), 260.0, 120.0, nil, 300)
end


-- summons a void well which does light area damage while tossing shadow minions out of it.
function boss:darkness_shadow_minions()
    local x1,y1,x2,y2,a = self:init_darkness_spell()
    speff_voidpool:play(x2, y2, 12.0, 1.33)
    speff_stormshad:play(x2,y2)
    utils.timedrepeat(0.33, math.floor(12/0.33), function(c)
        utils.debugfunc(function()
            if utils.isalive(self.unit) then
                if math.fmod(c, 3) == 0 then
                    x1,y1 = utils.projectxy(x2, y2, math.random(100,300), math.random(0,360))
                    local mis = missile:create_arc(x1, y1, self.unit, speff_embersha.effect, self:get_dmg(16))
                    mis.x, mis.y = x1, y1
                    mis.angle = utils.anglexy(x2, y2, x1, y1)
                    mis.explfunc = function(mis) utils.issatkxy(bm_darknessdrop:create(mis.x, mis.y), utils.unitx(self.trackedunit), utils.unity(self.trackedunit)) end
                end
            else
                ReleaseTimer()
            end
        end, "minions timer")
    end)
end


-- spawns an orb which chases the player, dealing massive damage if it hits them.
function boss:darkness_shadow_bomb()
    local x1,y1,x2,y2,a = self:init_darkness_spell()
    local vel = 3
    local e = mis_voidballhge:play(x2, y2, 20.0, 1.1)
    BlzSetSpecialEffectYaw(e, a*bj_DEGTORAD)
    utils.seteffectxy(e, x2, y2, utils.getcliffz(x2, y2, 115))
    speff_stormshad:play(x2,y2)
    utils.timed(2.0, function()
        utils.timedrepeat(0.03, math.floor(20/0.03), function(c)
            utils.debugfunc(function()
                if utils.isalive(self.unit) then
                    a = utils.anglexy(x2, y2, utils.unitx(self.trackedunit), utils.unity(self.trackedunit))
                    BlzSetSpecialEffectYaw(e, a*bj_DEGTORAD)
                    x2, y2 = utils.projectxy(x2, y2, vel, a)
                    utils.seteffectxy(e, x2, y2, utils.getcliffz(x2, y2, 215.0))
                    if math.fmod(c, 10) == 0 and utils.distxy(x2, y2, utils.unitx(self.trackedunit), utils.unity(self.trackedunit)) < 150.0 then
                        self:deal_area_dmg(self:get_dmg(124), x2, y2, 300.0)
                        speff_fspurp:play(x2, y2, nil, 1.5)
                        DestroyEffect(e)
                        ReleaseTimer()
                    end
                else
                    DestroyEffect(e)
                    ReleaseTimer()
                end
            end, "bomb timer")
        end)
    end)
end


--[[
    ********************************************************
    ******************** boss abilities ********************
    ********************************************************
--]]


-- launches arcing missile(s) toward a player location.
function boss:spell_artillery(damage, effect, scale, traveltime, cadence, count, spread, _hitradius, _hitfunc, _startheight, _archeight)
    utils.debugfunc(function()
        local damage = self:get_dmg(damage)
        if self.debug then print('-> trying to: spell_artillery') end
        local x,y = utils.unitxy(self.trackedunit)
        local x2,y2 = 0,0
        utils.timedrepeat(cadence, count, function()
            x2,y2 = utils.projectxy(x, y, math.random(math.floor(spread*0.5),spread), math.random(0,360))
            local mis = missile:create_arc(x2, y2, self.unit, effect.effect, damage)
            mis:updatescale(scale)
            mis.dmgtype = dmg.type.stack[self.dmgtypeid]
            mis.explr   = _hitradius or 80.0
            mis.offset  = 120
            mis.arch    = _archeight or 600
            -- initialize timed:
            mis.time    = traveltime
            mis.height  = _startheight or 100.0
            mis.colfunc = _hitfunc or nil
            boss:marker(x2, y2)
            mis:initduration()
        end)
    end, "spell_artillery")
end


-- creates a radial spread of mines which explode after @detonatedelay seconds.
function boss:spell_mines(damage, spawneffect, explrad, mineeffect, scale, detonatedelay, detonateeffect, wavecount, wavedelay, spread, minecount, mineincrement)
    utils.debugfunc(function()
        local startangle,spawnangle,w = math.random(0,360),math.floor(360/minecount),0
        local centerx,centery = utils.unitxy(self.unit)
        local currentspread,spread,explrad,mineincrement,minecount,scale = spread,spread,explrad,mineincrement,minecount,scale
        bossminet = {}
        utils.timedrepeat(wavedelay, wavecount, function()
            w = w + 1 -- wave number.
            local wc = w -- instantiate wave.
            bossminet[w] = {}
            for i = 1,minecount do
                bossminet[w][i] = {}
                bossminet[w][i].x, bossminet[w][i].y = utils.projectxy(centerx, centery, currentspread, startangle)
                spawneffect:play(bossminet[w][i].x, bossminet[w][i].y)
                bossminet[w][i].e = mineeffect:play(bossminet[w][i].x, bossminet[w][i].y, detonatedelay, scale) -- mine effect (stored)
                speffect:addz(bossminet[w][i].e, 16) -- raise it a bit to prevent clipping.
                startangle = startangle + spawnangle
            end
            minecount = minecount + mineincrement
            currentspread = currentspread + spread
            spawnangle = spawnangle + 8
            utils.timed(detonatedelay, function()
                utils.debugfunc(function()
                    for i,t in ipairs(bossminet[wc]) do
                        if t.x and t.y then
                            detonateeffect:play(t.x, t.y)
                            self:deal_area_dmg(damage, t.x, t.y, explrad)
                            bossminet[wc][i] = nil
                        end
                    end
                    bossminet[wc] = nil
                end, "spell_mines detonate")
            end)
        end)
    end, "spell_mines")
end


function boss:spell_missile_circle(damage, effect, scale, distance, count, velocity, _duration, _hitradius, _height, _collides, _explodes)
    -- launch a fan of missiles in every direction around the boss.
    local x,y = utils.unitxy(self.unit)
    local damage = self:get_dmg(damage)
    missile:create_in_radius(x, y, self.unit, effect.effect, damage, dmg.type.stack[self.dmgtypeid], count,
        distance, _duration or nil, _hitradius or nil, _height or nil, _collides or nil, _explodes or nil)
end


function boss:spell_wall_of_fire(damage, walleffect, moveeffect, scale, velocity, duration, hitradius, startx, starty, endx, endy, chunkspread, length, _hitfunc)
    utils.debugfunc(function()
        local e,x,y,t,a,d,hr,v,cr = {},0,0,1,utils.anglexy(startx, starty, endx, endy),damage,hitradius,velocity,chunkspread/2
        -- build random gap:
        -- build "up":
        for i = 1,math.ceil(length/2) do
            e[i] = {}
            e[i].x, e[i].y = utils.projectxy(startx, starty, cr, a - 90)
            e[i].e = walleffect:play(x,y,duration,scale or 1.0)
            cr = cr + chunkspread
            t  = t + 1
        end
        cr = chunkspread/2
        -- build "down":
        for i = t,t+math.floor(length/2) do
            e[i] = {}
            e[i].x, e[i].y = utils.projectxy(startx, starty, cr, a + 90)
            e[i].e = walleffect:play(x,y,duration,scale or 1.0)
            cr = cr + chunkspread
            t  = t + 1
        end
        -- run timer:
        local tick = 0
        utils.timedrepeat(0.03,math.floor(duration/0.03),function()
            utils.debugfunc(function()
                if map.manager.activemap then
                    tick = tick + 1
                    -- move effects forward:
                    for i,t in ipairs(e) do
                        t.x, t.y = utils.projectxy(t.x, t.y, v, a)
                        utils.seteffectxy(t.e, t.x, t.y)
                    end
                    -- deal damage every 0.33 sec:
                    if math.fmod(tick,10) == 0 then
                        for i,t in ipairs(e) do
                            self:deal_area_dmg(d, t.x, t.y, hr)
                            if math.fmod(tick,12) == 0 then
                                moveeffect:playradius(hr, 2, t.x, t.y)
                            end
                        end
                    end
                else
                    for i,t in ipairs(e) do if t.e then DestroyEffect(t.e) end e[i] = nil end e = nil ReleaseTimer()
                end
            end, "spell_wall_of_fire timer")
        end, function()
            if e then
                for i,t in ipairs(e) do if t.e then DestroyEffect(t.e) end e[i] = nil end e = nil
            end
        end)
    end, "spell_wall_of_fire")
end


function boss:spell_summon_minions(miseffect, creatureobj, spawneffect, centerx, centery, distance, spreaddist, staggerdist, count, wavecount, cadence)
    -- launches missiles in a radius with a @stagger distance over @cadence time, generating minions upon landing.
    local cx, cy, dist, c, wc, ca = centerx, centery, distance, count, wavecount, cadence
    local a, ao, sp, spo, stag = 0, 360/count, distance, spreaddist, staggerdist
    local landfunc = function(x,y)
        if utils.isalive(self.unit) and (boss_dev_mode or map.manager.activemap) then
            utils.issatkxy(creatureobj:create(x,y), utils.unitxy(self.trackedunit))
            spawneffect:play(x,y)
        end
    end
    utils.timedrepeat(ca, wc, function()
        utils.debugfunc(function()
            a, sp = math.random(0,360), sp + spo -- get random start angle, increase wave distance from center.
            -- summon minions:
            for i = 1,count do
                tarx,tary = utils.projectxy(cx, cy, sp, a)
                boss:marker(tarx, tary)
                tarx,tary = utils.projectxy(tarx, tary, math.random(math.floor(stag/2),stag), math.random(0,360))
                local mis = missile:create_arc(tarx, tary, self.unit, miseffect.effect, 0)
                mis.explfunc = function() landfunc(mis.x, mis.y) end
                a = a + ao
            end
        end, "spell_summon_minions timer")
    end)
end


function boss:spell_trample(damage, velocity, delay, hitradius, tarx, tary, animindex, exhaustdur)
    self.iscasting = true
    local exhaustdur = exhaustdur or 0.03
    local dist  = utils.distxy(utils.unitx(self.unit), utils.unity(self.unit), tarx, tary)
    local angle = utils.anglexy(utils.unitx(self.unit), utils.unity(self.unit), tarx, tary)
    local markd = dist/5 -- number of markers to place
    local x,y   = utils.projectxy(utils.unitx(self.unit), utils.unity(self.unit), markd, angle)
    for i = 1,5 do
        x,y = utils.projectxy(utils.unitx(self.unit), utils.unity(self.unit), markd*i, angle)
        boss:marker(x, y)
    end
    utils.face(self.unit, angle)
    utils.timed(delay, function()
        utils.debugfunc(function()
            sp_enchant_eff[2]:attachu(self.unit, dist/velocity*0.03, 'origin')
            PauseUnit(self.unit, true)
            ResetUnitAnimation(self.unit)
            SetUnitAnimationByIndex(self.unit, animindex)
            utils.timedrepeat(0.03,dist/velocity,function(c)
                utils.debugfunc(function()
                    if utils.isalive(self.unit) then
                        x,y = utils.projectxy(utils.unitx(self.unit), utils.unity(self.unit), velocity, angle)
                        utils.setxy(self.unit, x, y)
                        if math.fmod(c, 11) == 0 then
                            self:deal_area_dmg(damage, x, y, hitradius, nil)
                            speff_dustcloud:playradius(hitradius, 3, x, y)
                            speff_quake:playradius(hitradius, 3, x, y)
                        end
                    else
                        ReleaseTimer()
                    end
                end, "spell_trample timer 2")
            end, function()
                SetUnitVertexColor(self.unit, 125, 125, 125, 255)
                ArcingTextTag(color:wrap(color.tooltip.bad, "Exhausted!"), self.unit, 3.0)
                ResetUnitAnimation(self.unit)
                utils.timed(exhaustdur, function()
                    SetUnitVertexColor(self.unit, 255, 255, 255, 255)
                    self.iscasting = false
                    PauseUnit(self.unit, false)
                end)
            end)
        end, "spell_trample timer 1")
    end)
end


function boss:spell_shockwave(damage, effect, scale, waveeffect, startx, starty, angle, velocity, traveltime, hitradius, _misheight)
    local x,y   = utils.projectxy(startx, starty, 1000, angle)
    local d     = self:get_dmg(damage)
    local mis   = missile:create_piercexy(x, y, self.unit, effect.effect, 0)
    local tick  = 0
    mis.time    = traveltime
    mis.radius  = hitradius
    mis.vel     = velocity
    mis.height  = _misheight or mis.height
    mis.dmgtype = dmg.type.stack[self.dmgtypeid]
    mis:initduration()
    mis:updatescale(scale)
    utils.timedrepeat(0.12, math.floor(traveltime/0.12), function()
        tick = tick + 1
        if mis then
            if tick >= 3 then
                waveeffect:playradius(mis.radius, 3, mis.x, mis.y)
                self:deal_area_dmg(d, mis.x, mis.y, mis.radius, nil)
                tick = 0
            end
        end
    end)
end



function boss:spell_spinning_turret(damage, turreteffect, turretscale, height, miseffect, spawnx, spawny, duration, spinrate, radius, misvelocity, misdist, _isartillery,
        _dmgtype)
    -- creates a special effect shoots missiles in a radius over time.
    local d,a,ao,x,y,spawnx,spawny,isartillery = self:get_dmg(damage),math.random(0,360),360*spinrate,0,0,spawnx,spawny,_isartillery
    local r,v = radius,misvelocity
    utils.seteffectxy(turreteffect:play(spawnx, spawny, duration, turretscale), spawnx, spawny, utils.getcliffz(spawnx, spawny, height))
    utils.timed(1.5, function()
        utils.timedrepeat(spinrate, math.floor(duration/spinrate), function()
            utils.debugfunc(function()
                x,y         = utils.projectxy(spawnx, spawny, r, a) -- missile landing point
                local mis   = missile:create_point(spawnx, spawny, utils.anglexy(spawnx, spawny, x, y), misdist, self.unit, miseffect.effect, d, isartillery, 0.90)
                mis.dmgtype = _dmgtype or dmg.type.stack[self.dmgtypeid]
                mis.explr   = 80.0
                mis.radius  = 90.0
                mis.vel     = v
                a = a + ao
            end, "spell_spinning_turret timer")
        end)
    end)
end
