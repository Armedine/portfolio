-- drafted here: https://docs.google.com/spreadsheets/d/1OPFIguwadVlQnwkL4NPSZeXRrfWzFUMdKMeEonDlAAc/edit#gid=0
-- init LB
function LeaderboardGenerate()

	--config
	local concatLength = 24 -- number of chars to limit player names to (prevent overlap)
	local widthName = 12.33
	local widthElims = 5.21
	local widthDeaths = 6.12
	local widthXP = 7.18
	--

	udg_mb = CreateMultiboard()
	local rowSkip = 2 -- how many line items to skip to update a row (horde = 2, alliance = 3) aka unused line items to skip over

	MultiboardSetTitleText(udg_mb,"Leaderboard")
	MultiboardSetColumnCount(udg_mb,5)
	MultiboardSetRowCount(udg_mb,13)

	for col = 1,5 do -- go through each column
		rowSkip = 2
		for row = 1,13 do -- go through each row
			MultiboardSetItemStyleBJ(udg_mb,col,row,false,false) -- by default, hide cell
			if (col == 1) then -- set column 1 values, etc.
				if (row ~= 1 and row ~= 2 and row ~= 8) then -- set player hero icon placeholder
					if (row > 8) then rowSkip = 3 else rowSkip = 2 end
					if (udg_gamePlayerEmptyComp[GetConvertedPlayerId(ConvertedPlayer(row-rowSkip))] == true) then -- if player absent
						MultiboardSetItemStyleBJ(udg_mb,col,row,false,false) -- hide all
						MultiboardSetItemIconBJ(udg_mb,col,row,'_')
					else
						MultiboardSetItemStyleBJ(udg_mb,col,row,false,true) -- hide values, show icons
						MultiboardSetItemIconBJ(udg_mb,col,row,'ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp') -- set icons
					end
				elseif (row == 1) then -- set header
					MultiboardSetItemStyleBJ(udg_mb,col,row,false,false)
				elseif (row == 2) then -- hide title row details
					MultiboardSetItemStyleBJ(udg_mb,col,row,false,false)
				elseif (row == 8) then -- hide title row details
					MultiboardSetItemStyleBJ(udg_mb,col,row,false,false)
				end
				MultiboardSetItemWidthBJ(udg_mb,col,row,1.25) -- set width for whole column
			elseif (col == 2) then
				if (row ~= 1 and row ~= 2 and row ~= 8) then
					MultiboardSetItemStyleBJ(udg_mb,col,row,true,false) -- show values, hide icons
					if (row > 8) then rowSkip = 3 else rowSkip = 2 end -- set up row skip to get over empty line items (1,2,8 are headers/empty)
					if (udg_gamePlayerEmptyComp[GetConvertedPlayerId(ConvertedPlayer(row-rowSkip))] == true) then -- if player absent
						MultiboardSetItemValueBJ(udg_mb,col,row,' ') -- hide player name
					else
						if (row <= 8) then -- horde color coded names
							MultiboardSetItemValueBJ(udg_mb,col,row,'|cffff2c2c' .. string.sub(GetPlayerName(ConvertedPlayer(row-rowSkip)),1,concatLength) .. '|r') -- set player name
						else -- alliance color coded names
							MultiboardSetItemValueBJ(udg_mb,col,row,'|cff2c2ce9' .. string.sub(GetPlayerName(ConvertedPlayer(row-rowSkip)),1,concatLength) .. '|r') -- set player name
						end
					end
				elseif (row == 1) then -- set header
					MultiboardSetItemStyleBJ(udg_mb,col,row,false,false)
				elseif (row == 2) then -- set title row Horde
					MultiboardSetItemStyleBJ(udg_mb,col,row,true,true)
					MultiboardSetItemIconBJ(udg_mb,col,row,'ReplaceableTextures\\CommandButtons\\BTNOrcCaptureFlag.blp')
					MultiboardSetItemValueBJ(udg_mb,col,row,'|cffffc800' .. GetPlayerName(ConvertedPlayer(13)) .. '|r') -- set player name
				elseif (row == 8) then -- set title row Alliance
					MultiboardSetItemStyleBJ(udg_mb,col,row,true,true)
					MultiboardSetItemIconBJ(udg_mb,col,row,'ReplaceableTextures\\CommandButtons\\BTNHumanCaptureFlag.blp')
					MultiboardSetItemValueBJ(udg_mb,col,row,'|cffffc800' .. GetPlayerName(ConvertedPlayer(14)) .. '|r') -- set player name
				end
				MultiboardSetItemWidthBJ(udg_mb,col,row,widthName) -- set width for whole column
			elseif (col == 3 or col == 4 or col == 5) then
				if (row ~= 1 and row ~= 2 and row ~= 8) then -- set player hero icon placeholder
					MultiboardSetItemStyleBJ(udg_mb,col,row,true,false) -- show values, hide icons
					MultiboardSetItemValueBJ(udg_mb,col,row,'') -- initialize default value
				elseif ((row == 1 and col == 3)) then -- set Eliminations header
					MultiboardSetItemStyleBJ(udg_mb,col,row,true,true)
					MultiboardSetItemIconBJ(udg_mb,col,row,'ReplaceableTextures\\CommandButtons\\BTNSteelMelee.blp')
					MultiboardSetItemValueBJ(udg_mb,col,row,'|cffffc800Kills|r')
				elseif ((row == 1 and col == 4)) then -- set Deaths header
					MultiboardSetItemStyleBJ(udg_mb,col,row,true,true)
					MultiboardSetItemIconBJ(udg_mb,col,row,'ReplaceableTextures\\CommandButtons\\BTNCancel.blp')
					MultiboardSetItemValueBJ(udg_mb,col,row,'|cffffc800Deaths|r')
				elseif ((row == 1 and col == 5)) then -- set XP header
					MultiboardSetItemStyleBJ(udg_mb,col,row,true,true)
					MultiboardSetItemIconBJ(udg_mb,col,row,'ReplaceableTextures\\CommandButtons\\BTNRallyPoint.blp')
					MultiboardSetItemValueBJ(udg_mb,col,row,'|cffffc800XP Earned|r')
				elseif ((row == 2 and col == 3) or (row == 8 and col == 3)) then -- set faction Eliminations default value
					MultiboardSetItemStyleBJ(udg_mb,col,row,true,false)
					MultiboardSetItemValueBJ(udg_mb,col,row,'')
				elseif ((row == 2 and col == 4) or (row == 8 and col == 4)) then -- set faction Deaths default value
					MultiboardSetItemStyleBJ(udg_mb,col,row,true,false)
					MultiboardSetItemValueBJ(udg_mb,col,row,'')
				elseif ((row == 2 and col == 5) or (row == 8 and col == 5)) then -- set faction XP default value
					MultiboardSetItemStyleBJ(udg_mb,col,row,true,false)
					MultiboardSetItemValueBJ(udg_mb,col,row,'|cffc800c8Level 1|r')
				elseif (row == 2) then -- hide title row details
					MultiboardSetItemStyleBJ(udg_mb,col,row,false,false)
				elseif (row == 8) then -- hide title row details
					MultiboardSetItemStyleBJ(udg_mb,col,row,false,false)
				end
				if (col == 3) then -- eliminations width
					MultiboardSetItemWidthBJ(udg_mb,col,row,widthElims)
				elseif (col == 4) then -- deaths width
					MultiboardSetItemWidthBJ(udg_mb,col,row,widthDeaths)
				elseif (col == 5) then -- xp earned width
					MultiboardSetItemWidthBJ(udg_mb,col,row,widthXP)
				end
			end
		end
	end

	MultiboardDisplay(udg_mb,true)
	MultiboardMinimize(udg_mb,true)

