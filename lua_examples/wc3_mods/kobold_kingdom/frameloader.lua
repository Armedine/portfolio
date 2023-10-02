local frameloaderfuncs = {}

function FrameLoaderAdd(func)
    table.insert(frameloaderfuncs, func)
end

-- FrameLoaderAdd(function() utils.init() end)
-- FrameLoaderAdd(function() spell:buildeffects() end)
-- FrameLoaderAdd(function() g:init() end)
-- FrameLoaderAdd(function() missile:init() end)
-- FrameLoaderAdd(function() kk.init() end)
-- FrameLoaderAdd(function() trg:init() end)
-- FrameLoaderAdd(function() buffy:init() end)
-- FrameLoaderAdd(function() spell:init() end)
-- FrameLoaderAdd(function() sync:init() end)
-- FrameLoaderAdd(function() kobold:init() end)
-- FrameLoaderAdd(function() dmg:init() end)
-- FrameLoaderAdd(function() ability:init() end)
-- FrameLoaderAdd(function() mastery:init() end)
-- FrameLoaderAdd(function() tooltip:init() end)
-- FrameLoaderAdd(function() terrain:init() end)
-- FrameLoaderAdd(function() map:init() end)
-- FrameLoaderAdd(function() kui:init() end)
FrameLoaderAdd(function() tooltip:bake() end)
FrameLoaderAdd(function() kui:uigen() end)
FrameLoaderAdd(function() boss:init() end)
FrameLoaderAdd(function() loot:init() end)
FrameLoaderAdd(function() hotkey:init() end)
FrameLoaderAdd(function() hotkey:assignkuipanels() end)
FrameLoaderAdd(function() kui:hidecmdbtns() end)
FrameLoaderAdd(function() creature:init() end)
FrameLoaderAdd(function() elite:init() end)
FrameLoaderAdd(function() speffect:preload() end)
FrameLoaderAdd(function() alert:init() end)
FrameLoaderAdd(function() shop:init() end)
FrameLoaderAdd(function() screenplay:build() end)
FrameLoaderAdd(function() quest:init() end)

