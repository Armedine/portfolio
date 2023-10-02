function AddFrameEvent(target_fh, func, frameeventtype)
    local trig = CreateTrigger()
    local target_fh = target_fh
    BlzTriggerRegisterFrameEvent(trig, target_fh, frameeventtype)
    TriggerAddCondition(trig, Condition(function()
        return BlzGetTriggerFrameEvent() == frameeventtype and BlzGetTriggerFrame() == target_fh
    end) )
    TriggerAddAction(trig, func)
    return trig
end

do
    local real = MarkGameStarted
 function MarkGameStarted()
    real()

    if not BlzLoadTOCFile('war3mapImported\\CustomFrameTOC.toc') then print("error: main .fdf file failed to load") end
    -- ignore 4:3 aspect ratio limit:
    CreateLeaderboardBJ(bj_FORCE_ALL_PLAYERS, " ")
    local ignore_aspect_parent = BlzGetFrameByName("Leaderboard", 0)
    BlzFrameSetSize(ignore_aspect_parent, 0, 0)
    BlzFrameSetVisible(BlzGetFrameByName("LeaderboardBackdrop", 0), false)
    BlzFrameSetVisible(BlzGetFrameByName("LeaderboardTitle", 0), false)

    -- backdrop:
    local menu_main_background = BlzCreateFrameByType("BACKDROP", "item1", ignore_aspect_parent, "EscMenuBackdrop", 0)
    BlzFrameSetAbsPoint(menu_main_background, FRAMEPOINT_CENTER, 0.2, 0.3)
    BlzFrameSetSize(menu_main_background, 0.2, 0.2)
    BlzFrameSetVisible(menu_main_background, true)

    -- sub-backdrop:
    local menu_sub_background = BlzCreateFrameByType("BACKDROP", "item2", ignore_aspect_parent, "BattleNetControlBackdropTemplate", 0)
    BlzFrameSetSize(menu_sub_background, 0.1, 0.1)
    BlzFrameSetPoint(menu_sub_background, FRAMEPOINT_CENTER, menu_main_background, FRAMEPOINT_CENTER, 0, 0)
    BlzFrameSetVisible(menu_sub_background, true)
    BlzFrameSetParent(menu_sub_background, menu_main_background)

    -- button 1:
    local button1 = BlzCreateFrameByType("TEXTBUTTON", "button1", ignore_aspect_parent, "ScriptDialogButton", 0)
    BlzFrameSetSize(button1, 0.08, 0.03)
    BlzFrameSetText(button1, "Btn1")
    BlzFrameSetPoint(button1, FRAMEPOINT_CENTER, menu_main_background, FRAMEPOINT_BOTTOM, 0, 0)
    BlzFrameSetVisible(button1, true)
    BlzFrameSetParent(button1, menu_main_background)

    -- button 2:
    local button1 = BlzCreateFrameByType("TEXTBUTTON", "button2", ignore_aspect_parent, "ScriptDialogButton", 0)
    BlzFrameSetSize(button1, 0.08, 0.03)
    BlzFrameSetText(button1, "Btn2")
    BlzFrameSetPoint(button1, FRAMEPOINT_CENTER, menu_main_background, FRAMEPOINT_LEFT, 0, 0)
    BlzFrameSetVisible(button1, true)
    BlzFrameSetParent(button1, menu_main_background)

    -- button tooltip:
    local tooltip_bg = BlzCreateFrame("QuestButtonBaseTemplate", ignore_aspect_parent, 0, 0)
    local tooltip_text = BlzCreateFrameByType("TEXT", "item4", tooltip_bg, "", 0)
    BlzFrameSetPoint(tooltip_text, FRAMEPOINT_BOTTOM, button1, FRAMEPOINT_TOP, 0, 0.015)
    BlzFrameSetSize(tooltip_text, 0.15, 0)
    BlzFrameSetText(tooltip_text, "Lorem ipsum bla Lorem ipsum bla Lorem ipsum bla. Lorem ipsum bla Lorem ipsum bla Lorem ipsum bla.")
    BlzFrameSetPoint(tooltip_bg, FRAMEPOINT_BOTTOMLEFT, tooltip_text, FRAMEPOINT_BOTTOMLEFT, -0.015, -0.015)
    BlzFrameSetPoint(tooltip_bg, FRAMEPOINT_TOPRIGHT, tooltip_text, FRAMEPOINT_TOPRIGHT, 0.015, 0.015)
    BlzFrameSetTooltip(button1, tooltip_bg)
    BlzFrameSetEnable(tooltip_text, false)
 end
end
