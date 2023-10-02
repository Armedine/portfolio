hotkey      = {}
hotkey.map  = {} -- sub class for custom 1-4 hotkeys.


-- *note: this must be done after kui:uigen().
function hotkey:init()
    hotkey.map:init()
    self.hotkeyc     = color.ui.hotkey
    self.trigger     = CreateTrigger()
    -- self.movetrig    = CreateTrigger()
    self.movetimer   = {}
    self.timeout     = {} -- only allow events every x sec to prevent spam.
    self.timeoutdur  = 0.03
    self.closeall    = OSKEY_ESCAPE -- btn used to close all visible tabs.
    self.masterykeys = {
        [OSKEY_1] = "Z",
        [OSKEY_2] = "X",
        [OSKEY_3] = "T",
        [OSKEY_4] = "Y",
    }
    self.panel       = {
        char  =     { str = "C",   key = OSKEY_C,   tar = kui.canvas.game.char  }, -- panelid: 1
        equip =     { str = "V",   key = OSKEY_V,   tar = kui.canvas.game.equip }, -- panelid: 2
        inv   =     { str = "B",   key = OSKEY_B,   tar = kui.canvas.game.inv   }, -- panelid: 3
        dig   =     { str = "Tab", key = OSKEY_TAB, tar = kui.canvas.game.dig   }, -- panelid: 4
        mast  =     { str = "N",   key = OSKEY_N,   tar = kui.canvas.game.mast  }, -- panelid: 5
        abil  =     { str = "K",   key = OSKEY_K,   tar = kui.canvas.game.abil  }, -- panelid: 6
        badg  =     { str = "J",   key = OSKEY_J,   tar = kui.canvas.game.badge }, -- panelid: 7
    }
    --------------------------------------
    for panel,kt in pairs(self.panel) do kt.str = color:wrap(self.hotkeyc, kt.str) end
    --self:createclicktomove()
end


-- *note: this must be done after kui and kk packages init.
function hotkey:assignkuipanels()
    utils.playerloop(function(p)
        local p = p
        if kobold.player[p] then
            self.timeout[p] = false
            for panelname,ktab in pairs(self.panel) do
                local func = function()
                    if not map.manager.loading then
                        if utils.islocaltrigp() then
                            if not ktab.tar:isvisible() and not scoreboard_is_active then
                                ktab.tar:show()
                                if ktab.tar.alerticon then
                                    -- hide the eyecandy alert for this panel button.
                                    ktab.tar.alerticon:hide()
                                end
                            else
                                -- we have to do a hacky fix to make sure opening panels refreshes selected slot:
                                if panelname == "inv" and kobold.player[p].selslotid and kobold.player[p].selslotid < 1000 then
                                    ktab.tar:hide(function() kobold.player[p].selslotid = nil end)
                                elseif panelname == "equip" and kobold.player[p].selslotid and kobold.player[p].selslotid > 1000 then
                                    ktab.tar:hide(function() kobold.player[p].selslotid = nil end)
                                elseif panelname == "dig" and kobold.player[p].selslotid and kobold.player[p].selslotid == 1011 then
                                    ktab.tar:hide(function() kobold.player[p].selslotid = nil end)
                                else
                                    ktab.tar:hide()
                                end
                            end
                        end
                    end
                end
                hotkey:regkeyevent(p, ktab.key, func, true, true)
            end
            local escfunc = function()
                if utils.islocaltrigp() then
                    shop.fr:hide()
                    shop.gwfr:hide()
                    for panelname,ktab in pairs(self.panel) do
                        if ktab.tar:isvisible() then ktab.tar:hide(function() kobold.player[utils.trigp()].selslotid = nil end) end
                    end
                end
            end
            hotkey:regkeyevent(p, self.closeall, escfunc, true, false)
        end
    end)
end


-- @istimeout,@ondown, and @meta are optional and have defaults.
function hotkey:regkeyevent(p, oskey, func, islocal, istimeout, ondown, meta)
    -- create an OSKEY event for a player.
    local meta      = meta      or 0
    local ondown    = ondown    or true
    local istimeout = istimeout or true
    BlzTriggerRegisterPlayerKeyEvent(self.trigger, p, oskey, meta, ondown)
    local action    = TriggerAddAction(self.trigger, function()
        if not self.timeout[p] and hotkey:iskey(p, oskey) then
            if islocal and p == utils.localp() then
                func()
            else
                func()
            end
        end
        if istimeout then self:timeout(p) end
    end)
    return action
end


