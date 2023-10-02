--[[
    init after GUI:
--]]
onInitialization(function()
    speak:init()
end)


-- time elapsed init.
utils.timed(0.0, function()
    utils.debugfunc(function()
        if not BlzLoadTOCFile('war3mapImported\\CustomFrameTOC.toc') then
            print("error: .fdf file failed to load")
            print("tip: are you missing a curly brace in the fdf?")
            print("tip: does the .toc file have the correct file paths?")
            print("tip: .toc files require an empty newline at the end")
        end
        speak.consolebd = BlzGetFrameByName("ConsoleUIBackdrop",0)
        speak.gameui    = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
        speak:initframes()
    end, "elapsed init")
end)
