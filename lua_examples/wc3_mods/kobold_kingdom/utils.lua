utils       = {} -- class.
utils.weakt = {} -- table for storing weak tables to gc (temp tables).
utils.debug    = false
utils.lorem = "Space, the final frontier. These are the voyages of the Starship"
    .." Enterprise. Its five-year mission: to explore strange new worlds, to seek out new"
    .." life and new civilizations, to boldly go where no man has gone before. Many say"
    .." exploration is part of our destiny, but it’s actually our duty to future generations"
    .." and their quest to ensure the survival of the human species."
utils.hotkeyt  = {} -- store player hotkey trigs.
setmetatable(utils.weakt, { __mode = 'k' })


function utils.init()
  fp = { -- shorthand 'FRAMEPOINT' for terser code.
    tl = FRAMEPOINT_TOPLEFT, t = FRAMEPOINT_TOP, tr = FRAMEPOINT_TOPRIGHT, r = FRAMEPOINT_RIGHT, br = FRAMEPOINT_BOTTOMRIGHT,
    b = FRAMEPOINT_BOTTOM, bl = FRAMEPOINT_BOTTOMLEFT, l = FRAMEPOINT_LEFT, c = FRAMEPOINT_CENTER, }
end


-- fetch top left corner of a rect (how grid layout is determined).
function utils.getrectcorner(rect)
    return GetRectMinX(rect), GetRectMaxY(rect)
end


function utils.xpcall( func )
  local status = xpcall( func, utils.printerror )
  -- print(status)
end


function utils.fixfocus(fh)
  BlzFrameSetEnable(fh, false)
  BlzFrameSetEnable(fh, true)
end


function utils.printerror( err )
   print( "error:", err )
end


function utils.debugfunc( func, name )
  local name = name or ""
  local passed, data = pcall( function() func() return "func " .. name .. " passed" end )
  if not passed then
    print(name, passed, data)
  end
  -- global debug options:
  -- print("debug:"..tostring(name))
end


function commaformat(amount)
  local formatted = tostring(amount)
  local k
  while true do  
    formatted, k = string.gsub(formatted, "^(-?\x25d+)(\x25d\x25d\x25d)", '\x251,\x252')
    if (k==0) then
      break
    end
  end
  return formatted
end


-- :: helper function to check if table has index value.
-- @t = table to search.
-- @v = value to search for, returns true if it exists; false if not.
function utils.tableindexof(t,v)
  for index, value in pairs(t) do
      if index == v then
          return index
      end
  end
  return false
end


function utils.removefromtable(t,val)
  for i,v in pairs(t) do
    if v == val then
      table.remove(t, i)
    end
  end
end


-- :: count number of tables within a table.
-- @t = table to search; returns number of tables.
function utils.counttables(t)
  local count = 0
  for t in pairs(t) do
    if type(t) == "table" then
      count = count +1
    end
  end
  return count
end


function utils.tablelength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end


-- :: helper function to see if table has value
-- @t = table to search
-- @v = value to search for, returns true if it exists; false if not
function utils.tablehasvalue(t,v)
    for index, value in pairs(t) do
        if value == v then
            return true
        end
    end
    return false
end


function utils.tablehasindex(t,v)
    for index, value in pairs(t) do
        if index == v then
            return true
        end
    end
    return false
end


-- :: helper function to remove table index by searching for value
-- @t = table to search
-- @v = value to search for, returns index of that value where it exists in @t, returns false if it doesn't exist
function utils.tablevalueindex(t,v)
    for index, value in pairs(t) do
        if value == v then
            return index
        end
    end
    return nil
end


-- :: helper function to collapse a table or array (remove empty spaces) e.g. [0, nil, 2] becomes [0,2]
-- @t = table to collapse
function utils.tablecollapse(t)
  for index, value in pairs(t) do
      if value == nil then
          table.remove(t, index)
      end
  end
end


