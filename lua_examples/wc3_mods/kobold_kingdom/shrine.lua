shrine = {} -- controls shrines in the world and what happens when a player right clicks on them.
shrine.biome = {}


function shrine:init()
    shrine_buff_dur = 120.0
    self.__index    = self
    self.stack      = {} -- stores FourCC() codes as index, shrine object as value
    self.devstack   = {} -- for dev testing, ipairs with shrine object as value.
    self.units      = {} -- active shrine units index by unit indexer value, with a table to store more data.

    -- h012 -- Ancient Crystal = Drops 1-2 Ancient Fragments and 3-6 random ore type.
    shrine_anctcrys = shrine:new("h012", function(u, ux, uy, tx, ty)
        local p = utils.powner(u)
        loot:generatelootmissile(tx, ty, "I00F", math.random(1,2), nil, speff_fireroar, speff_fragment.effect)
        map.block:spawnore(math.random(3*map.manager.diffid, 6*map.manager.diffid), math.random(1,6), tx, ty)
    end, true, speff_holyglow)

    -- h011 -- Ancient Chest = Drops 2-4 Ancient Fragments.
    shrine_anctchest = shrine:new("h011", function(u, ux, uy, tx, ty)
        local p = utils.powner(u)
        loot:generatelootmissile(tx, ty, "I00F", math.random(2,3) + math.ceil(map.manager.diffid/3), nil, speff_fireroar, speff_fragment.effect)
        cl_shrine_arcana:spawn(tx, ty, 6, 8, speff_iceburst2)
    end, false, speff_holyglow, "stand portrait alternate", "stand portrait")

    -- h00O -- Arcane Prison = Gives 15% Treasure Find and summons a Void Lord minion that follows you for shrine_buff_dur sec.
    shrine_arcprison = shrine:new("h00O", function(u, ux, uy, tx, ty)
        local p = utils.powner(u)
        local u = ai:new(utils.unitatxy(p, tx, ty, 'h00H', math.random(0,360)))
        u:initcompanion(900.0, 16.0 + math.floor((kobold.player[p].level/4)^1.2), p_stat_arcane)
        buffy:add_indicator(p, "Arcane Shrine", 'ReplaceableTextures\\CommandButtons\\BTNUrnOfKelThuzad.blp', shrine_buff_dur,
            "Followed by an Arcane Lord, +15%% Treasure Find", sp_armor_boost[4], 'overhead')
        spell:enhancepstat(p_stat_treasure, 15, shrine_buff_dur, p, true)
        utils.timed(shrine_buff_dur, function() if u then u:releasecompanion() end end)
    end, true, speff_rescast)

    -- h00V -- Abandoned Mine = Drops 5*diffid gold ore and summons a cluster of rock golems.
    shrine_mine = shrine:new("h00V", function(u, ux, uy, tx, ty)
        local p = utils.powner(u)
        map.block:spawnore(math.random(2*map.manager.diffid, 3*map.manager.diffid), 7, tx, ty)
        cl_foss_golem:spawn(tx, ty, 5, 8, speff_quake)
    end, true, speff_rescast)

    -- h00U -- Heroic Reliquary = Increases Physical damage done by 15% and reduces damages taken by 15% for shrine_buff_dur sec.
    shrine_hero = shrine:new("h00U", function(u, ux, uy, tx, ty)
        local p = utils.powner(u)
        buffy:add_indicator(p, "Heroic Shrine", 'ReplaceableTextures\\CommandButtons\\BTNAvatar.blp', shrine_buff_dur,
            "+15%% Physical Damage, +15%% damage reduction", sp_armor_boost[4], 'overhead')
        spell:enhancedmgtype(dmg_phys, 15, shrine_buff_dur, p, true)
        spell:enhancepstat(p_stat_dmg_reduct, 15, shrine_buff_dur, p, true)
    end, false, speff_rescast, "stand", "stand work")

    -- h00R -- Bloodthirsty Reliquary = Adds 15% Physical and Elemental lifesteal for shrine_buff_dur sec.
    shrine_blood = shrine:new("h00R", function(u, ux, uy, tx, ty)
        local p = utils.powner(u)
        buffy:add_indicator(p, "Bloodthirsty Shrine", 'ReplaceableTextures\\CommandButtons\\BTNVampiricAura.blp', shrine_buff_dur,
            "+15%% Elemental Lifesteal, +15%% Physical Lifesteal", speff_drainlf, 'overhead')
        spell:enhancepstat(p_stat_elels, 15, shrine_buff_dur, p, true)
        spell:enhancepstat(p_stat_physls, 15, shrine_buff_dur, p, true)
    end, false, speff_rescast, "stand", "stand work")

    -- h00T -- Enchanted Reliquary = Increases Elemental damage done by 15% and adds 15% Proliferation for shrine_buff_dur sec.
    shrine_enchant = shrine:new("h00T", function(u, ux, uy, tx, ty)
        local p = utils.powner(u)
        buffy:add_indicator(p, "Enchanted Shrine", 'ReplaceableTextures\\CommandButtons\\BTNSpellSteal.blp', shrine_buff_dur,
            "+15%% Elemental Damage, +15%% Proliferation", speff_phxfire, 'overhead')
        for dmgtypeid = 1,6 do if dmgtypeid ~= 6 then spell:enhancedmgtype(dmgtypeid, 15, shrine_buff_dur, p, true) end end
        spell:enhancepstat(p_stat_eleproc, 15, shrine_buff_dur, p, true)
    end, false, speff_rescast, "stand", "stand work")

    -- h00W -- Abyssal Reliquary = Summons 3 murloc minions for shrine_buff_dur sec.
    shrine_abyss = shrine:new("h00W", function(u, ux, uy, tx, ty)
        local p = utils.powner(u)
        buffy:add_indicator(p, "Abyssal Shrine", "ReplaceableTextures\\CommandButtons\\BTNMurloc.blp", shrine_buff_dur,
            "Followed by 3 Murloc Warriors", mis_acid, 'overhead')
        local mt = {}
        for i = 1,3 do
            mt[i] = {}
            mt[i].unit = utils.unitatxy(p, tx, ty, 'n01Q', math.random(0,360))
            mt[i].ai = ai:new(mt[i].unit)
            mt[i].ai:initcompanion(900.0, 12.0 + math.floor((kobold.player[p].level/6)^1.2), p_stat_nature)
        end
        utils.timed(shrine_buff_dur, function() for i,t in ipairs(mt) do t.ai:releasecompanion() mt[i] = nil end mt = nil end)
    end, false, speff_rescast, "stand", "stand work")

    -- h00Q -- Brutish Reliquary = Increases movespeed and mining speed by 25% for shrine_buff_dur sec, and adds a 25% to crit for 50% bonus damage (crit p_stat)
    shrine_brut = shrine:new("h00Q", function(u, ux, uy, tx, ty)
        local p = utils.powner(u)
        buffy:add_indicator(p, "Brutish Shrine", 'ReplaceableTextures\\CommandButtons\\BTNBerserk.blp', shrine_buff_dur,
            "+25%% Movespeed, +25%% Mining Speed, +25%% Critical Hit Chance", speff_lust, 'overhead')
        spell:enhancepstat(p_epic_hit_crit, 25.0, shrine_buff_dur, p, true)
        spell:enhancepstat(p_stat_minespd, 25.0, shrine_buff_dur, p, true)
        bf_ms:apply(u, shrine_buff_dur, nil, true)
    end, false, speff_rescast, "stand", "stand work")

    -- h00S -- Lost Treasure Chest = Spawns 1-3 random items, with a 25% chance to activate a radius of missiles trap after 1.5 sec.
    shrine_tchest = shrine:new("h00S", function(u, ux, uy, tx, ty)
        loot:generatelootpile(tx, ty, math.random(1,3), utils.powner(u))
    end, false, speff_holyglow, "stand portrait alternate", "stand portrait")

    -- h00K -- Blessed Fountain = Restores 50% Health and Mana instantly, plus restores 2.5% of the player's Health and Mana per sec for shrine_buff_dur sec.
    shrine_blessed = shrine:new("h00K", function(u, ux, uy, tx, ty)
        local p, u = utils.powner(u), u
        utils.addlifep(u, 50, true, u)
        utils.addmanap(u, 2.5, false)
        buffy:add_indicator(p, "Blessed Shrine", 'ReplaceableTextures\\CommandButtons\\BTNRegenerate.blp', shrine_buff_dur,
            "2.5%% health and mana recovered per sec", speff_rejuv, 'overhead')
        utils.timedrepeat(1.33, shrine_buff_dur, function()
            if kobold.player[p] and not kobold.player[p].downed then
                utils.addlifep(u, 2.5, false, u)
                utils.addmanap(u, 2.5, false) else
            ReleaseTimer() end
        end)
    end, false, speff_waterexpl, "stand", "stand alternate")

    -- h00N -- Wax-Lit Altar = Adds 15 Wax and drops 1-2 random item, and summons skeletal enemies.
    shrine_waxaltar = shrine:new("h00N", function(u, ux, uy, tx, ty)
        local p, u = utils.powner(u), u
        candle:add(15)
        cl_skele:spawn(tx, ty, 5, 8, speff_udexpl)
        loot:generatelootpile(tx, ty, math.random(1-2), utils.powner(u))
    end, true, speff_udexpl)

    --[[
        --------------------
        ancient boss shrines
        --------------------
    --]]

    -- h00L -- Demonic Tribute
    shrine_a_demonic = shrine:new("h00L", function(u, ux, uy, tx, ty)
        speff_judge:play(tx, ty)
        utils.timed(0.78, function()
            local u = utils.unitatxy(Player(PLAYER_NEUTRAL_AGGRESSIVE), tx, ty, 'n024', math.random(0,360))
            local ai = ai.miniboss:new(u, 4.72, "spell", true, 2)
            ai.spellfunc = function()
                shrine:mini_boss_spell_mortar(ai.unit, ai.trackedunit, cr_elefirelesr, speff_conflagoj, dmg_shadow, mis_voidballhge, 16)
            end
        end)
    end, true)

    -- h00P -- Arcane Relic
    shrine_a_arcane = shrine:new("h00P", function(u, ux, uy, tx, ty)
        speff_judge:play(tx, ty)
        utils.timed(0.78, function()
            local u = utils.unitatxy(Player(PLAYER_NEUTRAL_AGGRESSIVE), tx, ty, 'n020', math.random(0,360))
            local ai = ai.miniboss:new(u, 4.72, "spell", true, 2)
            ai.spellfunc = function()
                shrine:mini_boss_spell_mortar(ai.unit, ai.trackedunit, sh_arcshard, mis_boltblue, dmg_arcane, mis_boltblue, 16)
            end
        end)
    end, true)

    -- h00M -- Lost Tomb
    shrine_a_losttomb = shrine:new("h00M", function(u, ux, uy, tx, ty)
        speff_judge:play(tx, ty)
        utils.timed(0.78, function()
            local u = utils.unitatxy(Player(PLAYER_NEUTRAL_AGGRESSIVE), tx, ty, 'n025', math.random(0,360))
            local ai = ai.miniboss:new(u, 4.72, "spell", true, 2)
            ai.spellfunc = function()
                shrine:mini_boss_spell_mortar(ai.unit, ai.trackedunit, cr_skele_arch, speff_conflagoj, dmg_phys, mis_boltred, 16)
            end
        end)
    end, true)

    -- h00X -- Brood Dragon Roost
    shrine_a_brooddrag = shrine:new("h00X", function(u, ux, uy, tx, ty)
        speff_judge:play(tx, ty)
        utils.timed(0.78, function()
            local u = utils.unitatxy(Player(PLAYER_NEUTRAL_AGGRESSIVE), tx, ty, 'n021', math.random(0,360))
            local ai = ai.miniboss:new(u, 4.72, "spell", true, 2)
            ai.spellfunc = function()
                shrine:mini_boss_spell_mortar(ai.unit, ai.trackedunit, sh_dragbrood, speff_conflaggn, dmg_nature, mis_bat, 16)
            end
        end)
    end, true)

    -- h00Z -- Frost Dragon Roost
    shrine_a_frostdrag = shrine:new("h00Z", function(u, ux, uy, tx, ty)
        speff_judge:play(tx, ty)
        utils.timed(0.78, function()
            local u = utils.unitatxy(Player(PLAYER_NEUTRAL_AGGRESSIVE), tx, ty, 'n022', math.random(0,360))
            local ai = ai.miniboss:new(u, 4.72, "spell", true, 2)
            ai.spellfunc = function()
                shrine:mini_boss_spell_mortar(ai.unit, ai.trackedunit, sh_dragfrost, speff_iceblast, dmg_frost, mis_blizzard, 16)
            end
        end)
    end, true)

    -- h00Y -- Fire Dragon Roost
    shrine_a_firedrag = shrine:new("h00Y", function(u, ux, uy, tx, ty)
        speff_judge:play(tx, ty)
        utils.timed(0.78, function()
            local u = utils.unitatxy(Player(PLAYER_NEUTRAL_AGGRESSIVE), tx, ty, 'n023', math.random(0,360))
            local ai = ai.miniboss:new(u, 4.72, "spell", true, 2)
            ai.spellfunc = function()
                shrine:mini_boss_spell_mortar(ai.unit, ai.trackedunit, sh_dragfire, speff_conflagoj, dmg_fire, mis_fireballbig, 16)
            end
        end)
    end, true)

    -- h010 -- Marrow Hut
    shrine_a_marrowhut = shrine:new("h010", function(u, ux, uy, tx, ty)
        speff_judge:play(tx, ty)
        utils.timed(0.78, function()
            local u = utils.unitatxy(Player(PLAYER_NEUTRAL_AGGRESSIVE), tx, ty, 'n02A', math.random(0,360))
            local ai = ai.miniboss:new(u, 4.72, "spell", true, 2)
            ai.spellfunc = function()
                shrine:mini_boss_spell_mortar(ai.unit, ai.trackedunit, sh_fossloot, speff_quake, dmg_phys, mis_rock, 16)
            end
        end)
    end, true)

    -- add to rarity tables:
    for biomeid = 1,5 do shrine.biome[biomeid] = {} end
    shrine.biome:add_all("common",  {shrine_tchest, shrine_mine, shrine_hero, shrine_blood, shrine_enchant, shrine_abyss, shrine_brut, shrine_blessed, shrine_waxaltar})
    shrine.biome:add_all("rare",    {shrine_tchest, shrine_arcprison})
    shrine.biome:add_all("ancient", {shrine_a_demonic, shrine_anctchest, shrine_anctcrys})
    shrine.biome:add(biome_id_foss,  "ancient", {shrine_a_marrowhut})
    shrine.biome:add(biome_id_slag,  "ancient", {shrine_a_firedrag})
    shrine.biome:add(biome_id_mire,  "ancient", {shrine_a_brooddrag})
    shrine.biome:add(biome_id_ice,   "ancient", {shrine_a_frostdrag})
    shrine.biome:add(biome_id_vault, "ancient", {shrine_a_arcane})
    self.trig = trg:new("attacked", Player(PLAYER_NEUTRAL_AGGRESSIVE))
    self.trig:regaction(function()
        utils.debugfunc(function()
            local t, u = utils.trigu(), GetAttacker()
            -- if utils.powner(GetOrderTargetUnit()) == Player(PLAYER_NEUTRAL_AGGRESSIVE) and shrine:checkorder() and shrine:checkrange(t, u) then
            if utils.powner(t) == Player(PLAYER_NEUTRAL_AGGRESSIVE) then
                if self.units[utils.data(t)] and not self.units[utils.data(t)].exhausted then
                    local id = GetUnitTypeId(t)
                    local tx, ty = utils.unitxy(t)
                    local ux, uy = utils.unitxy(u)
                    if self.stack[id] then
                        self.stack[id].clickfunc(u, ux, uy, tx, ty)
                        utils.palert(utils.powner(u), "Shrine Activated!", nil, true)
                        if self.stack[id].dies then
                            KillUnit(t)
                        else
                            utils.playsoundall(kui.sound.shrine)
                            SetUnitVertexColor(t, 100, 100, 100, 255)
                            self.units[utils.data(t)].exhausted = true
                            SetUnitAnimation(t, self.stack[id].clickanim)
                            utils.timed(2.0, function()
                                SetUnitTimeScale(t, 0)
                            end)
                            utils.setinvul(t, true)
                            BlzSetUnitStringField(t, UNIT_SF_NAME, self.units[utils.data(t)].prevname.."|n|cffaaaaaa<Exhausted>|r")
                        end
                        if self.stack[id].effect then self.stack[id].effect:play(tx, ty) end
                    end
                end
            end
        end, "shrine click")
    end)
