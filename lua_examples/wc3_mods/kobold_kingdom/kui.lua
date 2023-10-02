kui                     = {}
kui.frame               = {}  -- frame object class.


-- TODO: store active mainframe in a focus variable or something, then have a hotkey which targets that context.
-- e.g. "ESC" calls the closebtn function attached to said mainframe.

function kui:init()
    -- note: kui.gameui has layer priority over kui.worldui.
    -- enable or disable debug event print() logging:
    self.debug              = false -- overrides all debug settings.
    self.debugclick         = false
    self.debughover         = false
    self.debugenter         = false
    self.lockcam            = true  -- character perma screen/sel lock.
    -- load meta data:
    kui:dataload()
    -- init other classes:
    kui.frame:init()
    -- run local-only code:
    -- block screen until loading complete:
    utils.fadeblack(true) -- ***note: async; cannot run locally!
    for p,_ in pairs(kobold.playing) do
        if p == utils.localp() then
            BlzFrameClearAllPoints(self.ubertip)
            BlzFrameSetPoint(self.ubertip, fp.tr, self.gameui, fp.tl, 0.0, -0.05) -- hide normal tooltip frame.
            BlzFrameSetPoint(self.otip, fp.tr, self.gameui, fp.tl, 0.0, -0.05)
            BlzFrameSetPoint(self.chatmsg, fp.bl, self.minimap, fp.tl, 0.1, 0.05)
            BlzFrameSetSize(self.chatmsg, 0.5, 0.2)
            BlzFrameSetVisible(self.consolebd, false)
            BlzFrameSetVisible(self.unitmsg, true)
            BlzFrameSetLevel(self.unitmsg,6)
            BlzFrameSetParent(self.unitmsg, self.worldui)
            BlzEnableUIAutoPosition(false)
            BlzHideOriginFrames(true)
            self.screenw = BlzGetLocalClientWidth()
            self.screenh = BlzGetLocalClientHeight()
            self.ratio   = self.screenh/self.screenw
            kui:pxdpiscale()
        end
    end
end


function kui:uigen() -- genui
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- o = master parent for custom ui frames.
    -- o.game = skill bar, etc. ('gameplay' ui).
    -- o.splash = main menu.
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    kui.canvas      = kui.frame:newbytype("PARENT", self.gameui)
    kui.canvas.game = kui.frame:newbytype("PARENT", kui.canvas)
    -- because simple frames are awful, run thru each
    --  child parent to fire their show/hide funcs.
    kui.canvas.game.showfunc = function()
        kui.canvas.game.inv:show()
        kui.canvas.game.char:show()
        kui.canvas.game.skill:show()
        kui.canvas.game.dig:show()
    end
    kui.canvas.game.hidefunc = function()
        kui.canvas.game.inv:hide()
        kui.canvas.game.char:hide()
        kui.canvas.game.skill:hide()
        kui.canvas.game.dig:hide()
    end
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    kui.canvas.game.party     = kui:createpartypane(kui.canvas.game)
    kui.canvas.game.inv       = kui:createinventory(kui.canvas.game)
    kui.canvas.game.equip     = kui:createequipment(kui.canvas.game)
    kui.canvas.game.char      = kui:createcharpage(kui.canvas.game)
    kui.canvas.game.skill     = kui:createskillbar(kui.canvas.game)
    kui.canvas.game.skill.obj = map.mission:buildpanel()
    kui.canvas.game.dig       = kui:createdigsitepage(kui.canvas.game)
    kui.canvas.game.bosschest = kui:createbosschest(kui.canvas.game)
    kui.canvas.game.abil      = ability:buildpanel()
    kui.canvas.game.mast      = mastery:buildpanel()
    kui.canvas.game.badge     = badge:buildpanel()
    kui.canvas.game.modal     = kui:createmodal(kui.gameui)
    kui.canvas.game.overwrite = kui:createoverwriteprompt(kui.gameui)
    kui:linkskillbarbtns()
    kui.canvas.game:hide()
    kui.canvas.game.skill:hide()
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    utils.debugfunc(function()    map.manager:initframes()  end, "map.manager:initframes")
    utils.debugfunc(function()    buffy:buildpanel()        end, "buffy:buildpanel")
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    utils.debugfunc(function()    kui.canvas.splash = kui:createsplashscreen(kui.canvas) end, "kui:createsplashscreen")
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
end


function kui.frame:init()
    self.fh         = nil   -- shorthand for object's framehandle.
    self.distex     = nil   -- disabled display graphic (backdrop only).
    self.normaltex  = nil   -- normal (backdrop only).
    self.activetex  = nil   -- active (backdrop only).
    self.hovertex   = nil   -- hover (backdrop only).
    self.statesnd   = false -- does the frame play open/close sounds?
    self.suppress   = false -- stop show/hide utility functions?
    self.simple     = false
    self.disabled   = false
    self.ismf       = false
    self.alpharatio = 0.8   -- for hover highlights.
    self.alpha      = 255
    self.alphahl    = 255   -- altered when hoverhl() is set, else ignore.
    self.__index    = self
end


-- @simplename  = the name of the frame as defined in .fdf.
-- @parentfr    = set to this parent frame.
function kui.frame:newbysimple(simplename, parentfr)
    -- these should typically be individual frames that
    --  are updated via GetFrameName for a local player.
    --  parentfr can be frame object or framehandle.
    local fr = {}
    setmetatable(fr, self)
    if parentfr == nil then
        fr.fh = BlzCreateSimpleFrame(simplename, kui.gameui, 0)
    else
        if type(parentfr) == "table" then
            fr.fh = BlzCreateSimpleFrame(simplename, parentfr.fh, 0)
        else
            fr.fh = BlzCreateSimpleFrame(simplename, parentfr, 0)
        end
    end
    if kui.debug then fr.debugn = simplename end
    fr.simple = true
    BlzFrameSetLevel(fr.fh, 0)
    return fr
end


-- @framevalue  = frame's text name.
-- @converttype = 0 or 1; 0 for framename, 1 for framehandle
-- @context     = [optional] defaults to 0
function kui.frame:convert(framevalue, converttype, context)
    -- create a frame object of a default frame
    --  via its frame name lookup or origin frame.
    local fr = {}
    setmetatable(fr, self)
    local context = context or 0
    if converttype == 0 then
        fr.fh = BlzGetFrameByName(framevalue,context)
    else
        fr.fh = framevalue
    end
    return fr
end


