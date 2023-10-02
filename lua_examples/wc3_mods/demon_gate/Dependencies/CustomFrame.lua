---A simple frame wrapper that converts framehandles into frame objects for easier manipulation.
---@class CustomFrame
---Requires: Total Initialization Lite
CustomFrame = {
    -- class:
    handle = nil,
    x = nil,
    y = nil,
    w = nil,
    h = nil,
    original_w = nil,
    original_h = nil,
    original_x = nil,
    original_y = nil,
    player = nil,
    anchor_handle = nil,
    anchor_origin_fp = nil,
    anchor_target_fp = nil,
    offset_x = nil,
    offset_y = nil,
    anchor_abs_origin_fp = nil,
    anchor_abs_offset_x = nil,
    anchor_abs_offset_y = nil,
    anchor_screen_point = nil,
    anchor_screen_point_fp = nil,
    -- global:
    id = 0,
    parent = nil,
    stack = {},
    timer = CreateTimer(),
    -- events:
    sync_trigs = {},
    event_trigs = {},
}
CustomFrame.abs_points = {
    bottom_left     = {0.0, 0.0},
    bottom          = {0.4, 0.0},
    bottom_right    = {0.8, 0.0},
    right           = {0.8, 0.3},
    top_right       = {0.8, 0.6},
    top             = {0.4, 0.6},
    top_left        = {0.0, 0.6},
    left            = {0.0, 0.3},
    center          = {0.4, 0.3},
}
CustomFrame.__index = CustomFrame


function CustomFrame:new(handle, _w, _h, _x, _y)
    local o = setmetatable({}, CustomFrame)
    o.handle = handle
    o.w, o.h = pixels(_w or 0), pixels(_h or 0)
    o.x, o.y = pixels(_x or 0), pixels(_y or 0)
    o.original_w, o.original_h = o.w, o.h
    self.id = #self.stack+1
    o:reset_size()
    self.stack[o.id] = o
    return o
end


------------------------
--Code Helpers----------
------------------------


FP_TL = FRAMEPOINT_TOPLEFT
FP_T  = FRAMEPOINT_TOP
FP_TR = FRAMEPOINT_TOPRIGHT
FP_L  = FRAMEPOINT_LEFT
FP_C  = FRAMEPOINT_CENTER
FP_R  = FRAMEPOINT_RIGHT
FP_BL = FRAMEPOINT_BOTTOMLEFT
FP_B  = FRAMEPOINT_BOTTOM
FP_BR = FRAMEPOINT_BOTTOMRIGHT


------------------------
--New Frame Types-------
------------------------


---Create a new CustomFrame.
---@param type_name string
---@param w? number
---@param h? number
---@param x? number
---@param y? number
---@return CustomFrame
function CustomFrame:new_frame(type_name, w, h, x, y)
    return self:new(BlzCreateFrame(type_name, self.parent, 0, 0), w, h, x, y)
end


---Create a CustomFrame by type (e.g. "FRAME", "BUTTON", etc.).
---@param type_name string
---@param frame_title string
---@param w? number
---@param h? number
---@param x? number
---@param y? number
---@param _inherit_frame_name? string
---@return CustomFrame
function CustomFrame:new_frame_type(type_name, frame_title, w, h, x, y, _inherit_frame_name)
    return self:new(BlzCreateFrameByType(type_name, frame_title, self.parent, _inherit_frame_name or "", 0), w, h, x, y)
end


---Create a simpleframe by specifying its name as defined in an FDF.
---@param type_name string
---@param w? number
---@param h? number
---@param x? number
---@param y? number
---@return CustomFrame
function CustomFrame:new_frame_simple(type_name, w, h, x, y)
    return self:new(BlzCreateSimpleFrame(type_name, self.parent, 0), w, h, x, y)
end


