---A minimalist UI that reduces screen clutter so players can focus on the game world.
---Requires: DetectPlayers
-- - - - - - - - - - - -
local mui                    = {}
local mui_data               = {}
-- - - - - - - - - - - -
mui_data.frameStack          = {}                            -- where custom frames are kept for reference.
-- - - - - - - - - - - -
mui_data.portraitSize        = 0.0225                        -- height and width.
-- - - - - - - - - - - -
mui_data.consoleUIOffsetY    = -0.24                         -- pushes the console UI originframe down.
mui_data.infoPanelOffsetX    = 0.4                           -- offset from left of screen.
mui_data.infoPanelOffsetY    = 0.00325                       -- offset from bottom of screen.
mui_data.infoPanelGutterY    = 0.004                         -- nudges the backdrop up for edge alignment.
mui_data.resourceBarOffsetX  = -0.004                        -- moves backdrop left and right
mui_data.resourceBarOffsetY  = -0.0005                       -- moves backdrop up and down.
-- - - - - - - - - - - -
mui_data.inventoryTxtAlpha   = 225                           -- 'Inventory' over the inv. pane. 
mui_data.backdropAlpha       = 130                           -- (0 to 255-based int) set alpha for floating UI elements (default = ~51%).
mui_data.txtColor            = '|cffffffff'
mui_data.screenGutter        = mui_data.infoPanelGutterY + mui_data.infoPanelOffsetY
mui_data.textureMain         = 'black_square.blp'
-- - - - - - - - - - - -
--[[
    original command bar matrix (reference):
    row1:   | 0| | 1| | 2| | 3|
    row2:   | 4| | 5| | 6| | 7|
    row3:   | 8| | 9| |10| |11|   

    default mui command bar matrix (reference):
    top:    | 0| | 1| | 2| | 3| | 4| | 5|
    bot:    | 8| | 9| |10| |11| | 6| | 7|
--]]
-- - - - - - - - - - - -

-- iterate through command buttons:
mui_data.commandBarMap = {
    [0] = "CommandButton_0",
    [1] = "CommandButton_1",
    [2] = "CommandButton_2",
    [3] = "CommandButton_3",
    [4] = "CommandButton_4",
    [5] = "CommandButton_5",
    [6] = "CommandButton_6",
    [7] = "CommandButton_7",
    [8] = "CommandButton_8",
    [9] = "CommandButton_9",
    [10] = "CommandButton_10",
    [11] = "CommandButton_11",
}

-- unhide desired components:
mui_data.unhideFramesByName = {
    [0] = "MiniMapFrame",
    [1] = "Multiboard",
    [2] = "UpperButtonBarFrame",
    [3] = "SimpleUnitStatsPanel",
    [4] = "SimpleHeroLevelBar",
    [5] = "ResourceBarFrame",
    [6] = "MinimapButtonBar"
}

mui_data.minimapButtons = {
    [0] = "FormationButton",
    [1] = "MiniMapCreepButton",
    [2] = "MiniMapAllyButton",
    [3] = "MiniMapTerrainButton",
    [4] = "MinimapSignalButton"
}

mui_data.inventoryButtons = {
    [0] = "InventoryButton_0",
    [1] = "InventoryButton_1",
    [2] = "InventoryButton_2",
    [3] = "InventoryButton_3",
    [4] = "InventoryButton_4",
    [5] = "InventoryButton_5"
}

mui_data.menuButtons = {
    [0] = "UpperButtonBarQuestsButton",
    [1] = "UpperButtonBarMenuButton",
    [2] = "UpperButtonBarAlliesButton",
    [3] = "UpperButtonBarChatButton"
}

-- rearrange originframes that were moved off screen:
mui_data.consoleFrames = {
    [0] = { frame = ORIGIN_FRAME_UNIT_MSG, x = 0.0, y = 0.2},
}