function utils.tabledeleteifempty(t)
  for index, value in pairs(t) do
      if value ~= nil then
          return false
      end
  end
  t = nil
  return true
end


function utils.distxy(x1,y1,x2,y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return SquareRoot(dx * dx + dy * dy)
end


function utils.distanglexy(x1,y1,x2,y2)
  return utils.distxy(x1,y1,x2,y2), utils.anglexy(x1,y1,x2,y2)
end


function utils.distunits(unit1,unit2)
  return utils.distxy(utils.unitx(unit1), utils.unity(unit1), utils.unitx(unit2), utils.unity(unit2))
end


-- ::  (alternative name that always causes headaches, so make it work) get facing angle from A to B
-- @x1,y1 = point A (facing from)
-- @x2,y2 = point B (facing towards)
function utils.anglexy(x1,y1,x2,y2)
  return bj_RADTODEG * Atan2(y2 - y1, x2 - x1)
end


function utils.angleunits(unit1, unit2)
  return bj_RADTODEG * Atan2(utils.unity(unit2) - utils.unity(unit1), utils.unitx(unit2) - utils.unitx(unit1))
end


-- :: PolarProjectionBJ converted to x,y
-- @x1,y1 = origin coord
-- @d = distance between origin and direction
-- @a = angle to project
function utils.projectxy(x1,y1,d,a)
    local x = x1 + d * Cos(a * bj_DEGTORAD)
    local y = y1 + d * Sin(a * bj_DEGTORAD)

    return x,y
end


function utils.unitprojectxy(unit,d,a)
    local x = utils.unitx(unit) + d * Cos(a * bj_DEGTORAD)
    local y = utils.unity(unit) + d * Sin(a * bj_DEGTORAD)

    return x,y
end


-- :: clones a table
-- @t = table to copy
function utils.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end


-- :: clones a table and any child tables
-- @t = table to copy
function utils.deep_copy(t)
  if type(t) == "table" then
    local t2 = {}
    for k,v in pairs(t) do
      if type(v) == "table" then
        t2[k] = utils.deep_copy(v)
        if getmetatable(v) then
          setmetatable(t2[k], getmetatable(v)) 
        end
      else
        t2[k] = v
      end
    end
    if getmetatable(t) then
      setmetatable(t2, getmetatable(t)) 
    end
    return t2
  else
    return t
  end
end


-- safest destroy loop.
function utils.shallow_destroy(t)
  for k,v in pairs(t) do
    v = nil
    k = nil
  end
  t = nil
end


-- :: loop through a parent table to find child tables, and delete them.
-- *note: will overflow the stack if used on tables that have self references.
-- @t = search this table.
function utils.deep_destroy(t)
  if t and type(t) == "table" then
    for k,v in pairs(t) do
      if k and v and type(v) == "table" then
        utils.deep_destroy(v)
      else
        v = nil
      end
    end
  elseif t then
    t = nil
  end
end


-- :: get the length of a table.
-- @t = table to measure
function utils.tablelength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end


-- :: round a number to a decimal place.
-- @num           = round this number
-- @numdecplaces  = to this many decimal places (use 0 for a whole number)
function utils.round(num, numdecplaces)
  local mult = 10^numDecimalPlaces
  return math.floor(num * mult + 0.5) / mult
end


-- :: shorthand for getting a player number
function utils.pid(player)
  return GetConvertedPlayerId(player)
end


function utils.powner(unit)
  return GetOwningPlayer(unit)
end


-- :: shorthand for getting a player number based on a unit
function utils.pidunit(unit)
  return GetConvertedPlayerId(GetOwningPlayer(unit))
end


-- @snd = sound to play
-- @p   = [optional] for this player (defaults to trig player)
function utils.soundstop(snd, p)
  if not p then p = GetTriggerPlayer() end
  if GetLocalPlayer() == p then
      StopSound(snd, false, false)
  end
end


function utils.triggeron(trig, bool)
  if bool then
    EnableTrigger(trig)
  else
    DisableTrigger(trig)
  end
end


function utils.localp()
  return GetLocalPlayer()
end

function utils.islocalp(p)
  return GetLocalPlayer() == p
end


function utils.getp(pnum)
  return Player(pnum-1)
end


function utils.pnum(p)
  return GetConvertedPlayerId(p)
end


function utils.trigpnum()
  return GetConvertedPlayerId(GetTriggerPlayer())
end


function utils.unitp()
  return GetOwningPlayer(GetTriggerUnit())
end


function utils.trigp()
  return GetTriggerPlayer()
end


function utils.trigu()
  return GetTriggerUnit()
end


function utils.killu()
  return GetKillingUnit()
end


function utils.triguid()
  return GetUnitTypeId(utils.trigu())
end


function utils.islocaltrigp()
  return GetLocalPlayer() == GetTriggerPlayer()
end


function utils.playsound(snd, p)
  local p = p or GetTriggerPlayer()
  if utils.localp() == p then
      StopSound(snd, false, false)
      StartSound(snd)
  end
end


function utils.playsoundall(snd)
  utils.looplocalp(function()
    StopSound(snd, false, false)
    StartSound(snd)
  end)
end


function utils.stopsoundall(snd)
  utils.looplocalp(function()
    StopSound(snd, false, false)
  end)
end


-- @rect = rect to get center of.
-- @p    = owning player
-- @id   = unit raw code to create.
function utils.unitinrect(rect, p, id)
  -- try to capture most use cases with a short function.
  return CreateUnit(p, FourCC(id), GetRectCenterX(rect), GetRectCenterY(rect), 255.0)
end


function utils.unitatxy(p, x, y, id, _face)
  return CreateUnit(p, FourCC(id), x, y, _face or 270.0)
end


-- @p   = this player
-- @x,y = coords.
-- @dur = [optional] over seconds. 
function utils.panto(p, x, y, dur)
  -- map camera to x,y instantly
  local dur = dur or 0.0
  PanCameraToTimedForPlayer(p, x, y, dur)
end


-- @p      = this player.
-- @unit   = this unit.
-- @dur    = [optional] over seconds. 
function utils.pantounit(p, unit, dur)
  -- map camera to x,y instantly
  local dur = dur or 0.0
  PanCameraToTimedForPlayer(p, GetUnitX(unit), GetUnitY(unit), dur)
end


-- @p   = this player.
-- @r   = this rect center.
-- @dur = [optional] over seconds. 
function utils.pantorect(p, r, dur)
  -- map camera to x,y instantly
  local dur = dur or 0.0
  PanCameraToTimedForPlayer(p, GetRectCenterX(r), GetRectCenterY(r), dur)
end


function utils.fadeblack(bool, _dur)
  -- turn screen black
  utils.looplocalp(function()
    if bool then
      CinematicFadeBJ( bj_CINEFADETYPE_FADEOUT, _dur or 0.0, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0 )
    else
      CinematicFadeBJ( bj_CINEFADETYPE_FADEIN, _dur or 0.0, "ReplaceableTextures\\CameraMasks\\Black_mask.blp", 0, 0, 0, 0 )
    end
  end)
end


-- @unit = follow this unit
-- @p = for this player
function utils.camlockunit(unit, p)
  SetCameraTargetControllerNoZForPlayer(p, unit, 0, 0, false)
end


-- @unit = select this unit
-- @p = for this player
function utils.selectu(unit, p)
  if utils.localp() == p then
    if not IsUnitSelected(unit, p) then
      SelectUnitForPlayerSingle(unit, p)
    end
    SetCameraFieldForPlayer(p, CAMERA_FIELD_TARGET_DISTANCE, 2200.0, 0)
    SetCameraFieldForPlayer(p, CAMERA_FIELD_ANGLE_OF_ATTACK, 304.0, 0)
    SetCameraFieldForPlayer(p, CAMERA_FIELD_ZOFFSET, 75.0, 0)
  end
end


-- @unit = select this unit
-- @p = for this player, every 0.03 sec
-- @t = store the timer on this table as .permtimer
function utils.permselect(unit, p, t)
  local unit,p = unit,p
  local func = function()
    if not screenplay.pause_camera then
      utils.pantounit(p, unit, 0.23)
      utils.selectu(unit, p)
    end
  end
  t.permtimer = NewTimer()
  TimerStart(t.permtimer, 0.03, true, func)
  SetTimerData(t.permtimer, func)
end


function utils.temphide(unit, bool)
  -- temporarily remove a unit (but maintaining their location presence).
  SetUnitPathing(unit, not bool)
  PauseUnit(unit, bool)
  utils.setinvul(unit, bool)
  utils.vertexhide(unit, bool)
end


function utils.stop(unit)
  -- order a unit to stop
  IssueImmediateOrderById(unit, 851972)
end


function utils.issmoverect(unit, rect)
  IssuePointOrder(unit, 'move', GetRectCenterX(rect), GetRectCenterY(gg_rct_expeditionExit))
end


function utils.issmovexy(unit, x, y)
  IssuePointOrder(unit, 'move', x, y)
end


function utils.smartmove(unit, target)
  IssueTargetOrderById(unit, 851971, target)
end


function utils.issatkxy(unit, x, y)
  IssuePointOrderById(unit, 851983, x, y)
end


function utils.issatkunit(unit, target)
  IssueTargetOrderById(unit, 851983, target)
end


-- @bool = var to switch.
-- @dur  = after x sec.
-- @flag = timer switch result (true or false)
function utils.booltimer(bool, dur, flag)
  -- a simple flag switch timer
  bool = not flag
  TimerStart(NewTimer(), dur, false, function()
    bool = flag ReleaseTimer()
  end)
end


function utils.umoverect(unit, rect)
  -- move unit to center of rect
  SetUnitPosition(unit, GetRectCenterX(rect), GetRectCenterY(rect))
end


function utils.umovexy(unit, x, y)
  -- move unit to center of rect
  SetUnitPosition(unit, x, y)
end


-- displays a red message followed by an error sound, or a green message with no sound if @_ispositive is passed as true
function utils.palert(p, str, dur, _ispositive)
  local dur = dur or 2.5
  if p == utils.localp() then
    if _ispositive then
      alert:new(color:wrap(color.tooltip.good, str), dur)
    else
      alert:new(color:wrap(color.tooltip.bad, str), dur)
      utils.playsound(kui.sound.error, p)
    end
  end
end


function utils.palertall(str, dur, _soundsuppress)
  utils.playerloop(function(p) utils.palert(p, str, dur, _soundsuppress) end)
end


function utils.pname(p)
  return GetPlayerName(p)
end


-- @func = run this for all players, but local only.
function utils.looplocalp(func)
  for p,_ in pairs(kobold.playing) do
    if p == utils.localp() then
      func()
    end
  end
end


function utils.textall(str)
  DisplayTextToForce(GetPlayersAll(), str)
end


function utils.unitx(taru)
  return GetUnitX(taru)
end


function utils.unity(taru)
  return GetUnitY(taru)
end


function utils.unitxy(taru)
  return GetUnitX(taru), GetUnitY(taru)
end


function utils.setxy(unit, x, y)
  SetUnitX(unit,x) SetUnitY(unit,y)
end


function utils.setheight(unit, z)
  SetUnitFlyHeight(unit, z, 10000.0)
end


function utils.face(unit, a)
  SetUnitFacing(unit, a)
end


function utils.faceunit(unit1, unit2)
  SetUnitFacing(unit1, utils.angleunits(unit1, unit2))
end


-- make both units face eachother.
function utils.eachface(unit1, unit2)
  SetUnitFacing(unit1, utils.anglexy(utils.unitx(unit1), utils.unity(unit1), utils.unitx(unit2), utils.unity(unit2)))
  SetUnitFacing(unit2, utils.anglexy(utils.unitx(unit2), utils.unity(unit2), utils.unitx(unit1), utils.unity(unit1)))
end


function utils.getface(unit)
  return GetUnitFacing(unit)
end


function utils.data(unit)
  return GetUnitUserData(unit)
end


function utils.spellxy()
  return GetSpellTargetX(), GetSpellTargetY()
end


function utils.rectxy(rect)
  return GetRectCenterX(rect), GetRectCenterY(rect) 
end


function utils.rectx(rect)
  return GetRectCenterX(rect)
end


function utils.recty(rect)
  return GetRectCenterY(rect) 
end


function utils.setcambounds(rect, _singlep)
  if not _singlep then -- set for all players
    for p,_ in pairs(kobold.playing) do
        SetCameraBoundsToRectForPlayerBJ(p, rect)
    end
  else -- target a single player
    SetCameraBoundsToRectForPlayerBJ(_singlep, rect)
  end
end


function utils.playerloop(func)
  -- run an action on all player objects (make sure function has 'p' as arg e.g. 'myfunc(p [,...])')
  for pnum = 1,kk.maxplayers do
    local p = Player(pnum-1)
    if kobold.player[p] then
      func(p)
    end
  end
end


function utils.moveallp(rect)
  -- move all players to this rect center
  utils.playerloop(function(p) utils.umoverect(kobold.player[p].unit, rect) end)
end


function utils.moveallpxy(x,y)
  -- move all players to this rect center
  utils.playerloop(function(p) utils.umovexy(kobold.player[p].unit, x, y) port_yellowtp:play(x, y) end)
end


function utils.panallp(x, y, _dur)
  -- pan camera for all players to x,y.
  local dur = _dur or 0
  utils.playerloop(function(p) utils.panto(p, x, y, dur) end)
end


function utils.timed(dur, func)
  -- one shot timer
  TimerStart(NewTimer(), dur, false, function() func() ReleaseTimer() end)
end


function utils.timedrepeat(dur, count, func, _releasefunc)
  local t, c, r = count, 0, _releasefunc or nil
  if t == nil then
    local tmr = TimerStart(NewTimer(), dur, true, function()
      utils.debugfunc(func,"timer") end)
    return tmr
  else
    local tmr = TimerStart(NewTimer(), dur, true, function()
      utils.debugfunc(function()
        func(c)
        c = c + 1
        if c >= t then
          ReleaseTimer()
          if r then r() end
        end
      end, "timer")
    end)
    return tmr
  end
end


function utils.newhotkey(p, oskey, func, islocal, ondown, meta)
    local p, pnum   = p, utils.pnum(p)
    local meta      = meta      or 0
    local ondown    = ondown    or true
    local islocal   = islocal   or true
    if not utils.hotkeyt[pnum] then
        utils.hotkeyt[pnum] = CreateTrigger()
    end
    BlzTriggerRegisterPlayerKeyEvent(utils.hotkeyt[pnum], p, oskey, meta, ondown)
    TriggerAddAction(utils.hotkeyt[pnum], function()
        if utils.ishotkey(p, oskey) then
            if islocal and p == GetLocalPlayer() then
                func()
            else
                func()
            end
        end
    end)
    return trig
end


function utils.ishotkey(p, oskey)
    if p == GetLocalPlayer() then
        if BlzGetTriggerPlayerKey() == oskey then
            return true
        else
            return false
        end
    end
end


function utils.disableuicontrol(bool)
  utils.looplocalp(function() EnableUserControl(not bool) EnableUserUI(not bool) end)
end


function utils.mana(unit)
  return GetUnitState(unit, UNIT_STATE_MANA)
end


function utils.maxmana(unit)
  return GetUnitState(unit, UNIT_STATE_MAX_MANA)
end


function utils.life(unit)
  return GetUnitState(unit, UNIT_STATE_LIFE)
end


function utils.maxlife(unit)
  return GetUnitState(unit, UNIT_STATE_MAX_LIFE)
end


function utils.setlifep(unit, val)
  -- 100-based.
  SetUnitLifePercentBJ(unit, val)
end


function utils.setmanap(unit, val)
  -- 100-based.
  SetUnitManaPercentBJ(unit, val)
end


function utils.getlifep(unit)
  -- 100-based.
  return GetUnitLifePercent(unit)
end


function utils.getmanap(unit)
  -- 100-based.
  return GetUnitManaPercent(unit)
end


-- @_owner = owner of the heal
function utils.addlifep(unit, val, _arctextbool, _owner)
  -- 100-based
  local amt = utils.maxlife(unit)*val/100
  if _owner and kobold.player[utils.powner(_owner)] then
    local p = utils.powner(_owner)
    amt = amt*(1+kobold.player[p][p_stat_healing]/100)
    kobold.player[p].score[4] = kobold.player[p].score[4] + amt
  end
  SetUnitState(unit, UNIT_STATE_LIFE, utils.life(unit) + amt)
  if _arctextbool and amt > 1.0 then
    ArcingTextTag(color:wrap(color.tooltip.good, "+"..math.floor(amt)), unit, 2.0)
  end
end


function utils.addmanap(unit, val, _arctextbool)
  -- 100-based
  local amt = utils.maxmana(unit)*val/100
  SetUnitState(unit, UNIT_STATE_MANA, utils.mana(unit) + amt)
  if _arctextbool and amt > 1.0 then
    ArcingTextTag(color:wrap(color.tooltip.alert, "+"..math.floor(amt)), unit, 2.0)
  end
end


function utils.addlifeval(unit, val, _arctextbool, _owner)
  -- add a raw life value to a unit.
  local val, p = val, utils.powner(unit)
  if _owner and kobold.player[utils.powner(_owner)] then
    local p = utils.powner(_owner)
    val = val*(1+kobold.player[p][p_stat_healing]/100)
    kobold.player[p].score[4] = kobold.player[p].score[4] + val
  end
  SetUnitState(unit, UNIT_STATE_LIFE, utils.life(unit) + val)
  if _arctextbool and val > 1.0 then
    ArcingTextTag(color:wrap(color.tooltip.good, "+"..math.floor(val)), unit, 2.0)
  end
end


function utils.addmanaval(unit, val, _arctextbool)
  -- add a raw life value to a unit.
  SetUnitState(unit, UNIT_STATE_MANA, RMaxBJ(utils.mana(unit) + val))
  if _arctextbool and val > 1.0 then
    ArcingTextTag(color:wrap(color.tooltip.alert, "+"..math.floor(val)), unit, 2.0)
  end
end


function utils.setlifep(unit, val)
  SetUnitState(unit, UNIT_STATE_LIFE, math.floor(GetUnitState(unit, UNIT_STATE_MAX_LIFE)*(val/100)))
end


function utils.setmanap(unit, val)
  SetUnitState(unit, UNIT_STATE_MANA, math.floor(GetUnitState(unit, UNIT_STATE_MAX_MANA)*(val/100)))
end


function utils.restorestate(unit)
  utils.setlifep(unit, 100)
  utils.setmanap(unit, 100)
  UnitRemoveBuffs(unit, true, true)
end


function utils.setnewdesthp(dest, val)
  SetDestructableMaxLife(dest, val)
  SetDestructableLifePercentBJ(dest, 100)
end


function utils.setnewunithp(unit, val, _resethp)
  BlzSetUnitMaxHP(unit, math.floor(val))
  if _resethp then
    utils.setlifep(unit, 100)
  end
end


function utils.setnewunitmana(unit, val, _donotreset)
  BlzSetUnitMaxMana(unit, math.floor(val))
  if not _donotreset and not map.manager.activemap then
    utils.setmanap(unit, 100)
  end
end


function utils.passivep()
  return Player(PLAYER_NEUTRAL_PASSIVE)
end


function utils.tempt()
  local t = {}
  utils.weakt[t] = t
  return t
end


function utils.isalive(unit)
  return not (GetUnitTypeId(unit) == 0 or IsUnitType(unit, UNIT_TYPE_DEAD) or GetUnitState(unit, UNIT_STATE_LIFE) < 0.405)
end


function utils.ishero(unit)
  return IsUnitType(unit, UNIT_TYPE_HERO)
end


function utils.isancient(unit)
  return IsUnitType(unit, UNIT_TYPE_ANCIENT)
end


function utils.speffect(effect, x, y, _scale, _perm)
  local e = AddSpecialEffect(effect, x, y)
  BlzSetSpecialEffectScale(e, _scale or 1.0)
  if not _perm then DestroyEffect(e) end
  return e
end


function utils.setinvul(unit, bool)
  SetUnitInvulnerable(unit, bool)
end


function utils.setinvis(unit, bool)
  if bool then
    UnitAddAbility(unit, FourCC('Apiv'))
  else
    UnitRemoveAbility(unit, FourCC('Apiv'))
  end
end


function utils.vertexhide(unit, bool)
  if bool then
    SetUnitVertexColor(unit, 255, 255, 255, 0)
  else
    SetUnitVertexColor(unit, 255, 255, 255, 255)
  end
end


-- @x,y = reposition an effect.
function utils.seteffectxy(effect, x, y, _z)
    BlzSetSpecialEffectX(effect, x)
    BlzSetSpecialEffectY(effect, y)
    if _z then
      BlzSetSpecialEffectZ(effect, _z)
    end
end


function utils.getcliffz(x, y, _height)
  return GetTerrainCliffLevel(x, y)*128 - 256 + (_height or 0)
end


function utils.dmgdestinrect(rect, dmg)
  EnumDestructablesInRect(rect, nil, function()
    if GetDestructableTypeId(GetEnumDestructable()) ~= b_bedrock.code then
      SetWidgetLife(GetEnumDestructable(), GetWidgetLife(GetEnumDestructable()) - dmg)
    end
  end)
end


-- move a rect to @x,y then set its size to @w/@_h based on a radius value.
function utils.setrectradius(rect, x, y, w, _h)
  local w, h = w, _h or w
  SetRect(rect, x - w, y - h, x + w, y + h)
end


function utils.stunned(unit)
  return UnitHasBuffBJ(unit, FourCC('BSTN')) or UnitHasBuffBJ(unit, FourCC('BPSE'))
end


function utils.slowed(unit)
  return UnitHasBuffBJ(unit, FourCC('Bslo')) or UnitHasBuffBJ(unit, FourCC('Bfro'))
end


function utils.scaleatk(unit, val)
  BlzSetUnitBaseDamage(unit,  math.ceil( BlzGetUnitBaseDamage(unit, 0)*val), 0 )
end


function utils.newclass(t)
    local t = t
    t.__index = t
    t.lookupt = {}
    t.new = function()
        local o = {}
        setmetatable(o, t)
        return o
    end
    t.destroy = function()
        t.lookupt[t] = nil
    end
    if utils.debug then print("made new class for "..tostring(t)) end
end


-- :: clones a table and any child tables (setting metatables)
-- @t = table to copy
function utils.deepcopy(t)
  local t2 = {}
  if getmetatable(t) then
    setmetatable(t2, getmetatable(t))
  end
  for k,v in pairs(t) do
    if type(v) == "table" then
      local newt = {}
      if getmetatable(v) then
        setmetatable(newt, getmetatable(v))
      end
      for k2, v2 in pairs(v) do
        newt[k2] = v2
      end
      t2[k] = newt
    else
      t2[k] = v
    end
  end
  return t2
end


function utils.destroytable(t)
    for i,v in pairs(t) do
        if type(v) == "table" then
            for i2,v2 in pairs(v) do
                v2 = nil
                i2 = nil
            end
        else
            v = nil
            i = nil
        end
    end
end


-- @bool = true to fade out (hide); false to fade in (show).
function utils.fadeframe(bool, fh, dur)
  BlzFrameSetVisible(fh, true)
  local bool  = bool
  local fh    = fh
  local alpha = 255
  local int   = math.floor(255/math.floor(dur/0.03))
  local tmr
  -- show:
  if bool then
    BlzFrameSetVisible(fh, true)
    BlzFrameSetAlpha(fh, 255)
    tmr = utils.timedrepeat(0.03, nil, function()
        if BlzFrameGetAlpha(fh) > 0 and BlzFrameGetAlpha(fh) > int then
            alpha = alpha - int
            BlzFrameSetAlpha(fh, alpha)
        else
            BlzFrameSetAlpha(fh, 0)
            BlzFrameSetVisible(fh, false)
            ReleaseTimer()
        end
    end)
  -- hide:
  else
    BlzFrameSetVisible(fh, true)
    BlzFrameSetAlpha(fh, 0)
    tmr = utils.timedrepeat(0.03, nil, function()
        if BlzFrameGetAlpha(fh) ~= 255 and BlzFrameGetAlpha(fh) < 255 - int then
            alpha = alpha + int
            BlzFrameSetAlpha(fh, alpha)
        else
            BlzFrameSetAlpha(fh, 255)
            BlzFrameSetVisible(fh, true)
            ReleaseTimer()
        end
    end)
  end
  return tmr
end


function utils.frameaddevent(fh, func, frameeventtype)
  local trig = CreateTrigger()
  local fh   = fh
  BlzTriggerRegisterFrameEvent(trig, fh, frameeventtype)
  TriggerAddCondition(trig, Condition(function()
      return BlzGetTriggerFrameEvent() == frameeventtype and BlzGetTriggerFrame() == fh
  end) )
  TriggerAddAction(trig, func)
  return trig
end


function utils.speechindicator(unit)
    UnitAddIndicatorBJ(unit, 100, 100, 0.00, 0)
end


function utils.trim(str)
  return string.gsub(str, "\x25s+", "")
end


-- for index-value table, get a random value.
function utils.trandom(t)
  return t[math.random(1,#t)]
end


-- requires v1 to be a negative number
function math.randomneg(v1,v2)
  if v1 >= 0 then print("math.randomneg only supports negative first argument") return end
  return math.random(0, v2+(-1*v1)) - v1
end


function utils.isinvul(u)
  return BlzIsUnitInvulnerable(u)
end


function utils.timedlife(u, dur)
  UnitApplyTimedLife(u, FourCC('BTLF'), dur)
end


-- order all units of @player within @radius of @x,y to attack move to position of @unit 
function utils.issueatkmoveall(player, radius, x, y, unit)
  local grp = g:newbyxy(player, g_type_ally, x, y, radius)
  grp:action(function() if not utils.isancient(grp.unit) then utils.issatkxy(grp.unit, utils.unitxy(unit)) end end)
  grp:destroy()
end


function utils.shakecam(p, dur, _mag)
  CameraSetEQNoiseForPlayer(p, _mag or 3.0)
  utils.timed(dur, function() CameraClearNoiseForPlayer(p) end)
end


function utils.booltobit(value)
  if value == true then return 1 else return 0 end
end


function utils.purgetrailing(str, char)
  local str = str
  if string.sub(str, -1) == char then str = string.sub(str,1,-2) end -- purge trailing character (last char).
  return str
end


-- split a string into a table based on a separator. returns @table
function utils.split(str, sep)
    sep = sep or "\x25s"
    local t = {}
    for field, s in string.gmatch(str, "([^" .. sep .. "]*)(" .. sep .. "?)") do
        table.insert(t, field)
        if s == "" then
            return t
        end
    end
end


function utils.tablesize(t)
  local count = 0
  for i,v in pairs(t) do
    count = count + 1
  end
  return count
end
