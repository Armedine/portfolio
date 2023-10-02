---@class GameObjective
---Listens for win/lose conditions and controls the objective game state.
GameObjective = {
    lives_total = 0,
    lives_current = 0,
}
GameObjective.__index = GameObjective


function GameObjective:initialize()
    self.lives_current = GameController:get_setting("player_starting_lives")
    self.lives_total = GameController:get_setting("player_starting_lives")
    InterfaceController:set_lives_bar_progress()
    return self
end


function GameObjective:check_rounds_completed()
    if GameController.rounds_completed >= GameController:get_total_rounds() then
        self:end_game(true)
    end
end


function GameObjective:threaten_player_life(u)
    if not IsHero(u) then
        TimerQueue:call_delayed(math.random(1,3), function()
            PauseUnit(u, true)
            SetUnitAnimation(u, "stand ready")
            BlzSetSpecialEffectScale(
                NewEffect["void_rift"]:attach_to_unit(u, "origin", GameController:get_setting("life_loss_delay")),
                0.6
            )
            TimerQueue:call_delayed(GameController:get_setting("life_loss_delay"), function()
                if u and IsUnitAlive(u) then
                    NewEffect["undead_dissipate"]:play_at_unit(u)
                    RemoveUnit(u)
                    self:modify_lives(-1)
                    GameController:defeat_demonic_unit(u)
                end
            end)
        end)
    end
end


function GameObjective:modify_lives(value)
    self.lives_current = self.lives_current + value
    InterfaceController:set_lives_bar_progress()
    if self.lives_current <= 0 then
        self:end_game(false)
    end
    return self
end


function GameObjective:end_game(is_victory)
    if not GameController.game_is_over then
        ClearTextMessages()
        GameController.game_is_over = true
        local snd, anim, game_string
        local end_game_pan_duration = 10.0
        if is_victory then
            --win:
            game_string = GameController.STRING_END_OF_GAME.victory
            snd = "game_end_victory"
            anim = "stand victory"
            UnitGroup:all_player_units(GameController.demon_player, function(u)
                KillUnit(u)
            end)
        else
            --defeat:
            game_string = GameController.STRING_END_OF_GAME.defeat
            snd = "game_end_defeat"
            anim = "stand"
        end
        PlaySoundForAllPlayers(game_sound_effects[snd])
        AllCurrentPlayers(function(p)
            ForLocalPlayer(p, function() BlzHideOriginFrames(true) mui.ShowHideCustomUI(true) end)
            -- camera effect:
            CameraSetupApplyForPlayer(true, gg_cam_GameEndCam1, p, 1.0)
            TimerQueue:call_delayed(1.0, function()
                CameraSetupApplyForPlayerSmooth(true, gg_cam_GameEndCam2, p, end_game_pan_duration, 1, 2, 1)
            end)
            -- wrap-up:
            PlayerController:get_player(p).army_manager:disable_ui()
            InterfaceController:hide_all()
            UnitGroup:all_player_units(p, function(u)
                PauseUnit(u, true)
                SetUnitAnimation(u, anim)
                SetUnitInvulnerable(u, is_victory)
            end)
        end)
        TimerQueue:call_delayed(1.0, function()
            -- delayed effects:
            DisplayTimedTextAll(game_string, 999.0)
            TimerQueue:call_delayed(end_game_pan_duration, function()
                -- end current wc3 game:
                AllCurrentPlayers(function(p)
                    ForLocalPlayer(p, function() BlzHideOriginFrames(false) mui.ShowHideCustomUI(false) end)
                    if is_victory then
                        CustomVictoryBJ(p, true, true)
                    else
                        CustomDefeatBJ(p, "Defeat")
                    end
                end)
            end)
        end)
    end
end


OnGameStart(function()
    GameObjective.invasion_trig = TriggerHelper:new("enter_rect", "any", gg_rct_WaveEnterGateRect, function()
        if GetTriggerUnitPlayer() == GameController.demon_player then
            GameObjective:threaten_player_life(GetTriggerUnit())
        end
    end)
end)
