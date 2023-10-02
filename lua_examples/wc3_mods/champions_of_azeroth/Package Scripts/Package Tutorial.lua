function TutorialGenerate(pInt)

    IssueImmediateOrder(udg_playerHero[pInt],"holdposition")
    local force = GetPlayersMatching(Filter(function() return GetFilterPlayer() == Player(pInt-1) end ) )
    local player = Player(pInt-1)
    local data = {}
    -- initialize horde details:
    if (pInt < 6) then
        data.panTo = {
            { x = GetUnitX(udg_playerShop[pInt]), y = GetUnitY(udg_playerShop[pInt]) }, -- item shop
            { x = -10200.0, y = -10250.0 },                                             -- portal stone
            { x = GetUnitX(gg_unit_o00F_0142), y = GetUnitY(gg_unit_o00F_0142) },       -- flight master
            { x = GetUnitX(gg_unit_n002_0069), y = GetUnitY(gg_unit_n002_0069) },       -- enemy base example
            { x = GetRectCenterX(gg_rct_creepsWestBarrens1), y = GetRectCenterY(gg_rct_creepsWestBarrens1) },   -- forest camp
            { x = GetRectCenterX(gg_rct_objectiveSpawnRiver1), y = GetRectCenterY(gg_rct_objectiveSpawnRiver1) },             -- objective
            { x = GetRectCenterX(gg_rct_coreAlliance), y = GetRectCenterY(gg_rct_coreAlliance) }                -- enemy base
        }
    --alliance:
    else
        data.panTo = {
            { x = GetUnitX(udg_playerShop[pInt]), y = GetUnitY(udg_playerShop[pInt]) },
            { x = 9775, y = 10200.0 },
            { x = GetUnitX(gg_unit_h008_0140), y = GetUnitY(gg_unit_h008_0140) },
            { x = GetUnitX(gg_unit_o004_0066), y = GetUnitY(gg_unit_o004_0066) },
            { x = GetRectCenterX(gg_rct_creepsEastForest1), y = GetRectCenterY(gg_rct_creepsEastForest1) },
            { x = GetRectCenterX(gg_rct_objectiveSpawnRiver2), y = GetRectCenterY(gg_rct_objectiveSpawnRiver2) },
            { x = GetRectCenterX(gg_rct_coreHorde), y = GetRectCenterY(gg_rct_coreHorde) }
        }
    end
    data.displayText = {
        [1] = "Earn |cffffc800100 gold|r every 2 levels. Buy items even when not at base (|cffffc800<F2>|r, |cffffc800<F3>|r).",
        [2] = "Return to base quickly with your |cffffc800Scroll of Town Portal (T)|r.",
        [3] = "Use |cffffc800Flight Masters|r to quickly fly to lanes.",
        [4] = "Destroy enemy bases to capture them, extending your |cffffc800Flight Master|r range.",
        [5] = "Defeat |cffffc800Forest Camps|r to add them to your faction's minion waves.",
        [6] = "|cffffc800Objectives|r will spawn periodically. Be the victor for powerful rewards. ",
        [7] = "Push the enemy's base and destroy their |cffffc800core|r to win!"
    }
    CinematicModeExBJ(true, force, 0.00)
    local i = 0
    local index = 0
    ClearTextMessagesBJ(force)
    DisplayTimedTextToPlayer(player,0,0,8.5,"Welcome to the tutorial! (To cancel, press |cffffc800<ESC>|r)")
    DisplayTimedTextToPlayer(player,0,0,8.5," ")
    DisplayTimedTextToPlayer(player,0,0,8.5,"In Champions of Azeroth, both teams have a |cffffc800shared hero level|r.")
    VolumeGroupResetBJ()
    TutorialPlaySound(player)
    TimerStart(NewTimer(),1.63,true,function()
        i = i + 1
        if i == 3 then SetCameraFieldForPlayer( player, CAMERA_FIELD_TARGET_DISTANCE, 1000.00, 0.33 ) end
        if math.fmod(i,3) == 0 and i < 22 then
            index = index + 1
            ClearTextMessagesBJ(force)
            PanCameraToTimedForPlayer(player,data.panTo[index].x,data.panTo[index].y,0.2)
            DisplayTimedTextToPlayer(player,0,0,8.5,data.displayText[index])
            TutorialPlaySound(player)
        end
        if i >= 24 or LUA_VAR_TUTORIAL_CANCEL[pInt] == true then
            PanCameraToTimedForPlayer(player,GetUnitX(udg_playerHero[pInt]),GetUnitY(udg_playerHero[pInt]),0.2)
            SetCameraFieldForPlayer( player, CAMERA_FIELD_TARGET_DISTANCE, 1650.00, 0.33 )
            ClearTextMessagesBJ(force)
            if not LUA_VAR_TUTORIAL_CANCEL[pInt] then
                DisplayTimedTextToPlayer(player,0,0,7.5,"First step? Head to a lane and start gathering EXP!")
                DisplayTimedTextToPlayer(player,0,0,7.5,"|cffffc800Forest Creatures|r spawn a few minutes after the battle begins.")
                DisplayTimedTextToPlayer(player,0,0,7.5," ")
                DisplayTimedTextToPlayer(player,0,0,7.5,"See |cffffc800Quests|r for more details. Have fun!")
            end
            TutorialPlaySound(player)
            CinematicModeExBJ(false, force, 0.00)
            DestroyForce(force)
            udg_zPlayerInTutorial[pInt] = false
            LUA_VAR_TUTORIAL_CANCEL[pInt] = false
            data = nil
            ReleaseTimer()
        end
    end)

end


function TutorialPlaySound(p)
    if GetLocalPlayer() == p then
        StartSound(udg_gameSoundTutorialHint)
        StopSound(udg_gameSoundTutorialHint,false,2.5)
    end
end
