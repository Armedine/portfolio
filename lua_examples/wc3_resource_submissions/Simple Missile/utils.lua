utils = {}


function utils.powner(unit)
  return GetOwningPlayer(unit)
end


function utils.distxy(x1,y1,x2,y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return SquareRoot(dx * dx + dy * dy)
end


function utils.unitxy(taru)
  return GetUnitX(taru), GetUnitY(taru)
end


function utils.anglexy(x1,y1,x2,y2)
  return bj_RADTODEG * Atan2(y2 - y1, x2 - x1)
end


function utils.projectxy(x1,y1,d,a)
    local x = x1 + d * Cos(a * bj_DEGTORAD)
    local y = y1 + d * Sin(a * bj_DEGTORAD)

    return x,y
end


function utils.isalive(unit)
  return not (GetUnitTypeId(unit) == 0 or IsUnitType(unit, UNIT_TYPE_DEAD))
end


function utils.pnum(p)
  return GetConvertedPlayerId(p)
end


function utils.powner(unit)
  return GetOwningPlayer(unit)
end


function utils.debugfunc( func, name )
  local name = name or ""
  local passed, data = pcall( function() func() return "func " .. name .. " passed" end )
  if not passed then  
    print(name, passed, data)
  end
end


function utils.tablecollapse(t)
  for index, value in pairs(t) do
      if value == nil then
          table.remove(t, index)
      end
  end
end


function utils.speffect(effect, x, y)
  DestroyEffect(AddSpecialEffect(effect, x, y))
end


function utils.timedrepeat(dur, count, func)
  local t, c = count, 0
  if t == nil then
    TimerStart(NewTimer(), dur, true, function() func() end)
  else
    TimerStart(NewTimer(), dur, true, function() func() c = c + 1 if c >= t then ReleaseTimer() end end)
  end
end


function utils.tablelength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end


function utils.tabledeepdestroy(t)
  for k,v in t do
    if type(v) == "table" then
      for k2,v2 in v do
        k2 = nil
      end
    end
  end
  t = nil
end


function utils.setxy(unit, x, y)
  SetUnitX(unit,x) SetUnitY(unit,y)
end


function utils.playsound(snd, p)
  local p = p or GetTriggerPlayer()
  if p == GetLocalPlayer() then
      StopSound(snd, false, false)
      StartSound(snd)
  end
end


function utils.panto(p, x, y, dur)
  -- map camera to x,y instantly
  local dur = dur or 0.0
  PanCameraToTimedForPlayer(p, x, y, dur)
end


function utils.disableuicontrol(p, bool)
  if p == GetLocalPlayer() then
    EnableUserControl(not bool) EnableUserUI(not bool)
  end
end


function utils.setcambounds(p, rect)
  SetCameraBoundsToRectForPlayerBJ(p, rect)
end


function utils.palert(p, str, dur, _snd, _isgoodalert)
  local dur = dur or 2.5
  if p == GetLocalPlayer() then
    DisplayTimedTextToPlayer(p, 0.0, 0.0, str)
    if _isgoodalert then
    else
      if _snd then
        utils.playsound(_snd, p)
      end
    end
  end
end


function utils.tablecontains(t, value)
  for i,v in pairs(t) do
    if v == value then
      return true
    end
  end
end


function utils.setlifep(unit, val)
  -- 100-based.
  SetUnitLifePercentBJ(unit, val)
end