-- @frametype  = frame type string: "FRAME", "BACKDROP", etc.
-- @parentfr   = [optional] parent frame object
function kui.frame:newbytype(frametype, parentfr)
    -- create a frame by frametype.
    --  parentfr can be frame object or framehandle.
    local fr = {}
    local t = frametype
    -- hacky custom frametype insert:
    if t == "PARENT" then t = "BACKDROP" end
    local parent
    setmetatable(fr, self)
    if parentfr == nil then
        parent = kui.gameui
    else
        if type(parentfr) == "table" then
            parent = parentfr.fh
        else
            parent = parentfr
        end
    end
    fr.fh = BlzCreateFrameByType(t, "kuiframe"..#kui.framestack, parent, "", 0)
    kui.framestack[#kui.framestack+1] = fr
    BlzFrameSetLevel(fr.fh, 0) -- don't use :setlvl
    if kui.debug then fr.debugn = frametype end
    -- init custom frametype:
    if frametype == "PARENT" then
        fr:setsize(0.001,0.001)
        fr:setfp(fp.tr, fp.tr, kui.gameui)
        fr:setabsfp(fp.tr, 0.0, 0.0)
        fr:addbgtex(kui.tex.invis)
    end
    return fr
end


-- @framename  = frame name string: "FrameBaseText", etc.
-- @parentfr   = [optional] parent frame object
function kui.frame:newbyname(framename, parentfr)
    -- create a frame by name and inherit its frametype (as defined in .fdf files).
    local fr = {}
    local parent
    setmetatable(fr, self)
    if parentfr == nil then
        parent = kui.gameui
    else
        if type(parentfr) == "table" then
            parent = parentfr.fh
        else
            parent = parentfr
        end
    end
    fr.fh = BlzCreateFrame(framename, parent, 0, 0)
    BlzFrameSetLevel(fr.fh, 0) -- don't use :setlvl
    kui.framestack[#kui.framestack+1] = fr
    if kui.debug then fr.debugn = framename end
    return fr
end


-- @parentfr = set as parent.
-- @texture  = set btn backdrop texture.
function kui.frame:newbtntemplate(parentfr, texture)
    -- create a frame with an invisible button over it (.btn)
    -- *note: these will only work in the 4:3 ratio screen space.
    -- *reminder: add events to .btn, not its wrapped backdrop.
    local fr = self:newbytype("BACKDROP", parentfr)
    fr.btn   = self:newbytype("GLUEBUTTON", fr)
    fr.btn:setallfp(fr)
    fr:addbgtex(texture)
    return fr
end


function kui.frame:newitempane(parentfr)
    -- item selection pane template.
    self.pane = kui.frame:newbytype("BACKDROP", parentfr)
    self.pane:addbgtex('war3mapImported\\inventory-selected_box.blp')
    self.pane:setsize(kui:px(52),kui:px(52))
    self.pane:setlvl(3)
    self.pane.btnbd = kui.frame:newbytype("BACKDROP", self.pane)
    self.pane.btnbd:addbgtex("war3mapImported\\inventory-icon_unequip.blp")
    self.pane.btnbd:setsize(kui:px(32),kui:px(32))
    self.pane.btnbd:setfp(fp.bl, fp.tr, self.pane, 0.0, 0.0)
    self.pane.btn   = kui.frame:newbytype("BUTTON", self.pane)
    self.pane.btn:setallfp(self.pane.btnbd)
    self.pane.btn:assigntooltip("invbtnunequip")
    local unequipfunc = function()
        utils.debugfunc(function()
            loot.item:unequip(utils.trigp()) -- selslotid is controlled by inventory pane selection.
        end, "unequip")
    end
    self.pane.btn:addevents(nil, nil, unequipfunc)
end


-- @showfr  = frame to show when clicked.
-- @hidefr  = hide this frame.
-- @func    = [optional] additional callback func to run after click event, if needed.
function kui.frame:createbackbtn(showfr, hidefr, func)
    -- attach a back btn to this frame object, which hides it to
    --  show the 'showfr' object it is led to. property: fr.btn
    local fr = self:newbtntemplate(hidefr, kui.tex.backbtn)
    fr.statesnd = true
    fr:setsize(kui:px(kui.meta.backbtnw), kui:px(kui.meta.backbtnh))
    fr.btn:addswapevent(showfr, hidefr)
    fr.btn:addhoverhl(fr)
    if func then fr.btn:addevents(nil,nil,func) end
    return fr
end


-- @x = frame level.
function kui.frame:setlvl(x)
    if type(self) == "table" and self.fh then -- fr obj.
        BlzFrameSetLevel(self.fh, x)
    else
        BlzFrameSetLevel(self, x) -- framehandle.
    end
end


-- @texturepath  = texture (.tga or .blp, .blp only on simple frames) as the background.
-- @alphavalue   = [optional] 0-255 (0 is invisible).
function kui.frame:addbgtex(texturepath, alphavalue)
    -- this should be used on frame objects ( e.g. fr:addbgtex() ).
    local alphavalue = alphavalue or self.alpha
    BlzFrameSetTexture(self.fh, texturepath, 0, true)
    BlzFrameSetAlpha(self.fh, math.ceil(alphavalue))
    self.normaltex = texturepath
    self.distex    = texturepath -- disabled texture by default
end


function kui.frame:setbgtex(texturepath)
    BlzFrameSetTexture(self.fh, texturepath, 0, true)
end


-- @entercallback,@leavecallback,@clickcallback = event func.
-- @clickoverridetype = [optional] to be used with SIMPLEBUTTON frames to detect clicks.
-- @islocalbool       = [optional] should the code be ran locally? (true by default)
function kui.frame:addevents(entercallback, leavecallback, clickcallback, clickoverridetype, islocalbool)
    -- *note: simplebuttons do not support enter or leave (handle that via textures).
    -- *note: simplebuttons can only have *one* event click, a 2nd will erase the 1st.
    -- this should be used on frame objects ( e.g. fr:addevents() ).
    if entercallback ~= nil then
        if self.mouseenter == nil then
            self.mouseenter = self:event(entercallback, FRAMEEVENT_MOUSE_ENTER)
        elseif self.mouseenter.trig then
            TriggerAddAction(self.mouseenter.trig, entercallback, kui.debug, islocalbool)
        else
            print("error: addevents is missing a trigger for mouseenter")
        end
    end
    if leavecallback ~= nil then
        if self.mouseleave == nil then
            self.mouseleave = self:event(leavecallback, FRAMEEVENT_MOUSE_LEAVE)
        elseif self.mouseleave.trig then
            TriggerAddAction(self.mouseleave.trig, leavecallback, kui.debug, islocalbool)
        else
            print("error: addevents is missing a trigger for mouseleave")
        end
    end
    if clickcallback ~= nil then
        local ct = FRAMEEVENT_CONTROL_CLICK
        if self.simple then ct = FRAMEEVENT_CONTROL_CLICK end
        if self.click == nil then
            self.click      = self:event(clickcallback, ct, kui.debug, islocalbool)
        elseif self.click.trig then
            TriggerAddAction(self.click.trig, clickcallback)
        else
            print("error: addevents is missing a trigger for click")
        end
    end
end


-- @eventcallback = run this func.
function kui.frame:addnetclickevent(eventcallback)
    -- add an event which requires being non-local e.g.
    --  create a unit, change or compare handles, etc.
    self:event(eventcallback, FRAMEEVENT_CONTROL_CLICK, false, false)
end



-- @eventcallback   = action to run on event.
-- @frameeventtype  = event which runs callback.
-- @debugbool       = [optional] set to false to individually disable debug.
-- @localbool       = [optional] default true. set to false to run net-code funcs. *important.
function kui.frame:event(eventcallback, frameeventtype, debugbool, localbool)
    -- this should be used on frame objects ( e.g. fr:event() )
    local localbool = localbool or true
    local eventfunc
    if localbool then
        eventfunc = function()
            if utils.islocaltrigp() then
                utils.debugfunc(function() eventcallback() end, kui.debugstr[frameeventtype])
                self:focusfix()
            end
        end
    else
        eventfunc = function()
            utils.debugfunc(function() eventcallback() end, kui.debugstr[frameeventtype])
            if utils.islocaltrigp() then self:focusfix() end
        end
    end
    local event = {
        trig   = CreateTrigger(),
        event  = eventcallback,
    }
    BlzTriggerRegisterFrameEvent(event.trig, self.fh, frameeventtype)
    TriggerAddCondition(event.trig, Condition(function()
        return BlzGetTriggerFrameEvent() == frameeventtype and self:istrigger()
    end) )
    TriggerAddAction(event.trig, eventfunc)
    if kui.debug and debugbool ~= false then self:addeventdebug(event.trig, kui.debugstr[frameeventtype]) end
    return event
end


-- @closefr = the frame which gets closed by this frame object.
function kui.frame:linkcloseevent(closefr)
    if self.fh and closefr.fh then
        local onclick = function()
            if utils.islocaltrigp() then
                self:focusfix()
                closefr:hide()
            end
        end
        self:addevents(nil, nil, onclick)
    else
        print("error: linkcloseevent found no eligible framehandles")
    end
end


-- @linkedfr = the frame which is controlled by the open/show btn.
function kui.frame:linkshowhidebtn(linkedfr)
    -- self (fr) will show/hide the linkedfr
    if self.fh and linkedfr.fh then
        local onclick = function()
            if utils.islocaltrigp() then
                self:focusfix()
                if linkedfr:isvisible() then
                    linkedfr:hide()
                else
                    -- if the button has an alert notification assigned, hide it.
                    if self.alerticon then
                        self.alerticon:hide()
                    end
                    linkedfr:show() -- show frame.
                end
            end
        end
        self:addevents(nil, nil, onclick)
    else
        print("error: linkshowhidebtn found no eligible framehandles")
    end
end


-- @targetfr      = show this frame and hide the triggering frame.
-- @groupparentfr = [optional] hide a group frame instead of the target frame.
function kui.frame:addswapevent(targetfr, groupparentfr)
    if self.fh and targetfr.fh then
        local onclick = function()
            if utils.islocaltrigp() and not self.disabled then
                targetfr:show()
                if groupparentfr then groupparentfr:hide() else self:hide() end
                utils.playsound(kui.sound.clickstr)
            end
        end
        self:addevents(nil, nil, onclick)
    else
        print("error: addswapevent found no eligible framehandles on 'targetfr'")
    end
end


-- @sndtype = 0 for close, 1 for open.
function kui.frame:statesound(sndtype)
    -- checks for panelid and plays stored sound. 
    if self.panelid and self.statesnd then
        if sndtype == 1 then
            utils.playsound(kui.sound.panel[self.panelid].open)
        else
            utils.playsound(kui.sound.panel[self.panelid].close)
        end
    end
end


function kui.frame:enableeventsall(bool)
    -- this should be used on frame objects ( e.g. fr:enableeventsall() )
    if self.mouseenter then utils.triggeron(self.mouseenter.trig, bool) end
    if self.mouseleave then utils.triggeron(self.mouseleave.trig, bool) end
    if self.click      then utils.triggeron(self.click.trig,      bool) end
end


function kui.frame:enableevent(enterbool, leavebool, clickbool)
    -- this should be used on frame objects ( e.g. fr:enableevent() )
    if self.mouseenter then utils.triggeron(self.mouseenter.trig, enterbool) end
    if self.mouseleave then utils.triggeron(self.mouseleave.trig, leavebool) end
    if self.click      then utils.triggeron(self.click.trig,      clickbool) end
end


-- @texttype = "header", "base", "tip", or "btn"
-- @str      = btn display text.
-- @anchor   = anchor point or "all"
function kui.frame:addtext(texttype, str, anchor)
    -- **note: this is used in our tooltip class.
    if texttype == "base"   then self.txt = kui.frame:newbyname("FrameBaseText",   self) elseif -- consolas reg, justify left, top
       texttype == "btn"    then self.txt = kui.frame:newbyname("FrameBtnText",    self) elseif -- tarzan sml, justify center, middle
       texttype == "tip"    then self.txt = kui.frame:newbyname("FrameTooltipText",self) elseif -- consolas reg, justify center, middle
       texttype == "header" then self.txt = kui.frame:newbyname("FrameHeaderText", self)        -- tarzan lrg, justify center, middle
    end
    BlzFrameSetText(self.txt.fh, str)
    if anchor == "all" then
        BlzFrameSetAllPoints(self.txt.fh, self.fh)
    else
        BlzFrameSetPoint(self.txt.fh, anchor, self.fh, anchor, 0.0, 0.0)
    end
end


-- @tipstr = tooltip lookup string (kui.tooltip)
function kui.frame:assigntooltip(tipstr)
    self.tip = tooltip:get(tipstr) -- fetch stored tooltip table w/ settings.
    -- check which frame to show/update on hover:
    if self.tip.fn then
        if self.tip.fn == "FrameItemTooltip" then
            self.tip.fr = tooltip.itemtipfr
        elseif self.tip.fn == "FrameLongformTooltip" then
            self.tip.fr = tooltip.advtipfr
        end
    else
        self.tip.fr = tooltip.simpletipfr
    end
    -- assign hover event:
    if self.tip.fr and self.tip.fr.fh then
        local enter = function()
            utils.debugfunc(function()
                if not self.disabled then
                    if self.tip.simple then -- simple frame, 1-line.
                        local c,w,_,h
                        if self.tip.hoverset then
                            local hovertext = self.tip.hoverset(self.hoverarg or nil)
                            if hovertext == nil then return end -- stop if something happened and text is nil.
                            _,h = string.gsub(hovertext,"|c","|c")
                            c = string.len(hovertext)
                            if utils.islocaltrigp() then
                                BlzFrameSetText(self.tip.fr.txt.fh, hovertext)
                            end
                        else
                            _,h = string.gsub(self.tip.txt,"|c","|c")
                            c = string.len(self.tip.txt)
                            if utils.islocaltrigp() then
                                BlzFrameSetText(self.tip.fr.txt.fh, self.tip.txt)
                            end
                        end
                        c      = c - (h*12) -- hex codes are 12 chars.
                        w      = tooltip.setting.simplew+(c*tooltip.setting.simplec)
                        self.tip.fr.alpha = 240
                        self.tip.fr:setsize(w, tooltip.setting.simpleh)
                        self.tip.fr:setlvl(tooltip.setting.flevel)
                        self.tip.fr:resetalpha()
                        self.tip.fr:show()
                        self.tip.fr:clearallfp()
                        self.tip.fr:setfp(self.tip.tipanchor, self.tip.attachanchor, self.fh, 0, 0)
                    end
                else
                    self.tip.fr:hide()
                end
            end, "simple tip hover")
        end
        local leave = function()
            self.tip.fr:hide()
        end
        self:addevents(enter, leave, nil)
        self.tip.fr:hide()
    else
        assert(false, "error: assigntooltip failed to find a tooltip frame for '"..tipstr.."'")
    end
end


function kui.frame:initializeadvtip()
    -- on hover, show a text area tooltip.
    self.tip = tooltip:get("advtip")
    self.tip.fr = tooltip.advtipfr
    if not self.advtipanchor    then self.advtipanchor    = self.tip.tipanchor end
    if not self.advattachanchor then self.advattachanchor = self.tip.attachanchor end
    local enter = function()
        if utils.trigp() == utils.localp() then
            if self:isvisible() and self.advtip and self.advtip[3] then
                BlzFrameSetTexture(tooltip.advtipfh[1], self.advtip[1], 0, true) -- icon texture
                BlzFrameSetText(tooltip.advtipfh[2], self.advtip[2]) -- name
                BlzFrameSetText(tooltip.advtipfh[3], self.advtip[3]) -- description
                self.tip.fr:show()
                self.tip.fr:clearallfp()
                self.tip.fr:setfp(self.advtipanchor, self.advattachanchor, self, 0.0, 0.0)
            else
                self.tip.fr:hide()
            end
        end
    end
    local leave = function()
        if utils.trigp() == utils.localp() then
            self.tip.fr:hide()
        end
    end
    self.tip.fr:hide()
    self:addevents(enter, leave, nil)
end


function kui.frame:initializeitemslot(slotid)
    -- hover-over functionality for item tooltips.
    self.tip    = tooltip:get("itemtip")
    self.tip.fr = tooltip.itemtipfr
    local enter = function()
        local p = utils.trigp()
        if kobold.player[p]:getitem(slotid) ~= nil then
            local targetslotid = kobold.player[p].items[slotid].itemtype.slottype.slotid
            -- update item comp tooltip:
            if slotid < 1000 and kobold.player[p].items[targetslotid] then
                kobold.player[p].items[targetslotid]:updatecomptooltip(p)
                tooltip.itemcompfr:show()
                tooltip.itemcompfr:setfp(fp.r, fp.l, self.tip.fr, kui:px(-10), 0.0)
            else
                tooltip.itemcompfr:hide()
            end
            -- update item hover tooltip:
            if kobold.player[p]:islocal() then
                kobold.player[p]:getitem(slotid):updatetooltip(p)
                self.tip.fr:show() 
                self.tip.fr:setfp(self.tip.tipanchor, self.tip.attachanchor, self, 0, 0)
            end
        else
            if kobold.player[p]:islocal() then self.tip.fr:hide() end
        end
    end
    local leave = function()
        if kobold.player[utils.trigp()]:islocal() then
            self.tip.fr:hide()
            tooltip.itemcompfr:hide()
        end
    end
    local click = function()
        -- understanding this event: .selslotid == currently selected slot if not nil, slotid == target slot.
        local p = utils.trigp()
        kui.canvas.game.inv.pane:hide()
        kui.canvas.game.equip.pane:hide()
        kui.canvas.game.dig.pane:hide()
        -- if no slot already selected and item exists in slot, or if clicking on another item that exists already:
        if (not kobold.player[p].selslotid and kobold.player[p].items[slotid])
                or (kobold.player[p].selslotid and kobold.player[p].items[slotid] and kobold.player[p].selslotid ~= slotid) then
            kobold.player[p].selslotid = slotid
            if p == utils.localp() then
                if slotid < 1000 then -- is inventory slot.
                    kui.canvas.game.inv.pane:show()
                    kui.canvas.game.inv.pane:setfp(fp.c, fp.c, self)
                    utils.playsound(kui.sound.itemsel)
                elseif slotid ~= 1011 then -- is equipment slot.
                    kui.canvas.game.equip.pane:show()
                    kui.canvas.game.equip.pane:setfp(fp.c, fp.c, self)
                    utils.playsound(kui.sound.itemsel)
                elseif slotid == 1011 then -- is dig key
                    kui.canvas.game.dig.pane:show()
                    kui.canvas.game.dig.pane:setfp(fp.c, fp.c, self)
                    utils.playsound(kui.sound.itemsel)
                end
            end
        -- if slot already selected, and next slot is empty:
        elseif kobold.player[p].selslotid and not kobold.player[p].items[slotid] then
            if p == utils.localp() then
                -- inventory slot to empty inventory slot:
                if kobold.player[p].selslotid < 1000 and slotid < 1000 then
                    loot.item:slotswap(p, kobold.player[p].selslotid, slotid)
                    utils.playsound(kui.sound.itemsel)
                -- equipment slot or dig key to empty inventory slot:
                elseif kobold.player[p].selslotid > 1000 and slotid < 1000 then
                    local firstslotid = loot:getfirstempty(p)
                    loot.item:unequip(p, kobold.player[p].selslotid) -- (plays sound internally)
                    if slotid ~= firstslotid then
                        loot.item:slotswap(p, firstslotid, slotid)
                    end
                -- inventory slot to empty equipment slot:
                elseif kobold.player[p].selslotid < 1000 and slotid > 1000 then
                    loot.item:equip(p, kobold.player[p].selslotid) -- (plays sound internally)
                end
            end
            kobold.player[p].selslotid = nil
        -- cleanup in all other situations:
        else
            kobold.player[p].selslotid = nil
        end
    end
    self.tip.fr:hide()
    self:addevents(enter, leave, click)
end


function kui.frame:isvisible()
    return BlzFrameIsVisible(self.fh)
end


function kui.frame:isenabled()
    return BlzFrameGetEnable(self.fh)
end


function kui.frame:istrigger()
    return BlzGetTriggerFrame() == self.fh
end


function kui.frame:suppress(bool)
    -- prevent a frame's sound, showfunc, and hidefunc actions
    --  after they are shown or hidden. Should be for temp use.
    self.suppress = bool
end


function kui.frame:suppressall(bool)
    -- run suppress for all canvas.game frames.
    for _,fr in pairs(kui.canvas.game) do
        if type(fr) == "table" then
            fr.suppress = bool
        end
    end
end


function kui.frame:show(_datafunc)
    if self.fh then
        BlzFrameSetVisible(self.fh, true)
        if self.showfunc and not self.suppress then self.showfunc() end
        if not suppress_all_panel_sounds and self.statesnd and not self.suppress then self:statesound(1) end
        if _datafunc then _datafunc() end
    else
        print("error: attempted to show frame with no 'fh' for "..self.fh)
    end
end


function kui.frame:hide(_datafunc)
    if self.fh then
        BlzFrameSetVisible(self.fh, false)
        if self.hidefunc and not self.suppress then self.hidefunc() end
        if not suppress_all_panel_sounds and self.statesnd and not self.suppress then self:statesound(0) end
        if _datafunc then _datafunc() end
    else
        print("error: attempted to hide frame with no 'fh' for "..self.fh)
    end
end


function kui.frame:enable()
    self.disabled = false
    self:resettex()
end


function kui.frame:active()
    -- for alternative functionality and graphics
    --  e.g. a button has multiple states.
    self.activated = true
    self.disabled  = false
    self:resettex()
end


function kui.frame:inactive()
    -- for alternative functionality and graphics
    --  e.g. a button has multiple states.
    self.activated = false
    self.disabled  = false
    self:resettex()
end


function kui.frame:disable()
    self.disabled = true
    self:resettex()
end


function kui.frame:focusfix()
    -- remove keyboard focus hack:
    -- *note this needs to run for local p only.
    if utils.islocaltrigp() then
        BlzFrameSetEnable(self.fh, false)
        BlzFrameSetEnable(self.fh, true)
    end
end


function kui.frame:settext(str)
    BlzFrameSetText(self.fh, str)
end


-- @targetfr = [optional] when provided, the hovered frame will instead alter this frame object.
-- (useful for when backdrops are used behind buttons)
function kui.frame:addhoverhl(targetfr)
    -- makes a frame light up on hover.
    local targetfr = targetfr or nil
    if not targetfr then
        self.alphahl = self.alpha
        self.alpha   = math.floor(self.alpha*self.alpharatio)
        self:resetalpha()
    else
        targetfr.alphahl = targetfr.alpha
        targetfr.alpha   = math.floor(targetfr.alpha*targetfr.alpharatio)
        targetfr:resetalpha()
    end
    local enter,leave
    if targetfr ~= nil then
        enter = function()
            if utils.islocaltrigp() then
                BlzFrameSetAlpha(targetfr.fh,targetfr.alphahl)
                if targetfr and targetfr.statesnd and targetfr:isnotpreviousframesoundfh() then
                    utils.playsound(kui.sound.hoverbtn)
                end
            end
        end
        leave = function() targetfr:resetalpha() end
    else
        enter = function()
            if utils.islocaltrigp() then
                BlzFrameSetAlpha(self.fh,self.alphahl)
                if targetfr and targetfr.statesnd and targetfr:isnotpreviousframesoundfh() then
                    utils.playsound(kui.sound.hoverbtn)
                end
            end
        end
        leave = function() self:resetalpha() end
    end
    self:event(enter, FRAMEEVENT_MOUSE_ENTER)
    self:event(leave, FRAMEEVENT_MOUSE_LEAVE)
end


function kui.frame:isnotpreviousframesoundfh()
    -- 1.33 tacky fix for enter/exit loop bug:
    if kui.previousframesoundfh and kui.previousframesoundfh == self.fh then
        return false -- stop sound from repeating
    else
        kui.previousframesoundfh = self.fh
        return true -- allow first sound
    end
end



function kui.frame:addtexhl(targetfr)
    if targetfr.normaltex and targetfr.hovertex then
        enter = function()
            if utils.islocaltrigp() then
                if not self.disabled then targetfr:setbgtex(targetfr.hovertex) end
                if self.statesnd and self:isnotpreviousframesoundfh() then
                    utils.playsound(kui.sound.hoverbtn)
                end
            end
        end
        leave = function()
            if utils.islocaltrigp() then
                if not self.disabled then
                    if self.activated then
                        targetfr:setbgtex(targetfr.activetex)
                    else
                        targetfr:setbgtex(targetfr.normaltex)
                    end
                else
                    targetfr:setbgtex(targetfr.distex)
                end
            end
        end
        self:event(enter, FRAMEEVENT_MOUSE_ENTER)
        self:event(leave, FRAMEEVENT_MOUSE_LEAVE)
    else
        print("error: addtexhl could not find a normal or hover texture")
    end
end


-- @targetfr = [optional] when provided, the hovered frame will instead alter this frame object.
-- (useful for when backdrops are used behind buttons)
-- @scale    = [optional] override default scale
function kui.frame:addhoverscale(targetfr, scale)
    -- makes a frame grow in scale when hovered.
    local scale = scale or kui.meta.hoverscale
    local enter,leave
    if targetfr ~= nil then
        enter = function()
            if utils.islocaltrigp() and not self.disablehoverscale then
                BlzFrameSetScale(targetfr.fh,scale)
                if self.statesnd and self:isnotpreviousframesoundfh() then utils.playsound(kui.sound.hoversft) end
            end
        end
        leave = function() targetfr:resetscale() end
    else
        enter = function()
            if utils.islocaltrigp() and not self.disablehoverscale then
                BlzFrameSetScale(self.fh,scale)
                if self.statesnd and self:isnotpreviousframesoundfh() then utils.playsound(kui.sound.hoversft) end
            end
        end
        leave = function() self:resetscale() end
    end
    self:event(enter, FRAMEEVENT_MOUSE_ENTER, kui.debughover)
    self:event(leave, FRAMEEVENT_MOUSE_LEAVE, kui.debughover)
end


-- @id     = unit to create.
-- @charid = class id to map custom assets.
-- @selsnd = [optional] character selected sound to play.
function kui.frame:addselectclassevent(id, charid, selsnd)
    -- create a new unit, using smart handling (trig player or trig unit owner).
    local trig = CreateTrigger()
    kui:addclasslistener(trig)
    local click = function()
        utils.debugfunc(function()
            local p = utils.trigp()
            local pnum = utils.pnum(p)
            if not kobold.player[p].unit then -- events dup sometimes; see if unit was made already.
                BlzSendSyncData("classpick", tostring(pnum)..tostring(charid)..tostring(id))
                if p == utils.localp() then
                    if selsnd then utils.playsound(selsnd, p) end
                end
            end
        end,"selectclass")
    end
    self:addnetclickevent(click)
end


function kui:addclasslistener(trig)
    for p,_ in pairs(kobold.playing) do
        BlzTriggerRegisterPlayerSyncEvent(trig, p, "classpick", false)
    end
    TriggerAddAction(trig, function()
        utils.debugfunc(function()
            local d      = BlzGetTriggerSyncData()
            local pid    = string.sub(d,1,1)
            local charid = string.sub(d,2,2)
            local id     = string.sub(d,3)
            charid       = tonumber(charid)
            pid          = tonumber(pid)
            local p      = Player(pid-1)
            if not kobold.player[p].unit then
                utils.setcambounds(gg_rct_expeditionVision, p)
                kobold.player[p].unit    = utils.unitinrect(kui.meta.rectspawn, p, id)
                kobold.player[p].charid  = charid
                kui.effects.char[charid]:playu(kobold.player[p].unit)
                utils.restorestate(kobold.player[p].unit)
                kui.canvas.game.equip:initequipment(charid, p)
                kobold.player[p].ability = ability.template:new(p, charid)
                kobold.player[p].ability:load(charid) -- keep below template:new
                kobold.player[p].ability:learn(1, 1)
                kobold.player[p].keymap = hotkey.map:new(p)
                kobold.player[p]:updateallstats()
                utils.pantorect(p, kui.meta.rectspawn, 0.0)
                kui:initializefootsteps(kobold.player[p])
                --
                if not kobold.player[p].loadchar then
                    quest:load_current()
                end
                kui:hidesplash(p, true)
                -- TODO: how would this work if we implement multiplayer?:
                if not kk.devmode then
                    if freeplay_mode then
                        utils.timed(1.21, function() screenplay:run(screenplay.chains.narrator_intro_freeplay) end)
                    elseif not kobold.player[p].loadchar then
                        utils.timed(1.21, function() screenplay:run(screenplay.chains.narrator_intro) end)
                    else
                        kui:showgameui(p, true)
                    end
                else
                    kui:showgameui(p, true)
                end
                if kui.lockcam then utils.permselect(kobold.player[p].unit, p, kobold.player[p]) end -- cam and select lock.
                kui.canvas.game.party.pill[pid] = kui:createpartypill(kui.canvas.game.party, pid, charid)
                kui:attachupdatetimer(p, pid) -- hp/mana bar and party pill timer.
                -- enable freeplay features if selected:
                if freeplay_mode and not kobold.player[p].loadchar then
                    kobold.player[p]:freeplaymode()
                end
                -- badges:
                badge:load_data(kobold.player[p])
                -- click to move:
                udg_click_move_unit = {}
                udg_click_move_unit[utils.pid(p)] = kobold.player[p].unit
                ctm.sys:create()
                -- recolor and add attachments:
                if charid == 1 then -- tunneler
                    SetUnitColor(kobold.player[p].unit, GetPlayerColor(Player(4)))
                    AddSpecialEffectTargetUnitBJ("right hand", kobold.player[p].unit, "war3mapImported\\Akamas Kama3.mdx")
                    BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.7)
                    AddSpecialEffectTargetUnitBJ("left hand", kobold.player[p].unit, "war3mapImported\\SpiritLantern_MyriadFungiForHive.mdx")
                BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.75)
                elseif charid == 2 then -- geomancer
                    SetUnitColor(kobold.player[p].unit, GetPlayerColor(Player(3)))
                    AddSpecialEffectTargetUnitBJ("right hand", kobold.player[p].unit, "war3mapImported\\NatureStaff - Corrupted.mdx")
                    BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.7)
                    AddSpecialEffectTargetUnitBJ("left hand", kobold.player[p].unit, "war3mapImported\\SpiritLanternBlueForHive.mdx")
                BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.75)
                elseif charid == 3 then -- rascal
                    SetUnitColor(kobold.player[p].unit, GetPlayerColor(Player(0)))
                    AddSpecialEffectTargetUnitBJ("right hand", kobold.player[p].unit, "war3mapImported\\MorgulBlade.mdx")
                    BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.6)
                    AddSpecialEffectTargetUnitBJ("left hand", kobold.player[p].unit, "war3mapImported\\SpiritLanternRedForHive.mdx")
                BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.75)
                elseif charid == 4 then -- wickfighter
                    SetUnitColor(kobold.player[p].unit, GetPlayerColor(Player(5)))
                    AddSpecialEffectTargetUnitBJ("right hand", kobold.player[p].unit, "war3mapImported\\Fire Sword.mdx")
                    BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.7)
                    AddSpecialEffectTargetUnitBJ("left hand", kobold.player[p].unit, "war3mapImported\\HandHeldLantern.mdx")
                BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.75)
                end
                AddSpecialEffectTargetUnitBJ("chest", kobold.player[p].unit, "war3mapImported\\Backpack_by_dioris.mdx")
                BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.9)
                AddSpecialEffectTargetUnitBJ("head", kobold.player[p].unit, "war3mapImported\\Candle1.mdx")
                BlzSetSpecialEffectScale(GetLastCreatedEffectBJ(), 0.9)
            end
        end, "select class")
    end)