---Create a new frame and set its points this custom frame. The attached frame's parent becomes the CustomFrame handle.
---@param frame_type string
---@param _inherit_frame_name? string
---@return CustomFrame
function CustomFrame:attach_frame(frame_type, _inherit_frame_name)
    return self:new_frame_type(frame_type, "Attachment_"..tostring(self.id+1), 0, 0, 0, 0, _inherit_frame_name or ""):set_parent(self):set_all_points(self)
end


---Create a button event listener for a target frame which cannot listen for certain events by itself. The function receives the event data as its argument.
---@param event_name string
---@param frame_event frameeventtype
---@param event_data string
---@param func function
---@param _inherit_frame_name? string
function CustomFrame:attach_event_listener(event_name, frame_event, event_data, func, _inherit_frame_name)
    return self:attach_frame("GLUEBUTTON", _inherit_frame_name):register_event(event_name, frame_event, func, event_data)
end


---Create a new parent frame that has an empty texture.
---@param w? number
---@param h? number
---@param x? number
---@param y? number
---@return CustomFrame
function CustomFrame:new_frame_parent(w, h, x, y)
    return self:new(BlzCreateFrameByType("BACKDROP", "Parent_"..tostring(self.id+1), self.parent, "", 0), w, h, x, y)
        :set_texture("UI\\Widgets\\EscMenu\\Human\\blank-background.blp")
end


function CustomFrame:destroy()
    BlzDestroyFrame(self.handle)
    table.remove(self.stack, self.id)
end


------------------------
--Event Functions-------
------------------------


---Registers a sync-safe event for a frame. Uses the sync string native, so it must have a unique event_name.
---@param event_name string -- unique value that determines the event trigger sync.
---@param frame_event frameeventtype -- the frameevent for self.handle to trigger this event (avoid enter and exit events on 1.33+ as it is bugged).
---@param func function -- the function that runs.
---@param _event_data? string|function -- (optional) override the sync string with something to manipulate in the function; functions are inserted into the action context.
---@return CustomFrame
function CustomFrame:register_event(event_name, frame_event, func, _event_data)
    local event_data = _event_data or ("CF_"..event_name)
    if type(event_data) ~= "string" and type(event_data) ~= "function" then
        event_data = tostring(event_data)
    end
    -- register event listener:
    if not CustomFrame.event_trigs[event_name] then
        CustomFrame.event_trigs[event_name] = CreateTrigger()
    end
    TriggerAddAction(CustomFrame.event_trigs[event_name], function()
        if IsLocalTriggerPlayer() and BlzGetTriggerFrame() == self.handle then
            self:apply_focus_fix()
            if type(event_data) == "function" then
                BlzSendSyncData(event_name, event_data())
            else
                BlzSendSyncData(event_name, event_data)
            end
        end
    end)
    BlzTriggerRegisterFrameEvent(CustomFrame.event_trigs[event_name], self.handle, frame_event)
    -- register sync listener:
    if not CustomFrame.sync_trigs[event_name] then
        CustomFrame.sync_trigs[event_name] = CreateTrigger()
        for _,p in pairs(DetectPlayers.player_user_table) do
            BlzTriggerRegisterPlayerSyncEvent(CustomFrame.sync_trigs[event_name], p, event_name, false)
            TriggerAddAction(CustomFrame.sync_trigs[event_name], function()
                local data = BlzGetTriggerSyncData()
                func(data)
            end)
        end
    end
    return self
end


function CustomFrame:enable_event(event_name)
    if self.event_trigs[event_name] then
        EnableTrigger(self.event_trigs[event_name])
        EnableTrigger(self.sync_trigs[event_name])
    end
    return self
end


function CustomFrame:disable_event(event_name)
    if self.event_trigs[event_name] then
        DisableTrigger(self.event_trigs[event_name])
        DisableTrigger(self.sync_trigs[event_name])
    end
    return self
end


---Stops the player's keyboard context from being locked to the frame after a click.
function CustomFrame:apply_focus_fix()
    BlzFrameSetEnable(self.handle, false)
    BlzFrameSetEnable(self.handle, true)
    StopCamera()
end


------------------------
--Class Functions-------
------------------------


