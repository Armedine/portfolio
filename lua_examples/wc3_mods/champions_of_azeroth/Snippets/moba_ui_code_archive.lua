-- inactive settings/features (these):
mui_data.barTimer        = {}                            -- a timer that updates the health bar of a unit.
mui_data.barCadence          = 0.33                          -- how fast bars update (higher = performance; lower = entering desync territory).
mui_data.barHeight           = 0.0075                        -- height of health and mana bar.
mui_data.barAlpha            = 125                           -- (0 to 255-based int) transparency of health and mana bar.
mui_data.barHealthTex        = 'Replaceabletextures\\Teamcolor\\Teamcolor00.blp'
mui_data.barManaTex          = 'Replaceabletextures\\Teamcolor\\Teamcolor01.blp'
-- - - - - - - - - - - -

mui_data.resourceBarFrames = {
    [0] = "ResourceBarGoldText",
    [1] = "ResourceBarLumberText",
    [2] = "ResourceBarSupplyText",
    [3] = "ResourceBarUpkeepText"
}

-- inactive due to lack of reliable group focus unit:
-- to make values update past selection, we could do a damage event or run a periodic timer.
function mui.UnitStateBarTimer(pInt)
    mui_data.barTimer[pInt] = NewTimer()
    TimerStart(mui_data.barTimer[pInt],mui_data.barCadence,true,function()
        -- tacky stuff that requires being outside of local player for GroupSelectionMimic to not act weird in multiplayer:
        mui_data.selectedCount[pInt] = mui.UnitSelectedCount(pInt)
        if mui_data.selectedCount[pInt] > 0 then
            mui_data.focusUnit[pInt] = GroupSelectionMimic.getFocusUnit(Player(pInt))
        end
        -- then commence local player:
        if Player(pInt) == GetLocalPlayer() then
            if GetWidgetLife(GetTimerData(mui_data.barTimer[pInt])) > 0.45
              and GetTimerData(mui_data.barTimer[pInt]) ~= nil
              and mui_data.selectedCount[pInt] == 1 then
                mui.UnitStateBarUpdate(pInt, GetTimerData(mui_data.barTimer[pInt]))
            elseif mui_data.selectedCount[pInt] > 1 then
                mui.UnitStateBarUpdate(pInt, mui_data.focusUnit[pInt])
            else
                mui.UnitStateBarCleanse(pInt)
            end
        end
    end)
end



function mui.UnitSelectedCount(pInt)
    local g = CreateGroup()
    local size
    -- this breaks when you are running test map etc., so check if multiplayer:
    if not bj_isSinglePlayer then
        SyncSelections()
    end
    GroupEnumUnitsSelected(g, Player(pInt), Condition( function() return true end))
    size = BlzGroupGetSize(g)
    DestroyGroup(g)
    if size > 0 then
        return size
    else
        return 0
    end
end


function mui.InitUnitSelectedUpdate(pInt)
    local selectTrig = CreateTrigger()
    local player = Player(pInt)
    TriggerRegisterPlayerUnitEvent(selectTrig, player, EVENT_PLAYER_UNIT_SELECTED, nil)
    TriggerAddAction(selectTrig, function()
        -- disabled until get group focus unit is more reliable/possible:
        local count = mui.UnitSelectedCount(pInt)
        if count == 1 then
            mui.UnitStateBarUpdate(pInt, GetTriggerUnit())
        elseif count > 1 then
            mui.UnitStateBarUpdate(pInt, GroupSelectionMimic.getFocusUnit(Player(pInt)))
        else
            mui.UnitStateBarCleanse(pInt)
        end
        mui.UnitPortraitSelection(pInt)

        -- move default hp and mana text:
        -- credit to Tasyen for this snippet. frames exist only when a unit is selected.
        local trig = GetTriggeringTrigger()
        TimerStart(NewTimer(), 0.023, false, function()
            if GetLocalPlayer() == player then
                local fh   = BlzGetOriginFrame(ORIGIN_FRAME_PORTRAIT_HP_TEXT, 0)
                local fh2  = BlzGetOriginFrame(ORIGIN_FRAME_PORTRAIT_MANA_TEXT, 0)
                
                BlzFrameClearAllPoints(fh)
                BlzFrameSetPoint(fh, FRAMEPOINT_CENTER, mui_data.portraitContainer,
                    FRAMEPOINT_CENTER,-(mui_data.portraitSize*2.5),-0.0056)

                BlzFrameClearAllPoints(fh2)
                BlzFrameSetPoint(fh2, FRAMEPOINT_CENTER, mui_data.portraitContainer,
                    FRAMEPOINT_CENTER,mui_data.portraitSize*2.5,-0.0056)
            end
            -- only needs to be initialized once:
            DestroyTrigger(trig)
            ReleaseTimer(GetExpiredTimer())
        end)
    end)
end


