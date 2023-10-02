-- :: helper function, safe counter
-- @t = table to return size of, returns int
function GetTableSize(t)
	local count = 0
	for k,v in pairs(t) do
	     count = count + 1
	end
	return count
end


-- :: helper function to remove table index by searching for value
-- @t = table to search
-- @v = value to search for, returns index of that value where it exists in @t, returns false if it doesn't exist
function GetTableIndexByValue(t,v)
    for index, value in pairs(t) do
        if value == v then
            return index
        end
    end
    return nil
end


-- :: helper function to see if table has value
-- @t = table to search
-- @v = value to search for, returns true if it exists; false if not
function DoesTableContainValue(t,v)
    for index, value in pairs(t) do
        if value == v then
            return true
        end
    end
    return false
end


-- :: debug helper; prevent permanent messages
-- @text = message (auto timed)
function DebugMsg(text)
	DisplayTextToForce(	bj_FORCE_ALL_PLAYERS, text )
end


-- :: debug helper; print array key value pairs
-- @t = table to print
function PrintArray(t)
    for index, value in pairs(t) do
        DebugMsg(index .. " has value " .. value)
    end
end


-- @g = group to get size for, returns int (alternative: BlzGroupGetSize(g) )
function GetGroupSize(g)
	local size = 0
	local u
	if (not IsUnitGroupEmptyBJ(g)) then
		u = FirstOfGroup(g)
	 	repeat
		  	size = size + 1
		  	GroupRemoveUnit(g, u)
		  	u = FirstOfGroup(g)
		until (u == nil or size > 32)
	end
	return size
end


-- :: get the host of the game and set it to a GUI var (run time elapsed trigger)
function GetHost()
    local g = InitGameCache("Map.w3v")
    StoreInteger ( g, "Map", "Host", GetPlayerId(GetLocalPlayer ())+1)
    TriggerSyncStart ()
    SyncStoredInteger ( g, "Map", "Host" )
    TriggerSyncReady ()
    udg_gameHostPlayer = Player( GetStoredInteger ( g, "Map", "Host" )-1)
    FlushGameCache( g )
    g = nil
end

function printTable(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. printTable(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

-- :: fetch x,y,angle from a set distance between point A and point B
-- @x1,y1 = origin coord
-- @x2,y2 = direction coord
-- @d = distance between origin and direction
function PointBetweenXY(x1,y1,x2,y2,d) -- credit: PurgeandFire https://www.hiveworkshop.com/threads/x-y-coordinates-and-facing.269871/
    local angle = Atan2(y2 - y1, x2 - x1)
    local x = x1 + d * Cos(angle)
    local y = y1 + d * Sin(angle)

    return x,y,angle
end

-- :: get facing angle from A to B
-- @x1,y1 = point A (facing from)
-- @x2,y2 = point B (facing towards)
function AngleBetweenPointsXY(x1,y1,x2,y2)
  return bj_RADTODEG * Atan2(y2 - y1, x2 - x1)
end


-- ::  (alternative name that always causes headaches, so make it work) get facing angle from A to B
-- @x1,y1 = point A (facing from)
-- @x2,y2 = point B (facing towards)
function AngleBetweenXY(x1,y1,x2,y2)
  return bj_RADTODEG * Atan2(y2 - y1, x2 - x1)
end

-- :: PolarProjectionBJ converted to x,y
-- @x1,y1 = origin coord
-- @d = distance between origin and direction
-- @a = angle to project
function PolarProjectionXY(x1,y1,d,a)
	local x = x1 + d * Cos(a * bj_DEGTORAD)
	local y = y1 + d * Sin(a * bj_DEGTORAD)

	return x,y
end


-- :: clones a table versus turning it into a pointer.
function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end


-- :: helper function to check if table has index value.
-- @t = table to search.
-- @v = value to search for, returns true if it exists; false if not.
function DoesTableContainIndex(t,v)
  for index, value in pairs(t) do
      if index == v then
          return true
      end
  end
  return false
end


function DistanceBetweenXY(x1,y1,x2,y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return SquareRoot(dx * dx + dy * dy)
end


function PrintFunctionError( func )
  --local err = function() return 'error occurred' end
  local status, err, ret = xpcall(func, err, 1, 1)
  print(status)
  print(err)
  print(ret)
  print('')
end


function tablelength(t)
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end


function GetHost()
  local g = InitGameCache("Map.w3v")
  StoreInteger(g, "Map", "Host", GetPlayerId(GetLocalPlayer ())+1)
  TriggerSyncStart()
  SyncStoredInteger(g, "Map", "Host" )
  TriggerSyncReady()
  udg_Host = Player( GetStoredInteger(g, "Map", "Host" )-1)
  FlushGameCache(g)
  g = null
end


function math.round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end


-- is @u alive?
function IsUnitAlive(u)
    return not (GetUnitTypeId(u) == 0 or IsUnitType(u, UNIT_TYPE_DEAD))
end
