speak           = {   -- main dialogue class.

    -- start of config settings (caution when editing durations):

    hideui      = true,     -- should the default game ui be hidden when scenes run?
    unitflash   = true,     -- should transmission indicators flash on the speaking unit?

    fade        = false,     -- should dialogue components have fading eye candy effects?
    fadedur     = 0.81,     -- how fast to fade if fade is enabled.

    unitpan     = false,     -- should the camera pan to the speaking actor's unit?
    camspeed    = 0.75,     -- how fast the camera pans when scenes start/end/shift.

    anchorx     = 0.4,      -- x-offset for dialogue box's center framepoint.
    anchory     = 0.12,     -- y-offset ``.
    width       = 0.333,     -- x-width of dialogue frame.
    height      = 0.083,     -- y-width ``.

    nextbtntxt  = "Continue",
    skipbtntxt  = "Skip",
    fdfbackdrop = "BattleNetControlBackdropTemplate",
    fdfportrait = "BattleNetControlBackdropTemplate",
    fdfbutton   = "ScriptDialogButton",
    fdftitle    = "CustomText",     -- from imported .fdf
    fdftextarea = "CustomTextArea", -- ``
    hextitle    = "|cff9a7757",     -- character title text color.
    hextext     = "|cff9a7757",     -- character speech text color.

    debug       = false,     -- print debug messages for certain functions.

    inprogress  = false,     -- speech window in progress; for controlling external logic.

    -- end of config settings.
}
speak.item      = {   -- sub class for dialogue strings and how they play.
    
    -- required inputs:
    text        = nil,      -- the dialogue string to display.
    actor       = nil,      -- the actor that owns this speech item.
    -- optional inputs:
    emotion     = nil,      -- the portrait to display (if left empty, the default will be shown play).
    anim        = nil,      -- play a string animation when the speech item is played.
    sound       = nil,      -- play a sound when this item begins.
    func        = nil,      -- call this function when the speech item is played (e.g. move a unit).
    -- optional config:
    speed       = 0.03,     -- cadence to show new string characters (you could increase for dramatic effect).

}
speak.portrait  = {   -- sub class for storing actor portrait files and rendering them.

    none        = '',       -- portrait file path.
    angry       = '',       -- ``
    blush       = '',       -- ``
    happy       = '',       -- ``

}
speak.actor     = {   -- sub class for storing actor settings.

    unit        = nil,      -- the unit which owns the actor object.
    name        = nil,      -- the name of the actor (defaults to unit name).
    portrait    = nil,      -- the portrait object to use for the unit.

}
speak.chain     = {}  -- sub class for chaining speech items in order.


-- initialize classes and class specifics:
function speak:init()
    utils.newclass(speak.actor)
    utils.newclass(speak.portrait)
    utils.newclass(speak.item)
    utils.newclass(speak.chain)
    self.worldui        = BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0)
    self.prevactor      = nil   -- control for previous actor if frames animate on change.
    self.itemdone       = false -- flag for controlling quick-complete vs. next speech item.
    self.currentindex   = 1     -- the item currently being played from an item queue.
    self.camtargetx     = 0     -- X coord to pan camera to.
    self.camtargety     = 0     -- Y coord ``
    self.paused         = false -- a flag for dealing with paused scenes.
    self.initialized    = false -- flag for if the system was already set up manually.
    self.camtmr         = NewTimer()
    self.clickednext    = false -- flag for controlling fade animations.
end


