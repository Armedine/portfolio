-- in order for -ai command to be asynchronous with player selection (for now), we generate hero sheet regardless
ai__faction__heroes__horde = {}
ai__faction__heroes__alliance = {}
ai__faction__heroes__neutral = {}
-- insert possible hero ids for HORDE 											-- NOT added due to mechanics conflict: acolyte
ai__faction__heroes__horde[#ai__faction__heroes__horde+1] = "O00C"				-- grunt
ai__faction__heroes__horde[#ai__faction__heroes__horde+1] = "O010"				-- shaman
ai__faction__heroes__horde[#ai__faction__heroes__horde+1] = "O00Q"				-- tauren
ai__faction__heroes__horde[#ai__faction__heroes__horde+1] = "O00R"				-- crypt fiend
ai__faction__heroes__horde[#ai__faction__heroes__horde+1] = "O00H"				-- gargoyle

-- insert possible hero ids for ALLIANCE 										-- NOT added due to mechanics conflict: wisp
ai__faction__heroes__alliance[#ai__faction__heroes__alliance+1] = "O00E"		-- footman
ai__faction__heroes__alliance[#ai__faction__heroes__alliance+1] = "O012"		-- knight
ai__faction__heroes__alliance[#ai__faction__heroes__alliance+1] = "O00T"		-- spell breaker
ai__faction__heroes__alliance[#ai__faction__heroes__alliance+1] = "E000"		-- huntress
ai__faction__heroes__alliance[#ai__faction__heroes__alliance+1] = "O00M"		-- priest

-- insert possible hero ids for NEUTRAL 										-- NOT added due to mechanics conflict: n/a
ai__faction__heroes__neutral[#ai__faction__heroes__neutral+1] = "O00J"			-- eredar warlock
ai__faction__heroes__neutral[#ai__faction__heroes__neutral+1] = "O00S"			-- fel orc warlock
ai__faction__heroes__neutral[#ai__faction__heroes__neutral+1] = "O013"			-- hydra
ai__faction__heroes__neutral[#ai__faction__heroes__neutral+1] = "O014"			-- tuskarr healer
ai__faction__heroes__neutral[#ai__faction__heroes__neutral+1] = "O016"			-- overlord

function DAI__VarGenProfiles()
	-- matches order string with hero ability
	-- Q,W,E,R,F
	ai__profileAbilityOrderString = {
		["O00C"] = {"slow","roar","taunt","fingerofdeath","battleroar"},								-- grunt
		["O010"] = {"slow","lightningshield","fingerofdeath","bloodlust","ward"},						-- shaman
		["O00Q"] = {"rainoffire","roar","fingerofdeath","taunt",""},									-- tauren
		["O00R"] = {"rejuvination","fingerofdeath","antimagicshell","clusterrockets","unholyfrenzy"},	-- crypt fiend
		["O00H"] = {"rainoffire","unholyfrenzy","metamorphosis","ward",""},								-- gargoyle
		["O00E"] = {"slow","holybolt","thunderbolt","ward",""},											-- footman
		["O012"] = {"slow","immolation","mirrorimage","rainoffire",""},									-- knight
		["O00T"] = {"fingerofdeath","taunt","roar","howlofterror",""},									-- spell breaker
		["E000"] = {"ensnare","ward","ambush","rainoffire",""},											-- huntress
		["O00M"] = {"heal","curse","holybolt","metamorphosis","roar"},									-- priest
		["O00J"] = {"clusterrockets","rainoffire","ward","darksummoning","unholyfrenzy"},				-- eredar warlock
		["O00S"] = {"deathcoil",--[["immolation"]]"","roar","unholyfrenzy",""},							-- fel orc warlock
		["O013"] = {"carrionswarm","breathoffrost","breathoffire","fingerofdeath",""},					-- hydra
		["O014"] = {"rainoffire","clusterrockets","ward","fingerofdeath","roar"},						-- tuskarr healer
		["O016"] = {"rainoffire","spiritlink","antimagicshell","howlofterror",""}						-- tuskarr healer
	}
	-- controls the order by which abilities should be used; lower value = use first
	ai__profileAbilityOrderPriority = {
		["O00C"] = {1,2,3,4,5},	-- grunt
		["O010"] = {1,4,2,5,3},	-- shaman
		["O00Q"] = {1,4,2,3,5},	-- tauren
		["O00R"] = {1,2,3,4,5},	-- crypt fiend
		["O00H"] = {1,2,3,4,5},	-- gargoyle
		["O00E"] = {2,4,1,3,5},	-- footman
		["O012"] = {1,2,3,4,5},	-- knight
		["O00T"] = {1,3,2,4,5},	-- spell breaker
		["E000"] = {1,2,3,4,5},	-- huntress
		["O00M"] = {1,2,3,4,5},	-- priest
		["O00J"] = {1,2,3,4,5},	-- eredar warlock
		["O00S"] = {2,1,4,3,5},	-- fel orc warlock
		["O013"] = {1,2,3,4,5},	-- hydra
		["O014"] = {1,3,2,4,5},	-- tuskarr healer
		["O016"] = {2,3,1,4,5}	-- overlord
	}
	-- controls how the ability is issued
	-- 0 = point, 1 = unit, 2 = instant (aoe), TODO: 3 = build structure
	ai__profileAbilityOrderType = {
		["O00C"] = {1,2,2,1,2},	-- grunt
		["O010"] = {1,1,1,1,0},	-- shaman
		["O00Q"] = {0,0,0,0,0},	-- tauren
		["O00R"] = {1,1,1,0,1},	-- crypt fiend
		["O00H"] = {0,1,2,0,0},	-- gargoyle
		["O00E"] = {1,1,1,0,0},	-- footman
		["O012"] = {1,2,2,0,0},	-- knight
		["O00T"] = {1,2,2,2,0},	-- spell breaker
		["E000"] = {1,0,2,0,0},	-- huntress
		["O00M"] = {1,1,1,0,0},	-- priest
		["O00J"] = {0,0,0,0,0},	-- eredar warlock
		["O00S"] = {1,2,2,1,0},	-- fel orc warlock
		["O013"] = {0,0,0,1,0},	-- hydra
		["O014"] = {0,0,0,0,2},	-- tuskarr healer
		["O016"] = {0,1,1,2,0}	-- overlord
	}
	-- controls how the unit should use an ability vs friend and foe
	-- 0 = enemy, 1 = friend, 2 = both, 3 = crowd control, 4 = self buff
	ai__profileAbilityFriendFoe = {
		["O00C"] = {0,4,4,0,0},	-- grunt
		["O010"] = {0,1,0,1,0},	-- shaman
		["O00Q"] = {0,0,0,0,0},	-- tauren
		["O00R"] = {1,1,3,0,1},	-- crypt fiend
		["O00H"] = {0,0,0,0,0},	-- gargoyle
		["O00E"] = {0,1,0,0,0},	-- footman
		["O012"] = {0,0,0,0,0},	-- knight
		["O00T"] = {0,0,0,0,0},	-- spell breaker
		["E000"] = {0,0,0,0,0},	-- huntress
		["O00M"] = {1,0,1,0,0},	-- priest
		["O00J"] = {0,0,0,0,0},	-- eredar warlock
		["O00S"] = {0,0,0,0,0},	-- fel orc warlock
		["O013"] = {0,0,0,0,0},	-- hydra
		["O014"] = {0,0,0,0,0},	-- tuskarr healer
		["O016"] = {0,1,0,0,0}	-- overlord
	}
	-- TODO: NOT IMPLEMENTED:
	-- controls how the a.i. should position themselves
	-- melee, ranged, caster, healer (future TODO: builder)
	ai__profileHeroAttitude = {
		["O00C"] = "melee",		-- grunt
		["O010"] = "caster",	-- shaman
		["O00Q"] = "melee",		-- tauren
		["O00R"] = "healer",	-- crypt fiend
		["O00H"] = "caster",	-- gargoyle
		["O00E"] = "melee",		-- footman
		["O012"] = "melee",		-- knight
		["O00T"] = "melee",		-- spell breaker
		["E000"] = "ranged",	-- huntress
		["O00M"] = "healer",	-- priest
		["O00J"] = "caster",	-- eredar warlock
		["O00S"] = "caster",	-- fel orc warlock
		["O013"] = "caster",	-- hydra
		["O014"] = "healer",	-- tuskarr healer
		["O016"] = "melee"		-- overlord
	}
	-- controls what ultimate agent learns at level 10
	-- add raw code for ultimate
	ai__profileAbilityUltimate = {
		["O00C"] = "A00F",	-- grunt
		["O010"] = "A034",	-- shaman
		["O00Q"] = "A01X",	-- tauren
		["O00R"] = "A023",	-- crypt fiend
		["O00H"] = "A00V",	-- gargoyle
		["O00E"] = "A00M",	-- footman
		["O012"] = "A03B",	-- knight
		["O00T"] = "A02J",	-- spell breaker
		["E000"] = "A00K",	-- huntress
		["O00M"] = "A019",	-- priest
		["O00J"] = "A014",	-- eredar warlock
		["O00S"] = "A02F",	-- fel orc warlock
		["O013"] = "A03G",	-- hydra
		["O014"] = "A03I",	-- tuskarr healer
		["O016"] = "A03W"	-- overlord
	}
	-- add item raw codes to this table for agent to acquire
	ai__profileItemTable = {
		[1] = {},
		[2] = {},
		[3] = {},
		[4] = {},
		[5] = {},
		[6] = {},
		[7] = {},
		[8] = {},
		[9] = {},
		[10] = {}
	}

	-- !! lua has base index of 1 !!
	-- grabbing values example: ai__profileAbilityOrderString.O00C[3] = taunt
	------------------------------------
	--config----------------------------
	ai__combatEngageHeroRange__r = 650.0			-- range at which agent will try to target an enemy or ally
	ai__combatDelayDuration__r = 2.44				-- the delay before the a.i. will auto attack enemy heroes in combat phase (try to keep just higher than ability cadence)
	------------------------------------
	ai__combatIncrement = {1,1,1,1,1,1,1,1,1,1}	-- cycles through ability priority; defaulted to 1 (increments then resets to 1)
end


-- @n = player to command
-- @bool = should the agent target a hero? set to false to target nearby minions e.g. wave-clear heroes
function DAI__InitiateCombatBasic(n, heroBool)
	if (ai__combatIncrement[n] > 5) then ai__combatIncrement[n] = 1 end -- reset possible ability cycle
	local id = ai__heroId[n]
	--DebugMsg("initiating combat, with hero id " .. id)
	local orderId = ai__profileAbilityOrderPriority[id][ai__combatIncrement[n]] -- grab the array position of orderString, type, etc. based on order priority
	--DebugMsg(orderId)
	local orderString = ai__profileAbilityOrderString[id][orderId]
	--DebugMsg(orderString)

	if (orderString ~= "" and orderId ~= nil) then -- don't run if the ability is a passive or disabled
		if (heroBool) then
			local FriendOrFoe = ai__profileAbilityFriendFoe[id][orderId]
			local orderType = ai__profileAbilityOrderType[id][orderId]

		if (orderType == 0) then -- target point
			--DebugMsg("found target point ability for " .. tostring(n))
			local bool = false
			if (FriendOrFoe == 1) then bool = true else DAI__CombatDelayedAttackUnit(n,unit) end -- true if ally target
			local unit = DAI__CombatGetNearbyHero(n, bool)
			if (unit ~= nil) then
				IssuePointOrder(udg_playerHero[n],orderString,GetUnitX(unit),GetUnitY(unit))
				DAI__CombatDelayedAttackUnit(n,unit)
			end

		elseif (orderType == 1) then -- unit
			--DebugMsg("found unit ability for " .. tostring(n))
			local unit
			local bool = false
			if (FriendOrFoe == 1) then bool = true else DAI__CombatDelayedAttackUnit(n,unit) end -- true if ally target
			unit = DAI__CombatGetNearbyHero(n, bool)
			IssueTargetOrder(udg_playerHero[n],orderString,unit)
			DAI__CombatDelayedAttackUnit(n,unit)

		elseif (orderType == 2) then -- instant / stomp
			--DebugMsg("found instant ability for " .. tostring(n))
			local unit = DAI__CombatGetNearbyHero(n, false)
			if (unit ~= nil) then
				IssueImmediateOrder(udg_playerHero[n],orderString)
			end

		-- TODO: elseif (ai__profileAbilityOrderType[id][orderId] == 3) then -- build structure 
			-- orderFunction = function(u,s)
				-- IssueBuildOrder (unit whichPeon, string unitToBuild, real x, real y)
			-- end
		end

		else
			if (ai__combatIncrement[n] ~= 4) then -- don't cast ultimates on minions
				local FriendOrFoe = ai__profileAbilityFriendFoe[id][orderId]
				local orderType = ai__profileAbilityOrderType[id][orderId]

				if (orderType == 0) then -- target point
					--DebugMsg("found target point ability for " .. tostring(n))
					local loc
					local bool = false
					if (FriendOrFoe == 1) then bool = true else DAI__CombatDelayedAttackUnit(n,unit) end -- true if ally target
					local unit = DAI__CombatGetNearbyUnit(n, bool)
					if (unit ~= nil) then
						IssuePointOrder(udg_playerHero[n],orderString,GetUnitX(unit),GetUnitY(unit))
					end
					DAI__CombatDelayedAttackUnit(n,unit)

				elseif (orderType == 1) then -- unit
					--DebugMsg("found unit ability for " .. tostring(n))
					local unit
					local bool = false
					if (FriendOrFoe == 1) then bool = true else DAI__CombatDelayedAttackUnit(n,unit) end -- true if ally target
					unit = DAI__CombatGetNearbyUnit(n, bool)
					IssueTargetOrder(udg_playerHero[n],orderString,unit)
					DAI__CombatDelayedAttackUnit(n,unit)

				elseif (orderType == 2) then -- instant / stomp
					--DebugMsg("found instant ability for " .. tostring(n))
					local unit = DAI__CombatGetNearbyUnit(n, false)
					if (unit ~= nil) then
						IssueImmediateOrder(udg_playerHero[n],orderString)
					end
				end
			end
		end

	end

	ai__combatIncrement[n] = ai__combatIncrement[n] + 1 -- cycle through possible abilities to use

end


-- get a nearby hero
-- @n = player number to check for; returns unit
-- @bool = set to true to grab ally, false to grab enemy
function DAI__CombatGetNearbyHero(n, bool)
	local g = CreateGroup()
	local size = 0
	local p = ConvertedPlayer(n)
	local u = nil
	if (bool) then
		GroupEnumUnitsInRange(g, GetUnitX(udg_playerHero[n]),GetUnitY(udg_playerHero[n]), ai__combatEngageHeroRange__r, Condition( function() return IsUnitAlly(GetFilterUnit(),p) and (not IsUnitDeadBJ(GetFilterUnit())) and (IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO)) end ) )
	else
		GroupEnumUnitsInRange(g, GetUnitX(udg_playerHero[n]),GetUnitY(udg_playerHero[n]), ai__combatEngageHeroRange__r, Condition( function() return IsUnitEnemy(GetFilterUnit(),p) and not BlzIsUnitInvulnerable(GetFilterUnit()) and (not IsUnitDeadBJ(GetFilterUnit())) and (IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO)) end ) )
	end
	size = BlzGroupGetSize(g)
	if (size > 0) then
		u = GroupPickRandomUnit(g)
	end
	DestroyGroup(g)
	return u
end


-- get a nearby unit
-- @n = player number to check for; returns unit
-- @bool = set to true to grab ally, false to grab enemy
function DAI__CombatGetNearbyUnit(n, bool)
	local g = CreateGroup()
	local size = 0
	local p = ConvertedPlayer(n)
	local u = nil
	if (bool) then
		GroupEnumUnitsInRange(g, GetUnitX(udg_playerHero[n]),GetUnitY(udg_playerHero[n]), ai__combatEngageHeroRange__r, Condition( function() return IsUnitAlly(GetFilterUnit(),p) and (not IsUnitDeadBJ(GetFilterUnit())) and (not IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO)) end ) )
	else
		GroupEnumUnitsInRange(g, GetUnitX(udg_playerHero[n]),GetUnitY(udg_playerHero[n]), ai__combatEngageHeroRange__r, Condition( function() return IsUnitEnemy(GetFilterUnit(),p) and not BlzIsUnitInvulnerable(GetFilterUnit()) and (not IsUnitDeadBJ(GetFilterUnit())) and (not IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO)) end ) )
	end
	size = BlzGroupGetSize(g)
	if (size > 0) then
		u = GroupPickRandomUnit(g)
	end
	DestroyGroup(g)
	return u
end


-- @n = player
-- @unit = unit to attack after a short delay
function DAI__CombatDelayedAttackUnit(n, unit)
	TimerStart(NewTimer(n),ai__combatDelayDuration__r,false,function()
		IssueTargetOrder(udg_playerHero[n],"attack",unit)
		ReleaseTimer()
	end)
end


-- @n = player
-- @unit = learn eligible ultimate for this unit
function DAI__LevelUpLearnUltimate(n)
	local ultId = ai__profileAbilityUltimate[ai__heroId[n]]
	SelectHeroSkill(udg_playerHero[n], FourCC(ultId))
end


-- queue item creation for the agent when they level up
-- @n = player
function DAI__LevelUpGrantItem(n)
	if (not udg_playerIsDead[n]) then
		DAI__LevelUpCreateItem(n)
	else
		TimerStart(NewTimer(n),0.99,true,function() -- cannot add to dead heroes, so we run a timer to wait for respawn
			if (not udg_playerIsDead[n]) then
				DAI__LevelUpCreateItem(n)
				ReleaseTimer()
			end
		end)
	end
end


-- create item for the agent from possible item pool
-- @n = player
function DAI__LevelUpCreateItem(n)
	local tempTable = ai__profileItemTable[n] -- grab nested item table so # works
	local roll = math.random(1,#tempTable) -- choose item based on max table size
	local itemId = ai__profileItemTable[n][roll]
	local item = CreateItem(FourCC(itemId),1,1)
	SetItemPlayer(item, ConvertedPlayer(n), false)
	UnitAddItemSwapped(item,udg_playerHero[n])
	table.remove(ai__profileItemTable[n],roll) -- remove from table using roll as index
end
