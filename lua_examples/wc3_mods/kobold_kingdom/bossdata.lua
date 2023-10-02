function boss:buildbosses()
    -- store UI meta details by unit code:
    self.bosst          = {}
    self.bosst['N01B']  = {name = "The Slag King", subtitle = "Is it getting hotter in here?", code = 'N01B', biomeid = biome_id_slag, dmgtypeid = dmg_fire}
    self.bosst['N01B'].badge_id       = 7
    self.bosst['N01B'].badge_id_tyran = 13
    self.bosst['N01B'].casteffect   = speff_conflagoj
    self.bosst['N01B'].evadetime    = 0.86
    self.bosst['N01B'].casttime     = 1.21
    self.bosst['N01B'].casteffectsc = 2.25
    self.bosst['N01B'].channeltime  = 4.25
    self.bosst['N01B'].hasminions   = false
    self.bosst['N01B'].playercolor  = Player(5) -- orange
    self.bosst['N01B'].spellcadence = { basic = 1.66, power = 6.0, channel = 8.0, ultimate = 16.0 }
    self.bosst['N01B'].spellbook    = {
        basic = {
            [1] = function(bossobj) -- launches a volley of fireballs at the tracktarget.
                bossobj:spell_artillery(42, mis_fireballbig, 0.81, 1.9, 0.19, math.random(9,15), 330.0, 120.0, nil, 300)
            end,
        },
        power = {
            [1] = function(bossobj) -- spews mines over the arena that explode in waves.
                bossobj:spell_mines(64, speff_conflagoj, 142.0, mis_grenadeoj, 1.33, 4.0, speff_redburst, 8, 0.33, 260.0, 6, 3)
            end,
        },
        channel = {
            [1] = function(bossobj) -- launches repeat fiery missiles in a radius that increase in travel range per wave.
                local c,d = 10,450
                kb:new_pgroup(Player(24), utils.unitx(bossobj.unit), utils.unity(bossobj.unit), 350.0, 400.0, 0.75)
                utils.timedrepeat(0.54, 8, function()
                    bossobj:spell_missile_circle(24, mis_fireball, 1.15, d, c, 7, nil, 60.0, 95.0, true)
                    c,d = c+1,d+425
                end)
            end
        },
        ultimate = {
            [1] = function(bossobj) -- creates a wall of fire that tracks across the arena.
                local x,y   = utils.unitx(bossobj.unit),utils.unity(bossobj.unit)
                local x1,y1 = utils.projectxy(x, y, 2500, utils.angleunits(bossobj.unit, bossobj.trackedunit) - 180)
                local x2,y2 = utils.projectxy(x, y, 2500, utils.angleunits(bossobj.unit, bossobj.trackedunit))
                bossobj:spell_wall_of_fire(86, speff_sacstorm, speff_flare, 1.5, 10.5, 24.0, 280, x1, y1, x2, y2, 725, 8)
            end,
        }
    }
    self.bosst['N01F']  = {name = "Marsh Mutant", subtitle = "*Inaudible gurgling noises.*", code = 'N01F', biomeid = biome_id_mire, dmgtypeid = dmg_nature}
    self.bosst['N01F'].badge_id       = 8
    self.bosst['N01F'].badge_id_tyran = 14
    self.bosst['N01F'].casteffect   = speff_waterexpl
    self.bosst['N01F'].casteffectsc = 2.5
    self.bosst['N01F'].channeltime  = 2.75
    self.bosst['N01F'].randomspells = false
    self.bosst['N01F'].playercolor  = Player(6) -- green
    self.bosst['N01F'].spellcadence = { basic = 4.87, power = 9.21, channel = 14.33, ultimate = 21.00 }
    self.bosst['N01F'].spellbook    = {
        basic = {
            [1] = function(bossobj) -- launches missiles in a radius to spawn a horde of minions.
                local x,y = utils.unitxy(bossobj.unit)
                bossobj:spell_summon_minions(speff_embernat, bm_swampling, speff_water, utils.unitx(bossobj.unit), utils.unity(bossobj.unit), 800.0, 200.0, 200.0, 4, 3, 0.33)
            end,
            [2] = function(bossobj) -- launches 3 waves of sludge missiles over 3 sec
                local misfunc = function(bossobj)
                    local centerx,centery   = utils.unitxy(bossobj.trackedunit)
                    local x,y,starta,offa   = 0, 0, utils.angleunits(bossobj.unit, bossobj.trackedunit), 90
                    starta = -offa
                    for i = 1,3 do
                        x,y         = utils.projectxy(centerx, centery, 225, starta)
                        local mis   = missile:create_arc(x, y, bossobj.unit, mis_acid.effect, boss:get_dmg(24))
                        mis.bounces = 0
                        mis.explr   = 96
                        mis.time    = 1.78
                        mis.dmgtype = dmg.type.stack[dmg_nature] 
                        mis:updatescale(1.33)
                        mis:initduration()
                        starta = starta + offa
                    end
                end
                misfunc(bossobj)
                utils.timedrepeat(1.0, 3, function()
                    misfunc(bossobj)
                end, function() misfunc = nil end)
            end
        },
        power = {
            [1] = function(bossobj) -- launches a single torrent of water in a line at trackedunit.
                local startangle = utils.angleunits(bossobj.unit, bossobj.trackedunit) + math.randomneg(-4,4)
                bossobj:spell_shockwave(24, mis_waterwave, 0.7, speff_water, utils.unitx(bossobj.unit), utils.unity(bossobj.unit), startangle, 7.0, 12.0, 150)
            end
        },
        channel = {
            [1] = function(bossobj) -- generate turrets that lob water artillery in a circle.
                local x,y,a,ao = 0,0,math.random(0,360),360/6
                utils.timedrepeat(0.45, 8, function()
                    x,y = utils.projectxy(utils.unitx(bossobj.unit), utils.unity(bossobj.unit), math.random(1200,1300), a - math.random(0,4))
                    speff_conflaggn:play(x, y, nil, 1.5)
                    bossobj:spell_spinning_turret(24, mis_boltgreen, 0.7, 124.0, mis_shot_nature, x, y, 13.5, 0.09, 260.0, 10, 333.0, false)
                    a = a + ao
                end)
            end
        },
        ultimate = {
            [1] = function(bossobj) -- launches multiple torrents of water in a line at trackedunit.
                bossobj.iscasting = true
                PauseUnit(bossobj.unit, true)
                local startangle, angleoffset = 0,0
                utils.timed(1.33, function()
                    utils.timedrepeat(1.21, 6, function()
                        if utils.isalive(bossobj.unit) then
                            angleoffset = math.random(30,40)
                            startangle = utils.angleunits(bossobj.unit, bossobj.trackedunit) - angleoffset
                            SetUnitAnimation(bossobj.unit, 'spell')
                            speff_waterexpl:play(utils.unitxy(bossobj.unit))
                            for i = 1,3 do
                                bossobj:spell_shockwave(24, mis_waterwave, 0.7, speff_water, utils.unitx(bossobj.unit), utils.unity(bossobj.unit), startangle, 6.5, 13.0, 150, 100)
                                startangle = startangle + angleoffset
                            end
                        else
                            ReleaseTimer()
                        end
                    end, function()
                        bossobj.iscasting = false
                        PauseUnit(bossobj.unit, false)
                    end)
                end)
            end
        }
    }
    self.bosst['N01H']  = {name = "Megachomp", subtitle = "Nobody move a muscle.", code = 'N01H', biomeid = biome_id_foss, dmgtypeid = dmg_phys}
    self.bosst['N01H'].badge_id       = 9
    self.bosst['N01H'].badge_id_tyran = 15
    self.bosst['N01H'].casteffect   = speff_roar
    self.bosst['N01H'].casteffectsc = 2.5
    self.bosst['N01H'].evadetime    = 0.91
    self.bosst['N01H'].casttime     = 0.66
    self.bosst['N01H'].channeltime  = 1.25
    self.bosst['N01H'].randomspells = false
    self.bosst['N01H'].playercolor  = Player(0) -- red
    self.bosst['N01H'].spellcadence = { basic = 3.81, power = 9.27, channel = 5.21, ultimate = 14.00 }
    self.bosst['N01H'].spellbook    = {
        basic = {
            [1] = function(bossobj) -- launch a huge boulder which summons an invincible golem which gets turned into artillery missiles by power ability.
                utils.timedrepeat(0.33, 3, function()
                    local x,y   = utils.projectxy(utils.unitx(bossobj.unit), utils.unity(bossobj.unit), math.random(800, 1000),
                        math.random(math.floor(utils.angleunits(bossobj.unit, bossobj.trackedunit)-30),math.floor(utils.angleunits(bossobj.unit, bossobj.trackedunit)+30)))
                    local mis   = missile:create_timedxy(x, y, 2, bossobj.unit, mis_rock.effect, bossobj:get_dmg(48))
                    mis.x,mis.y = utils.projectxy(utils.unitx(bossobj.unit), utils.unity(bossobj.unit), 175.0, utils.getface(bossobj.unit))
                    mis.dmgtype = dmg.type.stack[bossobj.dmgtypeid]
                    mis.vel     = 10.5
                    mis.radius  = 96
                    mis.expl    = true
                    mis.height  = 133
                    mis.explfunc = function(mis)
                        if utils.isalive(bossobj.unit) then
                            local u = bm_livfossil:create(mis.x, mis.y)
                            utils.setinvul(u, true)
                            PauseUnit(u, true)
                            utils.timedrepeat(2.0, nil, function()
                                if utils.isalive(u) and utils.isalive(bossobj.unit) then
                                    SetUnitAnimation(u, 'spell slam')
                                    utils.faceunit(u, bossobj.trackedunit)
                                    local mis = missile:create_timedxy(utils.unitx(bossobj.trackedunit), utils.unity(bossobj.trackedunit),
                                        12.0, u, mis_rock.effect, bossobj:get_dmg(16))
                                    mis.vel = math.random(14,18)
                                    mis.dmgtype = dmg.type.stack[bossobj.dmgtypeid]
                                else
                                    if u then KillUnit(u) end
                                    ReleaseTimer()
                                end
                            end)
                            utils.issatkunit(u, bossobj.trackedunit)
                        end
                    end
                    mis:updatescale(2.3)
                end)
            end,
            [2] = function(bossobj) -- stomps the ground to create a tremor that slowly moves in target direction.
                bossobj.iscasting = true
                PauseUnit(bossobj.unit, true)
                SetUnitAnimationByIndex(bossobj.unit, 4)
                utils.timedrepeat(0.78, 3, function(c)
                    local c = c + 1 -- prevent 0 for random angle negative function.
                    if utils.isalive(bossobj.unit) then
                        SetUnitAnimationByIndex(bossobj.unit, 4)
                        local a,vel = utils.angleunits(bossobj.unit, bossobj.trackedunit), 90.0
                        local x,y   = utils.unitprojectxy(bossobj.unit, 100.0, a)
                        speff_quake:play(x,y)
                        if utils.isalive(bossobj.unit) then
                            utils.timedrepeat(0.36, 62, function()
                                if utils.isalive(bossobj.unit) then
                                    x,y = utils.projectxy(x, y, vel, a)
                                    speff_quake:play(x,y)
                                    bossobj:deal_area_dmg(12, x, y, 180.0, function(u) bf_slow:apply(u, 6.0) end)
                                    local grp = g:newbyxy(Player(24), g_type_none, x, y, 180.0)
                                    grp:action(function()
                                        if GetUnitTypeId(grp.unit) == FourCC('n01I') and utils.isalive(grp.unit) then -- convert golems into artillery missiles.
                                            local x,y = utils.unitxy(grp.unit)
                                            missile:create_arc_in_radius(x, y, grp.unit, mis_rock.effect, bossobj:get_dmg(36),
                                                dmg.type.stack[bossobj.dmgtypeid], math.random(5,7), math.random(200,300), 2.21, 90.0, 350.0)
                                            KillUnit(grp.unit)
                                        end
                                    end)
                                    grp:destroy()
                                end
                            end)
                        end
                    else
                        ReleaseTimer()
                    end
                end, function()
                    ResetUnitAnimation(bossobj.unit)
                    bossobj.iscasting = false
                    PauseUnit(bossobj.unit, false)
                end)
            end
        },
        power = {
            [1] = function(bossobj) -- slams the ground, slowing all Kobolds in a huge radius and breaking golems.
                local d,c = 225, 6
                local x,y = utils.unitxy(bossobj.unit)
                utils.timedrepeat(0.15, 18, function(count)
                    utils.debugfunc(function()
                        speff_dustcloud:playradius(d, c, x, y)
                        speff_quake:playradius(d, c, x, y)
                        d,c = d + 225, c + 1
                        if math.fmod(count, 4) == 0 then
                            local grp = g:newbyxy(Player(24), g_type_none, x, y, d)
                            grp:action(function()
                                if GetUnitTypeId(grp.unit) == FourCC('n01I') and utils.isalive(grp.unit) then -- convert golems into artillery missiles.
                                    local x,y = utils.unitxy(grp.unit)
                                    missile:create_arc_in_radius(x, y, grp.unit, mis_rock.effect, bossobj:get_dmg(36),
                                        dmg.type.stack[bossobj.dmgtypeid], math.random(5,7), math.random(200,300), 2.21, 90.0, 350.0)
                                    KillUnit(grp.unit)
                                end
                            end)
                            bossobj:deal_area_dmg(6, x, y, d/2, function(u) bf_slow:apply(u, 8.0, true) end)
                            grp:destroy()
                        end
                    end, "megachomp power timer")
                end)
            end
        },
        channel = {
            [1] = function(bossobj) -- charges the focus target.
                local delay = 1.51
                if map.manager.diffid and map.manager.diffid == 5 then delay = delay*0.6 end
                kb:new_pgroup(Player(24), utils.unitx(bossobj.unit), utils.unity(bossobj.unit), 400.0, 500.0, 0.75)
                local x,y = utils.projectxy(utils.unitx(bossobj.unit), utils.unity(bossobj.unit), 1600, utils.angleunits(bossobj.unit, bossobj.trackedunit))
                bossobj:spell_trample(64, 24, delay, 264, x, y, 0, 3.78)
            end
        },
        ultimate = {
            [1] = function(bossobj) -- slows boss, chases player, launches artillery. if they get close, player loses 50% health and is stunned. boss heals for 10% health.
                utils.playsoundall(gg_snd_boss_megachomp_ultimate)
                speff_followmark:attachu(bossobj.trackedunit, 0.33*16, 'overhead')
                speff_ragered:attachu(bossobj.unit, 0.33*16, 'overhead')
                bossobj.iscasting = true
                SetUnitMoveSpeed(bossobj.unit, 330.0)
                utils.timed(1.33, function()
                    utils.timedrepeat(0.33, 18, function()
                        local x1, y1, x2, y2
                        local angle = utils.angleunits(bossobj.unit, bossobj.trackedunit)
                        local d = 164
                        -- launch rocks:
                        utils.timedrepeat(0.33, 4, function()
                            x1,y1 = utils.projectxy(utils.unitx(bossobj.unit), utils.unity(bossobj.unit), d, angle-30)
                            x2,y2 = utils.projectxy(utils.unitx(bossobj.unit), utils.unity(bossobj.unit), d, angle+30)
                            boss:marker(x1,y1)
                            boss:marker(x2,y2)
                            local mis1 = missile:create_arc(x1, y1, bossobj.unit, mis_rock.effect, bossobj:get_dmg(28))
                            local mis2 = missile:create_arc(x2, y2, bossobj.unit, mis_rock.effect, bossobj:get_dmg(28))
                            mis1.dmgtype, mis1.explr = dmg.type.stack[bossobj.dmgtypeid], 60.0
                            mis2.dmgtype, mis2.explr = dmg.type.stack[bossobj.dmgtypeid], 60.0
                            d = d + 164
                        end)
                        -- move unit:
                        utils.issmovexy(bossobj.unit, utils.unitxy(bossobj.trackedunit))
                        speff_dustcloud:playradius(156, 4, utils.unitxy(bossobj.unit))
                        if utils.distunits(bossobj.unit, bossobj.trackedunit) < 260.0 then
                            speff_bloodsplat:playradius(156, 4, utils.unitxy(bossobj.unit))
                            speff_pothp:play(utils.unitx(bossobj.unit), utils.unity(bossobj.unit), nil, 2.25)
                            dmg.type.stack[bossobj.dmgtypeid]:dealdirect(bossobj.unit, bossobj.trackedunit, utils.maxlife(bossobj.trackedunit)*0.5)
                            bf_stun:apply()
                            bossobj.iscasting = false
                            bossobj:heal_percent(10.0)
                            SetUnitMoveSpeed(bossobj.unit, 522.0)
                            bossobj.iscasting = true
                            PauseUnit(bossobj.unit, true)
                            SetUnitAnimationByIndex(bossobj.unit, 11)
                            utils.timed(1.44, function() bossobj.iscasting = false PauseUnit(bossobj.unit, false) end)
                            ReleaseTimer()
                        end
                    end, function()
                        if utils.isalive(bossobj.unit) then
                            PauseUnit(bossobj.unit, true) -- exhaust so melee can get hits in
                            SetUnitVertexColor(bossobj.unit, 125, 125, 125, 255)
                            ArcingTextTag(color:wrap(color.tooltip.bad, "Exhausted!"), bossobj.unit, 3.0)
                            utils.timed(6.0, function()
                                SetUnitVertexColor(bossobj.unit, 255, 255, 255, 255)
                                PauseUnit(bossobj.unit, false)
                                bossobj.iscasting = false
                                SetUnitMoveSpeed(bossobj.unit, 522.0)
                            end)
                        end
                    end)
                end)
            end
        }
    }
    self.bosst['N01J']  = {name = "Thawed Experiment", subtitle = "It's time to chill out.", code = 'N01J', biomeid = biome_id_ice, dmgtypeid = dmg_frost}
    self.bosst['N01J'].badge_id       = 10
    self.bosst['N01J'].badge_id_tyran = 16
    self.bosst['N01J'].casteffect   = speff_conflagbl
    self.bosst['N01J'].casteffectsc = 2.25
    self.bosst['N01J'].evadetime    = 1.45
    self.bosst['N01J'].casttime     = 1.05
    self.bosst['N01J'].channeltime  = 1.50
    self.bosst['N01J'].randomspells = false
    self.bosst['N01J'].playercolor  = Player(1) -- blue
    self.bosst['N01J'].spellcadence = { basic = 3.31, power = 6.3, channel = 16.65, ultimate = 12.1 }
    self.bosst['N01J'].spellbook    = {
        basic = {
            [1] = function(bossobj) -- launches a cluster of frozen bolts which explode to create impassable ice blocks.
                local x,y = 0,0
                for i = 1,6 do
                    x,y          = utils.unitxy(bossobj.trackedunit)
                    x,y          = utils.projectxy(x, y, math.random(30, 300), math.random(0,360))
                    local mis    = missile:create_arc(x, y, bossobj.unit, mis_blizzard.effect, boss:get_dmg(32))
                    mis.time     = 1.75
                    mis.radius   = 84.0
                    mis.explr    = 150.0
                    mis.vel      = 16.0
                    mis.dmgtype  = dmg.type.stack[bossobj.dmgtypeid]
                    mis.explfunc = function(mis)
                        if utils.isalive(bossobj.unit) then
                            utils.timedlife(utils.unitatxy(Player(24), mis.x, mis.y, 'h00I'), 24.0)
                            speff_frostnova:play(mis.x, mis.y)
                        end
                    end
                    mis:initduration()
                end
            end,
            [2] = function(bossobj) -- launches frozen orbs which summon minions.
                local x,y = 0,0
                for i = 1,9 do
                    x,y          = utils.unitxy(bossobj.trackedunit)
                    x,y          = utils.projectxy(x, y, math.random(10, 600), math.random(0,360))
                    local mis    = missile:create_arc(x, y, bossobj.unit, speff_frost.effect, boss:get_dmg(6))
                    mis.time     = 1.75
                    mis.radius   = 76.0
                    mis.vel      = 17.0
                    mis.dmgtype  = dmg.type.stack[bossobj.dmgtypeid]
                    mis.explfunc = function(mis)
                        if utils.isalive(bossobj.unit) then
                            utils.issatkxy(bm_discexperim:create(mis.x, mis.y), utils.unitxy(bossobj.trackedunit))
                            speff_conflagbl:play(mis.x, mis.y)
                        end
                    end
                    mis:initduration()
                end
            end
        },
        power = {
            [1] = function(bossobj) -- launches a line of crystals which act as movement blockers. slows on hit.
                bossobj.iscasting = true
                PauseUnit(bossobj.unit, true)
                utils.timedrepeat(1.0, 3, function()
                    if utils.isalive(bossobj.unit) then
                        SetUnitAnimation(bossobj.unit, 'spell')
                        local a,dt,d,x,y = 0,89.0,89.0,0,0
                        a = utils.angleunits(bossobj.unit, bossobj.trackedunit)
                        utils.face(bossobj.unit, a)
                        utils.timedrepeat(0.21, 18, function()
                            if utils.isalive(bossobj.unit) then
                                x,y = utils.unitxy(bossobj.unit)
                                x,y = utils.projectxy(x, y, dt, a)
                                x,y = utils.projectxy(x, y, math.random(0,16), math.random(90,180))
                                utils.timedlife(utils.unitatxy(Player(24), x, y, 'h00I'), 24.0)
                                bossobj:deal_area_dmg(32, x, y, 112.0, function(u) bf_slow:apply(u, 3.00, true) end)
                                speff_frostnova:play(x, y)
                                dt = dt + d
                            end
                        end)
                    end
                end, function() bossobj.iscasting = false PauseUnit(bossobj.unit, false) end)
            end
        },
        channel = {
            [1] = function(bossobj) -- launches a torrent of slow, spinning missiles which make a full loop around the arena.
                bossobj.iscasting = true
                PauseUnit(bossobj.unit, true)
                utils.timedrepeat(0.55, 12, function(c)
                    if utils.isalive(bossobj.unit) then
                        if math.fmod(c, 3) == 0 then
                            SetUnitAnimation(bossobj.unit, 'spell slam')
                            speff_iceblast:play(utils.unitx(bossobj.unit), utils.unity(bossobj.unit), nil, 2.25)
                        end
                        utils.timedrepeat(0.11, 5, function()
                            local mis  = missile:create_angle(math.random(0,360), 9600, bossobj.unit, speff_icecrystal.effect, bossobj:get_dmg(48))
                            mis.dmgtype= dmg.type.stack[bossobj.dmgtypeid]
                            mis.vel    = 8.3
                            mis.explr  = 124.0
                            mis.radius = 84.0
                            mis.expl   = true
                            mis.func   = function(mis)
                                mis.angle = mis.angle - 0.36
                                if not utils.isalive(bossobj.unit) then
                                    mis:destroy()
                                end
                            end
                            mis.explfunc = function(mis)
                                speff_iceblast:play(mis.x, mis.y)
                            end
                        end)
                    end
                end, function() bossobj.iscasting = false PauseUnit(bossobj.unit, false) end)
            end
        },
        ultimate = {
            [1] = function(bossobj) -- summons a mana storm which follows the player.
                local dur,vel = 60.0, math.random(1,3)
                local a     = utils.angleunits(bossobj.unit, bossobj.trackedunit)
                local x,y   = utils.projectxy(utils.unitx(bossobj.unit), utils.unity(bossobj.unit), 300.0, a)
                local e     = speff_manastorm:play(x, y, dur)
                BlzSetSpecialEffectColor(e, 0, 0, 0)
                utils.timed(1.87, function()
                    BlzSetSpecialEffectColor(e, 255, 255, 255)
                    utils.timedrepeat(0.03, dur/0.03, function(c)
                        if utils.isalive(bossobj.unit) then
                            a = utils.anglexy(x, y, utils.unitxy(bossobj.trackedunit))
                            x,y = utils.projectxy(x, y, vel, a)
                            utils.seteffectxy(e, x, y, BlzGetLocalSpecialEffectZ(e))
                            if math.fmod(c, 21) == 0 then
                                speff_iceblast:play(x, y)
                                bossobj:deal_area_dmg(64, x, y, 200.0, nil)
                            end
                        else
                            DestroyEffect(e)
                            ReleaseTimer()
                        end
                    end)
                end)
            end
        }
    }
    self.bosst['N01R']  = {name = "Amalgam of Greed", subtitle = "Taking one coin won't hurt... right?", code = 'N01R', biomeid = biome_id_vault, dmgtypeid = dmg_phys}
    self.bosst['N01R'].badge_id       = 11
    self.bosst['N01R'].badge_id_tyran = 17
    self.bosst['N01R'].casteffect   = speff_edict
    self.bosst['N01R'].casteffectsc = 1.33
    self.bosst['N01R'].evadetime    = 1.42
    self.bosst['N01R'].casttime     = 1.14
    self.bosst['N01R'].channeltime  = 4.50
    self.bosst['N01R'].randomspells = false
    self.bosst['N01R'].playercolor  = Player(4) -- yellow        
    self.bosst['N01R'].spellcadence = { basic = 3.27, power = 7.3, channel = 23.33, ultimate = 30.0 }
    self.bosst['N01R'].spellbook    = {
        basic = {
            [1] = function(bossobj) -- launches a line of shining flares at the player, which then return back toward the boss after meeting max range.
                local flaret = {}
                local a      = utils.angleunits(bossobj.unit, bossobj.trackedunit)
                local count, vel, startx, starty =  0, 120, utils.unitprojectxy(bossobj.unit, 150.0, a)
                boss:marker(startx, starty)
                utils.timedrepeat(0.84, 3, function(c)
                    count = #flaret+1
                    flaret[count]   = {}
                    flaret[count].x = startx
                    flaret[count].y = starty
                end)
                utils.timedrepeat(0.42, 24, function(c2)
                    if flaret[1] then
                        for idex = 1,#flaret do
                            flaret[idex].x, flaret[idex].y = utils.projectxy(flaret[idex].x, flaret[idex].y, vel, a)
                            if math.random(0,1) == 1 then
                                speff_flare:play(flaret[idex].x, flaret[idex].y)
                            else
                                speff_edict:play(flaret[idex].x, flaret[idex].y)
                            end
                            bossobj:deal_area_dmg(16, flaret[idex].x, flaret[idex].y, 160.0)
                        end
                    end
                end, function()
                    a = a - 180.0 -- invert the traveled path.
                    utils.timedrepeat(0.42, 24, function(c3)
                        if flaret[1] then
                            for idex = 1,#flaret do
                                flaret[idex].x, flaret[idex].y = utils.projectxy(flaret[idex].x, flaret[idex].y, vel, a)
                                if math.random(0,1) == 1 then
                                    speff_flare:play(flaret[idex].x, flaret[idex].y)
                                else
                                    speff_edict:play(flaret[idex].x, flaret[idex].y)
                                end
                                bossobj:deal_area_dmg(32, flaret[idex].x, flaret[idex].y, 160.0)
                            end
                        end
                    end, function()
                        utils.deep_destroy(flaret)
                    end)
                end)
            end,
            [2] = function(bossobj) -- launches shadow bolts which spawn dark kobolds upon impact.
                local x,y = 0,0
                utils.timedrepeat(0.33, math.random(3,5), function(c)
                    x,y         = utils.projectxy(utils.unitx(bossobj.trackedunit), utils.unity(bossobj.trackedunit), math.random(35,135), math.random(0,360))
                    local mis   = missile:create_arc(x, y, bossobj.unit, mis_voidball.effect, boss:get_dmg(6))
                    mis.time    = 2.0
                    mis.radius  = 70
                    mis.height  = 175
                    mis:updatescale(1.4)
                    mis:initduration()
                    mis.explfunc= function()
                        if utils.isalive(bossobj.unit) then
                            orb_prolif_stack[5]:play(mis.x, mis.y)
                            cr_dkoboldmel:create(mis.x, mis.y)
                        end
                    end
                    mis.dmgtype = dmg.type.stack[dmg_shadow]
                end)
            end,
        },
        power = {
            [1] = function(bossobj) -- marks the ground and begins launching a rapid volley of yellow lightning, tracking the player for the duration.
                local vel,dur       = 11.5, 12.0
                local x1,y1         = utils.unitxy(bossobj.trackedunit)
                local a,x2,y2       = 0, utils.unitxy(bossobj.trackedunit)
                local e             = speff_bossmark:play(x2, y2, dur)
                utils.timed(1.5, function()
                    utils.timedrepeat(0.10, dur/0.10, function(c)
                        if utils.isalive(bossobj.unit) then
                            -- move center point and marker effect:
                            a = utils.anglexy(x1, y1, utils.unitxy(bossobj.trackedunit))
                            x1,y1 = utils.projectxy(x1, y1, vel, a)
                            utils.seteffectxy(e, x1, y1)
                            -- create missile:
                            x2,y2       = utils.projectxy(x1, y1, math.random(33,120), c*(math.random(12,18)))
                            local mis   = missile:create_arc(x2, y2, bossobj.unit, speff_psiyel.effect, boss:get_dmg(18))
                            boss:marker(x2, y2)
                            mis.time    = 1.84
                            mis.radius  = 80
                            mis.height  = 425
                            mis.dmgtype = dmg.type.stack[dmg_fire]
                            mis:initduration()
                            if math.fmod(c, 14) == 0 then -- run animation, set facing.
                                mis_boltyell:play(utils.unitx(bossobj.unit), utils.unity(bossobj.unit), nil, 1.5)
                            end
                            -- move missile center toward player slowly:
                        else
                            DestroyEffect(e)
                            ReleaseTimer()
                        end
                    end)
                end)
            end
        },
        channel = {
            [1] = function(bossobj) -- becomes immune and summons 3 different manifestations - yellow, black, red (excess, ego, envy), each launching different damage type missiles.
                -- init boss animation and pause:
                if utils.distxy(0, 0, utils.unitxy(bossobj.unit)) > 1725 then -- move closer to center if near edge of arena.
                    utils.setxy(bossobj.unit, utils.unitprojectxy(bossobj.unit, 768, utils.anglexy(utils.unitx(bossobj.unit), utils.unity(bossobj.unit), 0, 0)))
                    port_yellowtp:play(utils.unitx(bossobj.unit), utils.unity(bossobj.unit), nil, 1.65)
                end
                bossobj.iscasting = true
                PauseUnit(bossobj.unit, true)
                utils.setinvul(bossobj.unit, true)
                SetUnitAnimationByIndex(bossobj.unit, 14)
                SetUnitVertexColor(bossobj.unit, 175, 175, 175, 175)
                bondeff = speff_bondgold:attachu(bossobj.unit, nil, 'chest', 1.5)
                bossobj.slainmanifs = 0
                -- missile launch function from each manifestation:
                if manifestation_init then manifestation_init = nil end -- destroy previous handles.
                manifestation_init = function(bossobj, u, miseffect, landeffect)
                    local u = u
                    local waves = 2
                    if map.manager.diffid == 5 then waves = waves + 1 end
                    utils.timedrepeat(3.81, nil, function()
                        if u and utils.isalive(u) and utils.isalive(bossobj.unit) then
                            landeffect:playu(u)
                            local x2,y2,starta = 0,0,math.random(0,360)
                            for b = 1,waves do
                                for i = 1,7 do
                                    x2,y2     = utils.unitprojectxy(u, b*305, starta + i*51.5)
                                    local mis = missile:create_arc(x2, y2, u, miseffect.effect, boss:get_dmg(24), function(m) landeffect:play(m.x, m.y) end)
                                    mis.time  = 2.33
                                    mis.explr = 115.0
                                    mis:initduration()
                                    mis.dmgtype = dmg.type.stack[dmg_nature]
                                end
                            end
                        else
                            if utils.isalive(bossobj.unit) then
                                bossobj.slainmanifs = bossobj.slainmanifs + 1
                                if bossobj.slainmanifs >= 3 then -- are all 3 manifestations dead?
                                    -- if so, queue effect, delay reactivation:
                                    bossobj.slainmanifs = nil
                                    speff_heavgate:play(utils.unitx(bossobj.unit), utils.unity(bossobj.unit), 7.0)
                                    utils.setinvul(bossobj.unit, false)
                                    SetUnitVertexColor(bossobj.unit, 255, 0, 0, 255)
                                    SetUnitAnimationByIndex(bossobj.unit, 18)
                                    ArcingTextTag(color:wrap(color.tooltip.bad, "Exhausted!"), bossobj.unit, 3.0)
                                    utils.timed(10.0, function()
                                        speff_resurrect:play(utils.unitx(bossobj.unit), utils.unity(bossobj.unit), nil, 2.0)
                                        ResetUnitAnimation(bossobj.unit)
                                        bossobj.iscasting = false
                                        PauseUnit(bossobj.unit, false)
                                        SetUnitVertexColor(bossobj.unit, 255, 255, 255, 255)
                                        if bondeff then DestroyEffect(bondeff) end
                                    end)
                                end
                            else
                                if bondeff then DestroyEffect(bondeff) end
                            end
                            ReleaseTimer()
                        end
                    end)
                end
                -- launch dark kobolds from the boss position while manifestations are active:
                utils.timedrepeat(1.0, nil, function(c)
                    if bossobj.slainmanifs and bossobj.slainmanifs < 3 and utils.isalive(bossobj.unit) then
                        local x2,y2 = utils.unitprojectxy(bossobj.unit, math.random(100,400), math.random(0,360))
                        local mis   = missile:create_arc(x2, y2, bossobj.unit, mis_voidball.effect, boss:get_dmg(6))
                        mis.time    = 2.21
                        mis.radius  = 70
                        mis.height  = 175
                        mis.arch    = 700
                        mis:updatescale(1.3)
                        mis:initduration()
                        mis.explfunc= function()
                            if utils.isalive(bossobj.unit) then
                                orb_prolif_stack[5]:play(mis.x, mis.y)
                                cr_dkoboldmel:create(mis.x, mis.y)
                            end
                        end
                        mis.dmgtype = dmg.type.stack[dmg_shadow]
                    else
                        ReleaseTimer()
                    end
                end)
                utils.timedrepeat(0.78, 3, function(c)
                    local c = c
                    local manifmaxlife = 0.125 -- %% of boss HP
                    if map.manager.diffid == 5 then manifmaxlife = 0.1 end
                    local x,y = utils.unitprojectxy(bossobj.unit, 612, c*120)
                    speff_heavgate:play(x, y, 0.78)
                    speff_judge:play(x, y)
                    utils.timed(0.78, function()
                        if c == 0 then
                            -- excess
                            bj_lastCreatedUnit = utils.unitatxy(Player(24), x, y, 'N01W', utils.anglexy(utils.unitx(bossobj.unit), utils.unity(bossobj.unit), x, y))
                            manifestation_init(bossobj, bj_lastCreatedUnit, mis_grenadegrn, speff_grnburst)
                            speff_stormnat:play(x, y)
                        elseif c == 1 then
                            -- envy
                            bj_lastCreatedUnit = utils.unitatxy(Player(24), x, y, 'N01X', utils.anglexy(utils.unitx(bossobj.unit), utils.unity(bossobj.unit), x, y))
                            manifestation_init(bossobj, bj_lastCreatedUnit, mis_grenadeblue, speff_iceburst2)
                            speff_stormfrost:play(x, y)
                        elseif c == 2 then
                            -- ego
                            bj_lastCreatedUnit = utils.unitatxy(Player(24), x, y, 'N01Y', utils.anglexy(utils.unitx(bossobj.unit), utils.unity(bossobj.unit), x, y))
                            manifestation_init(bossobj, bj_lastCreatedUnit, mis_grenadeoj, speff_redburst)
                            speff_stormfire:play(x, y)
                        end
                        utils.setnewunithp(bj_lastCreatedUnit, utils.maxlife(bossobj.unit)*manifmaxlife, true)
                        SetUnitAnimationByIndex(bj_lastCreatedUnit, 22)
                        PauseUnit(bj_lastCreatedUnit, true)
                    end)
                end)
            end
        },
        ultimate = {
            [1] = function(bossobj) -- creates a line of chests facing a direction with a gap. every few sec, they launch deadly gold coins that explode.
                local centerx, centery  = utils.unitprojectxy(bossobj.unit, 2200, math.random(0,360))
                local originx, originy  = centerx, centery
                local spacing           = 156
                local spacingt          = 0
                local a                 = utils.anglexy(centerx, centery, utils.unitxy(bossobj.trackedunit))
                local origina           = a -- cache default shooting direction of chests.
                -- place rows of chests:
                local row               = {}
                local num               = 1
                row[1], row[2] = {}, {}
                a = a - 90
                for i = 1,32 do
                    if i == 12 then
                        centerx, centery    = originx, originy -- reset to center, then reverse angle.
                        a                   = a + 180 -- swap to +90
                        num                 = 2 -- change to row 2.
                        spacingt            = -spacing -- reset starting projection distance, skip first by setting negative so no mid gap.
                    end
                    spacingt = spacingt + spacing
                    row[num][i] = {}
                    row[num][i].x, row[num][i].y = utils.projectxy(centerx, centery, spacingt, a)
                    row[num][i].e = speff_goldchest:create(row[num][i].x, row[num][i].y)
                    BlzSetSpecialEffectScale(row[num][i].e, 1.66)
                    BlzSetSpecialEffectYaw(row[num][i].e, origina*bj_DEGTORAD)
                    port_yellowtp:play(row[num][i].x, row[num][i].y)
                end
                -- missile timer:
                utils.timed(3.0, function()
                    utils.timedrepeat(2.54, 12, function()
                        if map.manager.activemap then
                            for rownum,rowt in pairs(row) do
                                for i,t in pairs(rowt) do
                                    if t.e then -- chest exists, shoot missile.
                                        mis_boltyell:play(t.x, t.y)
                                        local mis    = missile:create_angle(origina, 300.0, bossobj.unit, speff_coin.effect, boss:get_dmg(24))
                                        mis.x,mis.y  = t.x, t.y -- move away from unit origin point
                                        mis.time     = 16.0
                                        mis.vel      = math.random(3, 14)
                                        mis.radius   = 80.0
                                        mis.dmgtype  = dmg.type.stack[dmg_fire]
                                        mis.colfunc  = function(m) speff_edict:play(m.x, m.y) end
                                        mis.func     = function(m) if not map.manager.activemap then m:destroy() end end
                                        mis:updatescale(1.5)
                                        mis:initduration()
                                    end
                                end
                            end
                        end
                    end, function() -- cleanup after timer expires.
                        for rownum,rowt in pairs(row) do
                            for i,t in pairs(rowt) do
                                mis_boltyell:play(t.x, t.y)
                                if t.e then DestroyEffect(t.e) end
                            end
                        end
                        utils.deep_destroy(row)
                    end)
                end)
            end
        }
    }
end