-- @p           = for this player
-- @typestr     = "down", "up" or "move"
-- @localfunc   = local player function
-- @netfunc     = net-safe function
-- @leftorright = 0 for left, 1 for right
function hotkey:regmouseevent(p, typestr, localfunc, netfunc, leftorright)
    local meta
    if typestr == "down" then
        TriggerRegisterPlayerEvent(self.movetrig, p, EVENT_PLAYER_MOUSE_DOWN)
        meta = 0
    elseif typestr == "up" then
        TriggerRegisterPlayerEvent(self.movetrig, p, EVENT_PLAYER_MOUSE_UP)
    elseif typestr == "move" then
        TriggerRegisterPlayerEvent(self.movetrig, p, EVENT_PLAYER_MOUSE_MOVE)
    else
        print("error: hotkey:regmouseevent 'typestr' is not valid.")
    end
    if typestr ~= "move" then
        TriggerAddAction(self.movetrig, function()
            if hotkey:ismousebtn(leftorright) then
                if netfunc then
                    netfunc()
                end
                if p == utils.trigp() then
                    localfunc()
                end
            end
        end)
    else
        TriggerAddAction(self.movetrig, function()
            netfunc()
        end)
    end
end


function hotkey:timeout(p)
    utils.booltimer(self.timeout[p], self.timeoutdur, false)
end


function hotkey:iskey(p, oskey)
    if p == utils.localp() then
        if BlzGetTriggerPlayerKey() == oskey then
            return true
        else
            return false
        end
    end
end


function hotkey:ismousebtn(leftorright)
    if leftorright == 0 then
        return BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT
    elseif leftorright == 1 then
        return BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT
    else
        print("error: ismousebtn 'leftorright' should be 0 or 1")
    end
end


