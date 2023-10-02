alert = {}


function alert:init()
    self.__index     = self
    self.dur         = 4
    self.time        = 0
    self.displaytext = ''
    self.tmr         = NewTimer()
    -- create alert frame:
    self.fr = kui.frame:newbytype("BACKDROP", kui.canvas.gameui) -- parent frame
    self.fr:setsize(kui:px(770), kui:px(40))
    self.fr:setbgtex(kui.tex.invis)
    self.fr:setfp(fp.b, fp.b, kui.worldui, 0, kui:px(307))
    self.fr:setlvl(9)
    self.fr:show()
    self.textfr = self.fr:createheadertext("", 0.58) -- text frame
    self.textfr:setparent(self.fr.fh)
    self.textfr:setallfp(self.fr)
    self.textfr:setlvl(9)
    self.textfr:show()
    self.fr:hide()
    BlzFrameSetTextAlignment(self.textfr.fh, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_CENTER)
end


function alert:new(text, _dur)
    utils.debugfunc(function()
        self.time = _dur or self.dur
        BlzFrameSetText(self.textfr.fh, text)
        if not self.fr:isvisible() then
            -- reveal text frame.
            utils.fadeframe(false, self.fr.fh, 0.66)
        end
        TimerStart(self.tmr, 1.0, true, function()
            -- to prevent overlapping timers, we manually control a single timer:
            self.time = self.time - 1
            if self.time <= 0 then
                utils.fadeframe(true, self.fr.fh, 0.66)
                PauseTimer(self.tmr)
            end
        end)
        print(text) -- not multiplayer safe
        ClearTextMessages()
    end, "alert:new")
end