end


function kui:attachupdatetimer(p, pid)
    local p, pid = p, pid
    -- attach state bar update timer:
    TimerStart(NewTimer(),0.2,true,function()
        if utils.localp() == p then -- interface bars (local only).
            if kui.canvas.game.skill:isvisible() then
                if not kobold.player[p].downed then
                    utils.debugfunc(function()
                        BlzFrameSetValue( kui.canvas.game.skill.hpbar.fh, 
                            math.floor(100-GetUnitLifePercent(kobold.player[p].unit)) ) -- hp bar is inversed
                        BlzFrameSetValue( kui.canvas.game.skill.manabar.fh, 
                            math.ceil(GetUnitManaPercent(kobold.player[p].unit)) )
                        BlzFrameSetText( kui.canvas.game.skill.hptxt.fh,
                            math.floor(GetUnitState(kobold.player[p].unit, UNIT_STATE_LIFE))
                            .."/"
                            ..math.floor(GetUnitState(kobold.player[p].unit, UNIT_STATE_MAX_LIFE)))
                        BlzFrameSetText( kui.canvas.game.skill.manatxt.fh,
                            math.floor(GetUnitState(kobold.player[p].unit, UNIT_STATE_MANA))
                            .."/"
                            ..math.floor(GetUnitState(kobold.player[p].unit, UNIT_STATE_MAX_MANA)))
                    end, "update bars")
                else
                    BlzFrameSetText( kui.canvas.game.skill.hptxt.fh, color:wrap(color.tooltip.bad, "Incapacitated"))
                    BlzFrameSetValue( kui.canvas.game.skill.hpbar.fh, 100)
                    BlzFrameSetText( kui.canvas.game.skill.manatxt.fh, color:wrap(color.tooltip.bad, "Incapacitated"))
                    BlzFrameSetValue( kui.canvas.game.skill.manabar.fh, 0)
                end
            end
        end
        if not kobold.player[p].downed then -- party pill bars (non-local).
            BlzFrameSetValue( kui.canvas.game.party.pill[pid].hpbar.fh,   math.ceil(GetUnitLifePercent(kobold.player[p].unit)) )
            BlzFrameSetValue( kui.canvas.game.party.pill[pid].manabar.fh, math.ceil(GetUnitManaPercent(kobold.player[p].unit)) )
        else
            BlzFrameSetValue( kui.canvas.game.party.pill[pid].hpbar.fh, 0 )
            BlzFrameSetValue( kui.canvas.game.party.pill[pid].manabar.fh, 0 )
        end
    end )
end


-- @charid  = matching class id.
-- @p       = for this local player.
function kui.frame:initequipment(charid, p)
    -- since we use custom graphics, base equip is empty,
    --  we then update local player textures.
    if p == utils.localp() then
        self:addbgtex(kui.tex.char[charid].panelequip)
        self:hide()
    end
end


function kui.frame:resetalpha()
    if self.fh then BlzFrameSetAlpha(self.fh, self.alpha)
    else print("error: resetalpha found no 'fh' for frame object.") end
end


function kui.frame:setalpha(val)
    if self.fh then BlzFrameSetAlpha(self.fh, math.floor(val)) end
end


function kui.frame:setnewalpha(val)
    if self.fh then self.alpha = math.floor(val) BlzFrameSetAlpha(self.fh, self.alpha) end
end


function kui.frame:setscale(scale)
    if self.fh then BlzFrameSetScale(self.fh, scale) end
end


function kui.frame:resetscale()
    if self.fh then BlzFrameSetScale(self.fh,1.0)
    else print("error: resetscale found no 'fh' for frame object.") end
end


function kui.frame:resettex()
    if self.fh then
        if self.disabled and self.distex then
            BlzFrameSetTexture(self.fh, self.distex, 0, true)
        elseif self.activated and self.activetex then
            BlzFrameSetTexture(self.fh, self.activetex, 0, true)
        elseif self.normaltex then
            BlzFrameSetTexture(self.fh, self.normaltex, 0, true)
        end
    else print("error: resettex found no 'fh' for frame object.") end
end


function kui.frame:reset()
    self:resetscale()
    self:resetalpha()
    self:resettex()
end


-- @w,h = width, height (% of screen)
function kui.frame:setsize(w, h)
    -- set the height, width, or both of a frame with ease.
    --  pass nil for the one to ignore when using single arg.
    if w and h then
        BlzFrameSetSize(self.fh, w, h)
    elseif w then
        BlzFrameSetSize(self.fh, w, BlzFrameGetHeight(self.fh))
    elseif h then
        BlzFrameSetSize(self.fh, BlzFrameGetWidth(self.fh), h)
    else
        print("error: setsize found no width and height args")
    end
end


function kui.frame:w()
    return BlzFrameGetWidth(self.fh)
end


function kui.frame:h()
    return BlzFrameGetHeight(self.fh)
end


-- @anchor       = frame point of owner frame.
-- @targetanchor = frame point of the target frame.
-- @targetfr     = attach frame object to this frame.
-- @x,y          = [optional] screen percentage offset from anchor.
function kui.frame:setfp(anchor, targetanchor, targetfr, x, y)
    -- supports frame handle or frame object.
    local x = x or 0.0
    local y = y or 0.0
    if type(targetfr) == "table" then -- object
        if targetfr.fh then
            BlzFrameSetPoint(self.fh, anchor, targetfr.fh, targetanchor, x, y)
        else
            print("error: setfp() could not find a framehandle on 'targetfr'.")
        end
    else -- framehandle
        BlzFrameSetPoint(self.fh, anchor, targetfr, targetanchor, x, y)
    end
end


-- @anchor       = frame point of owner frame.
-- @x,y          = abs screen percentage offset.
function kui.frame:setabsfp(anchor, x, y)
    -- supports frame handle or frame object.
    BlzFrameSetAbsPoint(self.fh, anchor, x, y)
end


-- @targetfr = frame to match points.
function kui.frame:setallfp(targetfr)
    -- supports frame handle or frame object.
    if type(targetfr) == "table" then -- object
        self:clearallfp()
        BlzFrameSetAllPoints(self.fh, targetfr.fh)
    else -- framehandle
        BlzFrameSetAllPoints(self.fh, targetfr)
    end
end


function kui.frame:clearallfp()
    if self.fh then
        BlzFrameClearAllPoints(self.fh)
    end
end


-- @parentfr = set this as parent.
function kui.frame:setparent(parentfr)
    -- supports frame handle or frame object.
    if type(targetfr) == "table" then -- object
        BlzFrameSetParent(self.fh, parentfr.fh)
    else -- framehandle
        BlzFrameSetParent(self.fh, parentfr)
    end
end


function kui.frame:clearallfp()
    BlzFrameClearAllPoints(self.fh)
end


function kui.frame:verifytables()
    if not self.string then self.string = {} end
end


function kui.frame:addeventdebug(trig, eventnamestr)
    -- print frame events and frame names when testing
    --  frame event components.
    if not self.suppressdebug then
        TriggerAddAction(trig, function()
            print("::: new debug event :::")
            if self.debugn then print("'"..self.debugn.."'") end
            print("'"..eventnamestr.."' : trig: "..GetHandleId(trig).." fr: "..GetHandleId(self.fh).." fh: "..GetHandleId(BlzGetTriggerFrame()))
        end)
    end
end


function kui:pxdpiscale()
    -- for screens that have smaller than standard 0.6 max Y size
    -- since pixel values were pulled from a 1080px screen, use
    -- that as the baseline denominator.
    self.dpiratio = 0.6*(self.screenh/1080.0)
end


function kui:pxtodpi()
    return self.dpiratio/self.screenh
end


function kui:px(pixels)
    return pixels*kui:pxtodpi()
end


function kui:setfullscreen(fh)
    -- pass a  framehandle and set it to cover the entire screen.
    BlzFrameSetSize(fh, kui:px(1920), kui:px(1080))
    BlzFrameSetPoint(fh, fp.c, self.worldui, fp.c, 0, 0)
end


-- @parentfr     = assigned parent frame (e.g. the canvas frame).
-- @texture      = use this texture as the backdrop
-- @panelid      = determines positioning (ordering 1, 2, 3 on screen)
function kui:createmainframeparent(texture, parentfr, panelid)
    -- create a large container for main UI components (inventory, equipment, char panel, etc.).
    local fr = kui.frame:newbytype("BACKDROP", parentfr)
    local xpos
    if panelid == 1 then -- leftmost panel
        xpos = self.position.centerx-(kui:px(kui.meta.mfw)+kui:px(kui.meta.mfp))
    elseif panelid == 2 then -- center panel
        xpos = self.position.centerx
    elseif panelid == 3 then -- rightmost panel
        xpos = self.position.centerx+(kui:px(kui.meta.mfw)+kui:px(kui.meta.mfp))
    end
    fr.ismf     = true
    fr.statesnd = true
    fr.panelid  = panelid
    fr:addbgtex(texture)
    fr:setsize(kui:px(kui.meta.mfw), kui:px(kui.meta.mfh))
    fr:setabsfp(fp.c, xpos, 0.32 + kui:px(kui.meta.skillh*0.5))
    fr:createmainframeclosebtn()
    return fr
