do
	-- remove fog of war effects from cinematic mode function:
	function CinematicModeExBJ(cineMode, forForce, interfaceFadeTime)
	    if (not bj_gameStarted) then
	        interfaceFadeTime = 0
	    end

	    if (cineMode) then
	        if (not bj_cineModeAlreadyIn) then
	            bj_cineModeAlreadyIn = true
	        end

	        if (IsPlayerInForce(GetLocalPlayer(), forForce)) then
	            ClearTextMessages()
	            ShowInterface(false, interfaceFadeTime)
	            EnableUserControl(false)
	            EnableOcclusion(false)
	            SetCineModeVolumeGroupsBJ()
	            mui.ShowHideCustomUI(false)
	        end

	        SetMapFlag(MAP_LOCK_SPEED, true)

	    else
	        bj_cineModeAlreadyIn = false

	        if (IsPlayerInForce(GetLocalPlayer(), forForce)) then
	            ShowInterface(true, interfaceFadeTime)
	            EnableUserControl(true)
	            EnableOcclusion(true)
	            VolumeGroupReset()
	            EndThematicMusic()
	            CameraResetSmoothingFactorBJ()
	            mui.ShowHideCustomUI(true)
	            mui.AfterCinematic()
	        end

	        SetMapFlag(MAP_LOCK_SPEED, false)
	    end
	end
end
