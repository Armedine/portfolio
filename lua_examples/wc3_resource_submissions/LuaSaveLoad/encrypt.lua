encrypt = {}
--[[
    This is a very dumb encryption only meant to discourage players from tinkering with CustomMapData files on a whim.
    Advanced methods are beyond my skillset. If you want more security, you'll have to seek out your own alternative
    or translate an existing JASS library. I may try to revisit in the future, but time is finite :)
--]]


function encrypt:basic(str, seed, isencrypt, _shiftsum)
    local bytes = 0
    local spos, opos = 1, 1
    local smax, omax = string.len(seed), string.len(str)
    local nstr, ochar = "", ""
    local shiftsum = 0
    for i = 1, omax do
        ochar = string.sub(str, opos, opos)
        bytes = string.byte(ochar)
        bytesoff = tonumber(string.sub(seed, spos, spos))
        if isencrypt then
            bytes = bytes - bytesoff
        else
            bytes = bytes + bytesoff
        end
        shiftsum = shiftsum + bytesoff
        spos = spos + 1
        opos = opos + 1
        if spos > smax then
            spos = 1
        end
        nstr = nstr .. string.char(bytes)
    end
    local pass = true
    if _shiftsum then
        if shiftsum ~= _shiftsum then
            pass = false
        end
    end
    return nstr, pass, shiftsum
end