function hotkey:createclicktomove()
    click_atk_trig      = {}
    click_cast_trig     = {}
    click_move_disabled = {}
    click_move_bool     = {}
    click_move_x        = {}
    click_move_y        = {}
    click_move_tempx    = {}
    click_move_tempy    = {}
    click_move_tempa    = {}
    click_move_prevx    = {}
    click_move_prevy    = {}
    click_move_unit     = {}
    click_move_tmr      = NewTimer()
    click_move_uptrig   = CreateTrigger()
    click_move_dntrig   = CreateTrigger()
    click_move_mvtrig   = CreateTrigger()
    pause_click_to_move = function(p)
        click_move_disabled[utils.pnum(p)] = true
        if kobold.player[p].clickdistmr then ReleaseTimer(kobold.player[p].clickdistmr) kobold.player[p].clickdistmr = nil end
        kobold.player[p].clickdistmr = utils.timed(0.18, function()
            click_move_disabled[utils.pnum(p)] = false
        end)
    end
    for pnum = 1,kk.maxplayers do
        local p, pnum = Player(pnum-1), pnum
        if kobold.player[p] then
            click_move_bool[pnum] = false
            -- add each player to event listener:
            TriggerRegisterPlayerEvent(click_move_dntrig, p, EVENT_PLAYER_MOUSE_DOWN)
            TriggerRegisterPlayerEvent(click_move_uptrig, p, EVENT_PLAYER_MOUSE_UP)
            TriggerRegisterPlayerEvent(click_move_mvtrig, p, EVENT_PLAYER_MOUSE_MOVE)
            click_move_unit[pnum] = function() return kobold.player[Player(pnum-1)].unit end
        end
        -- click to move spell pause helper:
        click_cast_trig[pnum] = trg:new("startcast", Player(pnum-1))
        click_cast_trig[pnum]:regaction(function()
            pause_click_to_move(utils.unitp())
        end)
        -- click to move attack pause helper:
        click_atk_trig[pnum] = trg:new("order", Player(pnum-1))
        click_atk_trig[pnum]:regaction(function()
            if GetIssuedOrderId() == 851971 or GetIssuedOrderId() == 851983 or GetIssuedOrderId() == 851985
            or GetIssuedOrderId() == 851988 then
                pause_click_to_move(utils.unitp())
            end
        end)
    end
    -- listen for player events and set arrays:
    local mousedn = function()
        if hotkey:ismousebtn(1) then
            local pnum = utils.trigpnum()
            click_move_bool[pnum] = true
            click_move_x[pnum] = BlzGetTriggerPlayerMouseX()
            click_move_y[pnum] = BlzGetTriggerPlayerMouseY()
            click_move_prevx[pnum] = BlzGetTriggerPlayerMouseX()
            click_move_prevy[pnum] = BlzGetTriggerPlayerMouseY()
            click_move_tempa[pnum] = utils.anglexy(utils.unitx(click_move_unit[pnum]()), utils.unity(click_move_unit[pnum]()),
                click_move_prevx[pnum], click_move_prevy[pnum])
        end
    end
    local mouseup = function()
        if hotkey:ismousebtn(1) then
            click_move_bool[utils.trigpnum()] = false
            local pnum = utils.trigpnum()
            -- to prevent our hold-down fix from overriding on slight movement after release, issue a move if distance is greater than fix range:
            if not IsTerrainPathable(click_move_x[pnum], click_move_y[pnum], PATHING_TYPE_WALKABILITY)
            and utils.distxy(click_move_x[pnum], click_move_y[pnum], utils.unitx(click_move_unit[pnum]()), utils.unity(click_move_unit[pnum]()))
            > BlzGetUnitRealField(click_move_unit[pnum](), UNIT_RF_SPEED) then
                if not click_move_disabled[pnum] then
                    utils.issmovexy(kobold.player[Player(pnum-1)].unit, click_move_x[pnum], click_move_y[pnum])
                end
            end
        end
    end
    local mousemv = function()
        if click_move_bool[utils.trigpnum()] then
            local pnum = utils.trigpnum()
            if click_move_disabled[pnum] and kobold.player[Player(pnum-1)].clickdistmr then
                if utils.distxy(click_move_prevx[pnum], click_move_prevy[pnum], click_move_x[pnum], click_move_y[pnum]) > 40.0 then
                    ReleaseTimer(kobold.player[Player(pnum-1)].clickdistmr)
                    kobold.player[Player(pnum-1)].clickdistmr = nil
                    click_move_disabled[pnum] = false
                    SetUnitFacingTimed(click_move_unit[pnum](),
                        utils.anglexy(click_move_prevx[pnum], click_move_prevy[pnum], click_move_x[pnum], click_move_y[pnum]), 0.0)
                end
            end
            click_move_x[pnum] = BlzGetTriggerPlayerMouseX()
            click_move_y[pnum] = BlzGetTriggerPlayerMouseY()
            click_move_tempa[pnum] = utils.anglexy(utils.unitx(click_move_unit[pnum]()), utils.unity(click_move_unit[pnum]()),
                click_move_x[pnum], click_move_y[pnum])
        end
    end
    TriggerAddAction(click_move_dntrig, mousedn)
    TriggerAddAction(click_move_uptrig, mouseup)
    TriggerAddAction(click_move_mvtrig, mousemv)
    -- move hero when click arrays are valid:
    TimerStart(click_move_tmr, 0.06, true, function()
        utils.debugfunc(function()
            for pnum = 1,kk.maxplayers do
                if kobold.player[Player(pnum-1)].unit and utils.isalive(kobold.player[Player(pnum-1)].unit)then
                    if click_move_bool[pnum] and not click_move_disabled[pnum] and not kobold.player[Player(pnum-1)].downed then
                        -- check if minimum distance exceeded:
                        if utils.distxy(click_move_x[pnum], click_move_y[pnum], utils.unitxy(kobold.player[Player(pnum-1)].unit)) > 40.0 then
                            -- check for mouse held down on timer update:
                            if utils.distxy(click_move_x[pnum], click_move_y[pnum], click_move_prevx[pnum], click_move_prevy[pnum]) < 25.0 then
                                -- mouse is held down:
                                click_move_x[pnum], click_move_y[pnum] = BlzGetTriggerPlayerMouseX(), BlzGetTriggerPlayerMouseY()
                                local click_held_dist = utils.distxy(click_move_x[pnum], click_move_y[pnum], utils.unitxy(click_move_unit[pnum]()))
                                click_move_tempx[pnum], click_move_tempy[pnum] = utils.unitxy(click_move_unit[pnum]())
                                click_move_tempx[pnum], click_move_tempy[pnum] = utils.projectxy(click_move_tempx[pnum], click_move_tempy[pnum],
                                    click_held_dist, click_move_tempa[pnum])
                                if click_held_dist > 80.0 then
                                    if click_move_tempx[pnum] ~= 0.0 and click_move_tempy[pnum] ~= 0.0
                                    and not IsTerrainPathable(click_move_tempx[pnum], click_move_tempy[pnum], PATHING_TYPE_WALKABILITY) then
                                        utils.issmovexy(kobold.player[Player(pnum-1)].unit, click_move_tempx[pnum], click_move_tempy[pnum])
                                        pause_click_to_move(Player(pnum-1))
                                    end
                                end
                            -- standard on mouse move:
                            elseif click_move_x[pnum] ~= 0.0 and click_move_y[pnum] ~= 0.0
                            and not IsTerrainPathable(click_move_x[pnum], click_move_y[pnum], PATHING_TYPE_WALKABILITY) then
                                -- only issue a new command if updated to a new coordinate
                                if utils.distxy(click_move_prevx[pnum], click_move_prevy[pnum], click_move_x[pnum], click_move_y[pnum]) > 40.0 then
                                    utils.issmovexy(kobold.player[Player(pnum-1)].unit, click_move_x[pnum], click_move_y[pnum])
                                    pause_click_to_move(Player(pnum-1))
                                end
                            end
                            -- set previous values:
                            click_move_prevx[pnum], click_move_prevy[pnum] = click_move_x[pnum], click_move_y[pnum]
                        end
                    end
                end
            end
        end, "click move")
    end)
