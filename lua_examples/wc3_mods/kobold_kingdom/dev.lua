dev = {}

-- dev command listener:
onGlobalInit(function()
    boss_dev_mode = false
    dev.trig = CreateTrigger()
    TriggerRegisterPlayerChatEvent(dev.trig, Player(0), "-", false)
    TriggerAddAction(dev.trig, function()
        utils.debugfunc(function()
            dev_last_command = GetEventPlayerChatString()
            local p = utils.trigp()

            -- load quest
            if string.sub(dev_last_command,2,2) == "q" and string.sub(dev_last_command,3,3) == " " then
                -- clear current quest if it exists
                if quest.current then
                    quest.current.nextquest = nil
                    if not quest.current.triggered then
                        quest.current:begin(true)
                    end
                    quest.current:finish(true)
                end
                local qstid = utils.trim(string.sub(dev_last_command, 4))
                print("trying to load "..qstid)
                quest.lineage[tonumber(qstid)]:activate()
                quest.lineage[tonumber(qstid)]:begin()
                quest.lineage[tonumber(qstid)].triggered = true
                print("quest loaded with id: "..qstid)
            end
            if dev_last_command == "-proj" then
                testprojects()
            end
            if dev_last_command == "-dk" then
                kui.canvas.game.dig.mappiece:show()
                kui.canvas.game.dig.card[5]:show()
                for i = 1,5 do
                    loot:generatedigkey(p, kobold.player[p].level, i)
                end
            end
            if dev_last_command == '-kb' then
                KillUnit(map.mission.cache.boss.unit)
            end
            if dev_last_command == '-sk' then
                boss_dev_mode = true
                utils.setcambounds(GetPlayableMapRect())
                DisableTrigger(kk.boundstrig)
                local x,y = 0, 0
                utils.setxy(kobold.player[Player(0)].unit, x, y)
                map.mission:build(m_type_boss_fight)
                map.mission.cache.boss = boss:new(utils.unitatxy(Player(24), x, y, 'N01B', 270.0), 'N01B')
                map.mission.cache.boss.centerx, map.mission.cache.boss.centery = x,y
                map.mission.cache.boss:init_boss_ai()
                map.mission.cache.bossid = 'N01B'
                map.mission.cache.boss:play_sound('intro')
                -- test spell category:
                --[[map.mission.cache.boss.spellcadence = {}
                map.mission.cache.boss.spellcadence.basic = 999.9
                map.mission.cache.boss.spellcadence.power = 999.9
                map.mission.cache.boss.spellcadence.channel = 6.0
                map.mission.cache.boss.spellcadence.ultimate = 999.9--]]
                bossfr:show()
            end
            if dev_last_command == '-mm' then
                boss_dev_mode = true
                utils.setcambounds(GetPlayableMapRect())
                DisableTrigger(kk.boundstrig)
                local x,y = 0, 0
                utils.setxy(kobold.player[Player(0)].unit, x, y)
                map.mission:build(m_type_boss_fight)
                map.mission.cache.boss = boss:new(utils.unitatxy(Player(24), x, y, 'N01F', 270.0), 'N01F')
                map.mission.cache.boss.centerx, map.mission.cache.boss.centery = x,y
                map.mission.cache.boss:init_boss_ai()
                map.mission.cache.bossid = 'N01F'
                map.mission.cache.boss:play_sound('intro')
                bossfr:show()
            end
            if dev_last_command == '-mc' then
                boss_dev_mode = true
                utils.setcambounds(GetPlayableMapRect())
                DisableTrigger(kk.boundstrig)
                local x,y = 0, 0
                utils.setxy(kobold.player[Player(0)].unit, x, y)
                map.mission:build(m_type_boss_fight)
                map.mission.cache.boss = boss:new(utils.unitatxy(Player(24), x, y, 'N01H', 270.0), 'N01H')
                map.mission.cache.boss.centerx, map.mission.cache.boss.centery = x,y
                map.mission.cache.boss:init_boss_ai()
                map.mission.cache.bossid = 'N01H'
                map.mission.cache.boss:play_sound('intro')
                bossfr:show()
            end
            if dev_last_command == '-te' then
                boss_dev_mode = true
                utils.setcambounds(GetPlayableMapRect())
                DisableTrigger(kk.boundstrig)
                local x,y = 0, 0
                utils.setxy(kobold.player[Player(0)].unit, x, y)
                map.mission:build(m_type_boss_fight)
                map.mission.cache.boss = boss:new(utils.unitatxy(Player(24), x, y, 'N01J', 270.0), 'N01J')
                map.mission.cache.boss.centerx, map.mission.cache.boss.centery = x,y
                map.mission.cache.boss:init_boss_ai()
                map.mission.cache.bossid = 'N01J'
                map.mission.cache.boss:play_sound('intro')
                bossfr:show()
            end
            if dev_last_command == '-ag' then
                boss_dev_mode = true
                utils.setcambounds(GetPlayableMapRect())
                DisableTrigger(kk.boundstrig)
                local x,y = 0, 0
                utils.setxy(kobold.player[Player(0)].unit, x, y)
                map.mission:build(m_type_boss_fight)
                map.mission.cache.boss = boss:new(utils.unitatxy(Player(24), x, y, 'N01R', 270.0), 'N01R')
                map.mission.cache.boss.centerx, map.mission.cache.boss.centery = x,y
                map.mission.cache.boss:init_boss_ai()
                map.mission.cache.bossid = 'N01R'
                map.mission.cache.boss:play_sound('intro')
                bossfr:show()
            end
            if dev_last_command == '-bspell' then
                -- test spell category:
                map.mission.cache.boss.spellcadence = {}
                map.mission.cache.boss.spellcadence.basic = 999.9
                map.mission.cache.boss.spellcadence.power = 999.9
                map.mission.cache.boss.spellcadence.channel = 999.0
                map.mission.cache.boss.spellcadence.ultimate = 10.0
            end
            if dev_last_command == '-ai' then
                for aid = 1,36 do
                    loot:generateancient(Player(0), kobold.player[Player(0)].level, nil, nil, aid)
                end
            end
            if dev_last_command == '-ai2' then
                for aid = 37,48 do
                    loot:generateancient(Player(0), kobold.player[Player(0)].level, nil, nil, aid)
                end
            end
            if dev_last_command == '-pai' then
                for i,v in pairs(loot.ancienttable) do
                    print('ancientid stored in ancienttable:', i)
                end
            end
            if dev_last_command == '-eai' then
                for i,v in pairs(kobold.player[Player(0)].ancients) do
                    print("id", i, "=")
                    for i2, v2 in pairs(v) do
                        print(i2, "=", v2)
                    end
                end
            end
            if dev_last_command == '-can' then
                local x,y = utils.unitxy(kobold.player[Player(0)].unit)
                x,y = x + math.random(0,100), y + math.random(0,100)
                candle:spawnwax(x, y)
                candle:spawnwax(x, y, "medium")
                candle:spawnwax(x, y, "large")
            end
            if dev_last_command == '-relics' then
                placeproject('boss1')
                placeproject('boss2')
                placeproject('boss3')
                placeproject('boss4')
            end
            if dev_last_command == '-cons' then
                for i,v in pairs(constructiont) do
                    placeproject(i)
                end
            end
            if dev_last_command == '-ele' then
                kobold.player[Player(0)]:modstat(p_stat_eleproc, true, 1000)
            end
            if dev_last_command == '-h10' then
                utils.setlifep(kobold.player[Player(0)].unit, 10)
            end
            if dev_last_command == '-fp' then
                kobold.player[Player(0)]:freeplaymode()
            end
            if dev_last_command == '-verifyq' then
                utils.timedrepeat(1.0, 14, function()
                    if quest.current then
                        quest.current:finish()
                        utils.timed(1.0, function() speak:endscene() end)
                    else
                        ReleaseTimer()
                    end
                end)
            end
            if dev_last_command == '-save' then
                kobold.player[p].char.fileslot = 1
                kobold.player[p].char:save_character()
            end
            if dev_last_command == '-load' then
                kui:hidesplash(p, true)
                kobold.player[p].isloading = true
                kobold.player[p].char = char:new(p)
                kobold.player[p].char:read_file(1)
                kobold.player[p].char:get_file_data()
                kobold.player[p].char:load_character()
            end
            if dev_last_command == '-saveprint' then
                kobold.player[p].char:print_data()
            end
            if dev_last_command == '-frags' then
                kobold.player[p]:awardfragment(10)
            end
            if dev_last_command == '-fshop' then
                shop.gwfr:show()
            end
            if dev_last_command == '-chest1' then
                map.manager.prevbiomeid = math.random(1,5)
                map.manager.prevdiffid = 1
                boss:awardbosschest()
            end
            if dev_last_command == '-chest2' then
                map.manager.prevbiomeid = math.random(1,5)
                map.manager.prevdiffid = 2
                boss:awardbosschest()
            end
            if dev_last_command == '-chest3' then
                map.manager.prevbiomeid = math.random(1,5)
                map.manager.prevdiffid = 3
                boss:awardbosschest()
            end
            if dev_last_command == '-chest4' then
                map.manager.prevbiomeid = math.random(1,5)
                map.manager.prevdiffid = 4
                boss:awardbosschest()
            end
            if dev_last_command == '-chest5' then
                map.manager.prevbiomeid = math.random(1,5)
                map.manager.prevdiffid = 5
                boss:awardbosschest()
            end
            if dev_last_command == '-chestv1' then
                map.manager.prevbiomeid = 1
                map.manager.prevdiffid = 5
                boss:awardbosschest()
            end
            if dev_last_command == '-chestv2' then
                map.manager.prevbiomeid = 2
                map.manager.prevdiffid = 5
                boss:awardbosschest()
            end
            if dev_last_command == '-chestv3' then
                map.manager.prevbiomeid = 3
                map.manager.prevdiffid = 5
                boss:awardbosschest()
            end
            if dev_last_command == '-chestv4' then
                map.manager.prevbiomeid = 4
                map.manager.prevdiffid = 5
                boss:awardbosschest()
            end
            if dev_last_command == '-chestv5' then
                map.manager.prevbiomeid = 5
                map.manager.prevdiffid = 5
                boss:awardbosschest()
            end
            if dev_last_command == '-ts' then
                shrine_dev_mode = true
                map.manager.activemap = true
                map.mission.cache = map.mission:generate(m_type_monster_hunt)
                map.mission.cache.level = 60
                candle:load()
                utils.setcambounds(GetPlayableMapRect())
                DisableTrigger(kk.boundstrig)
                local x,y = -1300, 2300
                utils.setxy(kobold.player[Player(0)].unit, 0, 1000)
                for i,s in ipairs(shrine.devstack) do
                    s:create(x + (i-1)*326, y - (i-1)*326)
                end
            end
            if dev_last_command == '-ts1' then
                shrine_dev_mode = true
                map.manager.activemap = true
                map.mission.cache = map.mission:generate(m_type_monster_hunt)
                map.mission.cache.level = 60
                candle:load()
                utils.setcambounds(GetPlayableMapRect())
                DisableTrigger(kk.boundstrig)
                local x,y = -1300, 2300
                utils.setxy(kobold.player[Player(0)].unit, 0, 1000)
                for i = 1,3 do
                    shrine_arcprison:create(x, y)
                end
            end
            if dev_last_command == '-buff' then
                for i = 1,20 do
                    if i < 10 then
                        buffy:add_indicator(p, "Test Title "..tostring(i), 'war3mapImported\\class_ability_icons_0'..tostring(i)..'.blp', i+3, "Test description")
                    else
                        buffy:add_indicator(p, "Test Title "..tostring(i), 'war3mapImported\\class_ability_icons_'..tostring(i)..'.blp', i+3, "Test description")
                    end
                end
            end
            if dev_last_command == '-debuff' then
                for i,b in ipairs(buffy.stack) do
                    b:apply(kobold.player[p].unit, math.random(3,10))
                end
            end
            if dev_last_command == '-movespeed' then
                print(BlzGetUnitRealField(kobold.player[p].unit, UNIT_RF_SPEED))
            end
            if dev_last_command == '-badge' then
                kui.canvas.game.badge:show()
            end
            if dev_last_command == '-badgetest' then
                for id = 1,18 do
                    if math.random(1,2) == 1 then
                        for classid = 1,math.random(1,4) do
                            badge:earn(kobold.player[Player(0)], id, classid)
                        end
                    end
                end
            end

            if dev_last_command == '-debugloot' then
                loot.debug = true
            end

            -- force set a mission:
            if string.sub(dev_last_command,2,2) == "m" and string.sub(dev_last_command,3,3) == " " then
                local misid = utils.trim(string.sub(dev_last_command, 4))
                print("forced mission id set to "..misid)
                if misid == 0 then
                    dev_mission_id = nil
                else
                    dev_mission_id = tonumber(misid)
                end
            end
        end, "dev command")
    end)
end)


