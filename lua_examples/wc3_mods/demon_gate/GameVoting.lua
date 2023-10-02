---@class GameVoting
---Creates and controls the difficulty and round length voting dialog menu.
GameVoting = {}
GameVoting.__index = GameVoting


function GameVoting:set_difficulty()
    GameController:set_difficulty(
            table.get_index_by_value(self.dialog_difficulty_votes, math.max(table.unpack(self.dialog_difficulty_votes))),
            table.get_index_by_value(self.dialog_rounds_votes, math.max(table.unpack(self.dialog_rounds_votes)))
        )
    GameController.voting_is_complete = true
end


function GameVoting:check_votes()
    -- if all players voted:
    if not GameController.voting_is_complete and self.dialog_votes_cast >= PlayerController.active_player_count then
        DestroyTrigger(self.dialog_click_rounds_trig.trig)
        DestroyTrigger(self.dialog_click_difficulty_trig.trig)
        self.dialog_votes_cast = 0
        -- initialize map settings:
        TimerQueue:call_delayed(0.33, function()
            AllCurrentPlayers(function(p)
                if udg_faction_picker[GetConvertedPlayerId(p)] then
                    ShowUnit(udg_faction_picker[GetConvertedPlayerId(p)], true)
                    SelectUnitForPlayerSingle(udg_faction_picker[GetConvertedPlayerId(p)], p)
                end
            end)
        end)
        GameVoting:set_difficulty()
        -- initialize round timer and round system:
        RoundController:initialize_game_rounds(function()
            -- if players are afk, re-run difficuly check after first timer and hide dialog:
            GameVoting:set_difficulty()
            AllCurrentPlayers(function(p)
                DialogDisplay(p, self.dialog_difficulty, false)
                DialogDisplay(p, self.dialog_rounds, false)
            end)
        end)
    end
end


function GameVoting:create_dialog()
    GameController.voting_is_complete = false

    self.dialog_votes_cast = 0

    self.dialog_difficulty = DialogCreate()
    self.dialog_difficulty_btn = {}
    self.dialog_difficulty_votes = { [1] = 0, [2] = 0, [3] =  0 }
    DialogSetMessage(self.dialog_difficulty, GameController.STRING_VOTE_TITLE.difficulty)
    self.dialog_difficulty_btn[#self.dialog_difficulty_btn+1] = DialogAddButton(self.dialog_difficulty, GameController.STRING_DIFFICULTY_NAMES[1], 0)
    self.dialog_difficulty_btn[#self.dialog_difficulty_btn+1] = DialogAddButton(self.dialog_difficulty, GameController.STRING_DIFFICULTY_NAMES[2], 0)
    self.dialog_difficulty_btn[#self.dialog_difficulty_btn+1] = DialogAddButton(self.dialog_difficulty, GameController.STRING_DIFFICULTY_NAMES[3], 0)
    ShouldShowDialogAll(self.dialog_difficulty, true)

    self.dialog_rounds = DialogCreate()
    self.dialog_rounds_btn = {}
    self.dialog_rounds_votes = { [1] = 0, [2] = 0, [3] =  0}
    DialogSetMessage(self.dialog_rounds, GameController.STRING_VOTE_TITLE.rounds)
    self.dialog_rounds_btn[#self.dialog_rounds_btn+1] = DialogAddButton(self.dialog_rounds, GameController.STRING_ROUND_NAMES[1], 0)
    self.dialog_rounds_btn[#self.dialog_rounds_btn+1] = DialogAddButton(self.dialog_rounds, GameController.STRING_ROUND_NAMES[2], 0)
    self.dialog_rounds_btn[#self.dialog_rounds_btn+1] = DialogAddButton(self.dialog_rounds, GameController.STRING_ROUND_NAMES[3], 0)
    ShouldShowDialogAll(self.dialog_rounds, false)

    self.dialog_click_rounds_trig = TriggerHelper:new("dialog", "click", self.dialog_rounds)
    self.dialog_click_difficulty_trig = TriggerHelper:new("dialog", "click", self.dialog_difficulty)
    self.dialog_click_difficulty_trig:assign_action(function()
        for i = 1,3 do
            if GetClickedButton() == self.dialog_difficulty_btn[i] then
                -- vote on difficulty.
                DialogDisplay(GetTriggerPlayer(), self.dialog_difficulty, false)
                DialogDisplay(GetTriggerPlayer(), self.dialog_rounds, true)
                self.dialog_difficulty_votes[i] = self.dialog_difficulty_votes[i] + PLAYER_VOTE_WEIGHT
                break
            end
        end
    end)
    self.dialog_click_rounds_trig:assign_action(function()
        for i = 1,3 do
            if GetClickedButton() == self.dialog_rounds_btn[i] then
                -- vote on rounds.
                DialogDisplay(GetTriggerPlayer(), self.dialog_rounds, false)
                self.dialog_rounds_votes[i] = self.dialog_rounds_votes[i] + PLAYER_VOTE_WEIGHT
                self.dialog_votes_cast = self.dialog_votes_cast + 1
                GameVoting:check_votes()
                break
            end
        end
    end)
end
