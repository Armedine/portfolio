--- Utilities by Planetary @ hiveworkshop.com
--- A collection of functions that condense or simplify Blizzard natives and add easy-to-use features.
--- Requires:
--- 	* DetectPlayers
locust_id = FourCC('Aloc')


function table.collapse(t)
	for index, value in pairs(t) do
		if value == nil then
			table.remove(t, index)
		end
	end
end


function table.length(t)
	local count = 0
	for _ in pairs(t) do count = count + 1 end
	return count
end


function table.deep_destroy(t)
	for k,v in t do
		if type(v) == "table" then
			for k2,v2 in v do
				k2 = nil
			end
		end
	end
	t = nil
end


function table.get_index_by_value(t, value)
	for i,v in pairs(t) do
		if v == value then
			return i
		end
	end
	return nil
end


function print_error(text)
	-- print("line "..tostring(debug.getinfo(1).currentline).." error: "..tostring(text))
	print(text)
end


---Print a table's values (depth of 1)
---@param t table -- table to print.
---@param _ipairs? boolean -- use ipairs instead of pairs.
function print_table(t, _ipairs)
	if _ipairs then
		for k,v in ipairs(t) do
			print(k, v)
		end
	else
		for k,v in pairs(t) do
			print(k, v)
		end
	end
end


