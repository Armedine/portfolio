do
    objc        = {}
    -- config:
    objc.hideui = true
    -- globals:
    objc.count  = 0
    objc.timer  = CreateTimer()
    objc.trg    = CreateTrigger()
    -- lazy hook for pure code init:
    local oldglobals = InitGlobals
    function InitGlobals()
        debugf(function()
            oldglobals()
            BlzEnableUIAutoPosition(false)
            BlzHideOriginFrames(true)
            fp = {
                tl = FRAMEPOINT_TOPLEFT, t = FRAMEPOINT_TOP,         tr = FRAMEPOINT_TOPRIGHT, r = FRAMEPOINT_RIGHT, br = FRAMEPOINT_BOTTOMRIGHT,
                b = FRAMEPOINT_BOTTOM,   bl= FRAMEPOINT_BOTTOMLEFT,   l = FRAMEPOINT_LEFT,     c = FRAMEPOINT_CENTER,
            }
            if lochost() then
                p_screenw = BlzGetLocalClientWidth()
                p_screenh = BlzGetLocalClientHeight()
            end
            if not BlzLoadTOCFile('war3mapImported\\textarea.toc') then print("error: .toc failed to load!") end
        end, "InitGlobals")
    end
end


----------------------------------------------------------------
----------------------------- main -----------------------------
----------------------------------------------------------------


function objc:build()
    buildtestdata()
    objc.fh  = objc:newframe("EscMenuTextAreaTemplate", objc.gameui)
    objc.hdr = objc:newtext(objc.fh, fp.t, fp.t, "Console: Object Tracker - <no object>", 0, px(16))
    objc.btn = objc:newframebytype("GLUEBUTTON", objc.gameui, "IconButtonTemplate")
    objc.bbd = objc:newframebytype("BACKDROP", objc.btn)
    objc:gluehideshow(objc.btn, objc.fh)
    BlzFrameSetSize(objc.fh, px(920), px(660))
    BlzFrameSetPoint(objc.fh, fp.c, objc.gameui, fp.c, 0, px(90))
    BlzFrameSetSize(objc.btn, px(64), px(64))
    BlzFrameSetPoint(objc.btn, fp.l, objc.gameui, fp.r, -px(62), 0)
    BlzFrameSetTexture(objc.bbd,'ReplaceableTextures\\CommandButtons\\BTNEngineeringUpgrade.blp', 0, true)
    BlzFrameSetAllPoints(objc.bbd, objc.btn)
    objc:show(true)
    print("objc:build() success")
    ClearTextMessages()
    objc:printobj(mytestdata, "mytestdata")
end


function objc:newtext(parent, txtanchor, parentanchor, str, _x, _y)
    local fh  = objc:newframebytype("TEXT", parent)
    local x,y = _x or 0, _y or 0
    BlzFrameSetText(fh, str)
    BlzFrameSetPoint(fh, txtanchor, parent, parentanchor, x, y)
    return fh
end


function objc:newbtn()
    return objc:newframe("BUTTON", objc.gameui)
end


function objc:newframe(framename, parent)
    return BlzCreateFrame(framename, parent, 0, 0)
end


function objc:newframebytype(frametype, parent, _inherits)
    local inherits = _inherits or ""
    objc.count = objc.count + 1
    return BlzCreateFrameByType(frametype, "objcframe"..objc.count, parent, inherits, 0)
end


function objc:gluehideshow(btnfh, tarfh)
    BlzTriggerRegisterFrameEvent(objc.trg, btnfh, FRAMEEVENT_CONTROL_CLICK)
    TriggerAddAction(objc.trg, function()
        if BlzGetTriggerFrame() == btnfh then
            if not BlzFrameIsVisible(tarfh) then
                BlzFrameSetVisible(tarfh, true)
            else
                BlzFrameSetVisible(tarfh, false)
            end
            objc:fixfocus(btnfh)
        end
    end)
end


function objc:show(bool)
    BlzFrameSetVisible(objc.fh, bool)
end


function objc:fixfocus(tarfh)
    BlzFrameSetEnable(tarfh, false)
    BlzFrameSetEnable(tarfh, true)
end


function objc:printobj(t, _objname)
    assert(t ~= nil, "error: 'printobj' requires an object/table arg")
    if _objname then
        BlzFrameSetText(objc.hdr, "Console: Object Tracker |cffffcc00<".._objname..">|r")
    else
        BlzFrameSetText(objc.hdr, "Console: Object Tracker |cffffcc00<name not specified>|r")
    end
    BlzFrameSetText(objc.fh, prettytable(t))
end


function prettytable(t)
    local s = ''
    s = traverse(t, s)
    s = '{|n'..s..'}'
    return s
end


function traverse(t, s, d)
    local s = s
    local d = d or 1
    for k,v in pairs(t) do
        if type(v) == "table" then
            s = tmerge(s, tab(d), nil, k)
            s = traverse(v, s, d + 1)
            s = tmerge(s, tab(d), true)
        else
            s = pmerge(s, tab(d), v, k)
        end
    end
    return s
end


function tab(depth)
    local tabsize = '. . . . . '
    local b = ''
    if depth > 0 then
        for i = 1,depth do b = b..tabsize end
        return '|cff898989'..b.."|r"
    else
        return b
    end    
end


function pmerge(s, b, v, k)
    return s..b..pwrap(tostring(k))..": "..pwrap(tostring(v),true)..'|n'
end


function tmerge(s, b, _endbool, _tablekey)
    local cap = ''
    if _endbool then cap = '}' else cap = '{' end
    if _tablekey then
        return s..b..pwrap(tostring(_tablekey)).." = "..cap..'|n'
    else
        return s..b..cap..'|n'
    end
end


function pwrap(str, _valbool)
    local hex
    if _valbool then hex = '|cff1cea75' else hex = '|cff47c9ff' end
    return hex..str..'|r'
end


----------------------------------------------------------------
----------------------------- util -----------------------------
----------------------------------------------------------------


function lochost()
    return Player(0) == GetLocalPlayer()
end


function pxtodpi()
    return 0.6/p_screenh
end


function px(px)
    return px*pxtodpi()
end


function debugf( func, name )
  local passed, data = pcall( function() func() return "func " .. name .. " passed" end )
  if not passed then
    print(name, passed, data)
  end
  passed = nil
  data = nil
end


----------------------------------------------------------------
----------------------------- misc -----------------------------
----------------------------------------------------------------


-- elapsed init for things that break on map init:
TimerStart(objc.timer, 0.0, false, function()
    objc.consolebd  = BlzGetFrameByName("ConsoleUIBackdrop",0)
    objc.gameui     = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
    BlzFrameSetVisible(objc.consolebd, false)
    debugf(function()
        objc:build()
    end, "objc:build()")
end)