end


function shrine:mini_boss_spell_mortar(unit, trackedunit, minion, minioneffect, dmgtypeid, miseffect, damage)
    -- launches mortar missiles at the tracked player and summons minions.
    utils.timedrepeat(0.63, 3, function()
        utils.debugfunc(function()
            if utils.isalive(unit) then
                local x,y = utils.unitprojectxy(trackedunit, math.random(0,100), math.random(0,360))
                boss:marker(x, y)
                local mis = missile:create_arc(x, y, unit, miseffect.effect, boss:get_dmg(damage), nil, 0.93)
                mis.dmgtype = dmg.type.stack[dmgtypeid]
                mis.arch = 450.0
                mis.explr = 132.0
                x,y = utils.unitprojectxy(unit, math.random(200,500), math.random(0,360))
                minioneffect:play(x,y)
                utils.issatkxy(minion:create(x, y), utils.unitxy(trackedunit))
            end
        end, "mini boss spell")
    end)
end


function shrine:checkrange(tar, clicker)
    return utils.isalive(tar) and utils.isalive(clicker) and utils.distunits(tar, clicker) < 235.0
end


function shrine:checkorder()
    return (GetIssuedOrderId() == 851986 or GetIssuedOrderId() == 851971)
        and utils.pnum(utils.powner(utils.trigu())) <= kk.maxplayers and kobold.player[utils.powner(utils.trigu())]
