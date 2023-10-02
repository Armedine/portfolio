function quest:dataload()

    -- boss order:
    --[[
    Slag
    Mire
    Fossil
    Ice
    Vault
    ]]

    -- quest flags:
    quest_shinykeeper_unlocked = false
    quest_shinykeeper_upgrade_1 = false     -- shinies for dummies, +1 affix roll and sometimes rolls a secondary.
    quest_shinykeeper_upgrade_2 = false     -- can now roll epics.
    quest_elementalist_unlocked = false
    quest_elementalist_upgrade_1 = false    -- adds guaranteed secondary rolls.
    quest_elementalist_upgrade_2 = false    -- can now roll epics.
    quest_greywhisker_unlocked = false


    -- build map quests:
    -- actors[1] = Kobold
    -- actors[2] = Shinykeeper
    -- actors[3] = Dig Master
    -- actors[4] = Elementalist
    -- actors[5] = Narrator
    -- actors[6] = Grog
    -- actors[7] = Slog
    -- actors[8] = Greywhisker

    quest[1] = quest:createspeakquest(
        "Greenwhisker",
        screenplay.chains.quest[1].start,
        screenplay.chains.quest[1].finish,
        udg_actors[1],
        udg_actors[2],
        75)
    quest[1].awardfunc = function()
        quest:addloot(rarity_common, rarity_common, slot_helmet)
        quest:addloot(rarity_common, rarity_common, slot_candle)
        quest:addloot(rarity_common, rarity_common, slot_outfit)
    end
    ----------------------------------
    quest[2] = quest:createdigquest(
        "Miner's Trove",
        nil,
        screenplay.chains.quest[2].start,
        screenplay.chains.quest[2].finish,
        udg_actors[3],
        udg_actors[3],
        225)
    quest[2].awardfunc = function()
        quest:addloot(rarity_common, rarity_common, slot_tool)
        quest:addloot(rarity_common, rarity_common, slot_boots)
        quest:addloot(rarity_common, rarity_common, slot_backpack)
    end
    ----------------------------------
    quest[3] = quest:createdigquest(
        "Hammer Time",
        nil,
        screenplay.chains.quest[3].start,
        screenplay.chains.quest[3].finish,
        udg_actors[2],
        udg_actors[2],
        225)
    quest[3].awardfunc = function()
        placeproject('shiny1')
        quest_shinykeeper_unlocked = true
        badge:earn(kobold.player[Player(0)], 3)
        self.socialfr.shinshop:show()
        self:addgoldaward(100)
    end
    ----------------------------------
    quest[4] = quest:createdigquest(
        "Rock Your Socks",
        nil,
        screenplay.chains.quest[4].start,
        screenplay.chains.quest[4].finish,
        udg_actors[4],
        udg_actors[4],
        300)
    quest[4].awardfunc = function()
        placeproject('ele1')
        quest_elementalist_unlocked = true
        badge:earn(kobold.player[Player(0)], 4)
        self.socialfr.eleshop:show()
        self:addoreaward(10, nil, true)
        self:addgoldaward(100)
        quest.socialfr.fragshop:show()
    end
    ----------------------------------
    quest[5] = quest:createspeakquest(
        "Greywhisker",
        screenplay.chains.quest[5].start,
        screenplay.chains.quest[5].finish,
        udg_actors[3],
        udg_actors[8],
        100)
    quest[5].startfunc = function()
        utils.playerloop(function(p)
            if utils.localp() == p then
                quest.socialfr.fragshop:show()
                shop.gwfr.card[2].icon:show()
            end
        end)
    end
    quest[5].awardfunc = function()
        quest_greywhisker_unlocked = true
        badge:earn(kobold.player[Player(0)], 5)
        quest:addfragaward(5)
    end
    ----------------------------------
    quest[6] = quest:createbossquest(
        "Reign of Fire",
        m_type_boss_fight,
        "The Slag King",
        "N01B",
        screenplay.chains.quest[6].start,
        screenplay.chains.quest[6].finish,
        udg_actors[3],
        udg_actors[3],
        300)
    quest[6].startfunc = function()
        utils.playerloop(function(p)
            if utils.localp() == p then
                shop.gwfr.card[2].icon:show()
            end
        end)
    end
    quest[6].awardfunc = function()
        placeproject('boss1')
        self:addgoldaward(100)
        quest:addloot(rarity_rare, rarity_rare, loot:getrandomslottype(), 1)
    end
    ----------------------------------
    quest[7] = quest:createdigquest(
        "Scribble Rat",
        nil,
        screenplay.chains.quest[7].start,
        screenplay.chains.quest[7].finish,
        udg_actors[2],
        udg_actors[2],
        375)
    quest[7].awardfunc = function()
        placeproject('shiny2')
        quest_shinykeeper_upgrade_1 = true
        quest:addloot(rarity_common, rarity_common, slot_boots)
    end
    ----------------------------------
    quest[8] = quest:createdigquest(
        "Crystal Clear",
        nil,
        screenplay.chains.quest[8].start,
        screenplay.chains.quest[8].finish,
        udg_actors[4],
        udg_actors[4],
        375)
    quest[8].awardfunc = function()
        placeproject('ele2')
        quest_elementalist_upgrade_1 = true
        self:addgoldaward(100)
        for i = 1,6 do self:addoreaward(10, i, true) end -- give 10 of every ore type.
    end
    ----------------------------------
    quest[9] = quest:createbossquest(
        "Marsh Madness",
        m_type_boss_fight,
        "Marsh Mutant",
        "N01F",
        screenplay.chains.quest[9].start,
        screenplay.chains.quest[9].finish,
        udg_actors[3],
        udg_actors[3],
        375)
    quest[9].startfunc = function()
        utils.playerloop(function(p)
            if utils.localp() == p then
                shop.gwfr.card[3].icon:show()
            end
        end)
    end
    quest[9].awardfunc = function()
        placeproject('boss2')
        quest:addloot(rarity_rare, rarity_rare, loot:getrandomslottype(), 1)
    end
    ----------------------------------
    quest[10] = quest:createdigquest(
        "Epicness, Pt. 1",
        nil,
        screenplay.chains.quest[10].start,
        screenplay.chains.quest[10].finish,
        udg_actors[2],
        udg_actors[2],
        375)
    quest[10].awardfunc = function()
        placeproject('shiny3')
        quest_shinykeeper_upgrade_2 = true
        quest:addloot(rarity_rare, rarity_rare, slot_artifact)
        quest:addloot(rarity_rare, rarity_rare, slot_potion)
    end
    ----------------------------------
    quest[11] = quest:createdigquest(
        "Epicness, Pt. 2",
        nil,
        screenplay.chains.quest[11].start,
        screenplay.chains.quest[11].finish,
        udg_actors[4],
        udg_actors[4],
        375)
    quest[11].awardfunc = function()
        placeproject('ele3')
        quest_elementalist_upgrade_2 = true
        quest:addloot(rarity_rare, rarity_rare, slot_backpack)
    end
    ----------------------------------
    quest[12] = quest:createbossquest(
        "Mawrific",
        m_type_boss_fight,
        "Megachomp",
        "N01H",
        screenplay.chains.quest[12].start,
        screenplay.chains.quest[12].finish,
        udg_actors[3],
        udg_actors[3],
        375)
    quest[12].startfunc = function()
        utils.playerloop(function(p)
            if utils.localp() == p then
                shop.gwfr.card[1].icon:show()
            end
        end)
        self:addgoldaward(150)
    end
    quest[12].awardfunc = function()
        placeproject('boss3')
        quest:addloot(rarity_rare, rarity_rare, loot:getrandomslottype(), 1)
    end
    ----------------------------------
    quest[13] = quest:createdigquest(
        "Let's Go Clubin'",
        nil,
        screenplay.chains.quest[13].start,
        screenplay.chains.quest[13].finish,
        udg_actors[7],
        udg_actors[6],
        375,
        nil,
        biome_id_ice)
    quest[13].awardfunc = function()
        self:addgoldaward(150)
    end
    ----------------------------------
    quest[14] = quest:createbossquest(
        "Not Very Ice",
        m_type_boss_fight,
        "Thawed Experiment",
        "N01J",
        screenplay.chains.quest[14].start,
        screenplay.chains.quest[14].finish,
        udg_actors[3],
        udg_actors[3],
        375)
    quest[14].startfunc = function()
        speak.showskip = false
        utils.playerloop(function(p)
            if utils.localp() == p then
                shop.gwfr.card[4].icon:show()
            end
        end)
    end
    quest[14].awardfunc = function()
        placeproject('boss4')
        quest:addloot(rarity_rare, rarity_rare, loot:getrandomslottype(), 1)
    end
    ----------------------------------
    quest[15] = quest:createbossquest(
        "Greed Is Good",
        m_type_boss_fight,
        "The Guardian",
        "N01R",
        screenplay.chains.quest[15].start,
        screenplay.chains.quest[15].finish,
        udg_actors[8],
        udg_actors[3],
        750)
    quest[15].startfunc = function()
        utils.playerloop(function(p)
            if utils.localp() == p then
                shop.gwfr.card[5].icon:show()
            end
        end)
        kui.canvas.game.dig.mappiece:show()
        kui.canvas.game.dig.card[5]:show()
        alert:new("New Zone Unlocked: "..color:wrap(color.tooltip.good, "The Vault"), 4.0)
    end
    quest[15].awardfunc = function()
    speak.showskip = false
    self:addgoldaward(300)
    utils.playerloop(function(p)
        for i = 1,6 do self:addoreaward(100, i, false) end
    end)
    end
end