-- disabled state bar eye candy until get focus unit is more reliable/possible:
function mui.UnitStateBar(pInt)
    -- create health bar and mana bar:
    local panelHeight = BlzFrameGetHeight(mui_data.infoPanel)
    local panelWidth  = BlzFrameGetWidth(mui_data.infoPanel)
    mui_data.barWidth = panelWidth/2.0 - mui_data.portraitSize
    -- create holding frames:
    mui_data.healthBarFrame = mui.AttachBackdropByHandle(mui_data.infoPanel, 'bar_health_frame',
        mui_data.textureMain, mui_data.barAlpha,
        -(panelWidth*mui_data.unitInfoWidth - mui_data.portraitSize), panelHeight*mui_data.unitInfoHeight,
        mui_data.barWidth, mui_data.barHeight)
    mui_data.manaBarFrame = mui.AttachBackdropByHandle(mui_data.infoPanel, 'bar_mana_frame',
        mui_data.textureMain, mui_data.barAlpha,
        panelWidth*mui_data.unitInfoWidth - mui_data.portraitSize, panelHeight*mui_data.unitInfoHeight,
        panelWidth/2.0 - mui_data.portraitSize, mui_data.barHeight)
    -- actual frame piece that changes in size:
    mui_data.healthBarGraphic = mui.AttachBackdropByHandle(mui_data.infoPanel, 'bar_health_gfx',
        mui_data.barHealthTex, mui_data.barAlpha,
        -(panelWidth*mui_data.unitInfoWidth - mui_data.portraitSize), panelHeight*mui_data.unitInfoHeight,
        mui_data.barWidth, mui_data.barHeight)
    mui_data.manaBarGraphic = mui.AttachBackdropByHandle(mui_data.infoPanel, 'bar_mana_gfx',
        mui_data.barManaTex, mui_data.barAlpha,
        panelWidth*mui_data.unitInfoWidth - mui_data.portraitSize, panelHeight*mui_data.unitInfoHeight,
        panelWidth/2.0 - mui_data.portraitSize, mui_data.barHeight)
    mui_data.healthBarTxt = BlzCreateFrameByType("TEXT", "bar_health_txt", mui_data.healthBarFrame,"", 0)
    mui_data.manaBarTxt = BlzCreateFrameByType("TEXT", "bar_mana_txt", mui_data.manaBarFrame,"", 0)
    -- set up the graphics to scale from left to right using left framepoint:
    BlzFrameClearAllPoints(mui_data.healthBarGraphic)
    BlzFrameClearAllPoints(mui_data.manaBarGraphic)
    BlzFrameSetPoint(mui_data.healthBarGraphic,FRAMEPOINT_LEFT,mui_data.healthBarFrame,FRAMEPOINT_LEFT,0.0,0.0)
    BlzFrameSetPoint(mui_data.manaBarGraphic,FRAMEPOINT_LEFT,mui_data.manaBarFrame,FRAMEPOINT_LEFT,0.0,0.0)
    -- setup health:
    BlzFrameSetText(mui_data.healthBarTxt,' ')
    BlzFrameSetPoint(mui_data.healthBarTxt,FRAMEPOINT_BOTTOM,mui_data.healthBarFrame,FRAMEPOINT_TOP,0,0.0015)
    BlzFrameSetVisible(mui_data.healthBarTxt,true)
    BlzFrameSetAlpha(mui_data.healthBarTxt,255)
    BlzFrameSetTextAlignment(mui_data.healthBarTxt, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
    -- setup mana:
    BlzFrameSetText(mui_data.manaBarTxt,' ')
    BlzFrameSetPoint(mui_data.manaBarTxt,FRAMEPOINT_BOTTOM,mui_data.manaBarFrame,FRAMEPOINT_TOP,0,0.0015)
    BlzFrameSetVisible(mui_data.manaBarTxt,true)
    BlzFrameSetAlpha(mui_data.manaBarTxt,255)
    BlzFrameSetTextAlignment(mui_data.manaBarTxt, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
    --
    mui.UnitStateBarTimer(pInt)
end


-- @u = selected or stored timer unit for health bar.
function mui.UnitStateBarUpdate(pInt, u)
    if Player(pInt) == GetLocalPlayer() then
        -- store the unit that needs to update via the timer:
        SetTimerData(mui_data.barTimer[pInt], u)
        -- update health:
        if not BlzIsUnitInvulnerable(u) then
            BlzFrameSetSize(mui_data.healthBarGraphic, mui_data.barWidth*(GetUnitLifePercent(u)/100), mui_data.barHeight)
            BlzFrameSetText(mui_data.healthBarTxt, math.floor(GetUnitStateSwap(UNIT_STATE_LIFE, u))..'/'..math.floor(GetUnitStateSwap(UNIT_STATE_MAX_LIFE, u)))
            BlzFrameSetAlpha(mui_data.healthBarGraphic, mui_data.barAlpha)
        else
            BlzFrameSetSize(mui_data.healthBarGraphic, 100.0, mui_data.barHeight)
            BlzFrameSetText(mui_data.healthBarTxt, '|cffffc800Invulnerable|r')
            BlzFrameSetAlpha(mui_data.healthBarGraphic, 0)
        end
        -- update mana:
        BlzFrameSetSize(mui_data.manaBarGraphic, mui_data.barWidth*(GetUnitManaPercent(u)/100), mui_data.barHeight)
        if GetUnitStateSwap(UNIT_STATE_MANA, u) > 0.0 then
            BlzFrameSetText(mui_data.manaBarTxt, math.floor(GetUnitStateSwap(UNIT_STATE_MANA, u))..'/'..math.floor(GetUnitStateSwap(UNIT_STATE_MAX_MANA, u)))
            BlzFrameSetAlpha(mui_data.manaBarGraphic, mui_data.barAlpha)
        else
            BlzFrameSetText(mui_data.manaBarTxt, ' ')
            BlzFrameSetSize(mui_data.manaBarGraphic, mui_data.barWidth, mui_data.barHeight)
            BlzFrameSetAlpha(mui_data.manaBarGraphic, 0)
        end
    else
        mui_data.UnitStateBarCleanse(pInt)
    end
end


-- sets the state bars to grey with no value
function mui.UnitStateBarCleanse(pInt)
    if GetLocalPlayer() == Player(pInt) then
        -- health:
        BlzFrameSetText(mui_data.healthBarTxt, ' ')
        BlzFrameSetAlpha(mui_data.healthBarGraphic, 0)
        BlzFrameSetSize(mui_data.healthBarGraphic, mui_data.barWidth, mui_data.barHeight)
        -- mana:
        BlzFrameSetText(mui_data.manaBarTxt, ' ')
        BlzFrameSetAlpha(mui_data.manaBarGraphic, 0)
        BlzFrameSetSize(mui_data.manaBarGraphic, mui_data.barWidth, mui_data.barHeight)
        BlzFrameSetAlpha(mui_data.portraitContainer, 0)
        SetTimerData(mui_data.barTimer[pInt], nil)
    end
end

-- disabled since dealing with lumber, gold, food frames is extremely annoying.
--[[function mui.ResourceBarMove()
    local mfh = BlzGetFrameByName(mui_data.menuButtons[0],0)
    local fh
    BlzFrameClearAllPoints(mui_data.resourceBar)
    -- this should be nudged to the right opposite of the backdrop offset:
    BlzFrameSetPoint(mui_data.resourceBar,FRAMEPOINT_BOTTOMLEFT, mfh, FRAMEPOINT_TOPLEFT, 0.0, BlzFrameGetHeight(mfh)/2)
    BlzFrameSetSize(mui_data.resourceBar, BlzFrameGetWidth(mfh)*4 + mui_data.menuBtnPadding, BlzFrameGetHeight(mfh))
    for i = 0,#mui_data.resourceBarFrames do
        fh = BlzGetFrameByName(mui_data.resourceBarFrames[i],0)
        BlzFrameSetSize(fh, BlzFrameGetWidth(mfh), BlzFrameGetHeight(mfh))
    end
    -- center at top instead:
    --BlzFrameSetAbsPoint(mui_data.resourceBar,FRAMEPOINT_TOP,mui_data.getCenter + -mui_data.resourceBarOffsetX,mui_data.getMaxY - mui_data.screenGutter*0.75)
end--]]


-- show or hide custom made UI elements during a cinematic (be sure to use local player only)
-- @bool = should it be visible? true = visible; false = hide
function mui.ShowHideCustomUI(bool)
    for i = 1,#mui_data.frameStack do
        if mui_data.frameStack[i] ~= nil then
            BlzFrameSetVisible(mui_data.frameStack[i], bool)
        end
    end
    --[[BlzFrameSetVisible(mui_data.healthBarGraphic, bool)
    BlzFrameSetVisible(mui_data.manaBarGraphic, bool)
    BlzFrameSetVisible(mui_data.healthBarFrame, bool)
    BlzFrameSetVisible(mui_data.manaBarFrame, bool)
    BlzFrameSetVisible(mui_data.healthBarTxt, bool)
    BlzFrameSetVisible(mui_data.manaBarTxt, bool)--]]
end



--[[function mui.InitUnitSelectedUpdate()
    local playerSelectTrig = {}
    for pSlot = 0,mui_data.maxPlayers do
        playerSelectTrig[pSlot] = CreateTrigger()
        local trigPlayer = Player(pSlot)
        TriggerRegisterPlayerUnitEvent(playerSelectTrig[pSlot], trigPlayer, EVENT_PLAYER_UNIT_SELECTED, nil)
        TriggerAddAction(playerSelectTrig[pSlot], function()
            TimerStart(NewTimer(), 0.20, false, function()
                mui.MoveUnitStateText(trigPlayer)
                -- only needs to be initialized once:
                DestroyTrigger(playerSelectTrig[pSlot])
                ReleaseTimer()
            end)
        end)
    end
end--]]