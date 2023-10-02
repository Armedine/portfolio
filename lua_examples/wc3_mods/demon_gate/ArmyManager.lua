---@class ArmyManager
---UI frame that contains army units.
ArmyManager = {
    -- config:
    icon_width = 48,
    icon_height = 48,
    icon_bar_width = 48,
    icon_bar_height = 8,
    icon_padding = 8,
    icon_row_count = 6,
    -- class:
    player = nil,
    parent_frame = nil, ---@type CustomFrame
    unit = nil,
    unit_frames = nil,
    unit_index = nil,
    timer = CreateTimer(),
    stack = {}
}
ArmyManager.__index = ArmyManager


---Create an army manager parent frame for a player that will house unit icons.
---@param p player
function ArmyManager:new(p)
    local o = setmetatable({}, self)
    o.parent_frame = CustomFrame:new_frame_parent(1, 1)
        :anchor_screen(FP_TL, "top_left", 0, -64)
    o.unit_frames = SyncedTable.create()
    o.player = p
    self.stack[GetPlayerId(p)] = o
    return o
end


---Add a unit to a player's Army Manager frame.
---@param u unit
---@return ArmyManager
function ArmyManager:add_unit_frame(u)
    if not IsHero(u) then
        local unit_frame = CustomFrame:new_frame_type("BACKDROP", "unit_"..tostring(GetUnitIndex(u)), self.icon_width, self.icon_height)
            :set_parent(self.parent_frame)
            :anchor_to(self.parent_frame.handle, FP_TL, FP_TL)
        unit_frame:set_texture(ArmyUnit:get_by_id(GetUnitTypeId(u)).icon)
        unit_frame:set_texture_disabled(GetDisabledIcon(ArmyUnit:get_by_id(GetUnitTypeId(u)).icon))
        unit_frame.unit = u
        unit_frame.unit_index = GetUnitIndex(u)
        unit_frame.unit_id = GetUnitTypeId(u)
        local function data_sent()
            return unit_frame.unit_index
        end
        local function data_received(data)
            if self:get_clicked_frame_unit(data) then
                SelectUnitForPlayerSingle(self:get_clicked_frame_unit(data), self.player)
            end
        end
        unit_frame:attach_event_listener("AMC", FRAMEEVENT_CONTROL_CLICK, data_sent, data_received, "IconButtonTemplate")
            :initialize_show(self.player)
        unit_frame.hp_bar = CustomFrame:new_frame_simple("SimpleBarUnitHealth", self.icon_bar_width, self.icon_bar_height)
            :anchor_to(unit_frame.handle, FP_TL, FP_TL, 0, -self.icon_height)
            :initialize_show(self.player)
        unit_frame.mana_bar = CustomFrame:new_frame_simple("SimpleBarUnitMana", self.icon_bar_width, self.icon_bar_height)
            :anchor_to(unit_frame.handle, FP_TL, FP_TL, 0, -self.icon_height - self.icon_bar_height)
            :initialize_show(self.player)
        self.unit_frames[unit_frame.unit_index] = unit_frame
        self:sort_active_frames()
        self:update_unit_frame_state(unit_frame)
        unit_frame:initialize_show(self.player)
    end
    return self
end


function ArmyManager:create_action_buttons()
    local button_frame_heal = CustomFrame:new_frame_type("GLUETEXTBUTTON", frame_title, 228, 38, 0, 0, "ScriptDialogButton")
        :set_parent(self.parent_frame)
        :anchor_to(self.parent_frame.handle, FP_TL, FP_TL)
        :register_event("heal_army", FRAMEEVENT_CONTROL_CLICK, data_received, data_sent)
    button_frame_heal:initialize_show(self.player)
    -- TODO:
    -- disable these during active rounds
end


---Add a unit to a player's Army Manager frame.
---@param u unit
---@return ArmyManager
function ArmyManager:remove_unit_frame(u)
    self:get_unit_frame(u):destroy()
    table.remove(self.unit_frames, GetUnitIndex(u))
    self:sort_active_frames()
    return self
end


---Get a unit by the event index data when an army frame is clicked.
---@param data string
---@return unit
function ArmyManager:get_clicked_frame_unit(data)
    if IsUnitAlive(GetUnitByIndex(math.floor(tonumber(data)))) then
        return GetUnitByIndex(math.floor(tonumber(data)))
    end
end


---Looks for the first dead unit with a frame created and replaces it with a new one.
---@param unit_id integer -- the id to search for.
---@param new_unit unit -- the unit matching @unit_id to initiate replacement with.
function ArmyManager:replace_dead_unit(unit_id, new_unit)
    for _,unit_frame in pairs(self.unit_frames) do
        if unit_frame.unit_id == unit_id and (not unit_frame.unit or not IsUnitAlive(unit_frame.unit)) then
            unit_frame.unit = new_unit
            unit_frame.unit_index = GetUnitIndex(new_unit)
        end
    end
end


function ArmyManager:sort_active_frames()
    local row_count, x, y = 0, 0, 0
    for _,unit_frame in pairs(self.unit_frames) do
        if row_count > 0 then
            x = x + self.icon_padding + self.icon_width
        end
        if row_count == self.icon_row_count then
            x, y = 0, y + self.icon_height + self.icon_padding + self.icon_bar_height*2
            row_count = 0
        end
        unit_frame:anchor_to(self.parent_frame.handle, FP_TL, FP_TL, x, -y)
        row_count = row_count + 1
    end
    return self
end


function ArmyManager:update_unit_frame_state(unit_frame)
    if IsLocalPlayer(self.player) then
        if unit_frame.unit and IsUnitAlive(unit_frame.unit) then
            -- unit_frame:set_alpha(255)
            unit_frame:enable()
            unit_frame.hp_bar:value(math.ceil(GetUnitState(unit_frame.unit, UNIT_STATE_LIFE)/GetUnitState(unit_frame.unit, UNIT_STATE_MAX_LIFE)*100))
            if GetUnitState(unit_frame.unit, UNIT_STATE_MAX_MANA) > 1 then
                unit_frame.mana_bar:value(math.ceil(GetUnitState(unit_frame.unit, UNIT_STATE_MANA)/GetUnitState(unit_frame.unit, UNIT_STATE_MAX_MANA)*100))
                unit_frame.mana_bar:show()
            else
                unit_frame.mana_bar:hide()
            end
        else
            -- unit_frame:set_alpha(125)
            unit_frame:disable()
            unit_frame.hp_bar:value(0)
            unit_frame.mana_bar:value(0)
            unit_frame.mana_bar:hide()
        end
    end
    return self
end


function ArmyManager:update_all_frame_states()
    for _,unit_frame in pairs(self.unit_frames) do
        self:update_unit_frame_state(unit_frame)
    end
    return self
end


---Get a unit frame by its index value (sync-safe).
---@param u unit
---@return CustomFrame
function ArmyManager:get_unit_frame(u)
    return self.unit_frames[GetUnitIndex(u)]
end


function ArmyManager:disable_ui()
    -- TODO: disable other things that we add.
    for _,unit_frame in pairs(self.unit_frames) do
        unit_frame:hide()
        unit_frame.mana_bar:hide()
        unit_frame.hp_bar:hide()
    end
    self.parent_frame:hide()
end


OnGameStart(function()
    TimerQueue:call_echo(0.33, function()
        for id,_ in pairs(DetectPlayers.player_user_table) do
            -- update unit frame states if player is still in the game:
            if not DetectPlayers.player_left_table[id] and PlayerController.player_table[id].army_manager then
                PlayerController.player_table[id].army_manager:update_all_frame_states()
            end
        end
    end)
end)
