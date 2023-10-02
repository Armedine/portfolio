---@class GameController
GameController = {
    -- difficulty:
    difficulty_id = 1,  -- the player-voted difficulty.
    rounds_id = 1,      -- `` round length.
    -- globals:
    demon_player = Player(4),
    round_victory_gold = 100,
    -- dynamic data:
    round_is_active = false,
    rounds_completed = 0,
    voting_is_complete = false,
    game_is_over = false,
    spawned_units_alive = 0,            -- how many units are alive.
    spawned_units_total = 0,            -- total units created by a round.
    spawned_units_table = {},           -- table for interfacing with all living enemy units.
    wave_id_current = 1,                -- current wave number for a round.
    wave_id_maximum = 1,                -- total incoming waves for a round.
    -- player-picked difficulty settings:
    difficulty_name = {
        [1] = "Squire",
        [2] = "Soldier",
        [3] = "Commander"
    },
    round_healing = {
        [1] = 0.10,
        [2] = 0.05,
        [3] = 0.00
    },
    round_booster_fmod = {
        [1] = 3,
        [2] = 3,
        [3] = 3
    },
    player_health = {
        [1] = 1.1,
        [2] = 1.0,
        [3] = 1.0
    },
    difficulty = {
        [1] = 1,
        [2] = 2,
        [3] = 3
    },
    mutators_enabled = {
        [1] = false,
        [2] = true,
        [3] = true
    },
    life_loss_delay = {
        [1] = 12,
        [2] = 8,
        [3] = 5
    },
    player_starting_gold = {
        [1] = 200,
        [2] = 150,
        [3] = 100
    },
    player_starting_army_size = {
        [1] = 26,
        [2] = 21,
        [3] = 11
    },
    player_starting_lives = {
        [1] = 10,
        [2] = 5,
        [3] = 3
    },
    -- player-picked round settings:
    round_count = {
        [1] = 10,
        [2] = 20,
        [3] = 30
    },
    -- players-present difficulty modifiers:
    players_present_health_scaling = {
        [1] = 1.0,
        [2] = 1.1,
        [3] = 1.2,
        [4] = 1.3,
    },
    players_present_damage_scaling = {
        [1] = 1.0,
        [2] = 1.0,
        [3] = 1.1,
        [4] = 1.1,
    },
    players_present_enemy_count_scaling = {
        [1] = 1.0,
        [2] = 1.2,
        [3] = 1.4,
        [4] = 1.6,
    },
    -- match setting strings:
    STRING_VOTE_TITLE = {
        difficulty = "Vote: Difficulty",
        rounds = "Vote: Match Length",
    },
    STRING_DIFFICULTY_NAMES = {
        [1] = "|cff00ff00Squire|r (Beginner)",
        [2] = "|cffd45e19Soldier|r (Standard)",
        [3] = "|cffff0000Commander|r (Challenging)"
    },
    STRING_ROUND_NAMES = {
        [1] = "|cff8080ff10|r (Simple)",
        [2] = "|cffd45e1920|r (Standard)",
        [3] = "|cffff00ff30|r (Epic)",
    },
    STRING_DIFFICULTY_SELECTED = {
        [1] = "|cffffcc00Game Difficulty Selected:|r |cff00ff00Squire|r"
            .."\n - Army units have |cff00ff0010\x25|r bonus health."
            .."\n - Army units restore |cff00ff0010\x25|r health after each round."
            .."\n - Ailments last |cff00ff001|r round."
            .."\n - Demons teleport after |cff00ff0012|r seconds. You lose if |cff00ff0010|r escape."
            .."\n - |cff00ff00No mutators|r.",
        [2] = "|cffffcc00Game Difficulty Selected:|r |cffd45e19Soldier|r"
            .."\n - Army units have standard health."
            .."\n - Army units restore |cff00ff005\x25|r health after each round."
            .."\n - Ailments are |cffff0000permanent|r until cleansed."
            .."\n - Demons teleport after |cffd45e198|r seconds. You lose if |cffd45e195|r escape."
            .."\n - |cffd45e19Occasional|r |cff00ffffmutators|r.",
        [3] = "|cffffcc00Game Difficulty Selected:|r |cffff0000Commander|r"
            .."\n - Army units have standard health."
            .."\n - Army units restore |cffff0000no health|r after each round."
            .."\n - Ailments are |cffff0000permanent|r until cleansed, and are |cffff0000more frequent|r."
            .."\n - The enemy will deploy |cffff0000Siege Weaponry|r more often."
            .."\n - Demons teleport after |cffff00005|r seconds. You lose if |cffff00003|r escape."
            .."\n - |cffff0000Many|r |cff00ffffmutators|r."
    },
    STRING_ROUNDS_SELECTED = {
        [1] = "\n|cffffcc00Round Length Selected:|r |cff8080ff10|r",
        [2] = "\n|cffffcc00Round Length Selected:|r |cffd45e1920|r",
        [3] = "\n|cffffcc00Round Length Selected:|r |cffff00ff30|r"
    },
    STRING_END_OF_ROUND_AWARDS = {
        [1] = {
            [1] = "+|cffffff00100 Gold|r",
            [2] = "+|cff00ff0010\x25|r health restored",
            [3] = "+|cffff2596Reinforcement Booster|r",
        },
        [2] = {
            [1] = "+|cffffff00100 Gold|r",
            [2] = "+|cff00ff005\x25|r health restored",
            [3] = "+|cffff2596Reinforcement Booster|r",
        },
        [3] = {
            [1] = "+|cffffff00100 Gold|r",
            [2] = "",
            [3] = "+|cffff2596Reinforcement Booster|r",
        }
    },
    STRING_END_OF_GAME = {
        defeat = "|cffff2121Defeat!|r You failed to repel the demonic invasion. Your world will be ravaged.",
        victory = "|cff00ff00Victory!|r The demonic forces beyond the mysterious portal have been defeated... for now.",
    },
}
GameController.__index = GameController


