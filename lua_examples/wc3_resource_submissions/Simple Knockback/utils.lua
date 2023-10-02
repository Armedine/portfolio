function powner(unit)
  return GetOwningPlayer(unit)
end


function distxy(x1,y1,x2,y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return SquareRoot(dx * dx + dy * dy)
end


function unitxy(taru)
  return GetUnitX(taru), GetUnitY(taru)
end


function anglexy(x1,y1,x2,y2)
  return bj_RADTODEG * Atan2(y2 - y1, x2 - x1)
end


function projectxy(x1,y1,d,a)
    local x = x1 + d * Cos(a * bj_DEGTORAD)
    local y = y1 + d * Sin(a * bj_DEGTORAD)

    return x,y
end


function isalive(unit)
  return not (GetUnitTypeId(unit) == 0 or IsUnitType(unit, UNIT_TYPE_DEAD))
end


function pnum(p)
  return GetConvertedPlayerId(p)
end


function debugfunc( func, name )
  local name = name or ""
  local passed, data = pcall( function() func() return "func " .. name .. " passed" end )
  if not passed then  
    print(name, passed, data)
  end
end


function tablecollapse(t)
  for index, value in pairs(t) do
      if value == nil then
          table.remove(t, index)
      end
  end
end


function tablelength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end


function tabledeepdestroy(t)
  for k,v in t do
    if type(v) == "table" then
      for k2,v2 in v do
        k2 = nil
      end
    end
  end
  t = nil
end


function setxy(unit, x, y)
  SetUnitX(unit,x) SetUnitY(unit,y)
end
