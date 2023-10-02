function RunDataPreloader()

	-- create temporary units to give visibility (remove revealed units from fog of war)
	LUA_PRELOAD_VISIBILITY1 = CreateUnit(Player(12),FourCC('o01A'),0.0,0.0,0.0) -- temp unit to add abils to
	LUA_PRELOAD_VISIBILITY2 = CreateUnit(Player(13),FourCC('o01A'),0.0,0.0,0.0) -- temp unit to add abils to
	LUA_PRELOAD_TEMPUNIT = CreateUnit(Player(14),FourCC('e004'),0.0,0.0,0.0) -- temp unit to add abils to

	LUA_PRELOAD_OBJECTS = #LUA_PRELOAD_ABILCODES + #LUA_PRELOAD_UNITCODES + #LUA_PRELOAD_EFFECTSTRINGS
	LUA_PRELOAD_OBJECTS_LOADED = 0
	LUA_PRELOAD_OBJECTS_PROGRESS = {}

	LUA_PRELOAD_TXT_LOAD = ''
	LUA_PRELOAD_TXT_BAR_COMPLETE = ''
	LUA_PRELOAD_TXT_PROGRESS = ''
	LUA_PRELOAD_TXT_COLOR = '|cff37ff37'

	LUA_PRELOAD_TXT_BAR_MAP = {
		[1] = '••',
		[2] = '•••',
		[3] = '••••',
		[4] = '•••••',
		[5] = '••••••',
		[6] = '•••••••',
		[7] = '••••••••',
		[8] = '•••••••••',
		[9] = '••••••••••',
		[10] = '•••••••••••',
		[11] = '••••••••••••',
		[12] = '•••••••••••••',
		[13] = '••••••••••••••',
		[14] = '•••••••••••••••',
		[15] = '••••••••••••••••',
		[16] = '•••••••••••••••••',
		[17] = '••••••••••••••••••',
		[18] = '•••••••••••••••••••',
		[19] = '••••••••••••••••••••',
		[20] = '•••••••••••••••••••••',
		[21] = '••••••••••••••••••••••',
		[22] = '•••••••••••••••••••••••',
		[23] = '••••••••••••••••••••••••',
		[24] = '•••••••••••••••••••••••••',
		[25] = '••••••••••••••••••••••••••',
		[26] = '•••••••••••••••••••••••••••',
		[27] = '••••••••••••••••••••••••••••',
		[28] = '•••••••••••••••••••••••••••••',
		[29] = '••••••••••••••••••••••••••••••',
		[30] = '•••••••••••••••••••••••••••••••',
		[31] = '••••••••••••••••••••••••••••••••',
		[32] = '•••••••••••••••••••••••••••••••••',
		[33] = '••••••••••••••••••••••••••••••••••',
		[34] = '•••••••••••••••••••••••••••••••••••',
		[35] = '••••••••••••••••••••••••••••••••••••',
		[36] = '•••••••••••••••••••••••••••••••••••••',
		[37] = '••••••••••••••••••••••••••••••••••••••',
		[38] = '•••••••••••••••••••••••••••••••••••••••',
		[39] = '••••••••••••••••••••••••••••••••••••••••',
		[40] = '•••••••••••••••••••••••••••••••••••••••••',
		[41] = '••••••••••••••••••••••••••••••••••••••••••',
		[42] = '•••••••••••••••••••••••••••••••••••••••••••',
		[43] = '••••••••••••••••••••••••••••••••••••••••••••',
		[44] = '•••••••••••••••••••••••••••••••••••••••••••••',
		[45] = '••••••••••••••••••••••••••••••••••••••••••••••',
		[46] = '•••••••••••••••••••••••••••••••••••••••••••••••',
		[47] = '••••••••••••••••••••••••••••••••••••••••••••••••',
		[48] = '•••••••••••••••••••••••••••••••••••••••••••••••••',
		[49] = '••••••••••••••••••••••••••••••••••••••••••••••••••',
		[50] = '•••••••••••••••••••••••••••••••••••••••••••••••••••'
	}

	LUA_PRELOAD_TXT_BAR_MAP_SIZE = #LUA_PRELOAD_TXT_BAR_MAP

	udg_UnitIndexerEnabled = false -- turn off indexer while units are made

	--
	-- preload abilities by raw code
	--
	local max = #LUA_PRELOAD_ABILCODES
	local loop = 1

	TimerStart(NewTimer(),0.01,true,function()
		LUA_PRELOAD_TXT_LOAD = "|cff00b1ffLoading " .. LUA_PRELOAD_ABILCODES[loop] .. "|r"
		UnitAddAbilityBJ( FourCC(LUA_PRELOAD_ABILCODES[loop]), LUA_PRELOAD_TEMPUNIT )
		UnitRemoveAbilityBJ( FourCC(LUA_PRELOAD_ABILCODES[loop]), LUA_PRELOAD_TEMPUNIT )
		LUA_PRELOAD_OBJECTS_LOADED = LUA_PRELOAD_OBJECTS_LOADED + 1
		loop = loop + 1
		RunDataPreloaderProgress()
		if (loop >= #LUA_PRELOAD_ABILCODES) then
			RemoveUnit(LUA_PRELOAD_TEMPUNIT)
			--
			-- preload units by raw code
			--
			max = #LUA_PRELOAD_UNITCODES
			loop = 1
			TimerStart(NewTimer(),0.01,true,function()
				LUA_PRELOAD_TXT_LOAD = "|cff00b1ffLoading " .. LUA_PRELOAD_UNITCODES[loop] .. "|r"
				RemoveUnit( CreateUnit(Player(14),FourCC(LUA_PRELOAD_UNITCODES[loop]),0.0,0.0,0.0) )
				LUA_PRELOAD_OBJECTS_LOADED = LUA_PRELOAD_OBJECTS_LOADED + 1
				loop = loop + 1
				RunDataPreloaderProgress()
				if (loop >= #LUA_PRELOAD_UNITCODES) then
					--
					-- preload effects by string
					--
					max = #LUA_PRELOAD_EFFECTSTRINGS
					loop = 1
					TimerStart(NewTimer(),0.01,true,function()
						LUA_PRELOAD_TXT_LOAD = "|cff00b1ffLoading " .. string.sub(LUA_PRELOAD_EFFECTSTRINGS[loop],1,24) .. "|r.."
						Preload(LUA_PRELOAD_EFFECTSTRINGS[loop])
						LUA_PRELOAD_OBJECTS_LOADED = LUA_PRELOAD_OBJECTS_LOADED + 1
						loop = loop + 1
						RunDataPreloaderProgress()
						if (loop >= #LUA_PRELOAD_EFFECTSTRINGS) then
							RunDataPreloaderResume() -- continue after coroutine ends
							ReleaseTimer()
						end
					end)
					ReleaseTimer()
				end
			end)
			ReleaseTimer()
		end
	end)

end


function RunDataPreloaderResume()

	-- preload forest camps
	if (TriggerEvaluate(gg_trg_Forest_Camps_Init)) then
		TriggerExecute(gg_trg_Forest_Camps_Init)
		LUA_PRELOAD_TXT_LOAD = "|cff64ff64Forest Camps Preloaded|r"
		RunDataPreloaderProgress()
	else
		print("Error: Forest Camps Failed to Load")
	end

	-- loading complete, run post-map init trigger
	LUA_PRELOAD_TXT_LOAD = "|cff64ff64Loading Complete|r"

	if (TriggerEvaluate(gg_trg_Map_Loaded)) then
		TriggerExecute(gg_trg_Map_Loaded)
	else
		udg_victoryPlayer = Player(13)
		TriggerExecute(gg_trg_Victory)
		print("Error: Map Load Failed, please report to map author: failed to load 'gg_trg_Map_Loaded'")
	end

	udg_UnitIndexerEnabled = true -- re-enable unit indexer

	-- cleanup
	RemoveUnit(LUA_PRELOAD_VISIBILITY1)
	RemoveUnit(LUA_PRELOAD_VISIBILITY2)
	LUA_PRELOAD_UNITCODES = nil
	LUA_PRELOAD_ABILCODES = nil
	LUA_PRELOAD_EFFECTSTRINGS = nil
	LUA_PRELOAD_VISIBILITY1 = nil
	LUA_PRELOAD_VISIBILITY2 = nil
	LUA_PRELOAD_TEMPUNIT = nil
	LUA_PRELOAD_TXT_LOAD = nil
	LUA_PRELOAD_TXT_BAR_COMPLETE = nil
	LUA_PRELOAD_TXT_BAR_INCOMPLETE = nil
	LUA_PRELOAD_TXT_PROGRESS = nil
	LUA_PRELOAD_TXT_BAR_MAP = nil
	LUA_PRELOAD_TXT_BAR_MAP_SIZE = nil
	LUA_PRELOAD_TXT_COLOR = nil
	LUA_PRELOAD_OBJECTS_LOADED = nil
	LUA_PRELOAD_OBJECTS = nil
	LUA_PRELOAD_OBJECTS_PROGRESS = nil

end


function RunDataPreloaderProgress()

	-- fetch index based on % objects loaded:
	LUA_PRELOAD_OBJECTS_PROGRESS[1] = math.floor((LUA_PRELOAD_OBJECTS_LOADED/LUA_PRELOAD_OBJECTS)*LUA_PRELOAD_TXT_BAR_MAP_SIZE)
	-- fetch reverse for progress not yet done:
	LUA_PRELOAD_OBJECTS_PROGRESS[2] = LUA_PRELOAD_TXT_BAR_MAP_SIZE - LUA_PRELOAD_OBJECTS_PROGRESS[1]

	LUA_PRELOAD_TXT_BAR_COMPLETE = LUA_PRELOAD_TXT_BAR_MAP[LUA_PRELOAD_OBJECTS_PROGRESS[1]]
	LUA_PRELOAD_TXT_BAR_INCOMPLETE = LUA_PRELOAD_TXT_BAR_MAP[LUA_PRELOAD_OBJECTS_PROGRESS[2]]

	LUA_PRELOAD_TXT_PROGRESS = LUA_PRELOAD_TXT_COLOR .. LUA_PRELOAD_TXT_BAR_COMPLETE .. '|r|cffc8c8c7' .. LUA_PRELOAD_TXT_BAR_INCOMPLETE .. '|r'

	ClearTextMessages()

	print(LUA_PRELOAD_TXT_LOAD)
	print(LUA_PRELOAD_TXT_PROGRESS)

end