function CustomFrame:set_text(text)
    BlzFrameSetText(self.handle, text)
    return self
end


function CustomFrame:set_texture(path)
    self.texture = path
    BlzFrameSetTexture(self.handle, path, 0, true)
    return self
end


function CustomFrame:set_texture_disabled(path, _apply_now)
    self.texture_disabled = path
    if _apply_now then
        BlzFrameSetTexture(self.handle, path, 0, true)
    end
    return self
end


---Set a new parent (supports targeting a framehandle or CustomFrame).
---@param parent_frame framehandle|CustomFrame
---@return CustomFrame
function CustomFrame:set_parent(parent_frame)
    if type(parent_frame) == "table" and parent_frame.__index == CustomFrame then
        self.parent = parent_frame.parent
    else
        self.parent = parent_frame
    end
    return self
end


---Set a frame's owner (manipulation will only happen for this player).
---@param p player
---@return CustomFrame
function CustomFrame:set_owner(p)
    self.player = p
    return self
end


---Show a frame. Will only run locally if this frame has a player owner (self.player).
function CustomFrame:show()
    -- local only:
    if self.player and IsLocalPlayer(self.player) then
        BlzFrameSetVisible(self.handle, true)
        return self
    end
    -- all players:
    BlzFrameSetVisible(self.handle, true)
    return self
end


---Hide a frame. Will only run locally if this frame has a player owner (self.player).
---@return CustomFrame
function CustomFrame:hide()
    -- local only:
    if self.player and IsLocalPlayer(self.player) then
        BlzFrameSetVisible(self.handle, false)
        return self
    end
    -- all players:
    BlzFrameSetVisible(self.handle, false)
    return self
end


---Set initial visibility for a frame.
function CustomFrame:initialize_show(p)
    -- all players:
    BlzFrameSetVisible(self.handle, false)
    -- local only:
    if IsLocalPlayer(p) then
        BlzFrameSetVisible(self.handle, true)
    end
    return self
end


function CustomFrame:enable()
    if self.texture then
        BlzFrameSetTexture(self.handle, self.texture, 0, true)
    end
    BlzFrameSetEnable(self.handle, true)
    return self
end


function CustomFrame:disable()
    if self.texture_disabled then
        BlzFrameSetTexture(self.handle, self.texture_disabled, 0, true)
    end
    BlzFrameSetEnable(self.handle, false)
    return self
end


---Get the X position for a target point on the screen.
---@param screen_point string
---@return number
function CustomFrame:get_abs_x(screen_point)
    return CustomFrame.abs_points[screen_point][1]
end


---Get the X position for a target point on the screen.
---@param screen_point string
---@return number
function CustomFrame:get_abs_y(screen_point)
    return CustomFrame.abs_points[screen_point][2]
end


---Get the X position for a target point on the screen.
---@param screen_point string
---@return number, number
function CustomFrame:get_abs_xy(screen_point)
    return CustomFrame:get_abs_x(screen_point), CustomFrame:get_abs_y(screen_point)
end


---Sets a frame's position relative to another frame.
---@param anchor_handle framehandle -- the target frame.
---@param origin_fp framepointtype -- framepoint to anchor from.
---@param target_fp framepointtype -- framepoint to anchor to.
---@param _x? number -- x offset.
---@param _y? number -- y offset.
---@return CustomFrame
function CustomFrame:anchor_to(anchor_handle, origin_fp, target_fp, _x, _y)
    self.anchor_origin_fp, self.anchor_target_fp = origin_fp, target_fp
    self.offset_x, self.offset_y = pixels(_x or 0), pixels(_y or 0)
    self.anchor_handle = anchor_handle
    self:update_anchor()
    return self
end


---Sets a frame's absolute position relative to the bottom left of the screen.
---@param _fp? framepointtype -- anchor this point (defaults to FRAMEPOINT_CENTER)
---@param _x? number -- x offset.
---@param _y? number -- y offset.
---@return CustomFrame
function CustomFrame:anchor_abs(_fp, _x, _y)
    self.anchor_abs_origin_fp = _fp or FP_C
    self.offset_x, self.offset_y = pixels(_x or 0), pixels(_y or 0)
    self:update_anchor()
    return self