-- generate ui frames.
function speak:initframes()
    self.fr             = {}
    self.fr.backdrop    = BlzCreateFrameByType("BACKDROP", "SpeakFillBackdrop", self.gameui, "", 0)
    BlzFrameSetSize(self.fr.backdrop, self.width, self.height)
    BlzFrameSetAbsPoint(self.fr.backdrop, fp.c, self.anchorx, self.anchory)
    BlzFrameSetTexture(self.fr.backdrop, "war3mapImported\\campaign_export_bg.blp", 0, true)
    -- character potrait:
    self.fr.portrait    = BlzCreateFrameByType("BACKDROP", "SpeakFillPortrait", self.fr.backdrop, "", 0)
    BlzFrameSetSize(self.fr.portrait, self.height*0.8133, self.height*0.8133)
    BlzFrameSetPoint(self.fr.portrait, fp.tl, self.fr.backdrop, fp.tl, 0.0077, -0.0077)
    BlzFrameSetTexture(self.fr.portrait, "war3mapImported\\campaign_test_portrait.blp", 0, true)
    -- character title:
    self.fr.title       = BlzCreateFrame(self.fdftitle, self.fr.backdrop, 0, 0)
    BlzFrameSetPoint(self.fr.title, fp.tl, self.fr.portrait, fp.tr, self.height*0.12, -self.height*0.002)
    BlzFrameSetText(self.fr.title, "Character Name")
    -- dialogue string:
    self.fr.text        = BlzCreateFrame(self.fdftextarea, self.fr.backdrop, 0, 0)
    BlzFrameSetSize(self.fr.text, self.width - BlzFrameGetWidth(self.fr.portrait) - self.width*0.145, self.height*0.63)
    BlzFrameSetPoint(self.fr.text, fp.tl, self.fr.title, fp.bl, 0, -self.height*0.009)
    BlzFrameSetText(self.fr.text, utils.lorem)
    -- skip button:
    self.fr.nextbtn     = BlzCreateFrameByType("BUTTON", "SpeakNextBtn", self.fr.backdrop, "", 0)
    -- we leave outside the fr table so it follows parent visibility:
    self.nextbtnbg      = BlzCreateFrameByType("BACKDROP", "SpeakNextBtnBackdrop", self.fr.nextbtn, "", 0)
    BlzFrameSetTexture(self.nextbtnbg, "war3mapImported\\campaign_export_btn.blp", 0, true)
    BlzFrameSetPoint(self.fr.nextbtn, fp.br, self.fr.backdrop, fp.br, -0.0044, 0.0044)
    BlzFrameSetSize(self.fr.nextbtn, 0.05336, 0.0204)
    BlzFrameSetSize(self.nextbtnbg, 0.05336, 0.0204)
    BlzFrameSetPoint(self.nextbtnbg, fp.tl, self.fr.nextbtn, fp.tl, 0, 0)
    self.fr.skipbtn     = BlzCreateFrame(self.fdfbutton, self.fr.backdrop, 0, 0)
    BlzFrameSetSize(self.fr.skipbtn, 0.09, 0.033)
    BlzFrameSetPoint(self.fr.skipbtn, fp.tl, self.fr.backdrop, fp.bl, 0, 0)
    BlzFrameSetText(self.fr.skipbtn, self.skipbtntxt)
    --
    utils.frameaddevent(self.fr.nextbtn, function() speak:clicknext() end, FRAMEEVENT_MOUSE_UP)
    utils.frameaddevent(self.fr.nextbtn, function() speak:highlight(true) end, FRAMEEVENT_MOUSE_ENTER)
    utils.frameaddevent(self.fr.nextbtn, function() speak:highlight(false) end, FRAMEEVENT_MOUSE_LEAVE)
    utils.frameaddevent(self.fr.skipbtn, function() speak:endscene() end, FRAMEEVENT_MOUSE_UP)
    self:show(false, true)
end


-- initialize the scene interface (e.g. typically if you are running a cinematic component first).
function speak:initscene()
    self:clear()
    if self.hideui then
        BlzHideOriginFrames(true)
        BlzFrameSetVisible(self.consolebd, false)
    end
    BlzEnableSelections(false, true)
    PauseAllUnitsBJ(true)
    TriggerExecute(gg_trg_SpawnPeon)
    self:enablecamera(true)
    -- set flag for any GUI triggers that might need it:
    udg_speakactive  = true
    self.initialized = true

end