end


function hotkey.map:init()
    self.__index = self
    self.codet   = {
        [OSKEY_1] = {
            [casttype_point]      = FourCC('A02Z'),
            [casttype_unit]       = FourCC('A02Y'),
            [casttype_instant]    = FourCC('A030'),
        },
        [OSKEY_2] = {
            [casttype_point]      = FourCC('A032'),
            [casttype_unit]       = FourCC('A031'),
            [casttype_instant]    = FourCC('A033'),
        },
        [OSKEY_3] = {
            [casttype_point]      = FourCC('A035'),
            [casttype_unit]       = FourCC('A034'),
            [casttype_instant]    = FourCC('A036'),
        },
        [OSKEY_4] = {
            [casttype_point]      = FourCC('A038'),
            [casttype_unit]       = FourCC('A037'),
            [casttype_instant]    = FourCC('A039'),
        },
    }
    self.ordert = {
        [OSKEY_1] = 'ward',
        [OSKEY_2] = 'vengeance',
        [OSKEY_3] = 'forceofnature',
        [OSKEY_4] = 'web',
    }
    self.intmap = {
        [5] = OSKEY_1,
        [6] = OSKEY_2,
        [7] = OSKEY_3,
        [8] = OSKEY_4,
    }
end


function hotkey.map:new(p)
    local o     = setmetatable({}, self)
    o.code      = {} -- mapped ability code to cast.
    o.orderstr  = {} -- `` orderstr for spell dummy.
    o.action    = {} -- stored hotkey funcs.
    o.p         = p
    for oskey,target in pairs(hotkey.masterykeys) do
        o.action[oskey] = hotkey:regkeyevent(p, oskey, function()
            ForceUIKey(target)
        end, true, false)
    end
    o:mapabilkeys()
    return o
end


function hotkey.map:getplayerunit()
    return kobold.player[self.p].unit
end


function hotkey.map:updatekey(oskey, abilcode, casttype, orderstr)
    self:clearkey(oskey, casttype)
    self.code[oskey]     = abilcode -- keep after clear key.
    self.orderstr[oskey] = orderstr
    UnitAddAbility(self:getplayerunit(), self.codet[oskey][casttype])
    return self.codet[oskey][casttype]
end


function hotkey.map:clearkey(oskey, casttype)
    self.code[oskey] = nil
    for casttype,dummyabil in pairs(self.codet[oskey]) do
        if BlzGetUnitAbility(self:getplayerunit(), dummyabil) then
            UnitRemoveAbility(self:getplayerunit(), dummyabil)
        end
    end
end


function hotkey.map:mapabilkeys()
    self.trig = trg:new("spell", self.p)
    self.trig:regaction(function()
        for oskey,t in pairs(self.codet) do
            for casttype,dummyabil in pairs(t) do
                -- note: trg package controls owning player.
                if GetSpellAbilityId() == dummyabil then
                    if casttype == casttype_instant then
                        if not buffy:gen_cast_instant(
                            self:getplayerunit(), self.code[oskey], self.orderstr[oskey]) 
                        then
                            buffy:gen_reset(self:getplayerunit(), dummyabil)
                        end
                    elseif casttype == casttype_point then
                        if not buffy:gen_cast_point(
                            self:getplayerunit(), self.code[oskey], self.orderstr[oskey], GetSpellTargetX(), GetSpellTargetY()) 
                        then
                            buffy:gen_reset(self:getplayerunit(), dummyabil)
                        end
                    elseif casttype == casttype_unit then
                        if not buffy:gen_cast_unit(
                            self:getplayerunit(), self.code[oskey], self.orderstr[oskey], GetSpellTargetUnit()) 
                        then
                            buffy:gen_reset(self:getplayerunit(), dummyabil)
                        end
                    end
                    break
                end
            end
        end
    end)
end
