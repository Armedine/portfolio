utils          = {}
utils.debug    = false
utils.hotkeyt  = {} -- store player hotkey trigs.
fp = { -- shorthand 'FRAMEPOINT' for terser code.
  tl = FRAMEPOINT_TOPLEFT,      t = FRAMEPOINT_TOP, 
  tr = FRAMEPOINT_TOPRIGHT,     r = FRAMEPOINT_RIGHT, 
  br = FRAMEPOINT_BOTTOMRIGHT,  b = FRAMEPOINT_BOTTOM, 
  bl = FRAMEPOINT_BOTTOMLEFT,   l = FRAMEPOINT_LEFT,
  c  = FRAMEPOINT_CENTER,
}
utils.lorem = "Space, the final frontier. These are the voyages of the Starship"
    .." Enterprise. Its five-year mission: to explore strange new worlds, to seek out new"
    .." life and new civilizations, to boldly go where no man has gone before. Many say"
    .." exploration is part of our destiny, but it’s actually our duty to future generations"
    .." and their quest to ensure the survival of the human species."


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


function utils.timed(dur, func)
    local tmr = NewTimer()
    TimerStart(tmr, dur, false, function() func() ReleaseTimer() end)
    return tmr
end


function utils.timedrepeat(dur, count, func)
    local t, c = count, 0
    local tmr = NewTimer()
    if t == nil then
    TimerStart(tmr, dur, true, function() func() end)
    else
    TimerStart(tmr, dur, true, function() func() c = c + 1 if c >= t then ReleaseTimer() end end)
    end
    return tmr
end


function utils.tablecollapse(t)
  for index, value in pairs(t) do
      if value == nil then
          table.remove(t, index)
      end
  end
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
  -- show:
  if bool then
    BlzFrameSetVisible(fh, true)
    BlzFrameSetAlpha(fh, 255)
    utils.timedrepeat(0.03, nil, function()
        if BlzFrameGetAlpha(fh) > int then
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
    utils.timedrepeat(0.03, nil, function()
        if BlzFrameGetAlpha(fh) < 255 - int then
            alpha = alpha + int
            BlzFrameSetAlpha(fh, alpha)
        else
            BlzFrameSetAlpha(fh, 255)
            BlzFrameSetVisible(fh, true)
            ReleaseTimer()
        end
    end)
  end
end


function utils.debugfunc( func, name )
  local name = name or ""
  local passed, data = pcall( function() func() return "func " .. name .. " passed" end )
  if not passed then  
    print(name, passed, data)
  end
  passed = nil
  data = nil
end


function utils.playsound(snd, p)
  local p = p or GetTriggerPlayer()
  if p == GetLocalPlayer() then
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


-- @func = run this for all players, but local only.
function utils.looplocalp(func)
  ForForce(bj_FORCE_ALL_PLAYERS, function()
    if GetEnumPlayer() == GetLocalPlayer() then
      func(GetEnumPlayer())
    end
  end)
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
    UnitAddIndicatorBJ(unit, 0.00, 100, 0.00, 0)
end


function utils.fixfocus(fh)
  BlzFrameSetEnable(fh, false)
  BlzFrameSetEnable(fh, true)
end


function utils.tablelength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end
