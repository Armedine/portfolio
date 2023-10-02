ancient_event_damagedeal    = 1
ancient_event_damagetake    = 2
ancient_event_ability       = 3
ancient_event_equip         = 4
ancient_event_potion        = 5
ancient_event_movement      = 6
loot.ancient.diffnames = {
    [1] = '|cffebce5a(Greenwhisker)|r',
    [2] = '|cffd1d8eb(Standard)|r',
    [3] = '|cff2fceeb(Heroic)|r',
    [4] = '|cffb250d8(Vicious)|r',
    [5] = '|cffed6d00(Tyrannical)|r',
}


function loot.ancient:newplayertable()
    -- ancient storage table for event lookups (add new event types here as needed):
    local o = {}
    o[ancient_event_damagedeal] = {}
    o[ancient_event_damagetake] = {}
    o[ancient_event_ability] = {}
    o[ancient_event_equip] = {}
    o[ancient_event_potion] = {}
    o[ancient_event_movement] = {}
    return o
end


function loot.ancient:new(ancientid, biomeid, slotid, eventtype, fullname, description, func)
    -- wrapper object for actual item to control special interactions.
    local o     = setmetatable({}, o)
    o.fullname  = fullname
    o.descript  = description
    o.biomeid   = biomeid
    o.eventtype = eventtype
    o.slotid    = slotid
    o.func      = func
    o.ancientid = ancientid
    if biomeid then
        self.biomes[biomeid][#self.biomes[biomeid] + 1] = ancientid -- store for biome-specific drops.
    else
        for bid = 1,5 do self.biomes[bid][#self.biomes[bid] + 1] = ancientid end -- store as a globally available ancient.
    end
    self.allancients[#self.allancients + 1] = ancientid -- store for global drops.
    return o
end


function loot.ancient:raiseevent(eventtype, pobj, _flag, _eventobj, _ancientid)
    -- print("raising ancient event", eventtype, _flag, _eventobj)
    -- raise the event being triggered, then search the player's ancient table for eligible effects to run based on ancient ids equipped.
    utils.debugfunc(function()
        if #pobj.ancients[eventtype] > 0 then
            for _,ancientid in ipairs(pobj.ancients[eventtype]) do
                if not pobj.ancientscd[ancientid]then
                    if eventtype ~= ancient_event_equip or (_ancientid and eventtype == ancient_event_equip and ancientid == _ancientid) then
                        loot.ancienttable[ancientid].func(ancientid, pobj, _flag, _eventobj)
                    end
                end
            end
        end
    end, "ancient raiseevent")
end


function loot.ancient:registercooldown(ancientid, dur, pobj)
    if not pobj.ancientscd[ancientid] then
        pobj.ancientscd[ancientid] = true
        utils.timed(dur, function() pobj.ancientscd[ancientid] = nil end)
    end
end


function loot:builtancienttable()
    loot.ancienttable = {}

    loot.ancient.biomes = {}
    loot.ancient.biomes[biome_id_slag] = {}
    loot.ancient.biomes[biome_id_mire] = {}
    loot.ancient.biomes[biome_id_foss] = {}
    loot.ancient.biomes[biome_id_ice]  = {}
    loot.ancient.biomes[biome_id_vault]= {}

    -- used to map ore/damagetype ids to the appropriate biome when rolling ancient affixes.
    loot.biomedmgtypemap = {}
    loot.biomedmgtypemap[biome_id_slag]     = {}
    loot.biomedmgtypemap[biome_id_mire]     = {}
    loot.biomedmgtypemap[biome_id_foss]     = {}
    loot.biomedmgtypemap[biome_id_ice]      = {}
    loot.biomedmgtypemap[biome_id_vault]    = {}
    loot.biomedmgtypemap[biome_id_slag][1]  = dmg_fire
    loot.biomedmgtypemap[biome_id_slag][2]  = dmg_shadow
    loot.biomedmgtypemap[biome_id_mire][1]  = dmg_nature
    loot.biomedmgtypemap[biome_id_mire][2]  = dmg_shadow
    loot.biomedmgtypemap[biome_id_foss][1]  = dmg_phys
    loot.biomedmgtypemap[biome_id_foss][2]  = dmg_nature
    loot.biomedmgtypemap[biome_id_ice][1]   = dmg_frost
    loot.biomedmgtypemap[biome_id_ice][2]   = dmg_arcane
    loot.biomedmgtypemap[biome_id_vault][1]   = dmg_phys
    loot.biomedmgtypemap[biome_id_vault][2]   = dmg_shadow

    local a_id = 1

    -- ancients will not have secondary stats, and can only roll two other affixes (but they are 1.5x (?) as strong)
    -- instantiated for each player, allowing reads for equipped effects on ability use, loot equip, and damage event.
    -- event types: 'ability', 'equip', 'damagetake', 'damagedeal', 'potion', 'other'
    -- even better idea: have an array for players where we insert/remove ancient ids upon equip and then loop those ids in each event (limited processing done)
    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_slag, slot_boots, ancient_event_ability,
        'Doomwalkers', 'Using an ability ignites your feet for 6 sec, maxing your movespeed and damaging nearby targets for 6%% of your max health as Fire damage '
            ..'per sec. (10 sec cooldown)')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        local damage = utils.maxlife(pobj.unit)*0.06/3
        bf_msmax:apply(pobj.unit, 6.0)
        speff_liqfire:attachu(pobj.unit, 6.0)
        utils.timedrepeat(0.33, 6*3, function()
            spell:gdmgxy(pobj.p, dmg.type.stack[dmg_fire], damage, utils.unitx(pobj.unit), utils.unity(pobj.unit), 133.0)
        end)
        loot.ancient:registercooldown(ancientid, 10.0, pobj)
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_01.blp'
    a_id = a_id + 1
    ----------------------------------

    
    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_slag, slot_candle, ancient_event_damagetake,
        "Slag King's Torch", "If you take damage while under 50%% health, restore 10 Candle Light, 10%% health, and 10%% mana. (10 sec cooldown)")
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if event.target == pobj.unit and utils.getlifep(pobj.unit) < 50 then
            loot.ancient:registercooldown(ancientid, 10.0, pobj)
            speff_conflagoj:play(utils.unitxy(pobj.unit))
            speff_pothp:play(utils.unitx(pobj.unit), utils.unity(pobj.unit), nil, 0.6)
            if map.manager.activemap and candle.current > 0 then candle.current = candle.current + 10 end
            utils.addlifep(pobj.unit, 10, true, pobj.unit)
            utils.addmanap(pobj.unit, 10, true)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_02.blp'
    a_id = a_id + 1
    ----------------------------------

    
    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_slag, slot_outfit, ancient_event_ability,
        'Cuirass of the Flame', 'Using an ability increases your Fire damage by 10%% for 8 sec, but reduces all other damage by 5%% for the duration.')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if pobj.ancientsdata.cuirasseff then DestroyEffect(pobj.ancientsdata.cuirasseff) end
        pobj.ancientsdata.cuirasseff = sp_armor_boost[4]:attachu(pobj.unit, 8.0, 'overhead')
        for i = p_stat_fire, p_stat_phys do
            if i == p_stat_fire then spell:enhancepstat(p_stat_fire, 10.0, 8.0, pobj.p) else spell:enhancepstat(i, -5.0, 8.0, pobj.p) end
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_03.blp'
    a_id = a_id + 1
    ----------------------------------

    
    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_slag, slot_helmet, ancient_event_equip,
        'Phoenix Crown', 'Summons a Phoenix companion which launches fiery bolts at up to 3 targets at a time for 24 Fire damage.')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if flag then
            if not pobj.ancientsdata.phxunit then
                pobj.ancientsdata.phxunit   = utils.unitatxy(pobj.p, utils.unitx(pobj.unit), utils.unity(pobj.unit), 'n01L', math.random(0,360))
                pobj.ancientsdata.phxunitai = ai:new(pobj.ancientsdata.phxunit)
                pobj.ancientsdata.phxunitai:initcompanion(900.0, 24.0, p_stat_fire)
            end
        elseif not flag then
            if pobj.ancientsdata.phxunit then RemoveUnit(pobj.ancientsdata.phxunit) pobj.ancientsdata.phxunit = nil end
            if pobj.ancientsdata.phxunitai then pobj.ancientsdata.phxunitai:releasecompanion() end
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_04.blp'
    a_id = a_id + 1
    ----------------------------------


    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_slag, slot_outfit, ancient_event_damagetake,
        'Battlescarred Vestments', 'Taking damage restores 3%% of your mana and 1%% of your health. (1 sec cooldown)')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        utils.addmanap(pobj.unit, 3, true)
        utils.addlifep(pobj.unit, 1, true)
        loot.ancient:registercooldown(ancientid, 1, pobj)
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_05.blp'
    a_id = a_id + 1
    ----------------------------------


    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_slag, slot_gloves, ancient_event_damagedeal,
        'Broiling Mittens', 'Dealing damage has a 20%% chance to lob molten slag in a 6m radius for 54 Fire damage. (3 sec cooldown)')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if event.amount > 10 and math.random(0,10) <= 1 then
            local x,y = utils.unitxy(pobj.unit)
            missile:create_in_radius(x, y, pobj.unit, mis_fireballbig.effect, 54, dmg.type.stack[dmg_fire], 8, 600, 1.25, 96.0, 128.0, true, nil, true)
            loot.ancient:registercooldown(ancientid, 3.0, pobj)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_06.blp'
    a_id = a_id + 1
    ----------------------------------

    
    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_mire, slot_outfit, ancient_event_ability,
        'Mutant Husk', 'Using an ability causes you to spit up 3 murlocs which deal 10 Nature damage per sec for 15 sec. (6 sec cooldown)')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        for i = 1,3 do
            local x,y = utils.projectxy(utils.unitx(pobj.unit), utils.unity(pobj.unit), math.random(200,360), math.random(0,360))
            local mis = missile:create_arc(x, y, pobj.unit, speff_embernat.effect, 0)
            mis.explfunc = function(mis)
                ai:new(utils.unitatxy(pobj.p, mis.x, mis.y, 'n01M', math.random(0,360)))
                    :initcompanion(900.0, 11.0, p_stat_nature)
                    :timed(15.0)
                speff_water:play(mis.x, mis.y)
            end
        end
        loot.ancient:registercooldown(ancientid, 6.0, pobj)
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_07.blp'
    a_id = a_id + 1
    ----------------------------------

    
    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_mire, slot_boots, ancient_event_movement,
        'Bog Waders', 'While moving, gain 30%% Nature resistance. While standing still, deal 30%% more Nature damage.')
    loot.ancienttable[a_id].unequip = function(pobj)
        if pobj.ancientsdata.bogwaderbonus1 then
            pobj.ancientsdata.bogwaderbonus1 = false
            pobj:modstat(p_stat_nature_res, false, 30)
        end
        if pobj.ancientsdata.bogwaderbonus2 then
            pobj.ancientsdata.bogwaderbonus2 = false
            pobj:modstat(p_stat_nature, false, 30)
        end
    end
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if flag then
            if not pobj.ancientsdata.bogwaderbonus1 then
                pobj.ancientsdata.bogwaderbonus1 = true
                pobj:modstat(p_stat_nature_res, true, 30)
            end
            if pobj.ancientsdata.bogwaderbonus2 then
                pobj.ancientsdata.bogwaderbonus2 = false
                pobj:modstat(p_stat_nature, false, 30)
            end
        else
            if pobj.ancientsdata.bogwaderbonus1 then
                pobj.ancientsdata.bogwaderbonus1 = false
                pobj:modstat(p_stat_nature_res, false, 30)
            end
            if not pobj.ancientsdata.bogwaderbonus2 then
                pobj.ancientsdata.bogwaderbonus2 = true
                pobj:modstat(p_stat_nature, true, 30)
            end
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_08.blp'
    a_id = a_id + 1
    ----------------------------------

    
    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_mire, slot_tool, ancient_event_damagedeal,
        'Quagmirator', 'Dealing damage has a 15%% chance to unleash swamp bat missiles towards targets within 6m for 42 Nature damage. (3 sec cooldown)')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if event.amount > 10 and math.random(0,100) < 15 then
            local grp = g:newbyxy(pobj.p, g_type_dmg, utils.unitx(pobj.unit), utils.unity(pobj.unit), 600)
            grp:action(function()
                local x,y = utils.unitxy(grp.unit)
                local mis = missile:create_arc(x, y, pobj.unit, mis_bat.effect, 42)
                mis.dmgtype = dmg.type.stack[dmg_nature]
                mis.time    = 1.03
                mis:initduration()
            end)
            grp:destroy()
            loot.ancient:registercooldown(ancientid, 3.0, pobj)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_09.blp'
    a_id = a_id + 1
    ----------------------------------


    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_mire, slot_helmet, ancient_event_damagetake,
        'Forgotten Plate Helm', 'Taking damage has a 15%% chance to cause you to gain 10 Armor for 10 sec. (1.5 sec cooldown)')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if event.amount > 10 and math.random(1,100) < 15 then
            if pobj.ancientsdata.platebeff then DestroyEffect(pobj.ancientsdata.platebeff) end
            pobj.ancientsdata.platebeff = sp_armor_boost[6]:attachu(pobj.unit, 10.0, 'overhead')
            spell:enhancepstat(p_stat_armor, 10, 10, pobj.p)
            loot.ancient:registercooldown(ancientid, 1.5, pobj)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_10.blp'
    a_id = a_id + 1
    ----------------------------------


    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_mire, slot_potion, ancient_event_potion,
        'Swampbrewer Potion', 'On Mana Potion use, summon a Shroom at your feet every sec for 3 sec.')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if not flag then -- mpot only.
            utils.timedrepeat(0.99, 3, function()
                local x1,y1 = utils.unitxy(pobj.unit)
                speff_shroom:play(x1, y1, 6, 0.3)
                speff_explgrn:play(x1, y1, nil, 0.75)
                utils.timedrepeat(1.0, 6, function()
                    utils.debugfunc(function()
                        spell:ghealxy(pobj.p, 16, x1, y1, 300.0)
                        spell:gdmgxy(pobj.p, dmg.type.stack[dmg_nature], 12, x1, y1, 300.0)
                    end, 'heal')
                end)
            end)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_11.blp'
    a_id = a_id + 1
    ----------------------------------


    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_mire, slot_backpack, ancient_event_damagetake,
        'Sssnake Ssskin', 'Taking damage has a 15%% chance to grant you a shield that absorbs damage equal to 10%% of your health for 6 sec. (8 sec cooldown)')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if event.amount > 10 and math.random(1,100) < 15 then
            local amt = math.floor(utils.maxlife(pobj.unit)*.10)
            dmg.absorb:new(pobj.unit, 6.0, {all = amt}, speff_ubergrn)
            buffy:add_indicator(pobj.p, "Sssnake Ssskin", "ReplaceableTextures\\CommandButtons\\BTNReinforcedHides.blp", 8.0,
                "Absorbs up to "..tostring(amt).." damage")
            loot.ancient:registercooldown(ancientid, 8.0, pobj)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_12.blp'
    a_id = a_id + 1
    ----------------------------------


    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_foss, slot_tool, ancient_event_damagedeal,
        'Mawchomper', 'Dealing damage has a 15%% chance to crush targets in a 3m radius, stunning them for 1.5 sec and dealing 36 Physical damage. (3 sec cooldown)')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if event.amount > 10 and math.random(0,100) < 15 then
            local x,y = utils.unitxy(pobj.unit)
            spell:gdmgxy(pobj.p, dmg.type.stack[dmg_phys], 36, x, y, 300, function(u) bf_stun:apply(u, 1.5) end)
            speff_dustcloud:playradius(200, 3, x, y)
            speff_quake:playradius(200, 3, x, y)
            loot.ancient:registercooldown(ancientid, 3.0, pobj)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_13.blp'
    a_id = a_id + 1
    ----------------------------------


    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_foss, slot_tool, ancient_event_damagedeal,
        'Spinethrower', 'Targets farther than 10m from you take 15%% more damage.')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if event.amount > 10 and utils.distunits(pobj.unit, event.target) > 1000.0 then
            event.amount = event.amount*1.15
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_14.blp'
    a_id = a_id + 1
    ----------------------------------


    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_foss, slot_leggings, ancient_event_movement,
        'Treasure Trousers', 'While moving, occasionally drop 3 enchanted gold coins which explode for 48 Physical damage in a 1.5m radius after 2 sec.')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if flag and math.random(0,100) < 4 then
            for i = 1,3 do
                local x,y = utils.projectxy(utils.unitx(pobj.unit), utils.unity(pobj.unit), math.random(100,200), i*120 + math.randomneg(-15,15))
                local mis = missile:create_arc(x, y, pobj.unit, speff_coin.effect, 0)
                mis.explfunc = function(mis)
                    speff_coin:play(mis.x, mis.y, 2.0, 0.88)
                    local x,y = mis.x, mis.y
                    utils.timed(2.0, function()
                        speff_edict:play(x, y, nil, 0.3)
                        spell:gdmgxy(pobj.p, dmg.type.stack[dmg_phys], 48, x, y, 150.0)
                    end)
                end
            end
            loot.ancient:registercooldown(ancientid, 2.0, pobj)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_15.blp'
    a_id = a_id + 1
    ----------------------------------


    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_foss, slot_gloves, ancient_event_equip,
        "Archaeologist's Wraps", 'Increases your mining speed by 25%%.')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if flag then
            if not pobj.ancientsdata.archwrapsbonus then
                pobj.ancientsdata.archwrapsbonus = true
                pobj:modstat(p_stat_minespd, true, 25)
            end
        else
            if pobj.ancientsdata.archwrapsbonus then
                pobj.ancientsdata.archwrapsbonus = false
                pobj:modstat(p_stat_minespd, false, 25)
            end
        end
        pobj:updateattackspeed()
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_16.blp'
    a_id = a_id + 1
    ----------------------------------


    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_foss, slot_backpack, ancient_event_ability,
        'Fossilized Turboshell', 'Using an ability causes you to launch 3 spinning turtles which trample targets for 24 Physical damage. (3 sec cooldown)')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        for i = 1,3 do
            local x,y   = utils.projectxy(utils.unitx(pobj.unit), utils.unity(pobj.unit), 600.0, i*120 + math.randomneg(-15,15))
            local mis   = missile:create_piercexy(x, y, pobj.unit, 'Units\\Creeps\\DragonSeaTurtle\\DragonSeaTurtle', 0)
            mis.dmgtype = dmg.type.stack[dmg_phys]
            mis.cangle  = math.random(0,360)
            mis.vel     = 17
            mis.time    = 6.0
            mis:updatescale(0.27)
            mis:initduration()
            mis.func = function(mis)
                mis.cangle = mis.cangle + 12
                mis.angle = mis.angle + 2
                if math.fmod(mis.elapsed, 7) == 0 then -- every 0.21 sec
                    spell:gdmgxy(pobj.p, dmg.type.stack[dmg_phys], 24, mis.x, mis.y, 124.0)
                    speff_phys:play(mis.x, mis.y)
                end
            end
        end
        loot.ancient:registercooldown(ancientid, 3.0, pobj)
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_17.blp'
    a_id = a_id + 1
    ----------------------------------


    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_foss, slot_gloves, ancient_event_ability,
        'Skeleton Grasps', 'Using an ability has a 15%% chance to summon a skeletal warrior to fight for you for 12 sec, striking nearby targets for 24 Physical damage.')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if math.random(0,100) < 15 then
            local x,y = utils.projectxy(utils.unitx(pobj.unit), utils.unity(pobj.unit), 100, math.random(0,360))
            speff_animate:play(x, y)
            ai:new(utils.unitatxy(pobj.p, x, y, 'n01N', math.random(0,360)))
                :initcompanion(700.0, 25.0, p_stat_phys)
                :timed(12.0)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_18.blp'
    a_id = a_id + 1
    ----------------------------------


    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_ice, slot_tool, ancient_event_damagedeal,
        'Reaping Picksickle', 'Frost, Shadow, and Arcane damage combusts, dealing 100%% bonus Frost damage and Freezing the target for 1.5 sec (3 sec cooldown).')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if event.amount > 16.0
            and (dtypelookup[event.dmgtype] == dmg_frost or atypelookup[event.atktype] == dmg_frost or
                dtypelookup[event.dmgtype] == dmg_shadow or atypelookup[event.atktype] == dmg_shadow or
                dtypelookup[event.dmgtype] == dmg_arcane or atypelookup[event.atktype] == dmg_arcane) then
            loot.ancient:registercooldown(ancientid, 3.0, pobj)
            speff_frostnova:play(utils.unitx(event.target), utils.unity(event.target), nil, 0.75)
            bf_freeze:apply(event.target, 1.5)
            dmg.type[dmg_frost]:pdeal(pobj.p, event.amount, event.target)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_19.blp'
    a_id = a_id + 1
    ----------------------------------


    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_ice, slot_leggings, ancient_event_ability,
        'Frostfire Pantaloons', 'Using an ability increases your Frost or Fire damage by 5%% for 10 sec, cycling back and forth.')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if pobj.ancientsdata.frostfirepants then
            spell:enhancepstat(p_stat_frost, 5.0, 10.0, pobj.p)
            pobj.ancientsdata.frostfirepants = false
        else
            spell:enhancepstat(p_stat_fire, 5.0, 10.0, pobj.p)
            pobj.ancientsdata.frostfirepants = true
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_20.blp'
    a_id = a_id + 1
    ----------------------------------


    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_ice, slot_candle, ancient_event_movement,
        'Congealed Candlelight', 'While moving, deal 35%% more Fire damage.')
    loot.ancienttable[a_id].unequip = function(pobj)
        if pobj.ancientsdata.congealedbonus then
            pobj.ancientsdata.congealedbonus = false
            pobj:modstat(p_stat_fire, false, 35)
        end
    end
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if flag then
            if not pobj.ancientsdata.congealedbonus then
                pobj.ancientsdata.congealedbonus = true
                pobj:modstat(p_stat_fire, true, 35)
            end
        else
            if pobj.ancientsdata.congealedbonus then
                pobj.ancientsdata.congealedbonus = false
                pobj:modstat(p_stat_fire, false, 35)
            end
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_21.blp'
    a_id = a_id + 1
    ----------------------------------


    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_ice, slot_boots, ancient_event_ability,
        'Reversed Frost-Steppers', 'Using an ability leaves behind ice which explodes after 3 sec, Freezing targets in a 3m radius for 1.5 sec and dealing 48 Frost damage.'
            ..' (3 sec cooldown)')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        local x,y = utils.unitx(pobj.unit), utils.unity(pobj.unit)
        speff_frost:play(x, y)
        BlzSetSpecialEffectAlpha(speff_icestep:play(x, y, 3.0, 0.23), 200)
        utils.timed(3.0, function()
            speff_iceshard:playradius(300, 5, x, y, 1.0)
            spell:gdmgxy(pobj.p, dmg.type.stack[dmg_frost], 48, x, y, 300.0, function(u) bf_freeze:apply(u, 1.5) end)
        end)
        loot.ancient:registercooldown(ancientid, 3.0, pobj)
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_22.blp'
    a_id = a_id + 1
    ----------------------------------


    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_ice, slot_helmet, ancient_event_damagetake,
        'Bluewyrm Skullhelm', 'If you take damage while under 30%% health, reduce all damage taken by 25%% for 6 sec. (12 sec cooldown)')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if utils.getlifep(pobj.unit) < 50.0 then
            mis_blizzard:attachu(pobj.unit, 6.0, 'hand,left', 0.75)
            mis_blizzard:attachu(pobj.unit, 6.0, 'hand,right', 0.75)
            spell:enhanceresistpure(25, 6.0, pobj.p)
            loot.ancient:registercooldown(ancientid, 12.0, pobj)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_23.blp'
    a_id = a_id + 1
    ----------------------------------


    loot.ancienttable[a_id] = loot.ancient:new(a_id, biome_id_ice, slot_potion, ancient_event_potion,
        'Frozen Chalice', 'On Health Potion use, become encased in invulnerable ice for 2.5 sec.')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if flag then -- hpot only.
            utils.setinvul(pobj.unit, true)
            speff_iceblock:attachu(pobj.unit, 2.5, 'origin', 0.75)
            utils.timed(2.5, function() if not pobj.downed then utils.setinvul(pobj.unit, false) end end)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_24.blp'
    a_id = a_id + 1
    ----------------------------------


    ----------------------------------
    ------ generic ancient pool ------
    ----------------------------------

    loot.ancienttable[a_id] = loot.ancient:new(a_id, nil, slot_tool, ancient_event_damagedeal,
        'Gravel Lob-o-matic', 'When you swing your pickaxe, lob 6 boulders in front of you which each deal 24 Physical damage in a 3m radius.')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if event.source == pobj.unit and event.weptype ~= WEAPON_TYPE_WHOKNOWS and event.atktype == ATTACK_TYPE_HERO then
            local x,y = utils.unitprojectxy(pobj.unit, 150.0, utils.getface(pobj.unit))
            local x2,y2,a = 0, 0, math.random(0,360)
            for i = 1,6 do
                x2,y2 = utils.projectxy(x, y, math.random(0,150), a + (i-1)*60)
                local mis = missile:create_arc(x2, y2, pobj.unit, mis_rock.effect, 24)
                mis.dmgtype = dmg.type.stack[dmg_phys]
                mis.time = 1.0
                mis.height = 95.0
                mis:initduration()
            end
            loot.ancient:registercooldown(ancientid, 1.0, pobj)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_25.blp'
    a_id = a_id + 1
    ----------------------------------

    loot.ancienttable[a_id] = loot.ancient:new(a_id, nil, slot_potion, ancient_event_potion,
        'Omni-Potion', 'On Mana Potion use, increase all non-physical damage by 25%% for 6 sec. On Health Potion use, increase your Armor Rating by 10%% for 6 sec.')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if not flag then
            for dmgid = p_stat_arcane,p_stat_shadow do spell:enhancepstat(dmgid, 25.0, 6.0, pobj.p) end
        elseif flag then
            spell:enhancepstat(p_stat_armor, math.ceil(10*(pobj[p_stat_armor]/100)), 6.0, pobj.p)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_26.blp'
    a_id = a_id + 1
    ----------------------------------

    loot.ancienttable[a_id] = loot.ancient:new(a_id, nil, slot_backpack, ancient_event_damagetake,
        "Fleeting Adventurer's Pack", 'If you take damage while below 50%% health, max your movespeed and gain 50%% bonus Dodge Rating for 6 sec. (8 sec cooldown)')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if utils.getlifep(pobj.unit) < 50.0 then
            sp_enchant_eff[2]:attachu(pobj.unit, 8.0, 'origin', 0.7)
            bf_msmax:apply(pobj.unit, 6.0)
            spell:enhancepstat(p_stat_dodge, math.floor(50*(pobj[p_stat_dodge]/100)), 8.0, pobj.p)
            loot.ancient:registercooldown(ancientid, 8.0, pobj)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_27.blp'
    a_id = a_id + 1
    ----------------------------------

    loot.ancienttable[a_id] = loot.ancient:new(a_id, nil, slot_backpack, ancient_event_equip,
        "Archaeologist's Travel Pack", 'Increases your mining speed by 25%%.')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if flag then
            if not pobj.ancientsdata.archpackbonus then
                pobj.ancientsdata.archpackbonus = true
                pobj:modstat(p_stat_minespd, true, 25)
            end
        else
            if pobj.ancientsdata.archpackbonus then
                pobj.ancientsdata.archpackbonus = false
                pobj:modstat(p_stat_minespd, false, 25)
            end
        end
        pobj:updateattackspeed()
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_28.blp'
    a_id = a_id + 1
    ----------------------------------

    loot.ancienttable[a_id] = loot.ancient:new(a_id, nil, slot_artifact, ancient_event_equip,
        'Deep Fathom Seashell', 'Summons 3 murloc warriors to melee nearby targets for 14 Nature damage.')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if flag then
            if not pobj.ancientsdata.murloct then
                pobj.ancientsdata.murloct = {}
                local x,y = 0,0
                for i = 1,3 do
                    x,y = utils.projectxy(utils.unitx(pobj.unit), utils.unity(pobj.unit), 150.0, (i-1)*120)
                    pobj.ancientsdata.murloct[i] = {}
                    pobj.ancientsdata.murloct[i].unit = utils.unitatxy(pobj.p, x, y, 'n01Q', math.random(0,360))
                    pobj.ancientsdata.murloct[i].ai = ai:new(pobj.ancientsdata.murloct[i].unit)
                    pobj.ancientsdata.murloct[i].ai:initcompanion(900.0, 15.0, p_stat_nature)
                end
            end
        elseif not flag then
            if pobj.ancientsdata.murloct then
                for i = 1,3 do
                    pobj.ancientsdata.murloct[i].ai:releasecompanion()
                    RemoveUnit(pobj.ancientsdata.murloct[i].unit)
                    pobj.ancientsdata.murloct[i] = nil
                end
                pobj.ancientsdata.murloct = nil
            end
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_29.blp'
    a_id = a_id + 1
    ----------------------------------

    loot.ancienttable[a_id] = loot.ancient:new(a_id, nil, slot_artifact, ancient_event_potion,
        'Bauble of Endless Absorption', 'On Mana Potion use, gain 20 Absorb on Spell and increase your Absorb Power by 25%% for 6 sec.')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if not flag then -- mpot
            spell:enhancepstat(p_stat_shielding, 20, 6.0, pobj.p)
            spell:enhancepstat(p_stat_absorb, math.floor(25*(pobj[p_stat_absorb]/100)), 6.0, pobj.p)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_30.blp'
    a_id = a_id + 1
    ----------------------------------

    loot.ancienttable[a_id] = loot.ancient:new(a_id, nil, slot_candle, ancient_event_damagedeal,
        'Mana-Hungry Spelltorch', 'Arcane damage is increased by 50%% while you are above 50%% mana, but is reduced by 25%% while below 50%% mana.')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if atypelookup[event.atktype] == dmg_arcane then
            if utils.getmanap(pobj.unit) >= 50 then
                event.amount = event.amount*1.50
            else
                event.amount = event.amount*0.75
            end
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_31.blp'
    a_id = a_id + 1
    ----------------------------------

    loot.ancienttable[a_id] = loot.ancient:new(a_id, nil, slot_tool, ancient_event_damagedeal,
        'Shadowy Ore Spiker', 'Targets within 3m of you take 25%% more damage and heal you for 25%% of the total damage done.')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if utils.distunits(event.target, pobj.unit) <= 300.0 then
            event.amount = event.amount*1.25
            utils.addlifeval(pobj.unit, event.amount*0.25, true, pobj.unit)
            speff_embersha:playu(event.target)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_32.blp'
    a_id = a_id + 1
    ----------------------------------

    loot.ancienttable[a_id] = loot.ancient:new(a_id, nil, slot_gloves, ancient_event_damagedeal,
        'Gauntlets of Impending Doom', 'You deal 5%% increased damage for every 10 Candle Wax burned during a dig.')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if map.manager.activemap then
            event.amount = event.amount*(1+math.floor((candle.total - candle.current)/10)*0.05)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_33.blp'
    a_id = a_id + 1
    ----------------------------------

    loot.ancienttable[a_id] = loot.ancient:new(a_id, nil, slot_outfit, ancient_event_ability,
        'Darkness Hauberk', 'Using an ability gives you 5%% added Shadow damage for 6 sec. If used under 50%% health, also gain 10%% Elemental Lifesteal. (6 sec cooldown)')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if pobj.ancientsdata.darkhauberkeff then DestroyEffect(pobj.ancientsdata.darkhauberkeff) end
        pobj.ancientsdata.darkhauberkeff = sp_armor_boost[5]:attachu(pobj.unit, 6.0, 'overhead')
        spell:enhancedmgtype(dmg_shadow, 5.0, 6.0, pobj.p)
        if not pobj.ancientsdata.darkhauberkcd and utils.getlifep(pobj.unit) < 50 then
            pobj.ancientsdata.darkhauberkcd = true
            utils.timed(6.0, function() pobj.ancientsdata.darkhauberkcd = false end)
            spell:enhancepstat(p_stat_elels, 10.0, 6.0, pobj.p)
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_34.blp'
    a_id = a_id + 1
    ----------------------------------

    loot.ancienttable[a_id] = loot.ancient:new(a_id, nil, slot_helmet, ancient_event_damagedeal,
        'Looted Scourgehelm', 'Dealing damage has a 20%% chance to restore 3%% of your health. While under 35%% health, restore 6%% instead. (1.5 sec cooldown)')
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if event.amount > 10 then
            if math.random(1,10) <= 2 then
                if utils.getlifep(pobj.unit) >= 35.0 then
                    utils.addlifep(pobj.unit, 3.0, true, pobj.unit)
                else
                    utils.addlifep(pobj.unit, 6.0, true, pobj.unit)
                end
                loot.ancient:registercooldown(ancientid, 1.5, pobj)
            end
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_35.blp'
    a_id = a_id + 1
    ----------------------------------

    loot.ancienttable[a_id] = loot.ancient:new(a_id, nil, slot_boots, ancient_event_movement,
        'Fusion Slipshoes', 'While moving, occasionally become invisible for 2.5 sec and absorb up to 84 damage for the duration. While standing still, deal 20%% more Arcane damage.')
    loot.ancienttable[a_id].unequip = function(pobj)
        if pobj.ancientsdata.fusionb then
            pobj.ancientsdata.fusionb = false
            pobj:modstat(p_stat_arcane, false, 20)
        end
    end
    loot.ancienttable[a_id].func = function(ancientid, pobj, flag, event)
        if flag then
            if pobj.ancientsdata.fusionb then
                pobj.ancientsdata.fusionb = false
                pobj:modstat(p_stat_arcane, false, 20)
            end
            if math.random(1,100) < 3 and not pobj.ancientsdata.fusioncd then
                pobj.ancientsdata.fusioncd = true
                bf_invis:apply(pobj.unit, 2.5)
                dmg.absorb:new(pobj.unit, 2.5, { all = 84 }, speff_uberblu)
                utils.timed(2.5, function() pobj.ancientsdata.fusioncd = nil end)
            end
        else
            if not pobj.ancientsdata.fusionb then
                pobj.ancientsdata.fusionb = true
                pobj:modstat(p_stat_arcane, true, 20)
            end
        end
    end
    loot.ancienttable[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_36.blp'
    a_id = a_id + 1
    ----------------------------------

    ----------------------------------
    -------- itemtype builder --------
    ----------------------------------

    loot.ancienttypes = {}

    -- construct itemtypes with icon, ancientid (for use in save/load system):
    for ancientid,t in ipairs(loot.ancienttable) do
        loot.ancienttypes[ancientid] = loot.itemtype:new(t.fullname, loot:slot(t.slotid), 1, t.icon)
        loot.ancienttypes[ancientid].ancientid = ancientid
    end

end


function loot:builtancienttable_v1_5()
    -- MUST start at the last ancient_id + 1 for save/load system!
    -- MUST insert this function at the END of lootdata build functions!
    local a_id = 37
    loot.ancienttable_v_1_5 = {}
    -- biome_id_slag    Fire/Shadow
    -- biome_id_mire    Nature/Shadow
    -- biome_id_foss    Physical/Nature
    -- biome_id_ice     Frost/Arcane
    -- biome_id_vault   Physical/Shadow

    loot.ancienttable_v_1_5[a_id] = loot.ancient:new(a_id, biome_id_slag, slot_artifact, ancient_event_ability,
        'Pearlescent Prism', 'Using an ability increases all non-physical damage dealt by 3%% for 8 seconds.')
    loot.ancienttable_v_1_5[a_id].func = function(ancientid, pobj, flag, event)
        for dmgid = p_stat_arcane,p_stat_shadow do spell:enhancepstat(dmgid, 3.0, 8.0, pobj.p) end
    end
    loot.ancienttable_v_1_5[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_2_01.blp'
    a_id = a_id + 1
    ----------------------------------
    ----------------------------------
    loot.ancienttable_v_1_5[a_id] = loot.ancient:new(a_id, biome_id_mire, slot_potion, ancient_event_potion,
        'Summoning Elixir', 'On Mana Potion use, increase Minion damage dealt by 50%% for 10 seconds.')
    loot.ancienttable_v_1_5[a_id].func = function(ancientid, pobj, flag, event)
        if not flag then -- mpot
            spell:enhancepstat(p_stat_miniondmg, 50.0, 10.0, pobj.p)
        end
    end
    loot.ancienttable_v_1_5[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_2_02.blp'
    a_id = a_id + 1
    ----------------------------------
    ----------------------------------
    loot.ancienttable_v_1_5[a_id] = loot.ancient:new(a_id, biome_id_foss, slot_tool, ancient_event_ability,
        'Fossilized Wishbone', 'Using an ability increases your chance to critically strike by 3%% for 10 seconds.')
    loot.ancienttable_v_1_5[a_id].func = function(ancientid, pobj, flag, event)
        spell:enhancepstat(p_epic_hit_crit, 3.0, 10.0, pobj.p)
    end
    loot.ancienttable_v_1_5[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_2_03.blp'
    a_id = a_id + 1
    ----------------------------------
    ----------------------------------
    loot.ancienttable_v_1_5[a_id] = loot.ancient:new(a_id, biome_id_ice, slot_leggings, ancient_event_damagedeal,
        'Necromancer Strides', 'Dealing damage while above 75%% health gives you a 25%% chance to summon a demon to your side on ability use.')
    loot.ancienttable_v_1_5[a_id].func = function(ancientid, pobj, flag, event)
        if utils.getlifep(pobj.unit) >= 75 then
            spell:enhancepstat(p_epic_demon, 25.0, 3.0, pobj.p)
            loot.ancient:registercooldown(ancientid, 3.0, pobj)
        end
    end
    loot.ancienttable_v_1_5[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_2_04.blp'
    a_id = a_id + 1
    ----------------------------------
    ----------------------------------
    loot.ancienttable_v_1_5[a_id] = loot.ancient:new(a_id, biome_id_vault, slot_candle, ancient_event_equip,
        "Archaeologist's Lantern", 'Increases your mining speed by 25%%.')
    loot.ancienttable_v_1_5[a_id].func = function(ancientid, pobj, flag, event)
        if flag then
            if not pobj.ancientsdata.archlantbonus then
                pobj.ancientsdata.archlantbonus = true
                pobj:modstat(p_stat_minespd, true, 25)
            end
        else
            if pobj.ancientsdata.archlantbonus then
                pobj.ancientsdata.archlantbonus = false
                pobj:modstat(p_stat_minespd, false, 25)
            end
        end
    end
    loot.ancienttable_v_1_5[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_2_05.blp'
    a_id = a_id + 1
    ----------------------------------
    ----------------------------------
    loot.ancienttable_v_1_5[a_id] = loot.ancient:new(a_id, biome_id_slag, slot_candle, ancient_event_equip,
        "Phoenix Flame", 'Summons a Phoenix companion which launches fiery bolts at up to 3 targets at a time for 24 Fire damage.')
    loot.ancienttable_v_1_5[a_id].func = function(ancientid, pobj, flag, event)
        if flag then
            if not pobj.ancientsdata.phxunitB then
                pobj.ancientsdata.phxunitB   = utils.unitatxy(pobj.p, utils.unitx(pobj.unit), utils.unity(pobj.unit), 'n01L', math.random(0,360))
                pobj.ancientsdata.phxunitBai = ai:new(pobj.ancientsdata.phxunitB)
                pobj.ancientsdata.phxunitBai:initcompanion(900.0, 24.0, p_stat_fire)
            end
        elseif not flag then
            if pobj.ancientsdata.phxunitB then RemoveUnit(pobj.ancientsdata.phxunitB) pobj.ancientsdata.phxunitB = nil end
            if pobj.ancientsdata.phxunitBai then pobj.ancientsdata.phxunitBai:releasecompanion() end
        end
    end
    loot.ancienttable_v_1_5[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_2_06.blp'
    a_id = a_id + 1
    ----------------------------------
    ----------------------------------
    loot.ancienttable_v_1_5[a_id] = loot.ancient:new(a_id, biome_id_mire, slot_gloves, ancient_event_damagedeal,
        "Mire Wranglers", 'Increases your Nature and Minion damage by 25%%.')
    loot.ancienttable_v_1_5[a_id].func = function(ancientid, pobj, flag, event)
        if dtypelookup[event.dmgtype] == dmg_nature or atypelookup[event.atktype] == dmg_nature then
            event.amount = event.amount*1.25
        end
        if event.pmin or event.pminrep or event.target ~= pobj.unit then
            event.amount = event.amount*1.25
        end
    end
    loot.ancienttable_v_1_5[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_2_07.blp'
    a_id = a_id + 1
    ----------------------------------
    ----------------------------------
    loot.ancienttable_v_1_5[a_id] = loot.ancient:new(a_id, biome_id_foss, slot_tool, ancient_event_equip,
        "Skulltooth Channeling Rod", '50%% of your highest non-physical damage bonus is granted to all other non-physical damage bonuses.')
    loot.ancienttable_v_1_5[a_id].func = function(ancientid, pobj, flag, event)
        if flag then
            pobj.ancientsdata.skulltoothbonusfunc = function()
                if pobj.ancientsdata.skulltoothbonus then
                    for dmgid = p_stat_arcane,p_stat_shadow do
                        if dmgid ~= pobj.ancientsdata.skulltoothbonusid then
                            pobj:modstat(dmgid, false, pobj.ancientsdata.skulltoothbonus)
                        end
                    end
                end
                local highestid, highestvalue = 0, 0
                for dmgid = p_stat_arcane,p_stat_shadow do
                    if pobj[dmgid] > highestvalue then
                        highestid = dmgid
                        highestvalue = pobj[dmgid]
                    end
                end
                pobj.ancientsdata.skulltoothbonus = math.floor(highestvalue*0.5)
                pobj.ancientsdata.skulltoothbonusid = highestid
                for dmgid = p_stat_arcane,p_stat_shadow do
                    if dmgid ~= highestid then
                        pobj:modstat(dmgid, true, pobj.ancientsdata.skulltoothbonus)
                    end
                end
            end
            pobj.ancientsdata.skulltoothbonustmr = TimerStart(NewTimer(), 0.1, true, function()
                if pobj.ancientsdata.skulltoothbonusfunc then pobj.ancientsdata.skulltoothbonusfunc() else ReleaseTimer() end
            end)
        else
            for dmgid = p_stat_arcane,p_stat_shadow do
                if dmgid ~= pobj.ancientsdata.skulltoothbonusid then
                    pobj:modstat(dmgid, false, pobj.ancientsdata.skulltoothbonus)
                end
            end
            pobj.ancientsdata.skulltoothbonus = nil
            pobj.ancientsdata.skulltoothbonusid = nil
            pobj.ancientsdata.skulltoothbonusfunc = nil
        end
    end
    loot.ancienttable_v_1_5[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_2_08.blp'
    a_id = a_id + 1
    ----------------------------------
    ----------------------------------
    loot.ancienttable_v_1_5[a_id] = loot.ancient:new(a_id, biome_id_ice, slot_backpack, ancient_event_damagedeal,
        "Portable Storage Cooler", 'Increases damage dealt to Frozen, Stunned or Rooted targets by 25%%.')
    loot.ancienttable_v_1_5[a_id].func = function(ancientid, pobj, flag, event)
        if UnitHasBuffBJ(event.target, bf_stun.buffcode) or UnitHasBuffBJ(event.target, bf_freeze.buffcode) or UnitHasBuffBJ(event.target, bf_root.buffcode) then
            event.amount = event.amount *1.25
        end
    end
    loot.ancienttable_v_1_5[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_2_09.blp'
    a_id = a_id + 1
    ----------------------------------
    ----------------------------------
    loot.ancienttable_v_1_5[a_id] = loot.ancient:new(a_id, biome_id_vault, slot_artifact, ancient_event_damagedeal,
        "Time-Lost Amalgam", 'Increases damage dealt to Bosses by 25%%.')
    loot.ancienttable_v_1_5[a_id].func = function(ancientid, pobj, flag, event)
        if IsUnitType(event.target, UNIT_TYPE_ANCIENT) then
            event.amount = event.amount*1.25
        end
    end
    loot.ancienttable_v_1_5[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_2_10.blp'
    a_id = a_id + 1
    ----------------------------------
    ----------------------------------
    loot.ancienttable_v_1_5[a_id] = loot.ancient:new(a_id, biome_id_vault, slot_outfit, ancient_event_equip,
        "Gleaming Vault-Plate", 'Increases your Treasure Find by 100%%.')
    loot.ancienttable_v_1_5[a_id].func = function(ancientid, pobj, flag, event)
        if flag then
            pobj:modstat(p_stat_treasure, true, 100)
        else
            pobj:modstat(p_stat_treasure, false, 100)
        end
    end
    loot.ancienttable_v_1_5[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_2_11.blp'
    a_id = a_id + 1
    ----------------------------------
    ----------------------------------
    loot.ancienttable_v_1_5[a_id] = loot.ancient:new(a_id, biome_id_vault, slot_leggings, ancient_event_damagetake,
        "Liquid Gold Legplates", 'Reduces the damage you receive from Bosses by 10%%.')
    loot.ancienttable_v_1_5[a_id].func = function(ancientid, pobj, flag, event)
        if event.target == pobj.unit and IsUnitType(event.source, UNIT_TYPE_ANCIENT) then
            event.amount = event.amount*0.9
        end
    end
    loot.ancienttable_v_1_5[a_id].icon = 'war3mapImported\\item_loot_icons_ancient_2_12.blp'
    a_id = a_id + 1
    ----------------------------------
    ----------------------------------

    for ancientid,t in pairs(loot.ancienttable_v_1_5) do
        loot.ancienttypes[ancientid] = loot.itemtype:new(t.fullname, loot:slot(t.slotid), 1, t.icon)
        loot.ancienttypes[ancientid].ancientid = ancientid
        -- MUST add new ancients to the original ancient table:
        loot.ancienttable[ancientid] = t
    end

end
