kk = {}
kk.devmode = false -- disable certain features for expediency.


onGlobalInit(function()
    utils.debugfunc(function()
        if ReloadGameCachesFromDisk() then is_single_player = true else is_single_player = false end
        kk.packageinit()
        speak:init()
    end, "onGlobalInit")
end)


function kk.init()
    kk.maxplayers   = 1
    kk.boundstrig   = CreateTrigger()
    kk.dusteff      = speffect:new('Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl')
    kk.ymmudid      = FourCC('n004')
    BlzEnableSelections(true, false) -- disable sel circles.
    SetPlayerState(Player(PLAYER_NEUTRAL_AGGRESSIVE), PLAYER_STATE_GIVES_BOUNTY, 0)
    -- set up eyecandy units:
    local tempg = CreateGroup()
    GroupEnumUnitsInRange(tempg, 16300.0, -16900.00, 3000.0, Condition(function()
        local f = GetFilterUnit()
        if GetOwningPlayer(f) == Player(11) then
            SetUnitInvulnerable(f, true) 
            PauseUnit(f, true)
            if GetUnitTypeId(f) == FourCC('nkot') then -- tunneler
                UnitAddAbility(f, FourCC('A008'))
                IssueImmediateOrderBJ(f, "channel")
            else
                PauseUnit(f,true)
            end
            if GetUnitTypeId(f) == FourCC('n001') then -- shinykeeper
                SetUnitColor(f, GetPlayerColor(Player(4)))
            elseif GetUnitTypeId(f) == FourCC('n002') then -- elementalist
                SetUnitColor(f, GetPlayerColor(Player(3)))
            elseif GetUnitTypeId(f) == FourCC('n000') then -- dig master
                SetUnitColor(f, GetPlayerColor(Player(5)))
            end
        end
        return true
    end))
    DestroyGroup(tempg)
    -- make excavation sites invulnerable:
    EnumDestructablesInRect(gg_rct_expeditionVision, nil, function()
        if GetDestructableTypeId(GetEnumDestructable()) == FourCC('B00A') then
            SetDestructableMaxLife(GetEnumDestructable(), 100000)
            SetDestructableLifePercentBJ(GetEnumDestructable(), 100)
            SetDestructableInvulnerable(GetEnumDestructable(), true)
        end
    end)
    -- catch starting area escapees:
    TriggerRegisterLeaveRectSimple(kk.boundstrig, gg_rct_expeditionVision, nil)
    TriggerAddAction(kk.boundstrig, function()
        local p = utils.unitp()
        if utils.pnum(p) < kk.maxplayers then -- is player
            utils.setxy(GetTriggerUnit(), GetRectCenterX(gg_rct_charspawn), GetRectCenterY(gg_rct_charspawn))
        end
    end)
    -- kobold enter/exit eyecandy:
    expeditionExitTrig = CreateTrigger()
    TriggerRegisterEnterRectSimple(expeditionExitTrig, gg_rct_expeditionExit)
    TriggerAddCondition(expeditionExitTrig, Condition(function() return GetUnitTypeId(GetTriggerUnit()) == FourCC('nkot') end))
    TriggerAddAction(expeditionExitTrig, function()
        kk.dusteff:playu(GetTriggerUnit())
        RemoveUnit(GetTriggerUnit()) end)
    TimerStart(NewTimer(), 4.33, true, function()
        if not map.manager.activemap then
            local unit = utils.unitinrect(gg_rct_expeditionEnter, Player(11), 'nkot')
            kk.dusteff:playu(unit)
            utils.issmoverect(unit, gg_rct_expeditionExit)
            UnitAddAbility(unit, FourCC('Aloc'))
        end
    end)
    -- clear placed preload units:
    local pregrp = g:newbyrect(nil, nil, gg_rct_preloadclear)
    pregrp:completepurge()
    -- visibility:
    pvisvis = {}
    pvigfog = {}
    pvisblk = {}
    pvisscr = {}
    for pnum = 1,kk.maxplayers do
        pvisvis[pnum] = CreateFogModifierRectBJ( true, Player(pnum-1), FOG_OF_WAR_VISIBLE, gg_rct_expeditionVision )
        pvisscr[pnum] = CreateFogModifierRectBJ( true, Player(pnum-1), FOG_OF_WAR_VISIBLE, gg_rct_scorebounds )
        pvisblk[pnum] = CreateFogModifierRectBJ( true, Player(pnum-1), FOG_OF_WAR_MASKED, bj_mapInitialPlayableArea )
        pvigfog[pnum] = CreateFogModifierRectBJ( true, Player(pnum-1), FOG_OF_WAR_FOGGED, bj_mapInitialPlayableArea )
    end
    -- credits:
    kk.creds = CreateQuest()
    QuestSetDescription(kk.creds, kk.bakecreds() )
    QuestSetTitle(kk.creds, "Credits")
    QuestSetIconPath(kk.creds, "ReplaceableTextures\\CommandButtons\\BTNRepair.blp")
    QuestSetRequired(kk.creds, false)
    kk.badges = CreateQuest()
    QuestSetDescription(kk.badges, "Access Badges (J) to view your achievements. This progress is account-wide and will load independent of your character slot." )
    QuestSetTitle(kk.badges, "Badges")
    QuestSetIconPath(kk.badges, "ReplaceableTextures\\CommandButtons\\BTNMedalionOfCourage.blp")
    QuestSetRequired(kk.badges, false)
    kk.author = CreateQuest()
    QuestSetDescription(kk.author, "User interface, systems, component scripts, and map design by Planetary @hiveworkshop.com.|n|nThis map is unprotected and open source.")
    QuestSetTitle(kk.author, "Author")
    QuestSetIconPath(kk.author, "war3mapImported\\icon_planetary_author_credit.blp")
    QuestSetRequired(kk.author, true)
    kk.saving = CreateQuest()
    QuestSetDescription(kk.saving, "You can have up to 4 save slots at any given time. Save your current character by opening the Equipment panel ('V') and clicking the save button in the"
        .." lower left.|n|nYou can only load from the menu. To load a different save, use the restart map option in the options menu ('F10').|n|n"
        .."Save slots will be managed automatically unless you already have 4 files and attempt to save a new character. At that point, a prompt will occur to choose a file to delete."
        .." |n|nIf you wish to have more than 4 save slots at once, navigate to your /CustomMapData directory and cut any desired saves into a sub folder of any name. You may wish to"
        .." rename moved files to keep track of them. You can then drag and drop files between the main /KoboldKingdom directory and the sub folder when you wish to load different"
        .." characters. However, keep in mind that placed file names MUST be 'char1.txt', 'char2.txt', 'char3.txt', or 'char4.txt' in order to properly load."
        .."|n|nNote: items stored in the Item Overflow feature at the bottom of your inventory are NOT saved.")
    QuestSetTitle(kk.saving, "Save/Load")
    QuestSetIconPath(kk.saving, "ReplaceableTextures\\CommandButtons\\BTNTransmute.blp")
    QuestSetRequired(kk.saving, true)
    StopMusicBJ(false)
    -- we want to freeze time but randomseed needs a value, so let time of day cycle:
    TimerStart(NewTimer(), 60.0, true, function() SetTimeOfDay(24.00) end)
    TimerStart(NewTimer(), 1.0, true, function() StopMusicBJ(false) end) -- 1.33 troubleshooting.