-- @chain = the chain object to play items from.
-- @...   = [optional] merge together additional chain objects (ordered by argument position).
function speak:startscene(chain, ...)
    -- index increment is controlled in speak.chain:playnext.
    self.currentindex = 0
    self.currentchain = utils.deepcopy(chain)
    self.paused       = false
    if not self.initialized then
        self:initscene()
    end
    if ... then
        for _,v in pairs({...}) do
            if type(v) == "table" then
                for i,itemval in pairs(v) do
                    table.insert(self.currentchain, utils.tablelength(self.currentchain) + 1, itemval)
                end
            else
                assert(false, "speak:startscene was passed a non-table argument. (tip: was it a scene object?)")
            end
        end
    end
    self:hideshowskip()
    if speak.fade then
        self:fadeout(false)
    else
        BlzFrameSetVisible(self.fr.backdrop, true)
    end
    BlzFrameSetEnable(self.fr.nextbtn, true)
    self.currentchain:playnext()
    -- run debug if enabled:
    if self.debug then self.currentchain:debug("startscene") end
end


function speak:hideshowskip()
    if self.showskip then
        BlzFrameSetVisible(self.fr.skipbtn, true)
        BlzFrameSetEnable(self.fr.skipbtn, true)
    else
        BlzFrameSetVisible(self.fr.skipbtn, false)
        BlzFrameSetEnable(self.fr.skipbtn, false)
    end
end


-- end the dialogue sequence.
function speak:endscene()
    BlzEnableSelections(false, false)
    BlzFrameSetVisible(self.fr.nextbtn, false)
    if speak.fade then
        self:fadeout(true)
    else
        BlzFrameSetVisible(self.fr.backdrop, false)
    end
    PauseAllUnitsBJ(false)
    self:enablecamera(false)
    utils.fixfocus(self.fr.skipbtn)
    BlzFrameSetEnable(self.fr.nextbtn, false)
    BlzFrameSetVisible(self.fr.nextbtn, false)
    BlzFrameSetEnable(self.fr.skipbtn, false)
    BlzFrameSetVisible(self.fr.skipbtn, false)
    -- disable flag for any GUI triggers that might need it:
    udg_speakactive  = false
    self.initialized = false
    SelectUnitForPlayerSingle( (udg_adevramies), Player(0) )
    TriggerExecute( gg_trg_SpawnPeon )
    -- clear cache:
    if not self.paused then
        utils.destroytable(self.currentchain)
    end
end


-- @bool = true to enter dialogue camera; false to exit.
function speak:enablecamera(bool)
    utils.debugfunc(function()
        if bool then
            ClearTextMessagesBJ(bj_FORCE_ALL_PLAYERS)
            TimerStart(self.camtmr, 0.03, true, function()
                utils.looplocalp(function(p)
                    CameraSetupApplyForPlayer(true, self.scenecam, p, self.camspeed)
                end)
            end)
        else
            PauseTimer(self.camtmr)
            utils.looplocalp(function(p)
            end)
        end
    end,"enablecamera")
end


-- function to run when the "next" button is clicked.
function speak:clicknext()
    -- fix focus:
    utils.fixfocus(self.fr.nextbtn)
    if self.currentchain then
        if speak.itemdone then
            self.currentchain:playnext()
        else
            speak.itemdone = true
        end
    else
        self:endscene()
    end
end


-- highlight the next button manually.
function speak:highlight(bool)
    if bool then -- mouse enter
        BlzFrameSetTexture(self.nextbtnbg, "war3mapImported\\campaign_export_btn_hl.blp", 0, true)
    else -- mouse leave
        BlzFrameSetTexture(self.nextbtnbg, "war3mapImported\\campaign_export_btn.blp", 0, true)
    end
end


-- @bool = true to show, false to hide.
-- @skipeffectsbool = [optional] set to true skip fade animation.
function speak:show(bool, skipeffectsbool)
    if bool then
        if self.fade and not skipeffectsbool then
            self:fadeout(bool)
        else
            for _,fh in pairs(self.fr) do
                if fh ~= self.fr.skipbtn then
                    BlzFrameSetVisible(fh, true)
                end
            end
        end
    else
        for _,fh in pairs(self.fr) do
            BlzFrameSetVisible(fh, false)
        end
    end