end


function kui:createmassivepanel(headerstr, texture)
    -- build scroll panel that takes up the whole screen:
    local texture = texture or kui.meta.massivescroll.tex
    local fr = kui.frame:newbytype("BACKDROP", kui.canvas.game)
    fr:addbgtex(texture)
    fr:setsize(kui:px(kui.meta.massivescroll.w), kui:px(kui.meta.massivescroll.h))
    fr:setabsfp(fp.c, kui.position.centerx, 0.32 + kui:px(kui.meta.skillh*0.5))
    fr:addtext("btn",headerstr,fp.c)
    fr.txt:setfp(fp.c, fp.c, fr, kui:px(kui.meta.massivescroll.headerx), kui:px(kui.meta.massivescroll.headery) - kui:px(38))
    fr:createmainframeclosebtn()
    return fr
end


function kui:createcharpage(parentfr)
    -- this frame is complicated so we are going the hardcoded route.
    local ltext, rtext, lval, rval = {},{},{},{}
    ltext[1], ltext[2], rtext[1], rtext[2], lval[1], lval[2], rval[1], rval[2] = tooltip:charcleanse(kobold.player)
    local fr    = self:createmainframeparent(kui.tex.panelchar, parentfr, 1)
    local offx  = kui:px(97) -- gap between attr values.
    local funcs = {}
    -- hidden parent for group control:
    fr.attr    = self.frame:newbytype("PARENT", parentfr)
    fr.attr:setlvl(1)
    -- 1 = str, 2 = wis, 3 = ala, 4 = vit
    for i = 1,4 do
        local attrid = p_attr_map[i]
        funcs[i] = function() utils.debugfunc(function() kobold.player[utils.trigp()]:applyattrpoint(attrid) end, "applyattrpoint") end
        -- start attribute values:
        fr.attr[i] = fr:createtext("0", 1.0, true)
        fr.attr[i]:setsize(kui:px(54), kui:px(20))
        fr.attr[i]:setfp(fp.c, fp.tl, fr, kui:px(90) + ((i-1)*offx), -kui:px(216))
        -- start "add attribute +" button:
        fr.attr[i].addbd  = kui.frame:newbytype("BACKDROP", fr)
        fr.attr[i].addbd:addbgtex(kui.tex.addatr)
        fr.attr[i].addbd:setsize(kui:px(43), kui:px(25))
        fr.attr[i].addbd:setfp(fp.c, fp.tl, fr, kui:px(90) + ((i-1)*offx), -kui:px(239))
        fr.attr[i].addbd:setlvl(1)
        fr.attr[i].addbtn = kui.frame:newbytype("BUTTON", fr.attr[i].addbd)
        fr.attr[i].addbtn:setallfp(fr.attr[i].addbd)
        fr.attr[i].addbtn:assigntooltip("attrzero")
        fr.attr[i].addbtn:addevents(nil, nil, funcs[i], nil, false)
        -- start invisible attribute wrapper for hovering tooltip
        fr.attr[i].tiptxt = fr:createheadertext(color:wrap(color.tooltip.good, ""))
        fr.attr[i].tiptxt:setfp(fp.c, fp.c, fr.attr[i].addbd, 0.0, kui:px(70))
        fr.attr[i].tiptxt:setsize(kui:px(70), kui:px(70))
    end
    fr.attr[1].tiptxt:assigntooltip("strength")
    fr.attr[2].tiptxt:assigntooltip("wisdom"  )
    fr.attr[3].tiptxt:assigntooltip("alacrity")
    fr.attr[4].tiptxt:assigntooltip("vitality")
    -- left/right page arrows:
    fr.rightarr = kui.frame:newbtntemplate(fr, "war3mapImported\\icon-arrow_right.blp")
    fr.rightarr:setsize(kui:px(32), kui:px(32))
    fr.rightarr:setfp(fp.tl, fp.tl, fr, kui:px(395), kui:px(-279))
    fr.rightarr.btn:addhoverhl(fr.rightarr)
    fr.leftarr  = kui.frame:newbtntemplate(fr, "war3mapImported\\icon-arrow_left.blp")
    fr.leftarr:setsize(kui:px(32), kui:px(32))
    fr.leftarr:setfp(fp.c, fp.c, fr.rightarr)
    fr.leftarr.btn:addhoverhl(fr.leftarr)
    fr.leftarr:hide()
    -- start building page text:
    fr.page = {}
    for i = 1,2 do
        fr.page[i]      = kui.frame:newbytype("PARENT", fr)
        fr.page[i].enhl = fr.page[i]:createtext(ltext[i]) -- left block
        fr.page[i].enhl:setsize(kui:px(162), kui:px(210))
        fr.page[i].enhl:setfp(fp.tl, fp.tl, fr, kui:px(60), -kui:px(310))
        fr.page[i].enhr = fr.page[i]:createtext(rtext[i]) -- right block
        fr.page[i].enhr:setsize(kui:px(162), kui:px(210))
        fr.page[i].enhr:setfp(fp.tl, fp.tl, fr, kui:px(245), -kui:px(310))
        -- start "enhancements" data value blocks:
        fr.page[i].lval = fr.page[i]:createtext(lval[i]) -- left vals
        fr.page[i].lval:setsize(kui:px(162), kui:px(210))
        fr.page[i].lval:setfp(fp.tr, fp.tr, fr.page[i].enhl, kui:px(6), 0.0)
        BlzFrameSetTextAlignment(fr.page[i].lval.fh, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_RIGHT)
        fr.page[i].rval = fr.page[i]:createtext(rval[i]) -- right vals
        fr.page[i].rval:setsize(kui:px(162), kui:px(210))
        fr.page[i].rval:setfp(fp.tr, fp.tr, fr.page[i].enhr, kui:px(10), 0.0)
        BlzFrameSetTextAlignment(fr.page[i].rval.fh, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_RIGHT)
    end
    local leftarrclick = function()
        if utils.islocaltrigp() then
            fr.leftarr:hide()
            fr.rightarr:show()
            fr.page[1]:show()
            fr.page[2]:hide()
        end
    end
    local rightarrclick = function()
        if utils.islocaltrigp() then
            fr.rightarr:hide()
            fr.leftarr:show()
            fr.page[1]:hide()
            fr.page[2]:show()
        end
    end
    fr.leftarr.btn:addevents(nil, nil, leftarrclick, nil, nil)
    fr.rightarr.btn:addevents(nil, nil, rightarrclick, nil, nil)
    fr.page[2]:hide()
    -- kobold level indicator:
    fr.lvl  = fr:createheadertext(color:wrap(color.tooltip.alert,"1")) -- left block
    fr.lvl:setsize(kui:px(70), kui:px(34))
    fr.lvl:setfp(fp.c, fp.c, fr, kui:px(59), -kui:px(259))
    fr.lvl:assigntooltip("level")
    -- points available label:
    fr.pointsbd = kui.frame:newbytype("BACKDROP", fr)
    fr.pointsbd:addbgtex("war3mapImported\\ui-scroll_decoration.blp")
    fr.pointsbd:setsize(kui:px(240), kui:px(60))
    fr.pointsbd:setfp(fp.c, fp.t, fr, 0.0, -kui:px(92))
    fr.points = fr.pointsbd:createtext("Points Available: "..color:wrap(color.txt.txtdisable,"0"), nil, true) -- left block
    fr.points:setsize(kui:px(160), kui:px(26))
    fr.points:setfp(fp.c, fp.c, fr.pointsbd, 0.0, kui:px(3))
    fr.pointsbd:hide() -- only show when points > 0
    -- auto-assign btn:
    fr.autoattr = kui.frame:newbtntemplate(fr, 'war3mapImported\\btn-add_attr_auto.blp')
    fr.autoattr:setsize(kui:px(43), kui:px(25))
    fr.autoattr:setfp(fp.c, fp.t, fr, kui:px(0), kui:px(-110))
    fr.autoattr.btn:assigntooltip("attrauto")
    fr.autoattr.btn:addevents(nil, nil, function() kobold.player[utils.trigp()]:autoapplyattr() end)
    fr.autoattr:hide()
    ltext = nil rtext = nil lval = nil rval = nil
    return fr
end


function kui:createequipment(parentfr)
    -- this frame has manually placed invisible buttons
    -- to help save on total frame count.
    local fr = self:createmainframeparent(self.color.black, parentfr, 2)
    fr.space = {}
    for slotid = 1001,1010 do -- we do a global "item space" table, with equip at the very end.
        fr.space[slotid] = self.frame:newbytype("BUTTON", fr)
        fr.space[slotid]:setsize(kui:px(kui.meta.equipslotw), kui:px(kui.meta.equipslotw))
        fr.space[slotid]:setlvl(2)
        fr.space[slotid]:initializeitemslot(slotid)
        fr.space[slotid].icon = self.frame:newbytype("BACKDROP", fr)
        fr.space[slotid].icon:setsize(kui:px(52), kui:px(52))
        fr.space[slotid].icon:setfp(fp.c, fp.c, fr.space[slotid])
        fr.space[slotid].icon:addbgtex(kui.tex.invis)
        fr.space[slotid].rareind = kui.frame:newbytype("BACKDROP", fr.space[slotid])
        fr.space[slotid].rareind:setallfp(fr.space[slotid].icon)
        fr.space[slotid].rareind:addbgtex(kui.tex.invis)
    end
    -- unequip item selection pane:
    fr:newitempane(fr)
    -- equipment slots:
    fr.space[1001]:setfp(fp.c, fp.tl, fr,  kui:px(96),  -kui:px(215))
    fr.space[1002]:setfp(fp.c, fp.tl, fr,  kui:px(96),  -kui:px(317))
    fr.space[1003]:setfp(fp.c, fp.tl, fr,  kui:px(96),  -kui:px(420))
    fr.space[1004]:setfp(fp.c, fp.tl, fr,  kui:px(190), -kui:px(503))
    fr.space[1005]:setfp(fp.c, fp.tl, fr,  kui:px(293), -kui:px(503))
    fr.space[1006]:setfp(fp.c, fp.tl, fr,  kui:px(380), -kui:px(420))
    fr.space[1007]:setfp(fp.c, fp.tl, fr,  kui:px(380), -kui:px(317))
    fr.space[1008]:setfp(fp.c, fp.tl, fr,  kui:px(380), -kui:px(215))
    fr.space[1009]:setfp(fp.c, fp.tl, fr,  kui:px(292), -kui:px(130))
    fr.space[1010]:setfp(fp.c, fp.tl, fr,  kui:px(189), -kui:px(130))
    fr.hidefunc = function() fr.pane:hide() end
    -- save btn:
    fr.save = kui.frame:newbtntemplate(fr, 'war3mapImported\\btn-save_char.blp')
    fr.save:setfp(fp.c, fp.b, fr, kui:px(-180), kui:px(65))
    fr.save:setsize(kui:px(38), kui:px(37))
    fr.save.btn:assigntooltip("savechar")
    fr.save.btn:addevents(nil, nil, function()
        utils.debugfunc(function()
            local p = utils.trigp()
            if not kobold.player[p].pausesave then
                kobold.player[p].pausesave = true
                kobold.player[p].char:save_character()
                utils.playsound(kui.sound.splashclk, p)
                fr.save:setnewalpha(175)
                utils.timed(1.5, function() fr.save:setnewalpha(255) kobold.player[p].pausesave = nil end)
            else
                utils.palert(p, "Recently saved, try again in a moment", 3.0)
            end
        end, "save btn")
    end)
    -- unequip all btn:
    fr.unequipall = kui.frame:newbtntemplate(fr, 'war3mapImported\\btn-unequip_all.blp')
    fr.unequipall:setfp(fp.c, fp.b, fr, kui:px(172), kui:px(65))
    fr.unequipall:setsize(kui:px(38), kui:px(37))
    fr.unequipall.btn:assigntooltip("unequipall")
    fr.unequipall.btn:addevents(nil, nil, function()
        utils.debugfunc(function()
            loot:unequipall(utils.trigp())
        end, "sortall")
    end)
    fr.pane:hide()
    return fr
end


function kui:createcurrencypanel(parentfr)
    local fr = kui.frame:newbytype("BACKDROP", parentfr)
    fr:addbgtex("war3mapImported\\panel-currency-widget.blp")
    fr:setsize(kui:px(353), kui:px(89))
    fr.txt = {}
    for id = 1,6 do
        fr.txt[id] = fr:createtext(color:wrap(color.txt.txtdisable, "0"))
        BlzFrameSetTextAlignment(fr.txt[id].fh, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_CENTER)
        fr.txt[id]:setsize(kui:px(40), kui:px(40))
        fr.txt[id]:assigntooltip(kui.meta.oretooltip[id])
        fr.txt[id].icon = kui.frame:newbytype("BACKDROP", fr.txt[id])
        fr.txt[id].icon:setbgtex(kui.meta.oreicon[id])
        fr.txt[id].icon:setsize(kui:px(24), kui:px(24))
        if id == 1 then
            fr.txt[id]:setfp(fp.c, fp.tl, fr, kui:px(52), -kui:px(45))
        else
            fr.txt[id]:setfp(fp.c, fp.c, fr.txt[id-1], kui:px(50), 0.0)
        end
        fr.txt[id].icon:setfp(fp.c, fp.c, fr.txt[id], 0.0, -kui:px(12))
    end
    fr:setlvl(0)
    return fr
end