end


---Sets a frame's absolute position relative to a defined point on the screen (CustomFrame.abs_points).
---@param _fp? framepointtype -- anchor this point (defaults to FRAMEPOINT_CENTER).
---@param _screen_point? string -- anchor this screen location (defaults to "center").
---@param _x? number -- x offset.
---@param _y? number -- y offset.
---@return CustomFrame
function CustomFrame:anchor_screen(_fp, _screen_point, _x, _y)
    self.offset_x, self.offset_y = pixels(_x or 0), pixels(_y or 0)
    self.anchor_screen_point = _screen_point or "center"
    self.anchor_screen_point_fp = _fp or FP_C
    self:update_anchor()
    return self
end


---@return CustomFrame
function CustomFrame:update_anchor()
    if self.anchor_origin_fp and self.anchor_target_fp then
        -- anchor to target frame:
        BlzFrameSetPoint(self.handle, self.anchor_target_fp, self.anchor_handle, self.anchor_target_fp, self.offset_x, self.offset_y)
    elseif self.anchor_abs_origin_fp then
        -- anchor to absolute screen position:
        BlzFrameSetAbsPoint(self.handle, self.anchor_abs_origin_fp, self.offset_x, self.offset_y)
    elseif self.anchor_screen_point_fp then
        -- anchor to absolute screen position using screen point calculation:
        local x, y = self.offset_x + self:get_abs_x(self.anchor_screen_point), self.offset_y + self:get_abs_y(self.anchor_screen_point)
        BlzFrameSetAbsPoint(self.handle, self.anchor_screen_point_fp, x, y)
    end
    return self
end


---Set a frame's value (e.g. for status bars).
---@param v integer
---@return CustomFrame
function CustomFrame:value(v)
    BlzFrameSetValue(self.handle, v)
    return self
end


---Set the size of a frame's width and height using a pixel value (default 1440p scale).
---@return CustomFrame
function CustomFrame:set_size(w, h)
    self.w, self.h = pixels(w), pixels(h)
    BlzFrameSetSize(self.handle, self.w, self.h)
    return self
end


---Set the size of a frame's width and height using a pixel value (default 1440p scale).
---@return CustomFrame
function CustomFrame:set_alpha(v)
    BlzFrameSetAlpha(self.handle, math.floor(v))
    return self
end


---Set the size of a frame's width and height using a pixel value (default 1440p scale).
---@return CustomFrame
function CustomFrame:reset_size()
    if self.original_w and self.original_h then
        BlzFrameSetSize(self.handle, self.original_w, self.original_h)
    end
    return self
end


---Set all framepoints of this frame to a target frame.
---@param target_frame framehandle|CustomFrame
---@return CustomFrame
function CustomFrame:set_all_points(target_frame)
    if type(target_frame) == "table" then
        BlzFrameSetAllPoints(self.handle, target_frame.handle)
    else
        BlzFrameSetAllPoints(self.handle, target_frame)
    end
    return self
end


---Clear all framepoints.
---@return CustomFrame
function CustomFrame:clear_all_points()
    BlzFrameClearAllPoints(self.handle)
    return self
end


------------------------
--Other-----------------
------------------------


OnGameStart(function()
    -- fix to ignore aspect ratio limitations:
    CreateLeaderboardBJ(bj_FORCE_ALL_PLAYERS, "title")
    CustomFrame.parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
    -- CustomFrame.parent = BlzGetFrameByName("Leaderboard", 0)
    -- BlzFrameSetSize(CustomFrame.parent, 0, 0)
    BlzFrameSetVisible(BlzGetFrameByName("LeaderboardBackdrop", 0), false)
    BlzFrameSetVisible(BlzGetFrameByName("LeaderboardTitle", 0), false)
end)