function dev:fakeplayers()
    for pnum = 2,4 do
        local p = Player(pnum-1)
        SetPlayerAlliance(p, Player(0), ALLIANCE_SHARED_CONTROL, true)
        kobold.player[p]           = kobold.player:new(p)
        kobold.player[p].unit      = CreateUnit(p, FourCC(kui.meta.char04raw), utils.rectx(gg_rct_charspawn), utils.recty(gg_rct_charspawn), 270.0)
        kobold.player[p].charid    = 4
        kobold.player[p].mastery   = mastery:new()
        kobold.player[p].permtimer = NewTimer()
        SetTimerData(kobold.player[p].permtimer, function() end) -- dummy func to prevent error raise
        kui.canvas.game.party.pill[pnum] = kui:createpartypill(kui.canvas.game.party, pnum, kobold.player[p].charid)
        kui:attachupdatetimer(p, pnum)
    end
end


function dev:completequest()
    quest.current:markprogress(true)
end


function dev:showshop()
    quest_elementalist_unlocked = true
    quest_shinykeeper_unlocked = true
    quest.socialfr.eleshop:show()
    quest.socialfr.shinshop:show()
    for i = 1,6 do
        kobold.player[Player(0)]:awardoretype(i, 100)
    end
    kobold.player[Player(0)]:awardgold(10000)