end


-- @bool = true to animate out (hide), false to animate in (show).
function speak:fadeout(bool)
    if self.fade then
        utils.fadeframe(bool, self.fr.backdrop, self.fadedur)
    else
        BlzFrameSetVisible(self.fr.backdrop, false)
    end
end


-- pause the dialogue frame, hiding and clearing it in order to run a cinematic sequence, etc.
function speak:pause()
    self:reset()
    self:show(false)
    self.resumeindex = self.currentindex + 1
    self.pause = true
end


-- resume after initiating a pause event.
function speak:resume()
    self:show(true)
    self.currentchain:start(self.resumeindex)
    self.resumeindex = nil
    self.pause = false
end


-- when a new chain is being played, initialize the default display.
function speak:clear()
    BlzFrameSetText(self.fr.text, "")
    BlzFrameSetText(self.fr.title, "")
    if self.fade then
        BlzFrameSetAlpha(self.fr.portrait, 0)
        BlzFrameSetAlpha(self.fr.portraitbg, 0)
        BlzFrameSetAlpha(self.fr.text, 0)
        BlzFrameSetAlpha(self.fr.title, 0)
    end
end


-- @unit = assign the unit responsible for @portrait.
-- @portrait = portrait object for @unit.
function speak.actor:assign(unit, portrait)
    self.unit     = unit
    self.portrait = portrait
    self.name     = GetUnitName(unit)
    if not getmetatable(portrait) then
        setmetatable(portrait, speak.portrait)
    end
end


-- play a speech item, rendering its string characters over time and displaying actor details.
function speak.item:play()
     -- a flag for skipping the text animation:
    speak.itemdone = false
    -- initialize timer settings:
    if speak.tmr then
        ReleaseTimer(speak.tmr)
        speak.tmr = nil
    end
    local count = string.len(self.text)
    local pos   = 1
    local dur   = speak.fadedur
    local ahead = ''
    -- render string characters:
    BlzFrameSetText(speak.fr.title, speak.hextitle..self.actor.name.."|r")
    speak.tmr = utils.timedrepeat(self.speed, count, function()
        if pos < count and not speak.itemdone then
            ahead = string.sub(self.text, pos, pos+1)
            -- scan for formatting patterns:
            if ahead == '|c' then
                pos = pos + 10
            elseif ahead == '|r' or ahead == '|n' then
                pos = pos + 2
            else
                pos = pos + 1
            end
            BlzFrameSetText(speak.fr.text, speak.hextext..string.sub(self.text, 1, pos))
            utils.fixfocus(speak.fr.text)
        else
            speak.itemdone = true
            BlzFrameSetText(speak.fr.text, speak.hextext..self.text)
            ReleaseTimer()
        end
    end)
    -- run additional speech inputs if present:
    if speak.unitflash then
        utils.speechindicator(self.actor.unit)
    end
    if self.anim then
        ResetUnitAnimation(self.actor.unit)
        QueueUnitAnimation(self.actor.unit, self.anim)
        QueueUnitAnimation(self.actor.unit, "stand")
    end
    if self.sound then
        utils.playsoundall(self.sound)
    end
    if self.func then
        self.func()
    end
    -- manage frames:
    self.actor.portrait:render(self.emotion)
    speak:hideshowskip()
    BlzFrameSetVisible(speak.fr.nextbtn, true)
    BlzFrameSetVisible(speak.fr.title, true)
    BlzFrameSetVisible(speak.fr.text, true)
    BlzFrameSetVisible(speak.fr.portraitbg, true)
    if speak.fade and speak.prevactor ~= self.actor then
        utils.fadeframe(false, speak.fr.portrait, speak.fadedur)
        utils.fadeframe(false, speak.fr.title, speak.fadedur)
        utils.fadeframe(false, speak.fr.text, speak.fadedur)
        utils.fadeframe(false, speak.fr.portraitbg, speak.fadedur)
    else
        BlzFrameSetVisible(speak.fr.portrait, true)
    end
    -- manage units:
    if speak.unitpan then
        speak.camtargetx = GetUnitX(self.actor.unit)
        speak.camtargety = GetUnitY(self.actor.unit)
    end
    speak.prevactor = self.actor