local frameloadertrig = CreateTrigger()
TriggerRegisterGameEvent(frameloadertrig, EVENT_GAME_LOADED)
TriggerAddAction(frameloadertrig, function()
    -- kui:init()
    speak:init()
    if BlzLoadTOCFile('war3mapImported\\CustomFrames.toc') then --[[print("fdf loaded")--]] else print("***FDF FAILED TO LOAD***") end
    if not BlzLoadTOCFile('war3mapImported\\DialogueFrameTOC.toc') then print("error: .fdf file failed to load") end
    -- speak.consolebd = BlzGetFrameByName("ConsoleUIBackdrop",0)
    -- speak.gameui    = kui.canvas.fh
    -- speak.customgameui = kui.canvas.game.fh
    speak:initframes()
    screenplay:build()
    kui.gameui  = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
    kui.chatlog = BlzFrameGetChild(kui.gameui, 7)
    BlzFrameSetLevel(kui.chatlog, 6)
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- init global sounds
    -- play main panel sounds easily with kui.sound.panel[id]
    kui.sound   = {
        closebtn    = gg_snd_BigButtonClick,
        clickstr    = gg_snd_MouseClick1,
        clicksft    = gg_snd_MouseClick2,
        hoversft    = gg_snd_OverViewSelectionChange1,
        hoverbtn    = gg_snd_PickUpItem,
        digsel      = gg_snd_Switch,
        digstart    = gg_snd_BattleNetDoorsStereo2,
        digend      = gg_snd_audio_loading_complete,
        splashclk   = gg_snd_QuestActivateWhat1,
        char01new   = gg_snd_audio_tunl_finder_looook_new_shinies,
        char02new   = gg_snd_audio_geom_fungal_mushroom_power,
        char03new   = gg_snd_audio_scout_knight_onward,
        char04new   = gg_snd_audio_wickf_kobold_smash,
        loadend     = gg_snd_QuestNew,
        itemsel     = gg_snd_audio_item_selected,
        selnode     = gg_snd_audio_mastery_select_node,
        runenode    = gg_snd_FarseerMissile,
        scorebcard  = gg_snd_audio_mastery_open,
        complete    = gg_snd_QuestCompleted,
        objstep     = gg_snd_GoodJob,
        failure     = gg_snd_QuestFailed,
        completebig = gg_snd_NewTournament,
        error       = gg_snd_Error,
        sell        = gg_snd_AlchemistTransmuteDeath1,
        darkwarning = gg_snd_GraveYardWhat1,
        menumusic   = gg_snd_audio_music_main_menu_kobolds_catacombs_gather,
        bossmusic   = nil,
        caveambient = nil,
        bossdefeat  = gg_snd_boss_defeated_cheer,
        mumble      = {
            [1]    = gg_snd_mumbling_1,
            [2]    = gg_snd_mumbling_2,
            [3]    = gg_snd_mumbling_3,
            [4]    = gg_snd_mumbling_4,
            [5]    = gg_snd_mumbling_direct,
            [6]    = gg_snd_mumbling_positive,
        },
        goldcoins   = gg_snd_forge_item_shinykeeper,
        eleforge    = gg_snd_forge_item_elementalist,
        questdone   = gg_snd_wow_quest_complete,
        queststart  = gg_snd_wow_quest_start,
        tutorialpop = gg_snd_tutorial_popup,
        panel = { -- panelid
            [1] = { -- char
                close = gg_snd_audio_char_page_close,
                open  = gg_snd_audio_char_page_open,
            },
            [2] = { -- equip
                close = gg_snd_audio_equipment_close,
                open  = gg_snd_audio_equipment_open,
            },
            [3] = { -- inv
                close = gg_snd_audio_inventory_close,
                open  = gg_snd_audio_inventory_open,
            },
            [4] = { -- dig site map
                close = gg_snd_audio_map_open_close,
                open  = gg_snd_audio_char_page_close,
            },
            [5] = { -- mastery
                close = gg_snd_audio_abilities_panel_close,
                open  = gg_snd_audio_abilities_panel_open,
            },
            [6] = { -- abilities
                close = gg_snd_audio_abilities_panel_close,
                open  = gg_snd_audio_abilities_panel_open,
            },
        },
        boss = {
            ['ultimate'] = gg_snd_boss_ability_warning,
            ['N01B'] = { -- slag king
                intro = gg_snd_boss_slag_king_intro,
                basic = gg_snd_boss_slag_king_spell_basic,
                power = gg_snd_boss_slag_king_spell_power,
                channel = gg_snd_boss_slag_king_spell_channel,
            },
            ['N01F'] = { -- marsh mutant
                intro = gg_snd_boss_marsh_mutant_intro,
                basic = gg_snd_boss_marsh_mutant_cast,
                power = gg_snd_boss_marsh_mutant_cast,
                channel = gg_snd_boss_marsh_mutant_cast,
            },
            ['N01H'] = { -- megachomp
                intro = gg_snd_boss_megachomp_ultimate,
                basic = gg_snd_boss_megachomp_basic,
                power = gg_snd_boss_megachomp_power,
                channel = gg_snd_boss_megachomp_basic,
            },
            ['N01J'] = { -- thawed experiment
                intro = gg_snd_boss_thawed_experiment_power,
                basic = gg_snd_boss_thawed_experiment_basic,
                power = gg_snd_boss_thawed_experiment_basic,
                channel = gg_snd_boss_thawed_experiment_channel,
            },
            ['N01R'] = { -- amalgam of greed
                intro = gg_snd_boss_amalgam_greed_intro,
                basic = gg_snd_boss_amalgam_greed_basic,
                power = gg_snd_boss_amalgam_greed_basic,
                channel = gg_snd_boss_amalgam_greed_channel,
            },
        },
        drinkpot = gg_snd_audio_potion_drink,
        openchest = gg_snd_boss_chest_open,
        hoverchest = gg_snd_boss_chest_hover,
        bossintro = gg_snd_boss_intro,
        footsteps = {
            [1] = gg_snd_audio_foostep_1, [2] = gg_snd_audio_foostep_2, [3] = gg_snd_audio_foostep_3, [4] = gg_snd_audio_foostep_4,
            [5] = gg_snd_audio_foostep_5, [6] = gg_snd_audio_foostep_6, [7] = gg_snd_audio_foostep_7, [8] = gg_snd_audio_foostep_8
        },
        portalmerge = gg_snd_BarrelExplosion2,
    }
    TimerStart(NewTimer(), 0, false, function()
        for _,v in ipairs(frameloaderfuncs) do v() end
    end)
end)