function mui.Init()
    CinematicModeBJ(true, GetPlayersAll())
    for pInt = 0,bj_MAX_PLAYERS do

        if Player(pInt) == GetLocalPlayer() then

            -- temporary framehandle variable for multiple lookups + readability:
            local fh

            -- will stop the moving of frames when changing resolution or window mode when set to false:
            BlzEnableUIAutoPosition(false)

            -- move undesired items off screen:
            -- BlzFrameSetAbsPoint(BlzGetFrameByName("ConsoleUI", 0), FRAMEPOINT_BOTTOM, 0.0, mui_data.consoleUIOffsetY)

            -- fetch items we use repeatedly:
            mui_data.gameUI       = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI,0)
            mui_data.portrait     = BlzGetOriginFrame(ORIGIN_FRAME_PORTRAIT,0)
            mui_data.chatMsg      = BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG,0)
            mui_data.infoPanel    = BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail",0))
            mui_data.minimap      = BlzGetFrameByName("MiniMapFrame",0)
            mui_data.minimapBar   = BlzGetFrameByName("MinimapButtonBar",0)
            mui_data.resourceBar  = BlzGetFrameByName("ResourceBarFrame",0)
            mui_data.inventoryTxt = BlzGetFrameByName("InventoryText", 0)

            -- reposition items move after nudging ConsoleUI off screen:
            for i = 0,#mui_data.consoleFrames do
                fh = BlzGetOriginFrame(mui_data.consoleFrames[i].frame,0)
                BlzFrameClearAllPoints(fh)
                BlzFrameSetAbsPoint(fh,FRAMEPOINT_BOTTOMLEFT,mui_data.consoleFrames[i].x,mui_data.consoleFrames[i].y + mui_data.screenGutter)
            end
            fh = BlzGetFrameByName("MiniMapFrame",0)
            BlzFrameClearAllPoints(fh)
            BlzFrameSetAbsPoint(fh, FRAMEPOINT_BOTTOMLEFT, 0.0, 0.0 + mui_data.screenGutter)
            BlzFrameClearAllPoints(mui_data.chatMsg)
            -- for some reason the chat frame ignores x offset:
            BlzFrameSetPoint(mui_data.chatMsg, FRAMEPOINT_BOTTOMLEFT, mui_data.minimap, FRAMEPOINT_TOPLEFT, 0.0, 0.0)
            BlzFrameSetSize(mui_data.chatMsg, 0.5, 0.2)

            -- unhide:
            for i = 0,#mui_data.unhideFramesByName do
                BlzFrameSetVisible(BlzGetFrameByName(mui_data.unhideFramesByName[i],0), true)
            end
            for i = 0,#mui_data.inventoryButtons do
                BlzFrameSetVisible(BlzGetFrameByName(mui_data.inventoryButtons[i],0), true)
            end
            for i = 0,#mui_data.menuButtons do
                BlzFrameSetVisible(BlzGetFrameByName(mui_data.menuButtons[i],0), true)
            end

            -- hide:
            BlzFrameSetVisible(BlzGetFrameByName("ConsoleUIBackdrop",0), false)
            BlzFrameSetVisible(BlzFrameGetParent(BlzGetFrameByName("ResourceBarFrame",0)), false)

            -- unhide specific frames:
            for i = 0,4 do
                BlzFrameSetVisible(BlzGetOriginFrame(ORIGIN_FRAME_MINIMAP_BUTTON,i), true)
            end
            BlzFrameSetVisible(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BAR,0), true)
            BlzFrameSetVisible(mui_data.infoPanel,true)

            -- cover cannot be hidden, has to be made 100% transparent:
            fh = BlzGetFrameByName("SimpleInventoryCover", 0)
            BlzFrameSetAlpha(fh, 0)
            BlzFrameSetAbsPoint(fh, FRAMEPOINT_BOTTOMLEFT, 1.0,1.0)

            -- set custom transparencies:
            BlzFrameSetAlpha(mui_data.inventoryTxt, mui_data.inventoryTxtAlpha)

            -- set custom text overrides:
            BlzFrameSetText(mui_data.inventoryTxt, mui_data.txtColor .. 'Inventory|r')

            -- menu button backdrops:
            for i = 0,#mui_data.menuButtons do
                fh = BlzGetFrameByName(mui_data.menuButtons[i],0)
                BlzFrameSetTexture(fh, mui_data.textureMain, 0, true)
                BlzFrameSetAlpha(fh, 0.0)
                mui_data.frameStack[#mui_data.frameStack + 1] = mui.AttachBackdropByHandle(fh,'menu_bd_'..i,
                    mui_data.textureMain, mui_data.backdropAlpha, 0.0, 0.0)
            end

            -- command bar backdrops:
            for i = 0,11 do
                mui_data.frameStack[#mui_data.frameStack + 1] = mui.AttachBackdropByHandle(
                    BlzGetFrameByName(mui_data.commandBarMap[i], 0
                ), 'cmd_bd_'..tostring(i), mui_data.textureMain, mui_data.backdropAlpha)
            end

            -- create custom frames, assign stored index for future manipulation:
            mui_data.frameStack[#mui_data.frameStack + 1] = mui.AttachBackdropByHandle(mui_data.minimap,'minimap_bd',mui_data.textureMain)
            mui_data.frameStack[#mui_data.frameStack + 1] = mui.AttachBackdropByHandle(mui_data.infoPanel,
                'unitinfo_bd',mui_data.textureMain,mui_data.backdropAlpha,nil,mui_data.infoPanelGutterY)
            for i = 0,5 do
                mui_data.frameStack[#mui_data.frameStack + 1] = mui.AttachBackdropByHandle(BlzGetFrameByName("InventoryButton_"..i,0),
                    'inv_bd_'..i,mui_data.textureMain,mui_data.backdropAlpha)
            end
            for i = 0,4 do
                mui_data.frameStack[#mui_data.frameStack + 1] = mui.AttachBackdropByHandle(BlzGetFrameByName(mui_data.minimapButtons[i],0),
                    'minimapbar_bd_'..i,mui_data.textureMain,mui_data.backdropAlpha)
            end

            mui_data.frameStack[#mui_data.frameStack + 1] = mui.AttachBackdropByHandle(mui_data.resourceBar,'resourcebar_bd',
                mui_data.textureMain,mui_data.backdropAlpha, mui_data.resourceBarOffsetX, mui_data.resourceBarOffsetY)

        end
    end
    -- keep outside of local player to stop desyncs:
    mui.InitUnitSelectedUpdate()
end


-- we have to do some janky stuff here to allow hp/text bars to update.
-- the short version of it is:
--   a) the unit selected needs to be present for all players or it can desync. we make one for each player so they are guaranteed to have visibility of it.
--   b) there is a few frames of delay between hp/mana text becoming enabled. trying to move it too early can cause a client crash.
function mui.InitUnitSelectedUpdate()
    for pSlot = 0,bj_MAX_PLAYERS-1 do
        local player, t1, t2 = Player(pSlot), CreateTimer(), CreateTimer()
        TimerStart(t1, 0.1, false, function()
            local u = CreateUnit(player, FourCC('hfoo'),0.0,0.0,270.0)
            PauseUnit(u,true)
            SelectUnit(u, false)
            SetUnitVertexColorBJ(u, 0, 0, 0, 100)
            TimerStart(t2, 0.09, false, function()
                local fh   = BlzGetOriginFrame(ORIGIN_FRAME_PORTRAIT_HP_TEXT, 0)
                local fh2  = BlzGetOriginFrame(ORIGIN_FRAME_PORTRAIT_MANA_TEXT, 0)
                mui_data.frameStack[#mui_data.frameStack + 1] = mui.AttachBackdropByHandle(fh, 'hp_bg', mui_data.textureMain, mui_data.backdropAlpha, 0.00121, 0)
                mui_data.frameStack[#mui_data.frameStack + 1] = mui.AttachBackdropByHandle(fh2, 'mana_bg', mui_data.textureMain, mui_data.backdropAlpha, 0.00121, 0)
                RemoveUnit(u)
                mui.initialized = true
                CinematicModeBJ(false, GetPlayersAll())
                DestroyTimer(t2)
            end)
            DestroyTimer(t1)
        end)
    end
end


-- must be run after a cinematic or hero portrait resets position:
function mui.AfterCinematic()
    BlzFrameSetVisible(BlzGetFrameByName("ConsoleUIBackdrop",0), false)
    BlzFrameSetVisible(BlzGetFrameByName("CinematicPortrait",0), false)
    BlzFrameSetAlpha(BlzGetFrameByName("SimpleInventoryCover", 0), 0)
    BlzFrameSetAbsPoint(BlzGetFrameByName("SimpleInventoryCover", 0), FRAMEPOINT_BOTTOMLEFT, 1.0,1.0)
    BlzFrameSetAbsPoint(mui_data.chatMsg,FRAMEPOINT_BOTTOMLEFT,0.15,0.20)
end


-- create a backdrop and set it to be positioned at the desired frame via FRAMEPOINT_CENTER.
-- @fh = target this frame
-- @newFrameNameString = enter a custom value to manipulate backdrop by name if needed e.g. "myInventoryBackdrop"
-- @texturePathString = [optional; usually needed] texture (.blp) as the background
-- @alphaValue = [optional] if the backdrop should be transparent, pass in a value 0-255
-- @offsetx = [optional] nudge the frame left or right (percentage of screen)
-- @offsety = [optional] nudge the frame up or down (percentage of screen)
-- @width, @height = [optional] override the frame size
-- :: returns framehandle
function mui.AttachBackdropByHandle(fh, newFrameNameString, texturePathString, alphaValue, offsetx, offsety, width, height)
    local nh = BlzCreateFrameByType("BACKDROP", newFrameNameString, BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0), "", 0)
    local x = offsetx or 0.0
    local y = offsety or 0.0
    local w = width or BlzFrameGetWidth(fh)
    local h = height or BlzFrameGetHeight(fh)
    BlzFrameSetSize(nh, w, h)
    BlzFrameSetPoint(nh, FRAMEPOINT_CENTER, fh, FRAMEPOINT_CENTER, 0.0 + x, 0.0 + y)
    if texturePathString then
        BlzFrameSetTexture(nh, texturePathString, 0, true)
    end
    BlzFrameSetLevel(nh, 0)
    if alphaValue then 
        BlzFrameSetAlpha(nh, math.ceil(alphaValue))
    end
    return nh
end


-- show or hide custom made UI elements during a cinematic (be sure to use local player only)
-- @bool = should it be visible? true = visible; false = hide
function mui.ShowHideCustomUI(bool)
    for i = 1,#mui_data.frameStack do
        if mui_data.frameStack[i] ~= nil then
            BlzFrameSetVisible(mui_data.frameStack[i], bool)
        end
    end
end