end


-- after a speech item completes, see what needs to happen next (load next item or close, etc.)
function speak.chain:playnext()
    utils.debugfunc(function()
        speak.currentindex = speak.currentindex + 1
        if speak.currentindex > utils.tablelength(speak.currentchain) + 1 then
            speak:clear()
            speak:endscene()
        else
            if not self[speak.currentindex] then
                -- if next item was set to nil or is empty, try to skip over:
                self:playnext()
            else
                if speak.debug then
                    print("trying to play index item: "..speak.currentindex)
                    print(self[speak.currentindex].actor.name)
                end
                self[speak.currentindex]:play()
            end
        end
    end, "playnext")
end


-- @t = provide a table of items to automatically build; item's value ordering will follow index-values.
-- item format reminder: { text, actor, emotion, anim, sound, func } (if jumping a space, leave it nil)
function speak.chain:build(t)
    assert(t and t[1], "error: speak.chain:build is missing an index-value table argument.")
    local o = speak.chain:new()
    -- we do pairs instead of ipairs so we can skip over nil values
    -- that the end user may want to fill out later:
    for i,v in pairs(t) do
        if type(v) == "table" and type(i) == "number" then
            o[i]       = speak.item:new()
            o[i].text  = v[1]
            o[i].actor = v[2]
            if v[3] then
                o[i].emotion = v[3]
            end
            if v[4] then
                o[i].anim    = v[4]
            end
            if v[5] then
                o[i].sound   = v[5]
            end
            if v[6] then
                o[i].func    = v[6]
            end
        end
    end
    if speak.debug then o:debug("build") end
    return o
end


-- @item  = add this item as the next item in the chain.
-- @index = [optional] insert @item into this index location instead.
function speak.chain:add(item, index)
    if index then
        table.insert(self, index, item)
    else
        self[#self + 1] = item
    end
end


-- @item = remove this item from the chain (accepts item object or the index location in the chain).
function speak.chain:remove(item)
    -- remove by index:
    if type(item) == "number" then
        table.remove(self, item)
    -- remove by value:
    else
        for i,v in ipairs(self) do
            if v == item then
                table.remove(self, i)
            end
        end
    end
end


-- @str = label this debug print source (e.g. "manual debug call" or "scene build", etc.).
-- @startindex, @endindex = [optional] index range to loop through (for large scene objects).
function speak.chain:debug(str, startindex, endindex)
    -- if you need to debug an object, print its values via index range.
    local i, startindex, endindex = 1, startindex or 1, endindex or utils.tablelength(self)
    for i,v in pairs(self) do
        if type(i) == "number" then
            if i >= startindex then
                print(" ")
                print("debug: reading chain item from call: "..str)
                print(i.." = "..tostring(v))
                print("text  = "    ..tostring(v.text))
                if v.actor then
                    print("actor = "    ..tostring(v.actor.name))
                    print("unit  = "    ..tostring(v.actor.unit))
                else
                    print("actor = nil")
                end
                print("emotion  = " ..tostring(v.emotion))
                print("anim     = " ..tostring(v.anim))
                print("sound    = " ..tostring(v.sound))
                print("func     = " ..tostring(v.func))
            end
        else
            assert(false, "speak.chain:debug read error: scene objects should be index-value pairs.")
        end
        i = i + 1
        if i > endindex then
            break
        end
    end
end


-- @emotion = string value used to look up an actor's portrait and render it in the dialogue box.
function speak.portrait:render(emotion)
    if self[emotion] then
        BlzFrameSetTexture(speak.fr.portrait, self[emotion], 0, true)
    elseif self.none then
        BlzFrameSetTexture(speak.fr.portrait, self.none, 0, true)
    else
        assert(false, "speak.portrait:render could not find a file path.")
    end
end