-- should only be used on tables that are ipairs.
function remove_nils(t)
	local t2 = {}
	for _,v in t do
		t2[#t2+1] = v
	end
	return t2
end


function assign_if_type(var, var_type)
	if var ~= nil and Wc3Type(var) == var_type then return var else return nil end
end


function trunc(num, digits)
	local mult = 10^(digits)
	return math.modf(num*mult)/mult
end


function AllPlayers(func)
	for i = 0,bj_MAX_PLAYERS-1 do
		func(Player(i))
	end
end


function AllCurrentPlayers(func)
	for _,p in pairs(DetectPlayers.player_user_table) do
		func(p)
	end
end


function AllCurrentLocalPlayers(func)
	AllCurrentPlayers(function(p)
		if IsLocalPlayer(p) then
			func(p)
		end
	end)
end


function ForLocalPlayer(p, func)
	if IsLocalPlayer(p) then
		func()
	end
end


function AllComputerPlayers(func)
	for _,p in pairs(DetectPlayers.player_computer_table) do
		func(p)
	end
end


function DisplayTimedTextAll(text, duration)
	AllPlayers(function(p)
		DisplayTimedTextToPlayer(p, 0, 0, duration, text)
	end)
end


function ShouldShowDialogAll(dialog, bool)
	AllPlayers(function(p)
		DialogDisplay(p, dialog, bool)
	end)
end


---Get the player owner of the triggering unit.
---@return player
function GetTriggerUnitPlayer()
	return GetOwningPlayer(GetTriggerUnit())
end


function GetTriggerUnitXY()
	return GetUnitX(GetTriggerUnit()), GetUnitY(GetTriggerUnit())
end


function GetUnitXY(u)
	return GetUnitX(u), GetUnitY(u)
end


function GetTriggerUnitTypeId()
	return GetUnitTypeId(GetTriggerUnit())
end


function GetSoldUnitTypeId()
	return GetUnitTypeId(GetSoldUnit())
end


function RemoveTriggerUnit()
	RemoveUnit(GetTriggerUnit())
end


function RemoveSoldUnit()
	RemoveUnit(GetSoldUnit())
end


function IsHero(u)
	return IsUnitType(u, UNIT_TYPE_HERO)
end


---Set a unit state to a value, with option for a percentage.
---@param u unit -- unit
---@param state string -- life, mana, max_life, max_mana, or all
---@param new_value number -- value to set (for percentage, use 1.0-based values e.g. 0.5 for 50%)
---@param _is_percentage? boolean -- should it be percentage?
function SetState(u, state, new_value, _is_percentage)
	local v = new_value
	if state == "all" then
		if _is_percentage then
			SetUnitState(u, UNIT_STATE_LIFE, math.floor(v*GetUnitState(u, UNIT_STATE_MAX_LIFE)))
			SetUnitState(u, UNIT_STATE_MANA, math.floor(v*GetUnitState(u, UNIT_STATE_MAX_MANA)))
		else
			SetUnitState(u, UNIT_STATE_LIFE, v)
			SetUnitState(u, UNIT_STATE_MANA, v)
		end
	elseif state == "health" or state == "life" then
		if _is_percentage then
			SetUnitState(u, UNIT_STATE_LIFE, math.floor(v*GetUnitState(u, UNIT_STATE_MAX_LIFE)))
		else
			SetUnitState(u, UNIT_STATE_LIFE, v)
		end
	elseif state == "mana" then
		if _is_percentage then
			SetUnitState(u, UNIT_STATE_MANA, math.floor(v*GetUnitState(u, UNIT_STATE_MAX_MANA)))
		else
			SetUnitState(u, UNIT_STATE_MANA, v)
		end
	elseif state == "max_health" or state == "max_life" then
		if _is_percentage then
			BlzSetUnitMaxHP(u, math.floor(v*GetUnitState(u, UNIT_STATE_MAX_LIFE)))
		else
			BlzSetUnitMaxHP(u, math.floor(v))
		end
	elseif state == "max_mana" then
		if _is_percentage then
			BlzSetUnitMaxMana(u, math.floor(v*GetUnitState(u, UNIT_STATE_MAX_MANA)))
		else
			BlzSetUnitMaxMana(u, math.floor(v))
		end
	end
end


---Add a value to a unit state, with option for a percentage.
---@param u unit -- unit
---@param state string -- life, mana, max_life, or max_mana
---@param value number -- value to add (for percentage, use 1.0-based values e.g. 0.5 for 50%)
---@param _is_percentage? boolean -- should it be percentage?
function AddState(u, state, value, _is_percentage)
	local v, us, ms = value, "", ""
	if state == "life" or state == "max_life" then
		us = UNIT_STATE_LIFE
		ms = UNIT_STATE_MAX_LIFE
	elseif state == "mana" or state == "max_mana" then
		us = UNIT_STATE_MANA
		ms = UNIT_STATE_MAX_MANA
	end
	if _is_percentage and string.find(state, "max") then
		-- adjust max state:
		v = GetUnitState(u, ms) + GetUnitState(u, ms)*v
		SetUnitState(u, ms, v)
	elseif _is_percentage then
		-- adjust current state:
		v = GetUnitState(u, us) + GetUnitState(u, ms)*v
		SetUnitState(u, us, v)
	end
end


---Initialize a unit state (has Demon Gate specific game rules).
---@param u unit
---@param health number
---@param mana number
---@param attack number
---@param attack_rate number
---@param _armor? number
---@param _reset_state? boolean
function InitializeUnitState(u, health, mana, attack, attack_rate, _armor, _reset_state)
    SetState(u, "max_life", health, false)
    SetState(u, "max_mana", mana, false)
	SetUnitBaseDamage(u, attack, 0)
	SetUnitBaseDamage(u, attack, 1)
    BlzSetUnitAttackCooldown(u, attack_rate, 0)
	BlzSetUnitRealField(u, UNIT_RF_MANA_REGENERATION, 0.0)
    BlzSetUnitRealField(u, UNIT_RF_HIT_POINTS_REGENERATION_RATE, 0.0)
	if _armor then
		BlzSetUnitArmor(u, _armor) -- native tries to negate bonuses, so add it first.
	end
	if _reset_state then
		SetState(u, "all", 1.0, true)
	end
end


---Create a temporary countdown timer in the top right of the screen and show it automatically.
---@param duration number -- seconds.
---@param title string -- text to show.
---@param code? function -- run this function at the end of the timer.
function CreateCountdownTimer(duration, title, code)
	local t = CreateTimer()
	local d = CreateTimerDialog(t)
	TimerStart(t, duration, false, nil)
	TimerDialogSetTitle(d, title)
	TimerDialogDisplay(d, true)
	TimerQueue:call_delayed(duration + 1.0, function()
		TimerDialogDisplay(d, false)
		DestroyTimerDialog(d)
		if code then
			code()
		end
	end)
	return d
end


---Order a unit to stop.
---@param unit unit
function IssueOrderStop(unit)
	-- order a unit to stop
	IssueImmediateOrderById(unit, 851972)
end


---Order a unit to the center of a rect.
---@param unit unit
---@param rect rect
function IssueOrderMoveToRect(unit, rect)
	IssuePointOrder(unit, 'move', GetRectCenterX(rect), GetRectCenterY(gg_rct_expeditionExit))
end


---Order a unit to an x/y coordinate.
---@param unit unit
---@param x number
---@param y number
function IssueOrderMoveToXY(unit, x, y)
	IssuePointOrder(unit, 'move', x, y)
end


---Issue the smart move command on a target.
---@param unit unit
---@param target widget
function IssueOrderSmartMove(unit, target)
	IssueTargetOrderById(unit, 851971, target)
end


---Order a unit to attack move to a coordinate.
---@param unit unit
---@param x number
---@param y number
function IssueOrderAttackMove(unit, x, y)
	IssuePointOrderById(unit, 851983, x, y)
end


---Order a unit to attack a target.
---@param unit unit
---@param target widget
function IssueOrderAttackUnit(unit, target)
	IssueTargetOrderById(unit, 851983, target)
end

---Check a unit's alive state.
---@param unit widget
---@return boolean
function IsUnitAlive(unit)
	return not (GetUnitTypeId(unit) == 0 or IsUnitType(unit, UNIT_TYPE_DEAD) or GetUnitState(unit, UNIT_STATE_LIFE) < 0.405)
end


---Get the distance between two coordinates.
---@param x1 number -- first x.
---@param y1 number -- first y.
---@param x2 number -- target x.
---@param y2 number -- target y
---@return number -- distance.
function DistanceXY(x1, y1, x2, y2)
	local dx = x2 - x1
	local dy = y2 - y1
	return SquareRoot(dx * dx + dy * dy)
end


---Get the angle from an origina coordinate to a target coordinate.
---@param x1 number -- origin x.
---@param y1 number -- origin y.
---@param x2 any 	-- target x.
---@param y2 any 	-- target y.
---@return number 	-- new angle.
function AngleFromXY(x1, y1, x2, y2)
	return bj_RADTODEG * Atan2(y2 - y1, x2 - x1)
end


---Get a next coordinate based on a distance and angle from a previous coordinate.
---@param x1 number -- origin x.
---@param y1 number -- origin y.
---@param d number  -- distance.
---@param a number  -- towards this angle.
---@return number   -- new x.
---@return number   -- new y.
function ProjectXY(x1, y1, d, a)
	local x = x1 + d * Cos(a * bj_DEGTORAD)
	local y = y1 + d * Sin(a * bj_DEGTORAD)
	return x,y
end


---Move a unit to a coordinate instantly.
---@param unit unit
---@param x number
---@param y number
function SetUnitXY(unit, x, y)
	SetUnitX(unit, x) SetUnitY(unit, y)
end


function PlayerNumber(p)
	return GetConvertedPlayerId(p)
end


---Set a unit's base damage for an attack.
---@param u unit -- unit.
---@param value number -- to this value.
---@param _weapon_index? integer -- (optional) attack to update.
function SetUnitBaseDamage(u, value, _weapon_index)
	BlzSetUnitWeaponIntegerField(u, UNIT_WEAPON_IF_ATTACK_DAMAGE_BASE, _weapon_index or 0, math.floor(value))
end


---Scale a unit's base damage based on a percentage (1.0-based arguments).
---@param u unit -- unit.
---@param value number -- 1.0-based value to scale damage by (e.g. 1.5 = 150%).
---@param _weapon_index? integer -- (optional) attack to update.
function SetUnitBaseDamageScaled(u, value, _weapon_index)
	BlzSetUnitWeaponIntegerField(u, UNIT_WEAPON_IF_ATTACK_DAMAGE_BASE, _weapon_index or 0, math.floor(BlzGetUnitWeaponIntegerField(u, UNIT_WEAPON_IF_ATTACK_DAMAGE_BASE, 0)*value))
end


function IsLocalTriggerPlayer()
	return GetLocalPlayer() == GetTriggerPlayer()
end


function IsLocalPlayer(p)
	return GetLocalPlayer() == p
end


---Fades a unit's alpha over time, then hides/shows it.
---@param u unit -- unit to hide.
---@param hide_bool boolean -- show or hide flag.
---@param _duration number -- default is 1.0
function FadeUnitHide(u, hide_bool, _duration)
	local t = CreateTimer()
	local r = BlzGetUnitIntegerField(u, UNIT_IF_TINTING_COLOR_RED)
	local g = BlzGetUnitIntegerField(u, UNIT_IF_TINTING_COLOR_GREEN)
	local b = BlzGetUnitIntegerField(u, UNIT_IF_TINTING_COLOR_BLUE)
	local a
	if hide_bool then
		a = 255
		SetUnitVertexColor(u, r, g, b, a)
	else
		a = 0
		SetUnitVertexColor(u, r, g, b, a)
	end
	local count_ticks = 0
	local target_ticks = math.floor(33.3333*(_duration or 0.33))
	local a_tick = 255/target_ticks
	TimerStart(t, 0.03, true, function()
		if hide_bool then
			a = a - a_tick
		else
			a = a + a_tick
		end
		count_ticks = count_ticks + 1
		SetUnitVertexColor(u, r, g, b, math.max(1, math.ceil(a)))
		if target_ticks == count_ticks or not u then
			if u then
				if hide_bool then
					ShowUnitHide(u)
				else
					ShowUnitShow(u)
				end
				SetUnitVertexColor(u, r, g, b, 255)
			end
			DestroyTimer(t)
		end
	end)
	return t
end


local PxToRatio_source_height = 1440 -- the screen height the pixel value was pulled from (i.e. your monitor).
local PxToRatio_local_height = BlzGetLocalClientHeight() -- the player's monitor.
local PxToRatio_precalc = (0.6*(PxToRatio_local_height/PxToRatio_source_height))/PxToRatio_local_height
---Convert pixels to screen width percentage from a source screen (1440p x 2560p).
---Formula: pixels * ( ( 0.6 * ( screen_height/screen_height_design_source ) ) / screen_height ).
---
---1440p precal = 0.000416
---@param px integer
---@return number
function pixels(px)
	return px*PxToRatio_precalc
end


function PlaySoundForPlayer(snd, p)
	if IsLocalPlayer(p) then
		StopSound(snd, false, false)
		StartSound(snd)
	end
end


function PlaySoundForAllPlayers(snd)
	AllPlayers(function(p)
		if IsLocalPlayer(p) then
			StopSound(snd, false, false)
			StartSound(snd)
		end
	end)
end
