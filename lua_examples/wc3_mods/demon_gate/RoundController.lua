---@class RoundController
---Controls the difficulty and number of waves in a round.
RoundController = {
    -- round data:
    rounds = {},                -- where all RoundControllers are stored.
    end_of_round_step = 1.75,   -- time between end of round award steps.
    round_award_step = 0,       -- current stage in round award table.
    -- attached wave data:
    waves = nil,                -- WaveControllers that will run this round.
    game_state_type = nil,      -- starter, midgame, endgame (what units will spawn).
    wave_interval = 5.0,        -- time between waves.
    army_power = nil,           -- determines ratio of unit types to maximum unit count.
    wave_count = 1,             -- number of standard minion waves.
    elite_count = 0,            -- `` elite.
    commander_count = 0,        -- `` commander.
    multiplier_health = 1.0,
    multiplier_damage = 1.0,
    -- globals:
    intermission_length = 5.0,  -- time between rounds,
    intermission_timer = nil,   -- timer for round intermission.
}
RoundController.__index = RoundController


---Create a new round.
---@param game_state_type string -- starter, midgame, endgame (determines eligible wave units).
---@param army_power integer -- strength of the entire round.
---@param wave_count integer -- how many standard waves?
---@param elite_count? integer -- `` elite waves? (requires high enough army_power)
---@param commander_count? integer -- `` commander waves? (IGNORES army power!)
---@param wave_interval? number -- `` how fast waves spawn.
---@return RoundController
function RoundController:new(game_state_type, army_power, wave_count, elite_count, commander_count, wave_interval)
    local o = setmetatable({}, self)
    o.waves = {}
    o.game_state_type = game_state_type
    o.army_power = army_power
    o.wave_count = wave_count or self.wave_count
    o.elite_count = elite_count or self.elite_count
    o.commander_count = commander_count or self.commander_count
    o.wave_interval = wave_interval or self.wave_interval
    o:build_waves()
    RoundController.rounds[#self.rounds+1] = o
    return o
end


function RoundController:build_waves()
    local distributed_army_power, distributed_army_power_elite
    local total_army_power_waves = self.wave_count
    if self.elite_count > 0 then
        distributed_army_power = math.ceil(self.army_power/total_army_power_waves*0.75)
        distributed_army_power_elite = distributed_army_power*0.25
    else
        distributed_army_power = math.ceil(self.army_power/total_army_power_waves)
    end
    if self.wave_count > 0 then
        for _ = 1,self.wave_count do
            self.waves[#self.waves+1] = WaveController:new(distributed_army_power, self.multiplier_health, self.multiplier_damage,
                {EnemyGroup:get_random_group("minion", self.game_state_type)})
        end
    end
    if self.elite_count > 0 then
        for _ = 1,self.elite_count do
            self.waves[#self.waves+1] = WaveController:new(distributed_army_power_elite, self.multiplier_health, self.multiplier_damage,
                {EnemyGroup:get_random_group("elite", self.game_state_type)})
        end
    end
    if self.commander_count > 0 then
        for _ = 1,self.commander_count do
            self.waves[#self.waves+1] = WaveController:new(1, self.multiplier_health, self.multiplier_damage,
                {EnemyGroup:get_random_group("commander", self.game_state_type)})
        end
    end
end


---Increase the attack damage and health of units for a round.
---@param multiplier_health number -- 1.0-based multiplier for spawned unit health.
---@param multiplier_damage number -- `` damage.
function RoundController:set_unit_scaling(multiplier_health, multiplier_damage)
    -- Not yet implemented.
    self.multiplier_health = multiplier_health or self.multiplier_health
    self.multiplier_damage = multiplier_damage or self.multiplier_damage
    return self
end


---@return RoundController
function RoundController:get_next_round()
    return self.rounds[GameController.rounds_completed + 1]
end


---Initiate timers for enemy waves, determine spawn locations, determine mutators.
function RoundController:start_round()
    if not GameController.game_is_over then
        InterfaceController:show_progress_bars(true)
        GameController.spawned_units_total = 0
        GameController.spawned_units_alive = 0
        GameController.round_is_active = true
        GameController.wave_id_maximum = self.wave_count + self.elite_count + self.commander_count
        GameController.wave_id_current = 0
        -- TODO: Make players vulnerable
        for wave_id = 1,GameController.wave_id_maximum do
            if wave_id == 1 then
                -- initial wave (don't delay):
                self.waves[1]:start_wave(1, self.wave_count)
            else
                -- following waves:
                TimerQueue:call_delayed(wave_id*self.wave_interval, function()
                    self.waves[wave_id]:start_wave(wave_id, self.wave_count)
                end)
            end
        end
    end
end


function RoundController:end_round_victory()
    if not GameController.game_is_over then
        InterfaceController:show_progress_bars(false)
        InterfaceController.bar_wave_progress:value(100) -- stops refill on show.
        GameController.rounds_completed = GameController.rounds_completed + 1
        GameController.round_is_active = false
        GameObjective:check_rounds_completed()
        DisplayTimedTextAll("Round "..tostring(GameController.rounds_completed).." Complete!", 3.0)
        PlaySoundForAllPlayers(game_sound_effects.end_of_round_win)
        self:end_of_round_awards()
        TimerQueue:call_delayed(table.length(self.end_of_round_effect_table)*self.end_of_round_step + self.end_of_round_step, function()
            if not GameController.game_is_over then
                RoundController:intermission()
            end
        end)
    end
end


---Queues a timer before the next round starts and places Requisition shops.
---@param _end_of_intermission_func? function -- run a function at the end of the timer.
---@param _timer_title_text? string -- countdown timer title override.
function RoundController:intermission(_end_of_intermission_func, _timer_title_text)
    -- TODO: show requisition shops.
    FactionController:show_faction_pickers(true)
    self.intermission_timer = CreateCountdownTimer(self.intermission_length, _timer_title_text or ("|cff00ff00Round "..(GameController.rounds_completed+1).."|r"), function()
        Try(function()
            if not GameController.game_is_over then
                RoundController:get_next_round():start_round()
                FactionController:show_faction_pickers(false)
                -- TODO: hide requisition shops.
                if _end_of_intermission_func then _end_of_intermission_func() end
            end
        end)
    end)
end


function RoundController:end_round_defeat()
    -- ? : do we end the game on a single round loss?
    -- ? : should we do a 3-strike system for # of units entering the portal? progress bar that tracks entries, another with each strike so far?
    -- TODO: Kill player units then run defeat screen.
    GameController.round_is_active = false
    GameController.game_is_over = true
    DisableTrigger(GameController.unit_death_trigger)
end


function RoundController:initialize_end_of_round_awards()
    self.end_of_round_effect_table = {
        [1] = function()
            DisplayTimedTextAll(GameController.STRING_END_OF_ROUND_AWARDS[GameController.difficulty_id][1], self.end_of_round_step)
            PlaySoundForAllPlayers(game_sound_effects.end_of_round_gold)
            AllCurrentPlayers(function(p)
                AdjustPlayerStateBJ(GameController.round_victory_gold, p, PLAYER_STATE_RESOURCE_GOLD)
                AdjustPlayerStateBJ(1, p, PLAYER_STATE_RESOURCE_LUMBER)
        end)
    end,
        [2] = function()
            if GameController:get_setting("round_healing") > 0 then
                DisplayTimedTextAll(GameController.STRING_END_OF_ROUND_AWARDS[GameController.difficulty_id][2], self.end_of_round_step)
                PlaySoundForAllPlayers(game_sound_effects.end_of_round_whoosh)
                AllCurrentPlayers(function(p)
                    PlayerController:get_player(p).army_controller:heal_all_units(GameController:get_setting("round_healing"), NewEffect["holy_light"])
                end)
            else
                self:skip_round_award()
            end
        end,
        [3] = function()
            if math.fmod(GameController.rounds_completed, GameController:get_setting("round_booster_fmod")) == 0 then
                DisplayTimedTextAll(GameController.STRING_END_OF_ROUND_AWARDS[GameController.difficulty_id][3], self.end_of_round_step)
                TimerQueue:call_delayed(1.33, function()
                    AllCurrentPlayers(function(p)
                        PlayerController:get_player(p).booster_controller:run_booster_select_screen()
                    end)
                end)
            else
                self:skip_round_award()
            end
        end,
    }
end


function RoundController:skip_round_award()
    self.round_award_step = self.round_award_step + 1
    self:run_round_award()
end


function RoundController:run_round_award()
    if self.end_of_round_effect_table[self.round_award_step] then
        self.end_of_round_effect_table[self.round_award_step]()
    end
end


function RoundController:end_of_round_awards()
    self.round_award_step = 0
    TimerQueue:call_echo(1.0, function()
        if not GameController.game_is_over then
            self.round_award_step = self.round_award_step + 1
            self:run_round_award()
            if GameController.game_is_over or self.round_award_step >= table.length(self.end_of_round_effect_table) then
                return true
            end
        end
    end)
end


---Set up end of round award functions.
---@param round_start_func function --run this function when the first round timer ends.
function RoundController:initialize_game_rounds(round_start_func)
    self:initialize_end_of_round_awards()
    self:intermission(round_start_func, "|cff00ff00Round 1|r")
end
