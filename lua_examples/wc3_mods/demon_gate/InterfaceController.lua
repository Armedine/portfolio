---@class InterfaceController
---UI manager that controls interface state and applies desync protection.
InterfaceController = {
    army_manager = {}
}
InterfaceController.__index = InterfaceController


function InterfaceController:set_wave_bar_progress()
    self.bar_wave_progress:value(math.floor(((GameController.spawned_units_alive)/(GameController.spawned_units_total))*100))
end


function InterfaceController:set_lives_bar_progress()
    self.bar_lives_progress:value(math.floor((GameObjective.lives_current/GameObjective.lives_total)*100))
end


function InterfaceController:show_progress_bars(should_show)
    if should_show then
        self.bar_wave_progress:show()
        self.bar_lives_progress:show()
    else
        self.bar_wave_progress:hide()
        self.bar_lives_progress:hide()
    end
end


function InterfaceController:hide_all()
    self.bar_wave_progress:hide()
    self.bar_lives_progress:hide()
end


OnGameStart(function() Try(function() TimerQueue:call_delayed(0.03, function()
        if not BlzLoadTOCFile("war3mapImported\\CustomFrameTOC.toc") then print("Error - Failed to load CustomFrameTOC.toc") end
        InterfaceController.bar_wave_progress = CustomFrame:new_frame_simple("SimpleBarInvasionProgress", 402, 50)
            :anchor_screen(FP_C, "top", -337, -83):show()
        InterfaceController.bar_lives_progress = CustomFrame:new_frame_simple("SimpleBarLivesProgress", 402, 50)
            :anchor_screen(FP_C, "top", 337, -83):show()
        InterfaceController.bar_wave_progress:value(100)
        InterfaceController.bar_wave_progress:hide()
        InterfaceController.bar_lives_progress:value(0)
        InterfaceController.bar_lives_progress:hide()
end) end) end)