end

function dev:toggleshop()
    if not shop.fr.shinypane:isvisible() then
        shop_vendor_type_open[utils.trigpnum()] = 0
        shop.fr.shinypane:show()
        shop.fr.elepane:hide()
    else
        shop_vendor_type_open[utils.trigpnum()] = 1
        shop.fr.shinypane:hide()
        shop.fr.elepane:show()
    end
end

function dev:devscreenplay1()
    screenplay:run(screenplay.chains.intro_1)
end

function dev:devscreenplay2()
    screenplay:run(screenplay.chains.intro_2)
end

function dev:devscreenplay3()
    screenplay:run(screenplay.chains.intro_3)
end


function dev:candle()
    candle.current = candle.current - 75
end


function dev:fakeleave()
    kobold.player[Player(2)]:leftgame()
end


function dev:fakedown()
    for pnum = 2,4 do
        if kobold.player[Player(pnum-1)] then kobold.player[Player(pnum-1)]:down(true) end
    end
end


function dev:loot()
    -- dev space:
    if loot:isbagfull(Player(0)) then
        for slotid = 1,42 do
            kobold.player[Player(0)].items[slotid] = nil
        end
        loot:cleanupempty(Player(0))
    end
    for i = 1,42 do
        utils.debugfunc(function()
            loot:generate(Player(0),
                kobold.player[Player(0)].level,
                loot:getrandomslottype())
        end, "loot:generate")
    end
