-- DetectPlayers by Planetary (hiveworkshop.com): A simple tool to manage past/present player users.
-- Last updated 12 Dec 2022
-- Dependencies: SyncedTable
DetectPlayers = {
    leave_trig = nil,
    -- globals:
    player_count_on_start = 0,              -- users present when the game started.
    player_count_present = 0,               -- dynamic count of present users.
    player_count_left_game = 0,             -- dynamic count of users who left the game.
    player_user_force = CreateForce(),      -- dynamic force of user players.
    player_computer_force = CreateForce(),  -- dynamic force of computer players.
    player_user_table = SyncedTable(),      -- dynamic table of user players.
    player_left_table = SyncedTable(),      -- dynamic table of user players who left the game.
    player_computer_table = SyncedTable(),  -- dynamic table of computer players.
    players_initialized = false,            -- did the system init already? (prevents desyncs)
    -- configurable:
    player_share_on_leave = false,           -- should leaving players share control with allies?
    player_leave_message = "left the game.",-- show this message on leave. (leave empty/nil to disable)
    player_leave_message_dur = 10.          -- `` for this duration.
}
DetectPlayers.__index = DetectPlayers


--[[--------------------------------------------------------------------------------------
    Name: DetectPlayers:get_active_players
    Args: player_function
    Desc: Initializes the class object for active players and allows a return of a player force for all active user players.
----------------------------------------------------------------------------------------]]
---@param player_user_function? function        -- Run this function for present users (passes player as an argument)
---@param player_computer_function? function    -- `` for present computers (passes player as an argument)
---@return force
function DetectPlayers:get_active_players(player_user_function, player_computer_function)
    if not self.players_initialized then
        self.leave_trig = CreateTrigger() -- leave trigger.
        local func = function() -- leave action.
            self.player_count_present = self.player_count_present - 1
            self.player_count_left_game = self.player_count_left_game + 1
            DetectPlayers:run_for_users(function(p)
                DisplayTimedTextToPlayer(p, 0, 0, self.player_leave_message_dur, self.player_leave_message)
            end)
            if self.player_share_on_leave then
                ShareEverythingWithTeam(GetTriggerPlayer())
            end
            table.remove(self.player_user_table, GetPlayerId(GetTriggerPlayer()))
            table.insert(self.player_left_table, GetPlayerId(GetTriggerPlayer()))
        end
        TriggerAddAction(self.leave_trig, func) -- event defined below in player loop.
        for i = 0,bj_MAX_PLAYERS-1 do
            local p = Player(i)
            local id = GetPlayerId(p)
            if GetPlayerController(p) == MAP_CONTROL_USER and GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING then
                self.player_count_present = self.player_count_present + 1
                TriggerRegisterPlayerEvent(self.leave_trig, p, EVENT_PLAYER_LEAVE)
                ForceAddPlayer(self.player_user_force, p)
                self.player_user_table[id] = p
                if player_user_function then
                    player_user_function(p)
                end
            elseif GetPlayerController(p) == MAP_CONTROL_COMPUTER and GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING then
                self.player_computer_table[id] = p
                ForceAddPlayer(self.player_computer_force, p)
                if player_computer_function then
                    player_computer_function(p)
                end
            end
        end
        self.player_count_on_start = self.player_count_present
        self.players_initialized = true
    end
    return self.player_user_force
end


function DetectPlayers:run_for_users(func)
    for pid,_ in pairs(self.player_user_table) do
        func(Player(pid))
    end
end


---Remove a player from the a table object.
---@param p any
function DetectPlayers:remove_player(p)
    if self.player_user_table[GetPlayerId(p)] then
        self.player_user_table[GetPlayerId(p)] = nil
    elseif self.player_computer_table[GetPlayerId(p)] then
        self.player_computer_table[GetPlayerId(p)] = nil
    end
end
