do
    local data = {}
    function SetTimerData(whichTimer, dat)
        data[whichTimer] = dat
    end
 
    --GetData functionality doesn't even require an argument.
    function GetTimerData(whichTimer)
        if not whichTimer then whichTimer = GetExpiredTimer() end
        return data[whichTimer]
    end
 
    --NewTimer functionality includes optional parameter to pass data to timer.
    function NewTimer(...)
        local t = CreateTimer()
        local arg = {...}
        data[t] = {}
        if arg then
            for i,v in ipairs(arg) do
                data[t][i] = v
            end
        end
        return t
    end
    
    --Release functionality doesn't even need for you to pass the expired timer.
    --as an arg. It also returns the user data passed.
    function ReleaseTimer(whichTimer)
        if not whichTimer then whichTimer = GetExpiredTimer() end
        local dat = data[whichTimer]
        data[whichTimer] = nil
        PauseTimer(whichTimer)
        DestroyTimer(whichTimer)
        return dat
    end
end