end


function dev:devgear()
    for slotid = 1001,1010 do
        local item = loot:generate(Player(0), kobold.player[Player(0)].level, slotid, rarity_epic)
        kobold.player[Player(0)].selslotid = 1
        item:equip(Player(0))
    end
end


function dev:devgeardestroy()
    for slotid = 1001,1010 do
        kobold.player[Player(0)].selslotid = slotid
        loot.item:unequip(Player(0))
    end
    dev:clearitems()
end


function dev:clearitems()
    for slotid = 1,42 do
        kobold.player[Player(0)].items[slotid] = nil
    end
    loot:cleanupempty(Player(0))
end


function dev:loot60()
    -- dev space:
    if loot:isbagfull(Player(0)) then
        for slotid = 1,42 do
            kobold.player[Player(0)].items[slotid] = nil
        end
        loot:cleanupempty(Player(0))
    end
    for i = 1,42 do
        utils.debugfunc(function()
            loot:generate(Player(0),
                i+1,
                loot:getrandomslottype())
        end, "loot:generate")
    end
end


function dev:level(x)
    utils.debugfunc( function()
        for _ = 1,x do
            if kobold.player[Player(0)].level < 60 then
                kobold.player[Player(0)]:addlevel()
            end
        end
    end, "dev")
end


function dev:addallattr(_attr)
    for i = 1,300 do
        if _attr then
            kobold.player[Player(0)]:applyattrpoint(_attr)
        else
            kobold.player[Player(0)]:applyattrpoint(p_stat_strength)
            kobold.player[Player(0)]:applyattrpoint(p_stat_wisdom)
            kobold.player[Player(0)]:applyattrpoint(p_stat_alacrity)
            kobold.player[Player(0)]:applyattrpoint(p_stat_vitality)
        end
    end
end


function dev:learn()
    kobold.player[Player(0)].ability:learnmastery("na1")
end
