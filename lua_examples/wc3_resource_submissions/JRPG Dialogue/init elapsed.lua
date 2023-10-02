--[[
    time elapsed init:
--]]
utils.timed(0.33, function()
    utils.debugfunc(function()
        --[[
            sounds we play in the screenplay example:
        --]]
        soundt = {}
        soundt.grunt01      = gg_snd_PeonWhat2
        soundt.grunt02      = gg_snd_GruntWarcry1
        soundt.peon01       = gg_snd_PeonPissed4
        soundt.footman01    = gg_snd_FootmanYesAttack1
        -- build after map init so we have a cached log with F12:
        buildactors()
        buildscreenplay()
    end, "time elapsed init")
end)
