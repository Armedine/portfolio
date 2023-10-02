---@class PlayerController
PlayerController = {
    player = nil,                   -- player for this player object.
    player_table = SyncedTable(),   -- table<PlayerId:Player>.
    faction_id = nil,               -- chosen faction.
    hero = nil,                     -- hero unit.
    army_controller = nil,          --- @type ArmyController
    booster_controller = nil,       --- @type BoosterController
    army_manager = nil,             --- @type ArmyManager
    has_picked_hero = false,
    faction_color = nil
}
PlayerController.__index = PlayerController


function PlayerController:new(p)
    local o = setmetatable({}, self)
    o.name = GetPlayerName(p)
    o.player = p
    o.player_number = GetConvertedPlayerId(p)
    o.player_index = GetPlayerId(p)
    o.player_table[o.player_index] = o
    return o
end


function PlayerController:left_game()
    -- TODO: remove or share units, etc.
    DetectPlayers:remove_player(self.player)
    GameVoting:check_votes()
    if udg_faction_picker[GetConvertedPlayerId(self.player)] then
        RemoveUnit(udg_faction_picker[GetConvertedPlayerId(self.player)])
    end
    return self
end


---@param p player
---@return PlayerController
function PlayerController:get_player(p)
    return self.player_table[GetPlayerId(p)]
end


---@return PlayerController
function PlayerController:from_triggering_player()
    return self:get_player(GetTriggerPlayer())
end


---@return PlayerController
function PlayerController:from_triggering_unit()
    return self:get_player(GetTriggerUnitPlayer())
end


---@return PlayerController
function PlayerController:get_faction()
    return FactionController.factions[self.faction_id]
end


---@param unit any
function PlayerController:set_faction_color(unit)
    SetUnitColor(unit, self:get_faction().faction_color)
end


function PlayerController:set_camera_bounds_to_arena()
    SetCameraBoundsToRectForPlayerBJ(self.player, gg_rct_PlayableArea)
end


function PlayerController:set_camera_bounds_to_booster()
    SetCameraBoundsToRectForPlayerBJ(self.player, self.booster_controller.booster_rect)
end


function PlayerController:pan_to_demon_gate()
    PanCameraToForPlayer(self.player, GetRectCenterX(gg_rct_WaveEnterGateRect), GetRectCenterY(gg_rct_WaveEnterGateRect))
end


OnGameStart(function()
    local trig = CreateTrigger()
    for i = 0,3 do
        TriggerRegisterPlayerEventLeave(trig, Player(i))
    end
    TriggerAddAction(trig, function()
        PlayerController.active_player_count = PlayerController.active_player_count - 1
        if PlayerController:get_player(GetTriggerPlayer()) then
            PlayerController:get_player(GetTriggerPlayer()):left_game()
        end
    end)
end)
