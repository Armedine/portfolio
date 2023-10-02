function GeneratePlayerCommands()

	playerCommandTriggers = {}
	playerCommandTriggers.panToHero = {}

	-- create panToHero
	playerCommandTriggers.panToHero = CreateTrigger()
	for i = 0,9 do
		BlzTriggerRegisterPlayerKeyEvent(playerCommandTriggers.panToHero, Player(i), OSKEY_SPACE, 0, true)
	end
	TriggerAddAction(playerCommandTriggers.panToHero, function()
		local pInt = GetConvertedPlayerId(GetTriggerPlayer())
        SetCameraQuickPositionForPlayer(Player(pInt-1),GetUnitX(udg_playerHero[pInt]),GetUnitY(udg_playerHero[pInt]))
        PanCameraToTimedForPlayer(Player(pInt-1),GetUnitX(udg_playerHero[pInt]),GetUnitY(udg_playerHero[pInt]),0.00)
        -- prevent spam that might cause a desync:
        TimerStart(NewTimer(),0.25,false,function() EnableTrigger(playerCommandTriggers.panToHero) ReleaseTimer() end)
        DisableTrigger(playerCommandTriggers.panToHero)
    end)
    TriggerAddCondition(playerCommandTriggers.panToHero,Filter(function()
    	return udg_playerHero[GetConvertedPlayerId(GetTriggerPlayer())] ~= nil
	end ) )

	-- create setCameraDistance
	playerCommandTriggers.setPlayerCamera = CreateTrigger()
	for i = 0,9 do
		TriggerRegisterPlayerChatEvent( playerCommandTriggers.setPlayerCamera, Player(i), "-cam", true )
	end
	TriggerAddAction(playerCommandTriggers.setPlayerCamera, function()
        SetCameraFieldForPlayer( GetTriggerPlayer(), CAMERA_FIELD_TARGET_DISTANCE, 1900.00, 0.33 )
    end)
    TriggerAddCondition(playerCommandTriggers.setPlayerCamera,Filter(function()
    	return udg_playerHero[GetConvertedPlayerId(GetTriggerPlayer())] ~= nil
	end ) )

	-- create playTutorial
    playerCommandTriggers.playTutorial = CreateTrigger()
    LUA_VAR_TUTORIAL_X = {}
    LUA_VAR_TUTORIAL_Y = {}
    for i = 0,9 do
        TriggerRegisterPlayerChatEvent( playerCommandTriggers.playTutorial, Player(i), "-tutorial", true )
        if (i < 5) then
            LUA_VAR_TUTORIAL_X[i+1] = GetRectCenterX(gg_rct_spawnHeroHorde)
            LUA_VAR_TUTORIAL_Y[i+1] = GetRectCenterY(gg_rct_spawnHeroHorde)
        else
            LUA_VAR_TUTORIAL_X[i+1] = GetRectCenterX(gg_rct_spawnHeroAlliance)
            LUA_VAR_TUTORIAL_Y[i+1] = GetRectCenterY(gg_rct_spawnHeroAlliance)
        end
    end
    TriggerAddAction(playerCommandTriggers.playTutorial, function()
        TutorialGenerate(GetConvertedPlayerId(GetTriggerPlayer()))
        udg_zPlayerInTutorial[GetConvertedPlayerId(GetTriggerPlayer())] = true
    end)
    TriggerAddCondition(playerCommandTriggers.playTutorial,Filter(function()
        local pInt = GetConvertedPlayerId(GetTriggerPlayer())
        if ( udg_playerHero[pInt] == nil ) then
            DisplayTimedTextToPlayer(Player(pInt-1),0,0,0.75,"Choose a hero before running the tutorial!")
            return false
        elseif (udg_gameHasStarted == true) then
            DisplayTimedTextToPlayer(Player(pInt-1),0,0,0.75,"The game has already started!")
            return false
        elseif (DistanceBetweenXY(GetUnitX(udg_playerHero[pInt]),GetUnitY(udg_playerHero[pInt]),LUA_VAR_TUTORIAL_X[pInt],LUA_VAR_TUTORIAL_Y[pInt]) > 800.0) then
            DisplayTimedTextToPlayer(Player(pInt-1),0,0,0.75,"The tutorial can only be started while near your Portal Stone!")
            return false
        else
            return true
        end
    end ) )

    -- create cancelTutorial
    playerCommandTriggers.cancelTutorial = CreateTrigger()
    LUA_VAR_TUTORIAL_CANCEL = {}
    for i = 0,9 do
        LUA_VAR_TUTORIAL_CANCEL[i+1] = false
        TriggerRegisterPlayerEventEndCinematic( playerCommandTriggers.cancelTutorial, Player(i) )
    end
    TriggerAddAction(playerCommandTriggers.cancelTutorial, function()
        LUA_VAR_TUTORIAL_CANCEL[GetConvertedPlayerId(GetTriggerPlayer())] = true
        DisplayTimedTextToPlayer(GetTriggerPlayer(),0,0,4.5,"Canceling Tutorial...")
    end)
    TriggerAddCondition(playerCommandTriggers.cancelTutorial,Filter(function()
        return udg_zPlayerInTutorial[GetConvertedPlayerId(GetTriggerPlayer())] == true end ) )

end
