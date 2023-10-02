-- function Hook:CreateUnit(...)
--     local args = {...}
--     args[2] = FourCC(args[2])
--     return self.old(CreateUnit(table.unpack(args)))
-- end


-- local recycledTimers = {}
-- function Hook:CreateTimer() -- from Bribe @ hiveworkshop.com:
--     if recycledTimers[1] then
--         return table.remove(recycledTimers, #recycledTimers)
--     else
--         return self.old() --Call the CreateTimer native and return its timer
--     end
-- end


-- function Hook:DestroyTimer(whichTimer) -- from Bribe @ hiveworkshop.com:
--     if #recycledTimers < 100 then
--         table.insert(recycledTimers, whichTimer)
--     else
--         self.old(whichTimer) --This will not trigger recursively (but calling "DestroyTimer" again will cause recursion).
--     end
-- end


function Hook:TimerStart(timer, real, boolean, code)
    local f = code
    if boolean then
        self.old(timer, real, boolean, f)
    else
        self.old(timer, real, boolean, function() if f then f() end if timer then DestroyTimer(timer) end end)
    end
    return timer
end
