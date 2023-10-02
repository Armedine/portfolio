function purge_last(str, char)
    local str = str
    if string.sub(str, -1) == char then
        str = string.sub(str, 1, -2)
    end
    return str
end


function split(str, sep)
    sep = sep
    local t = {}
    for field, s in string.gmatch(str, "([^" .. sep .. "]*)(" .. sep .. "?)") do
        table.insert(t, field)
        if s == "" then
            return t
        end
    end
end


function table_size(t)
    local count = 0
    for i, v in pairs(t) do
        count = count + 1
    end
    return count
end


function shallow_destroy(t)
    for k,v in pairs(t) do
        v = nil
        k = nil
    end
    t = nil
end


function get_index_by_value(t, val)
    for i, v in ipairs(t) do
        if v == val then
            return i
        end
    end
    return nil
end


function pnum(player)
    return GetConvertedPlayerId(player)
end


function is_local(player)
    return player == GetLocalPlayer()
end


function timed(dur, func)
    -- one shot timer
    local t = CreateTimer()
    TimerStart(t, dur, false, function() func() DestroyTimer(t) end)
end


function debug( func )
  local passed, data = pcall( function() func() return "func passed" end )
  if not passed then
    print(passed, data)
  end
end