function kui:createinventory(parentfr)
    parentfr.curr   = kui:createcurrencypanel(parentfr)
    local fr        = kui:createmainframeparent(kui.tex.panelinv, parentfr, 3)
    local rowcount  = 1
    local slottotal = kui.meta.invmaxx*kui.meta.invmaxy
    local paddingt  = kui:px(kui.meta.invp)*(kui.meta.invmaxx-1)
    local iconsize  = ( kui:px(kui.meta.mfw) - paddingt - (kui:px(kui.meta.invg)*2) )/kui.meta.invmaxx
    parentfr.curr:setfp(fp.c, fp.b, fr, 0, -kui:px(18)) -- move after mainframe is made.
    -- create inventory spaces:
    fr.space = {}
    for slotid = 1,slottotal do
        -- layering overview:
        -- 1. item slot background .blp
        -- 2. invisible mouse event button
        -- 3. item icon .blp (invisible when empty)
        fr.space[slotid]      = kui.frame:newbytype("BACKDROP", fr)
        fr.space[slotid].btn  = kui.frame:newbytype("BUTTON", fr.space[slotid])
        fr.space[slotid].icon = kui.frame:newbytype("BACKDROP", fr.space[slotid])
        fr.space[slotid].rareind = kui.frame:newbytype("BACKDROP", fr.space[slotid])
        fr.space[slotid].rareind:setallfp(fr.space[slotid].icon)
        fr.space[slotid].rareind:setfp(fp.c, fp.b, fr.space[slotid].icon, 0, kui:px(2))
        fr.space[slotid].rareind:addbgtex(kui.tex.invis)
        fr.space[slotid]:setsize(iconsize,iconsize)
        fr.space[slotid]:addbgtex(kui.tex.invslot)
        fr.space[slotid]:setlvl(1)
        fr.space[slotid].btn:setallfp(fr.space[slotid])
        fr.space[slotid].btn:focusfix()
        fr.space[slotid].btn:setlvl(2)
        fr.space[slotid].btn:addhoverhl(fr.space[slotid])
        fr.space[slotid].btn:initializeitemslot(slotid)
        fr.space[slotid].icon:setsize(iconsize*0.73,iconsize*0.73)
        fr.space[slotid].icon:setfp(fp.c, fp.c, fr.space[slotid])
        fr.space[slotid].icon:addbgtex(kui.tex.invis)
        -- -- --
        if slotid == 1 then
            fr.space[slotid]:setfp(fp.tl, fp.tl, fr.fh, kui:px(kui.meta.invg), -kui:px(kui.meta.invg + kui.meta.invoffy))
        elseif math.fmod(slotid,kui.meta.invmaxx*rowcount+1) == 0 then
            rowcount = rowcount+1
            fr.space[slotid]:setfp(fp.tl, fp.bl, fr.space[slotid-kui.meta.invmaxx], 0.0, -kui:px(kui.meta.invp))
        else
            fr.space[slotid]:setfp(fp.tl, fp.tr, fr.space[slotid-1], kui:px(kui.meta.invp), 0.0)
        end
    end
    -- create gold icon and txt:
    fr.gold = kui.frame:newbtntemplate(fr, "war3mapImported\\tooltip-gold_icon.blp")
    fr.gold:setsize(0.00888, 0.00888)
    fr.gold:setfp(fp.c, fp.br, fr, kui:px(-70), kui:px(52))
    fr.gold.btn:assigntooltip("gold")
    fr.goldtxt = fr.gold:createtext("0")
    fr.goldtxt:setfp(fp.r, fp.l, fr.gold, -0.004, -0.0006)
    fr.goldtxt:setsize(kui:px(60), kui:px(20))
    fr.goldtxt:assigntooltip("gold")
    BlzFrameSetTextAlignment(fr.goldtxt.fh, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_RIGHT)
    -- ancient fragments:
    fr.frag = kui.frame:newbtntemplate(fr, "war3mapImported\\icon-ancient_fragment.blp")
    fr.frag:setsize(kui:px(17), kui:px(17))
    fr.frag:setfp(fp.c, fp.bl, fr, kui:px(70), kui:px(52))
    fr.frag.btn:assigntooltip("fragments")
    fr.fragtxt = fr.frag:createtext("0")
    fr.fragtxt:setfp(fp.l, fp.r, fr.frag, 0.004, -0.0006)
    fr.fragtxt:setsize(kui:px(60), kui:px(20))
    fr.fragtxt:assigntooltip("fragments")
    BlzFrameSetTextAlignment(fr.fragtxt.fh, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
    -- mission rewards cache button:
    fr.tcache = kui.frame:newbtntemplate(fr, "war3mapImported\\btn-loot_overflow.blp")
    fr.tcache:setsize(kui:px(46), kui:px(46))
    fr.tcache:setfp(fp.c, fp.b, fr, 0.0, kui:px(35))
    fr.tcache:hide() -- shown when tcache is filled by mission reward manager.
    fr.tcache.btn:assigntooltip("tcache")
    fr.tcache.btn:addhoverscale(fr.tcache, 1.10)
    local cacheclick = function() kobold.player[utils.trigp()]:fetchcachedloot() end
    fr.tcache.btn:addevents(nil, nil, cacheclick, nil, false)
    -- create inventory select pane:
    fr.pane = kui.frame:newbytype("BACKDROP", fr)
    fr.pane:addbgtex('war3mapImported\\inventory-selected_box.blp')
    fr.pane:setsize(iconsize*0.73, iconsize*0.73)
    fr.pane:setlvl(3)
    for btnid = 1,2 do
        fr.pane[btnid] = kui.frame:newbytype("BACKDROP", fr.pane)
        fr.pane[btnid]:addbgtex(kui.tex.invis)
        fr.pane[btnid]:setnewalpha(170)
        fr.pane[btnid]:setsize(kui:px(32),kui:px(32))
        fr.pane[btnid].icon = kui.frame:newbytype("BACKDROP", fr.pane)
        fr.pane[btnid].icon:setallfp(fr.pane[btnid])
        fr.pane[btnid].icon:addbgtex(kui.meta.inv[btnid].tex)
        fr.pane[btnid].btn = kui.frame:newbytype("BUTTON", fr.pane)
        fr.pane[btnid].btn:setallfp(fr.pane[btnid])
        fr.pane[btnid].btn:assigntooltip(kui.meta.inv[btnid].tipstr)
    end
    local equipfunc = function()
        utils.debugfunc( function() loot.item:equip(utils.trigp()) end, "equipfunc" ) -- selslotid is controlled by inventory pane selection.
    end
    local sellfunc = function()
        utils.debugfunc( function() loot.item:sell(utils.trigp()) end, "sellfunc" )
    end
    fr.pane[1]:setfp(fp.bl, fp.tr, fr.pane, 0.0, 0.0)
    fr.pane[2]:setfp(fp.tl, fp.br, fr.pane, 0.0, 0.0) -- sell btn
    fr.pane[1].btn:addevents(nil, nil, equipfunc) -- equip btn
    fr.pane[2].btn:addevents(nil, nil, sellfunc) -- sell btn
    -- sort and sell all btns:
    fr.sortall = kui.frame:newbtntemplate(fr, 'war3mapImported\\btn-sort_all.blp')
    fr.sortall:setfp(fp.c, fp.b, fr, kui:px(198), kui:px(-24))
    fr.sortall:setsize(kui:px(38), kui:px(37))
    fr.sortall.btn:assigntooltip("invsortall")
    fr.sortall.btn:addevents(nil, nil, function()
        utils.debugfunc(function()
            loot:inventorysortall(utils.trigp())
        end, "sortall")
    end)
    fr.sellall = kui.frame:newbtntemplate(fr, 'war3mapImported\\btn-sell_all.blp')
    fr.sellall:setfp(fp.c, fp.b, fr, kui:px(-198), kui:px(-24))
    fr.sellall:setsize(kui:px(38), kui:px(37))
    fr.sellall.btn:assigntooltip("invsellall")
    fr.sellall.btn:addevents(nil, nil, function()
        utils.debugfunc(function()
            loot:inventorysellall(utils.trigp())
        end, "sellall")
    end)
    -- wrap up:
    fr.showfunc = function() fr.pane:hide() parentfr.curr:show() end
    fr.hidefunc = function() fr.pane:hide() parentfr.curr:hide() end
    fr.pane:hide()
    return fr
end


function kui:createdigsitepage(parentfr)
    local fr     = kui.frame:newbytype("BACKDROP", parentfr) -- main parent
    local cardct = 5 -- total biome ids
    fr.panelid   = 4
    fr.statesnd  = true
    fr:addbgtex(kui.tex.paneldig)
    fr:setsize(kui:px(kui.meta.digsx), kui:px(kui.meta.digsy))
    fr:setabsfp(fp.c, kui.position.centerx, 0.31)
    -- vault biome map piece:
    fr.mappiece = kui.frame:newbytype("BACKDROP", fr)
    fr.mappiece:setbgtex('war3mapImported\\panel-dig_site_last_boss_map_piece.blp')
    fr.mappiece:setfp(fp.c, fp.tl, fr, kui:px(97), -kui:px(180))
    fr.mappiece:setsize(kui:px(260), kui:px(260))
    fr.mappiece:hide()
    -- active boss biome backdrop:
    fr.boss           = kui.frame:newbytype("BACKDROP", fr)
    fr.boss:setsize(kui:px(216), kui:px(225))
    fr.boss:addbgtex('war3mapImported\\panel-dig_site_boss_fight_marker.blp')
    fr.boss:setfp(fp.c, fp.c, fr)
    fr.boss:hide()
    -- dig start btn:
    fr.dig           = kui.frame:newbytype("BACKDROP", fr)
    fr.dig:setsize(kui:px(kui.meta.digcard.btn.w), kui:px(kui.meta.digcard.btn.h))
    fr.dig:addbgtex(kui.meta.digcard.btn.tex)
    fr.dig:setfp(fp.c, fp.tl, fr, kui:px(kui.meta.digcard.btn.x), -kui:px(kui.meta.digcard.btn.y))
    -- init state textures:
    fr.dig.distex    = kui.meta.digcard.btn.tex
    fr.dig.activetex = kui.meta.digcard.btn.texact
    fr.dig.hovertex  = kui.meta.digcard.btn.texhvr
    -- init invis wrapper btn:
    fr.dig.btn       = kui.frame:newbytype("BUTTON", fr)
    fr.dig.btn:setallfp(fr.dig)
    fr.dig.btn:assigntooltip("digstart")
    fr.dig.btn:addtexhl(fr.dig)
    local clickdigfunc = function()
        -- FIXME: DESYNCS
        -- only run if no map is live:
        if not map.manager.activemap and not fr.dig.btn.disabled then
            map.manager:run() -- generate map
            fr:hide() -- hide map panel
            fr.dig.btn:disable()
        end
    end
    fr.dig.btn.disabled = true -- disable events/tooltip until a dig is picked
    fr.dig.btn:addevents(nil, nil, clickdigfunc)
    -- biome selection cards:
    fr.card = kui.frame:newbytype("PARENT", fr)
    for id = 1,cardct do -- cardid lookup (careful when reordering meta).
        fr.card[id]              = kui.frame:newbytype("PARENT", fr)
        fr.card[id].bd           = kui.frame:newbytype("BACKDROP", fr.card[id])
        fr.card[id].bd.hovertex  = kui.meta.digcard[id].texhvr
        fr.card[id].bd.activetex = kui.meta.digcard[id].texact
        fr.card[id].bd:setsize(kui:px(kui.meta.digcard[id].w), kui:px(kui.meta.digcard[id].h))
        fr.card[id].bd:setfp(fp.c, fp.tl, fr, kui:px(kui.meta.digcard[id].x), -kui:px(kui.meta.digcard[id].y))
        fr.card[id].bd:addbgtex(kui.meta.digcard[id].tex)
        fr.card[id].btn = kui.frame:newbytype("BUTTON", fr.card[id])
        fr.card[id].btn:setallfp(fr.card[id].bd)
        fr.card[id].btn:assigntooltip("digsitecard")
        fr.card[id].btn:addtexhl(fr.card[id].bd)
        fr.card[id].btn.statesnd  = true
        -- initiate card selection function:
        fr.card[id].clickfunc = function()
            if map.manager.selectedid ~= id then
                local p = utils.trigp()
                if utils.localp() == p then
                    if map.manager.selectedid ~= nil then -- if previous card active, reset.
                        fr.card[map.manager.selectedid].bd:inactive()
                        fr.card[map.manager.selectedid].btn:inactive()
                    end
                    fr.selicon:show()
                    fr.selicon:clearallfp()
                    fr.selicon:setfp(fp.c, fp.c, fr.card[id].bd)
                    fr.card[id].bd:active()
                    fr.card[id].btn:active()
                    fr.dig:active()
                    fr.dig.btn:active()
                    utils.playsound(kui.sound.digsel)
                end
                map.manager:select(id) -- keep at end so we reference previous id above.
            end
        end
        fr.card[id].btn:addevents(nil, nil, fr.card[id].clickfunc)
    end
    fr.card[5]:hide() -- hide vault
    -- create dig selected btn that we show/hide later:
    fr.selicon = kui.frame:newbytype("BACKDROP", fr)
    fr.selicon:setsize(kui:px(kui.meta.digcard.btnsel.w), kui:px(kui.meta.digcard.btnsel.h))
    fr.selicon:addbgtex(kui.meta.digcard.btnsel.tex)
    fr.selicon:hide() -- show later
    -- difficulty panel:
    fr.diff    = kui.frame:newbytype("BACKDROP", fr)
    fr.diff:setfp(fp.c, fp.c, fr, kui:px(kui.meta.digdiff.texx), kui:px(kui.meta.digdiff.texy))
    fr.diff:addbgtex(kui.meta.digdiff.tex)
    fr.diff:setsize(kui:px(kui.meta.digdiff.texw), kui:px(kui.meta.digdiff.texh))
    fr.diffsel = kui.frame:newbytype("BACKDROP", fr.diff) -- (keep above click func)
    for id = 1,5 do
        fr.diff[id] = kui.frame:newbtntemplate(fr.diff, kui.meta.digdiff[id].tex)
        fr.diff[id]:setsize(kui:px(kui.meta.digdiff.btnwh), kui:px(kui.meta.digdiff.btnwh))
        fr.diff[id].btn:addhoverhl(fr.diff[id])
        fr.diff[id]:setfp(fp.c, fp.c, fr.diff, 0.0, kui:px(kui.meta.digdiff[id].y))
        fr.diff[id].name  = string.gsub(kui.meta.digdiff[id].name, "Difficulty:|n", "")
        fr.diff[id].click = function()
            local p = utils.trigp()
            if not map.manager.activemap and not map.manager.difftimer and utils.trigp() == Player(0) and map.manager.diffid ~= id then
                if kobold.player[p].level >= map.diff[id].lvlreq then
                    local previd = map.manager.diffid -- flip previous icon back.
                    for pnum = 1,kk.maxplayers do
                        map.manager.diffid = id -- set new difficulty.
                        if Player(pnum-1) == utils.localp() then
                            fr.diff[previd]:setnewalpha(255*kui.frame.alpharatio)
                            fr.diffsel:setfp(fp.c, fp.c, fr.diff[id], 0.0, 0.0)
                            fr.diff[id]:setnewalpha(255)
                            utils.palert(Player(pnum-1),
                                color:wrap(color.tooltip.alert, "Changed the difficulty to: ")..fr.diff[id].name, 3.25, true)
                            utils.playsound(kui.sound.digsel, Player(pnum-1))
                        end
                    end
                    map.manager.difftimer = true
                    TimerStart(NewTimer(), 3.0, false, function() map.manager.difftimer = false end)
                else
                    utils.palert(p, "You do not meet the level requirement for that difficulty.", 3.25 )
                end
            elseif map.manager.activemap then
                utils.palert(p, "You cannot change difficulty during a dig.", 3.25 )
            elseif map.manager.difftimer and map.manager.diffid ~= id then
                utils.palert(p, "You can only change difficulty once every few seconds.", 3.0 )
            end
        end
        fr.diff[id].btn.advtip = {}
        fr.diff[id].btn.advtip[1] = kui.meta.digdiff[id].tex
        fr.diff[id].btn.advtip[2] = kui.meta.digdiff[id].name
        fr.diff[id].btn.advtip[3] = kui.meta.digdiff[id].descript
        fr.diff[id].btn:initializeadvtip()
        fr.diff[id].btn:addevents(nil, nil, fr.diff[id].click, nil, false)
    end
    -- selected diff icon (map manager default):
    fr.diffsel:setlvl(2)
    fr.diffsel:addbgtex(kui.meta.digcard.btnsel.tex)
    fr.diffsel:setsize(kui:px(40), kui:px(45))
    fr.diffsel:setfp(fp.c, fp.c, fr.diff[map.manager.diffid], 0.0, 0.0)
    -- unequip dig key selection pane:
    fr:newitempane(fr)
    -- dig site key slot:
    local slotid = 1011 -- *note: hardcoded because kui runs first (slot_digkey)
    fr.digkeybd = kui.frame:newbytype("BACKDROP", fr)
    fr.digkeybd:addbgtex(kui.tex.digkeybd)
    fr.digkeybd.activetex = kui.tex.digkeybdact
    fr.digkeyglow = kui.frame:newbytype("BACKDROP", fr)
    fr.digkeyglow:setbgtex('war3mapImported\\btn-green_glow_aura.blp')
    fr.digkeyglow:setsize(kui:px(109), kui:px(117))
    fr.digkeyglow:setfp(fp.c, fp.br, fr, kui:px(56), kui:px(179))
    fr.digkeyglow:hide()
    fr.space    = {} -- dig key spaces (for now, only 1)
    fr.space[slotid] = kui.frame:newbytype("BUTTON", fr)
    fr.space[slotid]:setsize(kui:px(kui.meta.equipslotw), kui:px(kui.meta.equipslotw))
    fr.space[slotid]:setfp(fp.c, fp.br, fr, kui:px(56), kui:px(179))
    fr.space[slotid]:setlvl(1)
    fr.space[slotid]:initializeitemslot(slotid)
    fr.space[slotid]:assigntooltip("digkey")
    fr.space[slotid].icon = kui.frame:newbytype("BACKDROP", fr)
    fr.space[slotid].icon:setsize(kui:px(64), kui:px(64))
    fr.space[slotid].icon:setfp(fp.c, fp.c, fr.space[slotid])
    fr.space[slotid].icon:addbgtex(kui.tex.invis)
    fr.digkeybd:setallfp(fr.space[slotid].icon)
    fr.hidefunc = function()
        if not map.manager.activemap then map.manager.selectedid = nil end
        fr.selicon:hide()
        fr.dig:disable()
        fr.dig.btn:disable()
        fr.pane:hide()
        -- reset any active selected card textures:
        for i = 1,cardct do fr.card[i].bd:inactive() fr.card[i].btn:inactive() end
    end
    -- quest marker above everything else:
    fr.questmark = kui.frame:newbytype("BACKDROP", fr)
    fr.questmark:setbgtex('war3mapImported\\panel-dig_site_quest_marker.blp')
    fr.questmark:setsize(kui:px(41), kui:px(48))
    fr.questmark:hide()
    -- wrap up:
    fr:createmainframeclosebtn()
    fr.closebtn:setfp(fp.c, fp.tr, fr, -kui:px(294),-kui:px(26))
    fr:hide()
    return fr
end


function kui:createsplashscreen(parentfr)
    -- master container:
    local fr            = kui.frame:newbytype("BACKDROP", parentfr)
    -- create nav parent frames:
    fr.splash           = kui.frame:newbysimple("SimpleFrameSplash", fr)
    -- main frames control groupings of btns:
    fr.options          = kui.frame:newbytype("BACKDROP", fr)
    fr.newmf            = kui.frame:newbytype("BACKDROP", fr)
    fr.loadmf           = kui.frame:newbytype("BACKDROP", fr)
    fr.freemf           = kui.frame:newbytype("BACKDROP", fr)
    -- create splash screen scroll buttons:
    fr.options.loadbtn  = self:createsplashbtn(kui.tex.opload, fr.options, nil)  -- load character scroll.
    fr.options.freeplay = self:createsplashbtn('war3mapImported\\menu-scroll-option_freeplay.blp', fr.options, nil)  -- load char scroll.
    fr.options.newbtn   = self:createsplashbtn(kui.tex.opnew,  fr.options, nil)  -- new character scroll.
    fr.newmf.char01     = self:createsplashbtn(kui.tex.char[1].selectchar, fr.newmf, nil, kui.meta.tipcharselect[1]) -- tunneler.
    fr.newmf.char02     = self:createsplashbtn(kui.tex.char[2].selectchar, fr.newmf, nil, kui.meta.tipcharselect[2]) -- geomancer.
    fr.newmf.char03     = self:createsplashbtn(kui.tex.char[3].selectchar, fr.newmf, nil, kui.meta.tipcharselect[3]) -- rascal.
    fr.newmf.char04     = self:createsplashbtn(kui.tex.char[4].selectchar, fr.newmf, nil, kui.meta.tipcharselect[4]) -- wickfighter.
    -- simple frames can only have children targeted via framename:
    local sfh = BlzGetFrameByName("SimpleFrameSplash",0)
    BlzFrameSetLevel(sfh, 0)
    utils.looplocalp(function() kui:setfullscreen(sfh) end)
    fr:setfp(fp.c, fp.c, self.gameui)
    fr.options.newbtn:setabsfp(fp.c, kui.position.centerx + kui:px(217), kui:px(195))
    fr.options.newbtn.btn:assigntooltip("storymode")
    fr.options.newbtn.btn:addswapevent(fr.newmf, fr.options) -- close all other options when this main frame is open.
    -- load btn:
    fr.options.loadbtn:setabsfp(fp.c, kui.position.centerx + kui:px(217 + 222), kui:px(195))
    fr.options.loadbtn.btn:assigntooltip("loadchar")
    -- character loading:
    load_character_func = function(fileslot)
        utils.debugfunc(function()
            local p = utils.trigp()
            if not kobold.player[p].isloading and not fr.loadmf.char[fileslot].btn.disabled then
                -- disable all loading buttons from further clicks:
                for i = 1,4 do
                    fr.loadmf.char[i].btn.disabled = true
                    fr.loadmf.char[i].btn.disablehoverscale = true
                end
                -- load character:
                kobold.player[p].char.fileslot = fileslot
                kobold.player[p].char:read_file(fileslot)
                if kobold.player[p].char:get_file_data() then
                    kui:hidesplash(p, true)
                else
                    print("error: file is corrupt or missing.")
                    return
                end
                kobold.player[p].char:load_character()
            end
        end, "load char")
    end
    -- load character btns:
    fr.loadmf.char = kui.frame:newbytype("PARENT", fr.loadmf)
    for i = 1,4 do
        fr.loadmf.char[i]     = self:createsplashbtn(kui.tex.invis, fr.loadmf)
        fr.loadmf.char[i].txt = fr.loadmf.char[i]:createtext("Missing File")
        fr.loadmf.char[i].txt:setfp(fp.b, fp.b, fr.loadmf.char[i], 0.0, kui:px(20))
        BlzFrameSetTextAlignment(fr.loadmf.char[i].txt.fh, TEXT_JUSTIFY_BOTTOM, TEXT_JUSTIFY_CENTER)
        fr.loadmf.char[i].txt:setsize(kui:px(90), kui:px(40))
        fr.loadmf.char[i].btn:addevents(nil, nil, function() load_character_func(i) end)
        -- load eyecandy tag:
        fr.loadmf.char[i].loadbd = kui.frame:newbytype("BACKDROP", fr.loadmf.char[i])
        fr.loadmf.char[i].loadbd:setbgtex("war3mapImported\\btn_save_icon.blp")
        fr.loadmf.char[i].loadbd:setsize(kui:px(40), kui:px(40))
        fr.loadmf.char[i].loadbd:setfp(fp.c, fp.br, fr.loadmf.char[i], kui:px(-45), kui:px(40))
        -- delete file button:
        fr.loadmf.char[i].delete = kui.frame:newbtntemplate(fr.loadmf.char[i], "war3mapImported\\btn_delete_icon.blp")
        fr.loadmf.char[i].delete:setsize(kui:px(28), kui:px(28))
        fr.loadmf.char[i].delete:setfp(fp.c, fp.tr, fr.loadmf.char[i], kui:px(-24), kui:px(-24))
        fr.loadmf.char[i].delete.btn:assigntooltip("deletesave")
        fr.loadmf.char[i].delete.btn:addevents(nil, nil, function()
            utils.debugfunc(function()
                local p = utils.trigp()
                if kobold.player[p].clickdelete then
                    kui:showmodal(function()
                        utils.playsound(kui.sound.portalmerge, p)
                        kobold.player[p].char:delete_file(i)
                        if kobold.player[p]:islocal() then
                            fr.loadmf.char[i]:hide()
                        end
                    end)
                    utils.timed(0.33, function() kobold.player[p].clickdelete = nil end)
                else
                    kobold.player[p].clickdelete = true
                end
            end, "click delete")
        end)
        fr.loadmf.char[i]:hide()
    end
    fr.loadmf.char[1]:setabsfp(fp.c, kui.position.centerx + kui:px(217), kui:px(195 + 285))
    fr.loadmf.char[2]:setabsfp(fp.c, kui.position.centerx + kui:px(217 + 222), kui:px(195 + 285))
    fr.loadmf.char[3]:setabsfp(fp.c, kui.position.centerx + kui:px(217), kui:px(195))
    fr.loadmf.char[4]:setabsfp(fp.c, kui.position.centerx + kui:px(217 + 222), kui:px(195))
    -- create 4 new cards that pull in file contents (char name, level)
    fr.options.loadbtn.btn:addswapevent(fr.loadmf, fr.options) -- close all other options when this main frame is open.
    fr.options.loadbtn.btn.disabled = true -- enabled by file verification.
    -- freeplay btn:
    fr.options.freeplay:setabsfp(fp.c, kui.position.centerx - kui:px(217), kui:px(195))
    fr.options.freeplay.btn:addswapevent(fr.newmf, fr.options)
    fr.options.freeplay.btn:addevents(nil, nil, function() freeplay_mode = true end)
    fr.options.freeplay.btn:assigntooltip("freeplaymode")
    -- back buttons:
    fr.newmf.backbtn  = kui.frame:createbackbtn(fr.options, fr.newmf)
    fr.newmf.backbtn:setabsfp(fp.c, kui.position.centerx, kui:px(90))
    fr.loadmf.backbtn = kui.frame:createbackbtn(fr.options, fr.loadmf)
    fr.loadmf.backbtn:setabsfp(fp.c, kui.position.centerx, kui:px(90))
    fr.freemf.backbtn = kui.frame:createbackbtn(fr.options, fr.newmf)
    fr.freemf.backbtn:setabsfp(fp.c, kui.position.centerx, kui:px(90))
    fr.freemf.backbtn.btn:addevents(nil, nil, function() freeplay_mode = false end)
    -- reposition char scrolls:
    fr.newmf.char01:setabsfp(fp.c, kui.position.centerx + kui:px(217), kui:px(195 + 285))
    fr.newmf.char02:setabsfp(fp.c, kui.position.centerx + kui:px(217 + 222), kui:px(195 + 285))
    fr.newmf.char03:setabsfp(fp.c, kui.position.centerx + kui:px(217), kui:px(195))
    fr.newmf.char04:setabsfp(fp.c, kui.position.centerx + kui:px(217 + 222), kui:px(195))
    -- *note: when interacting with splash scroll btns, remember to use .btn to target the hidden btn frame.
    fr.newmf.char01.btn:addselectclassevent(kui.meta.char01raw, 1, self.sound.char01new)
    fr.newmf.char02.btn:addselectclassevent(kui.meta.char02raw, 2, self.sound.char02new)
    fr.newmf.char03.btn:addselectclassevent(kui.meta.char03raw, 3, self.sound.char03new)
    fr.newmf.char04.btn:addselectclassevent(kui.meta.char04raw, 4, self.sound.char04new)
    fr.options.loadbtn:setalpha(145)
    fr.newmf:hide()
    fr.loadmf:hide()
    return fr
end


function kui:createbosschest(parentfr)
    local fr       = kui.frame:newbytype("PARENT", parentfr)
    fr.chest       = kui.frame:newbtntemplate(fr, 'war3mapImported\\boss-reward-chest.blp')
    fr.chest.gem   = {}
    fr.chest.btn:assigntooltip("bosschest")
    fr.chest.btn:addhoverscale(fr.chest, 1.10)
    fr.chest:setabsfp(fp.c, kui.position.centerx, kui:px(345))
    fr.chest:setlvl(0)
    fr.chest:setsize(kui:px(180), kui:px(128))
    for i = 1,5 do
        fr.chest.gem[i]  = kui.frame:newbytype("BACKDROP", fr.chest)
        fr.chest.gem[i]:setsize(kui:px(56), kui:px(56))
        fr.chest.gem[i]:setfp(fp.c, fp.c, fr.chest, kui:px(1), kui:px(-18))
        fr.chest.gem[i]:hide()
    end
    fr.chest.gem[1]:setbgtex("war3mapImported\\icon_bosskey_chomp.blp")
    fr.chest.gem[2]:setbgtex("war3mapImported\\icon_bosskey_slag.blp")
    fr.chest.gem[3]:setbgtex("war3mapImported\\icon_bosskey_mutant.blp")
    fr.chest.gem[4]:setbgtex("war3mapImported\\icon_bosskey_thawed.blp")
    fr.chest.gem[5]:setbgtex("war3mapImported\\icon_bosskey_amalgam.blp")
    local hoverfunc = function()
        if utils.islocaltrigp() then
            if not kui.previousframesoundfh or (kui.previousframesoundfh and kui.previousframesoundfh ~= fr.chest.btn.fh) then -- 1.33 fix
                -- utils.playsound(kui.sound.hoverchest, utils.trigp())
            end
        end
    end
    local clickfunc = function()
        utils.debugfunc(function()
            local p = utils.trigp()
            local x,y = utils.unitxy(kobold.player[p].unit)
            local diffid = map.manager.prevdiffid
            local count = math.max(2, map.manager.prevdiffid-1) -- +1 item roll on heroic and above, up to 4.
            local oddsmod, rarityid = 0, 0
            for i = 1,count do
                oddsmod = kobold.player[p]:getlootodds() + 100*diffid
                if diffid == 5 then
                    oddsmod = oddsmod + 2500
                    count = count*2
                end
                if diffid >= 4 then
                    rarityid = loot:getrandomrarity(rarity_epic, rarity_ancient, oddsmod)
                elseif diffid >= 3 then
                    rarityid = loot:getrandomrarity(rarity_rare, rarity_ancient, oddsmod)
                elseif diffid >= 2 then
                    rarityid = loot:getrandomrarity(rarity_rare, rarity_epic, oddsmod)
                else
                    rarityid = loot:getrandomrarity(rarity_common, rarity_rare, oddsmod)
                end
                loot:generatelootmissile(x, y, loot.missile[rarityid], 2)
            end
            -- always drop 1 ancient item:
            loot:generatelootmissile(x, y, loot.missile[4], 1)
            -- always drop bonus loot for vault boss:
            if map.manager.prevbiomeid == 5 then
                loot:generatelootmissile(x, y, loot.missile[4], 1) -- bonus ancient.
                loot:generatelootmissile(x, y, loot.missile[loot:getrandomrarity(rarity_common, rarity_ancient, 1500)], 2)
            end
            if utils.islocaltrigp() then
                utils.playsound(kui.sound.openchest, p)
                fr:hide()
            end
        end, 'boss chest')
    end
    fr.chest.btn:addevents(hoverfunc, nil, clickfunc)
    fr:hide()
    return fr
end


function kui:createskillbar(parentfr)
    local fr       = kui.frame:newbytype("PARENT", parentfr)
    local ypad     = kui:px(148) -- push up from bottom this much
    local xpos     = kui.position.centerx - kui:px(334)
    local w,h      = 72, 63 -- ability container w/h
    fr.skillbg     = kui.frame:newbysimple("KoboldSkillBarBackdrop", fr)
    fr.skillbg:setabsfp(fp.b, kui.position.centerx + 0.05722, 0.0)
    fr.skillbg:setlvl(0)
    fr.skillbg:hide()
    fr.skill       = {}
    for i = 1,8 do
        fr.skill[i]        = kui.frame:newbytype("FRAME", fr)
        fr.skill[i]:setsize(kui:px(w), kui:px(h))
        fr.skill[i]:setabsfp(fp.c, xpos, ypad)
        -- ability icon:
        fr.skill[i].fill   = kui.frame:newbytype("BACKDROP", fr.skill[i])
        fr.skill[i].fill:setsize(kui:px(52),kui:px(52))
        fr.skill[i].fill:setfp(fp.c, fp.c, fr.skill[i], 0, 0)
        fr.skill[i].fill:addbgtex(kui.color.black)
        -- cooldown overlay:
        fr.skill[i].cdfill = kui.frame:newbytype("BACKDROP", fr.skill[i])
        fr.skill[i].cdfill:addbgtex('war3mapImported\\potion-cdfill.blp')
        fr.skill[i].cdfill:setsize(kui:px(w*0.845),kui:px(h*0.845))
        fr.skill[i].cdfill:setfp(fp.c, fp.c, fr.skill[i].fill, 0, 0)
        fr.skill[i].cdfill:setnewalpha(200)
        fr.skill[i].cdfill:hide()
        fr.skill[i].hotkey = fr.skill[i]:createbtntext(kui.meta.skillhotkey[i], nil, true)
        fr.skill[i].hotkey:setfp(fp.c, fp.b, fr.skill[i], 0.0, kui:px(12))
        fr.skill[i].cdtxt  = fr.skill[i]:createbtntext("", nil, true)
        fr.skill[i].cdtxt:setallfp(fr.skill[i].fill)
        fr.skill[i].cdtxt.advtip = {}
        fr.skill[i].cdtxt.advtipanchor    = fp.b
        fr.skill[i].cdtxt.advattachanchor = fp.t
        fr.skill[i].cdtxt:initializeadvtip()
        -- ability card graphic:
        fr.skill[i].card   = kui.frame:newbytype("BACKDROP", fr.skill[i])
        fr.skill[i].card:setsize(kui:px(w), kui:px(h))
        fr.skill[i].card:setfp(fp.c, fp.c, fr.skill[i])
        fr.skill[i].card:addbgtex(kui.tex.skillbd)
        xpos = xpos + kui:px(w)
        if i == 4 then xpos = xpos + kui:px(158) end
    end
    -- item: healing slot:
    fr.skill[9]       = kui.frame:newbtntemplate(fr, 'war3mapImported\\potion-health.blp')
    fr.skill[9].txt   = fr.skill[9]:createbtntext("F", nil, true)
    fr.skill[9].txt:setfp(fp.b, fp.b, fr.skill[9], 0, 0)
    fr.skill[9]:setabsfp(fp.c, kui.position.centerx - kui:px(398), kui:px(54))
    fr.skill[9]:setsize(kui:px(63), kui:px(75))
    fr.skill[9].cdfill = kui.frame:newbytype("BACKDROP", fr.skill[9])
    fr.skill[9].cdfill:addbgtex('war3mapImported\\potion-cdfill.blp')
    fr.skill[9].cdfill:setsize(kui:px(63),kui:px(75))
    fr.skill[9].cdfill:setfp(fp.c, fp.c, fr.skill[9])
    fr.skill[9].cdfill:setnewalpha(200)
    fr.skill[9].cdfill:hide()
    fr.skill[9].cdtxt = fr.skill[9]:createbtntext("", nil, true)
    fr.skill[9].cdtxt:setallfp(fr.skill[9])
    fr.skill[9].cdtxt:assigntooltip("healthpot")
    -- fr.skill[9].btn:mapbtntohotkey("F")
    -- item: mana slot:
    fr.skill[10]       = kui.frame:newbtntemplate(fr, 'war3mapImported\\potion-mana.blp')
    fr.skill[10].txt   = fr.skill[10]:createbtntext("G", nil, true)
    fr.skill[10].txt:setfp(fp.b, fp.b, fr.skill[10], 0, 0)
    fr.skill[10]:setabsfp(fp.c, kui.position.centerx + kui:px(398), kui:px(54))
    fr.skill[10]:setsize(kui:px(63), kui:px(75))
    fr.skill[10].cdfill = kui.frame:newbytype("BACKDROP", fr.skill[10])
    fr.skill[10].cdfill:addbgtex('war3mapImported\\potion-cdfill.blp')
    fr.skill[10].cdfill:setsize(kui:px(63),kui:px(75))
    fr.skill[10].cdfill:setfp(fp.c, fp.c, fr.skill[10])
    fr.skill[10].cdfill:setnewalpha(200)
    fr.skill[10].cdfill:hide()
    fr.skill[10].cdtxt = fr.skill[10]:createbtntext("", nil, true)
    fr.skill[10].cdtxt:setallfp(fr.skill[10])
    fr.skill[10].cdtxt:assigntooltip("manapot")
    -- fr.skill[10].btn:mapbtntohotkey("G")
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- start interface buttons / menu buttons:
    local btnct  = #kui.meta.panelbtn -- how many total btns? lets us calc placement.
    local custct = #kui.meta.panelbtn-4 -- how many custom (non-upper menu btn conversions)?
    fr.panelbtn  = {}
    for i = 1,btnct do
        fr.panelbtn[i]  = kui.frame:newbytype("BACKDROP", fr)
        fr.panelbtn[i]:setlvl(5)
        fr.panelbtn[i]:setsize(kui:px(28), kui:px(28))
        if i < 6 then
            fr.panelbtn[i]:setabsfp(fp.c, kui:px(1176) + ((i-1)*kui:px(36)), kui:px(60))
        else
            fr.panelbtn[i]:setabsfp(fp.c, kui:px(1176) + ((i-6)*kui:px(36)), kui:px(26))
        end
        fr.panelbtn[i]:addbgtex(kui.meta.panelbtn[i].tex)
        -- set hover tip to our custom frames only (1-5)
        if i <= custct or i == 9 then
            fr.panelbtn[i].btn = kui.frame:newbytype("BUTTON", fr)
            fr.panelbtn[i].btn:setallfp(fr.panelbtn[i])
            fr.panelbtn[i].btn:assigntooltip(kui.meta.panelbtn[i].tipstr)
        end
    end
    -- add alert indicators (new stuff) to target buttons:
    fr.alerticon = {}
    for i = 1,5 do
        fr.alerticon[i] = kui.frame:newbytype("BACKDROP", fr)
        fr.alerticon[i]:setsize(kui:px(18), kui:px(15))
        fr.alerticon[i]:setbgtex('war3mapImported\\menu-button-alert-green-icon.blp')
        fr.alerticon[i]:hide()
    end
    fr.alerticon[1]:setfp(fp.c, fp.br, fr.panelbtn[1].btn, kui:px(-8), kui:px(8)) -- character page
    fr.alerticon[2]:setfp(fp.c, fp.br, fr.panelbtn[3].btn, kui:px(-8), kui:px(8)) -- equipment page
    fr.alerticon[3]:setfp(fp.c, fp.br, fr.panelbtn[4].btn, kui:px(-8), kui:px(8)) -- mastery page
    fr.alerticon[4]:setfp(fp.c, fp.br, fr.panelbtn[5].btn, kui:px(-8), kui:px(8)) -- spell page
    fr.alerticon[5]:setfp(fp.c, fp.br, fr.panelbtn[9].btn, kui:px(-8), kui:px(8)) -- badge page
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- map standard upper menu bar to new btns:
    BlzFrameSetVisible(BlzGetFrameByName("UpperButtonBarFrame",0), true)
    fr.mt = {
        -- order matters below.
        [1] = kui.frame:convert("UpperButtonBarQuestsButton", 0),
        [2] = kui.frame:convert("UpperButtonBarMenuButton", 0),
        [3] = kui.frame:convert("UpperButtonBarAlliesButton", 0),
        [4] = kui.frame:convert("UpperButtonBarChatButton", 0),
    }
    for i = 1,4 do
        fr.mt[i]:setparent(fr.fh)
        fr.mt[i]:setallfp(fr.panelbtn[i+custct])
        fr.mt[i]:setalpha(0)
        fr.mt[i]:setlvl(3)
        fr.mt[i].hoverfix = kui.frame:newbytype("LISTBOX", fr.panelbtn[i+custct])
        fr.mt[i].hoverfix:assigntooltip(kui.meta.panelbtn[i+custct].tipstr)
        fr.mt[i].hoverfix:setallfp(fr.panelbtn[i+custct])
        fr.mt[i].hoverfix:setlvl(9)
        -- hackishly hide the wrapped players button, which we converted to the Badges button:
        if i == 3 then
            BlzFrameSetVisible(fr.mt[i].fh, false)
            BlzFrameSetVisible(fr.mt[i].hoverfix.fh, false)
            fr.mt[i]:setabsfp(fp.tl, -0.1, -0.1) fr.mt[i]:setabsfp(fp.tr, -0.1, -0.1) fr.mt[i]:setabsfp(fp.bl, -0.1, -0.1) fr.mt[i]:setabsfp(fp.br, -0.1, -0.1)
            fr.mt[i].hoverfix:setabsfp(fp.tl, -0.1, -0.1) fr.mt[i].hoverfix:setabsfp(fp.tr, -0.1, -0.1)
            fr.mt[i].hoverfix:setabsfp(fp.bl, -0.1, -0.1) fr.mt[i].hoverfix:setabsfp(fp.br, -0.1, -0.1)
        end
    end
    fr.dec = {}
    fr.xpbar = kui.frame:newbysimple("KoboldExperienceBar", fr)
    fr.xpbar:setabsfp(fp.c, kui.position.centerx, kui:px(19))
    fr.xpbar:setlvl(2)
    BlzFrameSetValue(fr.xpbar.fh, 0)
    fr.xpbarwrap = kui.frame:newbytype("TEXT", fr) -- tooltip wrapper
    fr.xpbarwrap:setallfp(fr.xpbar)
    fr.xpbarwrap:assigntooltip("experience")
    fr.xpbar:hide()
    -- gold statue:
    fr.statue = kui.frame:newbytype("BACKDROP", fr)
    fr.statue:addbgtex("war3mapImported\\skillbar-gold_statue.blp")
    fr.statue:setsize(kui:px(123), kui:px(127))
    fr.statue:setabsfp(fp.b, kui.position.centerx, 0.0)
    fr.statue:setlvl(2)
    -- hp bar:
    fr.hpbar = kui.frame:newbysimple("SkillBarHealth", fr)
    fr.hpbar:setsize(kui:px(352), kui:px(32))
    fr.hpbar:setabsfp(fp.r, kui.position.centerx, kui:px(55))
    fr.hpbar:setlvl(2)
    fr.hptxt = fr:createbtntext("0/0", nil, true)
    fr.hptxt:setallfp(fr.hpbar)
    fr.hptxt:assigntooltip("health")
    -- mana bar:
    fr.manabar = kui.frame:newbysimple("SkillBarMana", fr)
    fr.manabar:setsize(kui:px(352), kui:px(32))
    fr.manabar:setabsfp(fp.l, kui.position.centerx, kui:px(55))
    fr.manabar:setlvl(2)
    fr.manatxt = fr:createbtntext("0/0", nil, true)
    fr.manatxt:setallfp(fr.manabar)
    fr.manatxt:assigntooltip("mana")
    -- decorate minimap:
    fr.minimapbd    = kui.frame:newbytype("BACKDROP", fr)
    fr.minimapbd:setallfp(kui.minimap)
    fr.minimapbd:addbgtex(kui.color.black)
    fr.minimapbd:setalpha(225)
    fr.minimapbd:setlvl(0) -- make it below the minimap.
    fr.minimapcover = kui.frame:newbytype("BACKDROP", fr)
    fr.minimapcover:setfp(fp.tl, fp.tl, kui.minimap, -kui:px(7), kui:px(7))
    fr.minimapcover:setsize(kui:px(274), kui:px(261))
    fr.minimapcover:addbgtex(kui.tex.minimap)
    fr.minimapcover:setlvl(2) -- make it above the minimap.
    BlzFrameSetParent(kui.minimap, fr.fh)
    -- do additional things on show/hide:
    fr.hidefunc = function()
        fr.xpbar:hide()
        fr.hpbar:hide()
        fr.manabar:hide()
        fr.skillbg:hide()
    end
    fr.showfunc = function()
        fr.xpbar:show()
        fr.hpbar:show()
        fr.manabar:show()
        fr.skillbg:show()
    end
    return fr
end


function kui:createoverwriteprompt(parentfr)
    local fr = kui.frame:newbytype("BACKDROP", parentfr)
    fr:setbgtex("war3mapImported\\panel-interface_shadow_blob.blp")
    fr:setsize(kui:px(888), kui:px(888))
    fr:setfp(fp.c, fp.c, kui.gameui, 0, 0)
    fr.delete = {}
    overwrite_char_slot_func = function(fileslot)
        local p = utils.trigp()
        kui:showmodal(function()
            kobold.player[p].char:delete_file(fileslot)
            fr.delete[fileslot].txt:settext("<Empty File>")
            utils.timed(0.11, function()
                kobold.player[p].char.fileslot = fileslot
                kobold.player[p].char:save_character()
                fr:hide()
            end)
        end)
    end
    for fileslot = 1,4 do
        fr.delete[fileslot] = kui.frame:newbtntemplate(fr, "war3mapImported\\btn-delete.blp")
        fr.delete[fileslot]:setsize(kui:px(179), kui:px(44))
        fr.delete[fileslot]:setfp(fp.c, fp.c, fr, kui:px(117), kui:px(-87) + kui:px(fileslot*60))
        fr.delete[fileslot].txt = fr.delete[fileslot]:createtext("<Empty File>")
        fr.delete[fileslot].txt:setsize(kui:px(270), kui:px(44))
        fr.delete[fileslot].txt:setfp(fp.r, fp.l, fr.delete[fileslot], kui:px(-15), kui:px(0))
        BlzFrameSetTextAlignment(fr.delete[fileslot].txt.fh, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_RIGHT)
        fr.delete[fileslot].btn:addevents(nil, nil, function() overwrite_char_slot_func(fileslot) end)
    end
    -- close btn:
    fr.backbtn = kui.frame:newbtntemplate(fr, kui.tex.backbtn)
    fr.backbtn.btn:linkcloseevent(fr)
    fr.backbtn:setsize(kui:px(kui.meta.backbtnw), kui:px(kui.meta.backbtnh))
    fr.backbtn:setabsfp(fp.c, kui.position.centerx, kui:px(435))
    fr.backbtn:assigntooltip("cancel")
    fr:hide()
    return fr
end


function kui:createmodal(parentfr)
    local fr = kui.frame:newbytype("BACKDROP", parentfr)
    fr:setbgtex("war3mapImported\\modal_bd.blp")
    fr:setsize(kui:px(461), kui:px(230))
    fr:setfp(fp.c, fp.c, kui.gameui, 0, 0)
    fr.title = fr:createheadertext("Are you sure?")
    fr.title:setfp(fp.c, fp.t, fr, 0, -kui:px(79))
    fr.title:setsize(kui:px(375), kui:px(35))
    fr.yesbtn = kui.frame:newbtntemplate(fr, "war3mapImported\\modal-yes_btn.blp")
    fr.yesbtn:setfp(fp.l, fp.b, fr, kui:px(4), kui:px(86))
    fr.yesbtn:setsize(kui:px(179), kui:px(44))
    fr.yesbtn.btn:addevents(nil, nil, function()
        utils.debugfunc(function()
            if fr.yesbtn.modalfunc then
                fr.yesbtn.modalfunc()
                fr.yesbtn.modalfunc = nil
            end
            utils.playsound(kui.sound.clickstr, utils.trigp())
            if kobold.player[utils.trigp()]:islocal() then fr:hide() end
        end, "modal yes func")
    end)
    fr.nobtn = kui.frame:newbtntemplate(fr, "war3mapImported\\modal-no_btn.blp")
    fr.nobtn:setfp(fp.r, fp.b, fr, kui:px(-4), kui:px(86))
    fr.nobtn:setsize(kui:px(179), kui:px(44))
    fr.nobtn.btn:addevents(nil, nil, function()
        utils.debugfunc(function()
            if fr.nobtn.modalfunc then
                fr.nobtn.modalfunc()
                fr.nobtn.modalfunc = nil
            end
            utils.playsound(kui.sound.clickstr, utils.trigp())
            if kobold.player[utils.trigp()]:islocal() then fr:hide() end
        end, "modal no func")
    end)
    BlzFrameSetLevel(fr.fh, 8)
    fr:hide()
    return fr
end


function kui:showmodal(yesfunc, _nofunc)
    utils.debugfunc(function()
        if kobold.player[utils.trigp()]:islocal() then
            kui.canvas.game.modal:show()
        end
        kui.canvas.game.modal.yesbtn.modalfunc = yesfunc
        kui.canvas.game.modal.nobtn.modalfunc = _nofunc or nil
    end, "modal functions")
end


function kui:createpartypane(parentfr)
    local fr = kui.frame:newbytype("PARENT", parentfr)
    fr.pill  = {}
    return fr
end


function kui:createpartypill(parentfr, pnum, charid)
    local w,h = 100,119
    local fr = kui.frame:newbytype("BACKDROP", parentfr)
    fr:addbgtex(kui.meta.partyframe[charid])
    fr:setsize(kui:px(w), kui:px(h))
    fr.hpbar    = kui.frame:newbysimple("KoboldPartyPillHealthBar", fr)
    fr.hpbar:setsize(kui:px(118), kui:px(23))
    fr.hpbar:setfp(fp.t, fp.b, fr, kui:px(6), kui:px(8))
    fr.hpbar:show()
    fr.manabar  = kui.frame:newbysimple("KoboldPartyPillManaBar", fr)
    fr.manabar:setsize(kui:px(118), kui:px(23))
    fr.manabar:setfp(fp.t, fp.b, fr.hpbar, 0.0, kui:px(7))
    fr.manabar:show()
    fr.downskull= kui.frame:newbytype("BACKDROP", fr)
    fr.downskull:setbgtex("war3mapImported\\party_pane-down_skull.blp")
    fr.downskull:setsize(kui:px(54), kui:px(54))
    fr.downskull:setfp(fp.c, fp.c, fr, kui:px(9), kui:px(1))
    fr.downskull:hide()
    fr.pname    = fr:createbtntext(kobold.player[Player(pnum-1)].name)
    fr.pname:setfp(fp.c, fp.t, fr, 0, -kui:px(8))
    fr:setfp(fp.tl, fp.tl, kui.worldui, 0, -kui:px((pnum-1)*180 + 22))
    return fr
end


function kui:linkskillbarbtns()
    -- this must be done after the actual panels are made.
    kui.canvas.game.skill.panelbtn[1].btn:linkshowhidebtn(kui.canvas.game.char)
    kui.canvas.game.skill.panelbtn[1].btn.alerticon = kui.canvas.game.skill.alerticon[1]
    kui.canvas.game.char.alerticon = kui.canvas.game.skill.alerticon[1] -- for hotkey functions.
    kui.canvas.game.char.alerticon:setlvl(7)

    kui.canvas.game.skill.panelbtn[2].btn:linkshowhidebtn(kui.canvas.game.equip)

    kui.canvas.game.skill.panelbtn[3].btn:linkshowhidebtn(kui.canvas.game.inv)
    kui.canvas.game.skill.panelbtn[3].btn.alerticon = kui.canvas.game.skill.alerticon[2]
    kui.canvas.game.inv.alerticon = kui.canvas.game.skill.alerticon[2]
    kui.canvas.game.inv.alerticon:setlvl(7)

    kui.canvas.game.skill.panelbtn[4].btn:linkshowhidebtn(kui.canvas.game.mast)
    kui.canvas.game.skill.panelbtn[4].btn.alerticon = kui.canvas.game.skill.alerticon[3]
    kui.canvas.game.mast.alerticon = kui.canvas.game.skill.alerticon[3]
    kui.canvas.game.mast.alerticon:setlvl(7)

    kui.canvas.game.skill.panelbtn[5].btn:linkshowhidebtn(kui.canvas.game.abil)
    kui.canvas.game.skill.panelbtn[5].btn.alerticon = kui.canvas.game.skill.alerticon[4]
    kui.canvas.game.abil.alerticon = kui.canvas.game.skill.alerticon[4]
    kui.canvas.game.abil.alerticon:setlvl(7)

    kui.canvas.game.skill.panelbtn[6].btn:linkshowhidebtn(kui.canvas.game.dig)

    kui.canvas.game.skill.panelbtn[9].btn:linkshowhidebtn(kui.canvas.game.badge)
    kui.canvas.game.skill.panelbtn[9].btn.alerticon = kui.canvas.game.skill.alerticon[5]
    kui.canvas.game.badge.alerticon = kui.canvas.game.skill.alerticon[5]
    kui.canvas.game.badge.alerticon:setlvl(7)

    -- hacky item selection fix:
    kui.canvas.game.skill.panelbtn[2].btn:addevents(nil, nil, function() -- equipment
        if kobold.player[utils.trigp()].selslotid and kobold.player[utils.trigp()].selslotid > 1000 then
            kobold.player[utils.trigp()].selslotid = nil
        end
    end)
    kui.canvas.game.skill.panelbtn[3].btn:addevents(nil, nil, function() -- inventory
        if kobold.player[utils.trigp()].selslotid and kobold.player[utils.trigp()].selslotid < 1000 then
            kobold.player[utils.trigp()].selslotid = nil
        end
    end)
    kui.canvas.game.skill.panelbtn[6].btn:addevents(nil, nil, function() -- dig sites
        if kobold.player[utils.trigp()].selslotid and kobold.player[utils.trigp()].selslotid == 1011 then
            kobold.player[utils.trigp()].selslotid = nil
        end
    end)
end


function kui:showgameui(p, _skipmusic)
    -- when a char is loaded or created,
    --  initialize default frame visibility.
    ctm_enabled = true
    if utils.localp() == p then
        kui.canvas.game:show() -- children inherit visibility.
        kui.canvas.game.skill:show()
        kui.canvas.game.inv:hide()
        kui.canvas.game.equip:hide()
        kui.canvas.game.char:hide()
        kui.canvas.game.dig:hide()
        kui.canvas.game.mast:hide()
        kui.canvas.game.abil:hide()
        kui.canvas.game.skill.xpbar:show()
        kui.canvas.game.skill.hpbar:show()
        kui.canvas.game.skill.manabar:show()
        kui:showhidepartypills(true)
        if quest.inprogress then
            quest.parentfr:show()
            if quest.minimized then quest.parentfr.minfr:show() else quest.parentfr.maxfr:show() end
        end
        if not map.manager.activemap then
            quest.socialfr:show()
            if not freeplay_mode then
                UnitAddAbility(kobold.player[p].unit, quest.speakcode)
            end
        else
            quest.socialfr:hide()
            if not freeplay_mode then
                UnitRemoveAbility(kobold.player[p].unit, quest.speakcode)
            end
        end
        BlzFrameSetVisible(kui.minimap, true)
        -- load music:
        if not _skipmusic then kui:loadmusictrack(p) end
    end
    kui.previousframesoundfh = nil
end


function kui:hidegameui(p)
    -- when a char is loaded or created,
    --  initialize default frame visibility.
    suppress_all_panel_sounds = true
    ctm_enabled = false
    if p == utils.localp() then
        kui.canvas.game:hide() -- children inherit visibility.
        kui.canvas.game.skill:hide()
        kui.canvas.game.inv:hide()
        kui.canvas.game.equip:hide()
        kui.canvas.game.char:hide()
        kui.canvas.game.dig:hide()
        kui.canvas.game.mast:hide()
        kui.canvas.game.abil:hide()
        kui.canvas.game.badge:hide()
        kui.canvas.game.skill.xpbar:hide()
        kui.canvas.game.skill.hpbar:hide()
        kui.canvas.game.skill.manabar:hide()
        quest.parentfr:hide()
        quest.socialfr:hide()
        kui:showhidepartypills(false)
        BlzFrameSetVisible(kui.minimap, false)
    end
    suppress_all_panel_sounds = false
end


function kui:loadmusictrack(p)
    -- find relevant track:
    if map.manager.activemap and map.manager.cache and map.manage.cache.id == m_type_boss_fight then -- boss active.
        StopSound(kui.sound.menumusic, false, true)
        utils.playsound(kui.sound.bossmusic, p)
    elseif map.manager.activemap then -- normal map.
        -- TODO
        StopSound(kui.sound.menumusic, false, true)
        StopSound(kui.sound.bossmusic, false, true)
    else -- in town.
        StopSound(kui.sound.bossmusic, false, true)
        utils.playsound(kui.sound.menumusic, p)
    end
end


function kui:showhidepartypills(bool)
    if bool then
        kui.canvas.game.party:show()
        for i = 1,4 do
            if kobold.player[Player(i-1)] and kui.canvas.game.party.pill[i] then
                kui.canvas.game.party.pill[i].hpbar:show()
                kui.canvas.game.party.pill[i].manabar:show()
            end
        end
    else
        kui.canvas.game.party:hide()
        for i = 1,4 do
            if kobold.player[Player(i-1)] and kui.canvas.game.party.pill[i] then
                kui.canvas.game.party.pill[i].hpbar:hide()
                kui.canvas.game.party.pill[i].manabar:hide()
            end
        end
    end
end


function kui:closeall()
    -- when transitioning to map, close all panels.
    --  e.g. after a player chooses a dig site.
    suppress_all_panel_sounds = true
    if kui.canvas.game.inv:isvisible()    then kui.canvas.game.inv:hide() end
    if kui.canvas.game.equip:isvisible()  then kui.canvas.game.equip:hide() end
    if kui.canvas.game.char:isvisible()   then kui.canvas.game.char:hide() end
    if kui.canvas.game.dig:isvisible()    then kui.canvas.game.dig:hide() end
    if kui.canvas.game.mast:isvisible()   then kui.canvas.game.mast:hide() end
    if kui.canvas.game.abil:isvisible()   then kui.canvas.game.abil:hide() end
    if kui.canvas.game.badge:isvisible()  then kui.canvas.game.badge:hide() end
    suppress_all_panel_sounds = false
end


-- @texture  = set this backdrop texture
-- @parentfr = set parent fr object.
-- @callback = run this function on click.
-- @_advtip  = pass in an advtip table.
function kui:createsplashbtn(texture, parentfr, callback, _advtip)
    local fr = kui.frame:newbtntemplate(parentfr, texture)
    fr:setsize(kui:px(kui.meta.splashbtnw), kui:px(kui.meta.splashbtnh))
    -- fr.btn:addhoverhl(fr)
    if _advtip then
        fr.btn.advtip = _advtip
        fr.btn.advtipanchor = fp.br
        fr.btn.advattachanchor = fp.l
        fr.btn:initializeadvtip()
    end
    fr.btn:addhoverscale(fr,1.06)
    fr.statesnd = true
    fr.btn.statesnd = true
    return fr
end


-- @str        = string text.
-- @scale      = [optional] scale the text (e.g. 1.25).
-- @iscentered = [optional] aling center of frame? (bool).
function kui.frame:createtext(str, scale, iscentered)
    local fr = kui.frame:newbyname("FrameBaseText", self)
    BlzFrameSetText(fr.fh, str)
    if scale then BlzFrameSetScale(fr.fh, scale) end
    if iscentered then BlzFrameSetTextAlignment(fr.fh, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER) end
    fr:setlvl(2)
    return fr
end


-- @str   = string text.
-- @scale = [optional] scale the text (e.g. 1.25).
function kui.frame:createheadertext(str, scale)
    -- this is vert/horiz centered by default
    local fr = kui.frame:newbyname("FrameHeaderText", self)
    BlzFrameSetText(fr.fh, str)
    if scale then BlzFrameSetScale(fr.fh, scale) end
    fr:setlvl(4)
    return fr
end


-- @str   = string text.
function kui.frame:createbtntext(str)
    -- this is vert/horiz centered by default
    local fr = kui.frame:newbyname("FrameBtnText", self)
    BlzFrameSetText(fr.fh, str)
    fr:setlvl(4)
    return fr
end


-- @str   = btn text
function kui.frame:creategluebtn(str, parentfr)
    local fr = self:newbyname("ScriptDialogButton", parentfr)
    fr:setsize(kui:px(200), kui:px(60))
    fr:settext(str)
    return fr
end


-- @ownerfr = the owner of the close btn (hide this frame on click).
function kui.frame:createmainframeclosebtn()
    self.closebtn = kui.frame:newbyname("FrameCloseBtn", self)
    self.closebtn.statesnd = true
    self.closebtn:setfp(fp.c, fp.c, self, (self:w()/2)-kui:px(38), (self:h()/2)-kui:px(26))
    self.closebtn:addbgtex(kui.tex.closebtn)
    self.closebtn:setlvl(6)
    self.closebtn:linkcloseevent(self)
    self.closebtn:addhoverhl()
    self.closebtn:resetalpha()
    self.closebtn:assigntooltip("closebtn")
end


-- when this frame is pressed, force playre to press key 'keystr' (e.g. "F")
function kui.frame:mapbtntohotkey(keystr)
    self:addevents(nil, nil, function()
        if utils.islocaltrigp() then
            ForceUIKey(keystr)
        end
    end)
end


function kui:initializefootsteps(pobj)
    pobj.steptmr = NewTimer()
    pobj.stepx = 0
    pobj.stepy = 0
    pobj.prevstepx = utils.unitxy(pobj.unit)
    pobj.prevstepy = utils.unitxy(pobj.unit)
    pobj.stepcheck = false
    TimerStart(pobj.steptmr, 0.33, true, function()
        utils.debugfunc(function()
            if pobj and pobj.unit then
                pobj.prevstepx = pobj.stepx
                pobj.prevstepy = pobj.stepy
                pobj.stepx = utils.unitxy(pobj.unit)
                pobj.stepy = utils.unitxy(pobj.unit)
                pobj.stepcheck = false
                if pobj.prevstepx == pobj.stepx and pobj.prevstepy == pobj.stepy then
                    -- not moving, do nothing:
                    loot.ancient:raiseevent(ancient_event_movement, pobj, false)
                elseif not pobj.currentlykb then
                    -- moving, play a footstep:
                    loot.ancient:raiseevent(ancient_event_movement, pobj, true)
                    utils.playsound(kui.sound.footsteps[math.random(#kui.sound.footsteps)], pobj.p)
                end
            else
                ReleaseTimer()
            end
        end, "movement timer")
    end)
end


function kui:hidesplash(p, hidebool)
    -- hides intro splash screen and menu for triggering player.
    if p == utils.localp() then
        if hidebool then
            BlzFrameSetVisible(BlzGetFrameByName("SimpleFrameSplash",0),false)
            self.canvas.splash:hide()
            self.canvas.splash.options:hide()
            self.canvas.splash.newmf:hide() -- hide char select for possible splash re-open.
        else
            BlzFrameSetVisible(BlzGetFrameByName("SimpleFrameSplash",0),true)
            self.canvas.splash:show()
            self.canvas.splash.options:show()
        end
    end
end


function kui:hidecmdbtns()
    local func = function()
        for i = 0,#self.cmdmap do
            local fh = BlzGetFrameByName(self.cmdmap[i],0) BlzFrameClearAllPoints(fh) BlzFrameSetAbsPoint(fh, fp.tl, 0.0, -0.25)
        end
        -- hide annoying invisible cmd btn cover:
        BlzFrameSetVisible(BlzFrameGetChild(self.consuleui, 5), false)
    end
    local unit = utils.unitinrect(gg_rct_expeditionVision, p, 'hfoo')
    for p,_ in pairs(kobold.playing) do
        SelectUnitForPlayerSingle(unit, p)
        -- SyncSelections()
        if p == utils.localp() then func() end
    end
    RemoveUnit(unit)
end