end


function shrine:create(x, y)
    if not shrine_dev_mode then
        map.grid:excavate(x, y, 768, t_udgrd_tile)
        map.grid:clearunits(x, y, 768, true)
    end
    local u = utils.unitatxy(Player(PLAYER_NEUTRAL_AGGRESSIVE), x, y, self.id)
    if self.anim then SetUnitAnimation(u, self.anim) end
    self.units[utils.data(u)] = {}
    self.units[utils.data(u)].prevname = BlzGetUnitStringField(u, UNIT_SF_NAME)
    BlzSetUnitStringField(u, UNIT_SF_NAME, self.units[utils.data(u)].prevname.."|n|cff00ff00<Attack to Activate>|r")
end


function shrine:placerandom(x, y, _biomeid)
    local biomeid = _biomeid or map.manager.biome.id
    local roll    = 0
    local rarity  = ""
    -- see if ancient is placed:
    if math.random(0,100) < 25 then
        rarity = "ancient"
    -- see if rare is placed:
    elseif math.random(0,100) < 50 then
        rarity = "rare"
    -- see if common is placed:
    elseif math.random(0,100) < 90 then
        rarity = "common"
    end
    if rarity ~= "" then
        roll = math.random(1,#shrine.biome[biomeid][rarity])
        shrine.biome[biomeid][rarity][roll]:create(x, y)
    end
end


-- @anim = animation to play after creation.
function shrine:new(id, clickfunc, diesonclick, _effect, _anim, _clickanim)
    local o = setmetatable({}, self)
    o.id        = id
    o.dies      = diesonclick
    o.clickfunc = clickfunc
    o.effect    = _effect or nil
    o.anim      = _anim or nil
    o.clickanim = _clickanim or nil
    self.stack[FourCC(id)] = o
    self.devstack[#self.devstack+1] = o
    return o
end


function shrine:collectfragment()
    if GetItemTypeId(GetManipulatedItem()) == FourCC("I00F") then
        utils.playerloop(function(p) kobold.player[p]:awardfragment(1) end)
    end
end


-- add shrine to a single biome.
function shrine.biome:add(biomeid, rarity, shrinest)
    if not shrine.biome[biomeid][rarity] then shrine.biome[biomeid][rarity] = {} end
    for i,v in ipairs(shrinest) do
        shrine.biome[biomeid][rarity][#shrine.biome[biomeid][rarity]+1] = v
    end
end


-- add shrine to every biome.
function shrine.biome:add_all(rarity, shrinest)
    for biomeid,_ in ipairs(shrine.biome) do
        shrine.biome:add(biomeid, rarity, shrinest)
    end
end


function shrine:cleanup()
    for i,v in pairs(self.units) do
        self.units[i] = nil
    end
end


function shrine:print_all()
    for biomeid = 1,5 do
        print("biomeid",biomeid)
        for rarityname,rarityt in pairs(shrine.biome[biomeid]) do
            if not rarityt[1] then
                print(rarityname,"is empty")
            else
                print(rarityname,"contains:")
            end
            for i,v in ipairs(rarityt) do
                print(i,v,v.id)
            end
        end
        print("")
    end
end
