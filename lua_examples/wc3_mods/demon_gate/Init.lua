OnMapInit(function()
    -- globals:
    udg_faction_picker = {}
    for pnum = 1,4 do
        UnitGroup:all_player_units(Player(pnum-1), function(u)
            if GetUnitTypeId(u) == FourCC("h008") then
                udg_faction_picker[pnum] = u
                ShowUnitHide(udg_faction_picker[pnum])
            end
        end)
    end
end)


OnGameStart(function()
    Try(function()
        -- sounds:
        game_sound_effects = {
            end_of_round_win = gg_snd_end_of_round_complete,
            end_of_round_gold = gg_snd_end_of_round_gold,
            end_of_round_whoosh = gg_snd_end_of_round_whoosh,
            game_end_defeat = gg_snd_game_end_defeat,
            game_end_victory = gg_snd_game_end_victory,
        }

        -- global settings constants:
        PLAYER_VOTE_WEIGHT = 1

        -- after-init class settings:
        BoosterController.booster_cameras = {gg_cam_PackSelectionCamP1, gg_cam_PackSelectionCamP2, gg_cam_PackSelectionCamP3, gg_cam_PackSelectionCamP4}

        -- init map:
        SetTimeOfDay(12)
        SuspendTimeOfDay(true)
        FogEnableOff()
        FogMaskEnableOff()
        SetGameSpeed(MAP_SPEED_FASTEST)
        BlzChangeMinimapTerrainTex('black_square.blp')

        -- init players:
        DetectPlayers:get_active_players()
        PlayerController.active_player_count = DetectPlayers.player_count_present
        for _,p in pairs(DetectPlayers.player_user_table) do
            local region_list, chest_list, lever_list = {}, {}, {}
            if p == Player(0) then
                region_list = {gg_rct_ArmyPicker1, gg_rct_ArmyPicker2, gg_rct_ArmyPicker3, gg_rct_ArmyPicker4}
            elseif p == Player(1) then
                region_list = {gg_rct_ArmyPicker5, gg_rct_ArmyPicker6, gg_rct_ArmyPicker7, gg_rct_ArmyPicker8}
            elseif p == Player(2) then
                region_list = {gg_rct_ArmyPicker9, gg_rct_ArmyPicker10, gg_rct_ArmyPicker11, gg_rct_ArmyPicker12}
            elseif p == Player(3) then
                region_list = {gg_rct_ArmyPicker13, gg_rct_ArmyPicker14, gg_rct_ArmyPicker15, gg_rct_ArmyPicker16}
            end
            for _,rect in ipairs(region_list) do
                chest_list[#chest_list+1] = CreateUnit(p, FourCC("h00D"), GetRectCenterX(rect), GetRectCenterY(rect), 270.0) -- chest eyecandy
                lever_list[#lever_list+1] = CreateUnit(p, FourCC("h00C"), GetRectCenterX(rect), GetRectCenterY(rect) - 256.0, 270.0) -- `` lever
            end
            PlayerController:new(p)
            PlayerController:get_player(p).army_controller = ArmyController:new(p)
            PlayerController:get_player(p).army_manager = ArmyManager:new(p)
            PlayerController:get_player(p).booster_controller = BoosterController:new(p, region_list, chest_list, lever_list)
            PlayerController:get_player(p).booster_controller:create_select_trigger()
            PlayerController:get_player(p):set_camera_bounds_to_arena()
        end

        -- leave play area punishment:
        leave_playable_area_trig = CreateTrigger()
        TriggerRegisterLeaveRectSimple(leave_playable_area_trig, gg_rct_PlayableArea)
        TriggerAddAction(leave_playable_area_trig, function()
            if not IsUnitType(GetTriggerUnit(), UNIT_TYPE_FLYING) and GetTerrainType(GetUnitXY(GetTriggerUnit())) == FourCC("Oaby") then
                KillUnit(GetTriggerUnit())
            elseif IsUnitType(GetTriggerUnit(), UNIT_TYPE_FLYING) then
                local ux, uy = GetUnitXY(GetTriggerUnit())
                SetUnitXY(GetTriggerUnit(), ProjectXY(ux, uy, 48.0, AngleFromXY(ux, uy, 0, 0)))
            end
        end)

        -- init minimalist ui:
        mui.Init()

        -- init game mode dialog:
        TimerQueue:call_delayed(0.33, function()
            GameVoting:create_dialog()
        end)
    end)
end)