end


-- split xp by nearby heroes and add to leaderboard stat (this gets called in Global Experience script)
function LeaderboardAddEligibleXP(x,y,xp,p)
	local g = CreateGroup()
	local pInt = GetConvertedPlayerId(p)
	local size = 1

	GroupEnumUnitsInRange(g, x, y, 1000.0, Condition( function() return DamagePackageAllyFilter(GetFilterUnit(), p) and IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO) and GetConvertedPlayerId(GetOwningPlayer(GetFilterUnit())) <= 10 end ) )
	size = BlzGroupGetSize(g)
	local u = FirstOfGroup(g)
	local i = 0
	local ownInt = pInt
	if (not IsUnitGroupEmptyBJ(g)) then
		repeat
			ownInt = GetConvertedPlayerId(GetOwningPlayer(u))
			udg_mbXPEarned[ownInt] = udg_mbXPEarned[ownInt] + (xp/size)
			LeaderboardUpdateXP(ownInt)
			GroupRemoveUnit(g, u)
			u = FirstOfGroup(g)
			i = i+1
		until (u == nil or i > 10)
	end
	DestroyGroup(g)
end


-- update leaderboard player hero icon to unit icon
function LeaderboardUpdateHeroIcon(pInt)
	if (pInt <= 10) then
		local rowSkip = LeaderboardGetRowSkip(pInt)
		if (udg_mbHeroIcon[pInt]) then
			MultiboardSetItemStyleBJ(udg_mb,1,rowSkip+pInt,false,true)
			MultiboardSetItemIconBJ(udg_mb,1,rowSkip+pInt,udg_mbHeroIcon[pInt])
		end
	end