end


function kk.bakecreds()
    local str = "Thanks to all those who make great models on The Hive. See official map page @ hiveworkshop.com for asset details."
    for asset,name in pairs(kkcreds) do str = str..name.."|n" end
    return str
end


function kk.packageinit()
    local funcs = {}
    -- *note: careful with reordering this:
    funcs[#funcs+1] = function()   utils.debugfunc(function() utils.init() end,         'utils.init')  end
    funcs[#funcs+1] = function()   utils.debugfunc(function() spell:buildeffects() end, 'buildeffects')end
    funcs[#funcs+1] = function()   utils.debugfunc(function() g:init() end,             'g')           end
    funcs[#funcs+1] = function()   utils.debugfunc(function() missile:init() end,       'missile')     end
    funcs[#funcs+1] = function()   utils.debugfunc(function() kk.init() end,            'kk.init')     end
    funcs[#funcs+1] = function()   utils.debugfunc(function() trg:init() end,           'trg:init')    end
    funcs[#funcs+1] = function()   utils.debugfunc(function() buffy:init() end,         'buffy:init')  end
    funcs[#funcs+1] = function()   utils.debugfunc(function() spell:init() end,         'spell')       end
    funcs[#funcs+1] = function()   utils.debugfunc(function() sync:init() end,          'sync:init')   end
    funcs[#funcs+1] = function()   utils.debugfunc(function() kobold:init() end,        'kobold')      end
    funcs[#funcs+1] = function()   utils.debugfunc(function() dmg:init() end,           'dmg')         end
    funcs[#funcs+1] = function()   utils.debugfunc(function() ability:init() end,       'ability')     end
    funcs[#funcs+1] = function()   utils.debugfunc(function() mastery:init() end,       'mastery')     end
    funcs[#funcs+1] = function()   utils.debugfunc(function() candle:init() end,        'candle')      end
    funcs[#funcs+1] = function()   utils.debugfunc(function() tooltip:init() end,       'tooltip')     end
    funcs[#funcs+1] = function()   utils.debugfunc(function() terrain:init() end,       'terrain')     end
    funcs[#funcs+1] = function()   utils.debugfunc(function() map:init() end,           'map')         end
    funcs[#funcs+1] = function()   utils.debugfunc(function() shrine:init() end,        'shrine')      end
    funcs[#funcs+1] = function()   utils.debugfunc(function() kui:init() end,           'kui')         end -- hotkey:init() runs here.
    for i = 1,#funcs do
       funcs[i]()
    end
    funcs = nil
end


---A simple sync mechanism for using a true randomseed based on os.time().
---This should be called once on init as it is destroyed to free up global namespace.
---Requires: DetectPlayers
function generate_global_randomseed() ---@type function|nil
    local t = CreateTrigger()
    AllCurrentPlayers(function(p)
        BlzTriggerRegisterPlayerSyncEvent(t, p, "seed", false)
    end)
    TriggerAddAction(t, function()
        math.randomseed(math.floor(tonumber(BlzGetTriggerSyncData())))
        DestroyTrigger(t)
    end)
    for id = 0,bj_MAX_PLAYER_SLOTS do
        -- finds the first player in the game:
        if table.has_value(DetectPlayers.player_user_table, id) then
            if GetLocalPlayer() == Player(id) and os and os.time() then
                BlzSendSyncData("seed", tostring(os.time()*2560))
            else
                BlzSendSyncData("seed", tostring(GetTimeOfDay()*2560*2560))
            end
            break
        end
    end
    generate_global_randomseed = nil
end



TimerStart(NewTimer(),0.0,false,function()
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- elapsed init for things that require it.
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
            [7] = { -- badges
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
        shrine = gg_snd_audio_shrine_click,
        footsteps = {
            [1] = gg_snd_audio_foostep_1, [2] = gg_snd_audio_foostep_2, [3] = gg_snd_audio_foostep_3, [4] = gg_snd_audio_foostep_4,
            [5] = gg_snd_audio_foostep_5, [6] = gg_snd_audio_foostep_6, [7] = gg_snd_audio_foostep_7, [8] = gg_snd_audio_foostep_8
        },
        portalmerge = gg_snd_BarrelExplosion2,
        reliccraft = gg_snd_audio_relic_craft,
    }
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- begin UI build
    if not BlzLoadTOCFile('war3mapImported\\CustomFrames.toc') then print("error: main .fdf file failed to load") end
    utils.debugfunc(function() initprojects()           end, "initprojects")
    utils.debugfunc(function() tooltip:bake()           end, "tooltip:bake")
    utils.debugfunc(function() kui:uigen()              end, "kui:uigen")
    utils.debugfunc(function() boss:init()              end, "boss:init")
    utils.debugfunc(function() loot:init()              end, "loot:init")
    utils.debugfunc(function() hotkey:init()            end, "hotkey:init")
    utils.debugfunc(function() hotkey:assignkuipanels() end, "hotkey:assignkuipanels")
    utils.debugfunc(function() kui:hidecmdbtns()        end, "kui:hidecmdbtns")
    utils.debugfunc(function() creature:init()          end, "creature")
    utils.debugfunc(function() elite:init()             end, "elite")
    utils.debugfunc(function() speffect:preload()       end, "speffect:preload")
    utils.debugfunc(function() alert:init()             end, "alert:init")
    utils.debugfunc(function() shop:init()              end, "shop:init")
    utils.debugfunc(function() screenplay:build()       end, "screenplay:build")
    utils.debugfunc(function() quest:init()             end, "quest:init")
    -- scan for files and update character slots on main screen:
    utils.timed(0.33, function()
        utils.playerloop(function(p)
            utils.debugfunc(function()
                kobold.player[p].char = char:new(p)
                if kobold.player[p]:islocal() then
                    kobold.player[p].char:validate_fileslots()
                end
            end, "file validation")
        end)
    end)
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- unblock screen after loading complete:
    utils.fadeblack(false) -- ***note: async; cannot run locally!
    -- misc.
    StopSound(bj_nightAmbientSound, true, true)
    StopSound(bj_dayAmbientSound, true, true)
    VolumeGroupSetVolumeBJ( SOUND_VOLUMEGROUP_AMBIENTSOUNDS, 15 )
    utils.playsoundall(kui.sound.menumusic) -- init menu music.
    BlzChangeMinimapTerrainTex('war3mapImported\\minimap-hub.blp')
    utils.timed(1.0, function()
        if not BlzLoadTOCFile('war3mapImported\\DialogueFrameTOC.toc') then print("error: speak .fdf file failed to load") end
        speak.consolebd    = kui.consolebd
        speak.gameui       = kui.canvas.fh
        speak.customgameui = kui.canvas.game.fh
        utils.debugfunc(function() speak:initframes() end, "speak:initframes")
    end)
    -- not sync-safe; fix editor's fixed seed for test map:
    generate_global_randomseed()
end)