---Set up the match based on the player mode votes.
---@param difficulty_id integer
---@param rounds_id integer
function GameController:set_difficulty(difficulty_id, rounds_id)
    if not self.voting_is_complete then
        self.rounds_completed = 0
        self.difficulty_id = difficulty_id
        self.rounds_id = rounds_id
        GameObjective:initialize()
        -- display difficulty information to players:
        DisplayTimedTextAll(self.STRING_DIFFICULTY_SELECTED[difficulty_id], 24)
        DisplayTimedTextAll(self.STRING_ROUNDS_SELECTED[rounds_id], 24)
        -- initialize players:
        AllCurrentPlayers(function(p)
            SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, self.player_starting_gold[difficulty_id])
            -- SetPlayerState(p, PLAYER_STATE_RESOURCE_FOOD_CAP, self.player_starting_army_size[difficulty_id])
        end)
    end
end


function GameController:get_setting(setting)
    if string.find(setting, "players_present_") then
        return self[setting][DetectPlayers.player_count_present]
    else
        return self[setting][self.difficulty_id]
    end
end


function GameController:get_total_rounds()
    return self.round_count[self.rounds_id]
end


function GameController:all_waves_have_spawned()
    return self.wave_id_current == self.wave_id_maximum
end


function GameController:defeat_demonic_unit(u)
    self.spawned_units_alive = self.spawned_units_alive - 1
    self.spawned_units_table[GetUnitUserData(u)] = nil
    self:check_round_state()
end


function GameController:create_wave_debug_timer()
    TimerQueue:call_echo(6.0, function()
        if GameController.round_is_active then
            GameController:check_round_state()
            local g = UnitGroup:new_from_rect(GameController.demon_player, UnitGroup.G_TYPE_ALLY, GetPlayableMapRect())
            g:action(function(u)
                -- if a unit exited or spawned outside of playable bounds, teleport them toward the center:
                if not RectContainsUnit(gg_rct_PlayableArea, u) then
                    local x, y = ProjectXY(GetUnitX(u), GetUnitY(u), math.random(500,800), AngleFromXY(GetUnitX(u), GetUnitY(u), 0, 0))
                    SetUnitXY(u, x, y)
                    IssueOrderAttackMove(u, 0, 1500)
                elseif RectContainsUnit(gg_rct_WaveSpawnPosition1, u)
                    or RectContainsUnit(gg_rct_WaveSpawnPosition2, u)
                    or RectContainsUnit(gg_rct_WaveSpawnPosition3, u)
                    or RectContainsUnit(gg_rct_WaveSpawnPosition4, u) then
                    IssueOrderAttackMove(u, 0, 1500)
                end
            end)
            g:destroy()
        end
    end)
end


function GameController:create_randomseed_timer()
    math.randomseed(GetTimeOfDay())
    self.randomseed_val = 1000000
    TimerQueue:call_echo(0.08, function()
        self.randomseed_val = self.randomseed_val + 1
        self.randomseed_val = math.ceil(self.randomseed_val+self.randomseed_val*math.random())
        if self.randomseed_val > 1000000000 then
            self.randomseed_val = 1000000
        end
    end)
end


function GameController:check_round_state()
    -- ClearTextMessages()
    -- print("Current Wave: "..tostring(GameController.wave_id_current).." of "..tostring(GameController.wave_id_maximum))
    -- print("Units Remaining: "..tostring(GameController.spawned_units_alive))
    -- print("Table Size: "..tostring(table.length(GameController.spawned_units_table)))
    if GameController:all_waves_have_spawned() and not GameController.round_victory_detected and GameController.round_is_active then
        if GameController.spawned_units_alive <= 0 and table.length(GameController.spawned_units_table) == 0 then
            GameController.round_victory_detected = true
            TimerQueue:call_delayed(3.0, function()
                ClearTextMessages()
                RoundController:end_round_victory()
                GameController.round_victory_detected = nil
            end)
        end
    end
    InterfaceController:set_wave_bar_progress()
end


-- Triggers:
OnGameStart(function()
    TimerQueue:call_delayed(0.03, function()
        GameController:create_wave_debug_timer()
        GameController:create_randomseed_timer()
    end)
    GameController.unit_death_trigger = TriggerHelper:new("unit", "death", GameController.demon_player, function()
        if not GameController.game_is_over and GameController.spawned_units_table[GetUnitUserData(GetTriggerUnit())] then
            GameController:defeat_demonic_unit(GetTriggerUnit())
        end
    end)
end)