end


-- update leaderboard player hero icon to a skull when they are dead
function LeaderboardUpdateDeathIcon(pInt)
	if (pInt <= 10) then
		local rowSkip = LeaderboardGetRowSkip(pInt)
		if (udg_mbHeroIcon[pInt]) then
			MultiboardSetItemIconBJ(udg_mb,1,rowSkip+pInt,'ReplaceableTextures\\CommandButtons\\BTNAnkh.blp')
		end
	end
end


-- update leaderboard values
function LeaderboardUpdateEliminations(pInt)
	if (pInt <= 10) then
		local rowSkip = LeaderboardGetRowSkip(pInt)
		MultiboardSetItemValueBJ(udg_mb,3,rowSkip+pInt,udg_mbEliminations[pInt]) -- update player
	end
	local str = ''
	str = '|cffffc800' .. udg_mbElimTotal[0] .. '|r'
	MultiboardSetItemValueBJ(udg_mb,3,2,str) -- update faction total horde
	str = '|cffffc800' .. udg_mbElimTotal[1] .. '|r'
	MultiboardSetItemValueBJ(udg_mb,3,8,str) -- update faction total alliance

end


-- update leaderboard values
function LeaderboardUpdateDeaths(pInt)
	if (pInt <= 10) then
		local rowSkip = LeaderboardGetRowSkip(pInt)
		MultiboardSetItemValueBJ(udg_mb,4,rowSkip+pInt,udg_mbDeaths[pInt])
	end
	local str = ''
	str = '|cffffc800' .. udg_mbDeathsTotal[0] .. '|r'
	MultiboardSetItemValueBJ(udg_mb,4,2,str) -- update faction total horde
	str = '|cffffc800' .. udg_mbDeathsTotal[1] .. '|r'
	MultiboardSetItemValueBJ(udg_mb,4,8,str) -- update faction total alliance

end


-- update leaderboard values
function LeaderboardUpdateXP(pInt)
	if (pInt <= 10) then
		local rowSkip = LeaderboardGetRowSkip(pInt)
		MultiboardSetItemValueBJ(udg_mb,5,rowSkip+pInt,math.floor(udg_mbXPEarned[pInt]))
	end

end


-- update leaderboard values
function LeaderboardUpdateFactionLevel()
	MultiboardSetItemValueBJ(udg_mb,5,2,'|cffc800c8Level ' .. GetHeroLevel(udg_zGlobalXPUnit[0]) .. '|r')
	MultiboardSetItemValueBJ(udg_mb,5,8,'|cffc800c8Level ' .. GetHeroLevel(udg_zGlobalXPUnit[1]) .. '|r')

end


-- run when a player leaves the game
function LeaderboardPlayerLeft(pInt)
	local rowSkip = LeaderboardGetRowSkip(pInt)

	MultiboardSetItemValueBJ(udg_mb,2,rowSkip+pInt,'|cffc0c0c0<left game>|r')

end


-- run to update player name; if colorString is empty or left nil then defaults to faction colors
function LeaderboardUpdatePlayerName(pInt, newNameString, colorString, isBotBool)

	--if (LUA_VAR_CACHED_LB_NAME == nil) then
	--	LUA_VAR_CACHED_LB_NAME = {}
	--end

	local rowSkip = LeaderboardGetRowSkip(pInt)
	newNameString = string.sub(newNameString,1,24) -- prevent overlapping columns

	if (colorString == nil) then
		if pInt > 5 then -- alliance
			colorString = '|cff2c2ce9'
		else -- horde
			colorString = '|cffff2c2c'
		end
	end

	if (isBotBool) then
		newNameString = colorString .. newNameString .. ' (|r|cff00e9ffBot|r' .. colorString .. ')|r'
	else
		newNameString = colorString .. newNameString .. '|r'
	end

	MultiboardSetItemValueBJ(udg_mb,2,rowSkip+pInt, newNameString )

	--LUA_VAR_LB_CACHED_NAME[pInt] = newNameString

end


-- get line item to update based on player number (in order to skip non-player rows)
function LeaderboardGetRowSkip(pInt)
	local rowSkip = 2
	if (pInt > 5) then rowSkip = 3 end
	return rowSkip
end
