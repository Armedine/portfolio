hotkey = {}
hotkey.__index = hotkey
click_move_debug = true
-- config:
click_move_min_player_number = 1
click_move_max_player_number = 1
click_move_update_cadance    = 0.03 -- check for mouse updates at this speed.
click_move_update_distance   = 84.  -- minimum distance of a change in x/y during timer ticks to update on mouse move (independent timer)
click_move_update_angle      = 2.66  -- `` angle change.
click_move_min_distance      = 64.  -- prevent movement when mouse is in this radius around unit (stops chaotic stationary updates)
click_move_footstep_cadence  = 0.33 -- how often to play a footstep sound while moving.
click_move_pause_duration    = 0.18 -- how long to pause between move commands (ignored during mouse movement)
click_move_project_dist      = 256. -- how far to project when mouse is held down (should not need to alter)


function hotkey:initializevariables()
    steptmr         = {}
    stepx           = {}
    stepy           = {}
    prevstepx       = {}
    prevstepy       = {}
    stepcheck       = {}
    is_player_here  = {}
    for pnum = click_move_min_player_number,click_move_max_player_number do
        if GetPlayerSlotState(Player(pnum-1)) == PLAYER_SLOT_STATE_PLAYING then
            steptmr[pnum]        = NewTimer()
            stepx[pnum]          = 0.
            stepy[pnum]          = 0.
            prevstepx[pnum]      = 0.
            prevstepy[pnum]      = 0.
            stepcheck[pnum]      = false
            is_player_here[pnum] = true
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
    -- temporary calc vars
    click_held_dist = 0.
    -- globals
    click_move_unit     = udg_click_move_unit
    click_atk_trig      = {}
    click_cast_trig     = {}
    click_off_timer     = {}
    click_move_held     = {}
    click_move_ignore   = {}
    click_move_disabled = {}
    click_move_stop_dis = {}
    click_move_stop_tmr = {}
    click_move_bool     = {}
    click_move_x        = {}
    click_move_y        = {}
    click_move_tempx    = {}
    click_move_tempy    = {}
    click_move_unita    = {}
    click_move_prevx    = {}
    click_move_prevy    = {}
    click_move_preva    = {}
    click_move_recent   = {}
    click_move_upd_tmr  = {}
    click_move_tmr      = NewTimer()
    click_move_uptrig   = CreateTrigger()
    click_move_dntrig   = CreateTrigger()
    click_move_mvtrig   = CreateTrigger()
    pause_click_to_move = function(pnum)
        click_move_disabled[pnum] = true
        if click_off_timer[pnum] then ReleaseTimer(click_off_timer[pnum]) click_off_timer[pnum] = nil end
        click_off_timer[pnum] = timed(click_move_pause_duration, function()
            click_move_disabled[pnum] = false
        end)
    end
    unpause_click_to_move = function(pnum)
        click_move_disabled[pnum] = false
        if click_off_timer[pnum] then ReleaseTimer(click_off_timer[pnum]) click_off_timer[pnum] = nil end
    end
    issue_move_command = function(pnum)
        SetUnitFacingTimed(click_move_unit[pnum], click_move_unita[pnum], 0.0)
        issmovexy(click_move_unit[pnum], click_move_tempx[pnum], click_move_tempy[pnum])
        pause_click_to_move(pnum)
    end
    get_unit_facing_mouse = function (pnum)
        click_move_unita[pnum]  = anglexy(unitx(click_move_unit[pnum]), unity(click_move_unit[pnum]),
            click_move_x[pnum], click_move_y[pnum])
    end
    for pnum = click_move_min_player_number,click_move_max_player_number do
        local p, pnum = Player(pnum-1), pnum
        if is_player_here[pnum] then
            click_move_bool[pnum] = false
            -- add each player to event listener:
            TriggerRegisterPlayerEvent(click_move_dntrig, p, EVENT_PLAYER_MOUSE_DOWN)
            TriggerRegisterPlayerEvent(click_move_uptrig, p, EVENT_PLAYER_MOUSE_UP)
            TriggerRegisterPlayerEvent(click_move_mvtrig, p, EVENT_PLAYER_MOUSE_MOVE)
            -- click to move spell pause helper:
            click_cast_trig[pnum] = trg:new("startcast", Player(pnum-1))
            click_cast_trig[pnum]:regaction(function()
                pause_click_to_move(getpnum(unitp()))
            end)
            -- click to move attack pause helper:
            click_atk_trig[pnum] = trg:new("order", Player(pnum-1))
            click_atk_trig[pnum]:regaction(function()
                if GetIssuedOrderId() == 851971 or GetIssuedOrderId() == 851983 or GetIssuedOrderId() == 851985
                or GetIssuedOrderId() == 851988 then
                    pause_click_to_move(getpnum(unitp()))
                end
            end)
            hotkey:initializefootsteps(pnum, click_move_unit[pnum])
        end
    end
    local get_mouse_x_y = function(pnum, update_prev)
        click_move_x[pnum], click_move_y[pnum] = BlzGetTriggerPlayerMouseX(), BlzGetTriggerPlayerMouseY()
    end
    -- listen for player events and set arrays:
    local mousedn = function()
        if hotkey:ismousebtn(1) then
            local pnum = trigpnum()
            get_mouse_x_y(pnum)
            get_unit_facing_mouse(pnum)
            unpause_click_to_move(pnum)
            click_move_bool[pnum]   = true
            click_move_ignore[pnum] = false
            click_move_held[pnum]   = false
        end
    end
    local mouseup = function()
        if hotkey:ismousebtn(1) then
            local pnum = trigpnum()
            get_mouse_x_y(pnum)
            if click_move_held[pnum] then
                -- to prevent  hold-down fix from overriding on slight movement after release, issue a move if distance is > than min range:
                if not IsTerrainPathable(click_move_x[pnum], click_move_y[pnum], PATHING_TYPE_WALKABILITY)
                and distxy(click_move_x[pnum], click_move_y[pnum], unitxy(click_move_unit[pnum])) > click_move_min_distance then
                    issue_move_command(pnum)
                end
            end
            click_move_bool[pnum]   = false
            click_move_ignore[pnum] = false
            click_move_held[pnum]   = false
        end
    end
    local mousemv = function()
        local pnum = trigpnum()
        if click_move_bool[pnum] then
            get_mouse_x_y(pnum)
            get_unit_facing_mouse(pnum)
            -- check if an updated move should be allowed:
            click_held_dist = distxy(click_move_x[pnum], click_move_y[pnum], unitxy(click_move_unit[pnum]))
            if click_held_dist > click_move_min_distance then
                -- only update movement if:
                --  * minimum update distance of drag exceeded
                --  * `` angle change exceeded
                --  * if no move update was recently issued
                if click_move_x[pnum] ~= click_move_prevx[pnum] and click_move_y[pnum] ~= click_move_prevy[pnum]
                and math.abs(click_move_preva[pnum] - click_move_unita[pnum]) > click_move_update_angle
                and (not click_move_disabled[pnum]
                and distxy(click_move_x[pnum], click_move_y[pnum], click_move_prevx[pnum], click_move_prevy[pnum]) > click_move_update_distance) then
                    -- if an update was not recently issued
                    issue_move_command(pnum)
                    click_move_ignore[pnum] = false
                end
            -- if held within minimum move radius, prevent movement:
            elseif click_held_dist < click_move_min_distance then
                IssueImmediateOrderById(click_move_unit[pnum], 851972)
                click_move_ignore[pnum] = true
                unpause_click_to_move(pnum)
            end
        end
    end
    TriggerAddAction(click_move_dntrig, mousedn)
    TriggerAddAction(click_move_uptrig, mouseup)
    TriggerAddAction(click_move_mvtrig, mousemv)
    -- move hero when click arrays are valid:
    TimerStart(click_move_tmr, click_move_update_cadance, true, function()
        debugfunc(function()
            for pnum = click_move_min_player_number,click_move_max_player_number do
                if is_player_here[pnum] and click_move_unit[pnum] and isalive(click_move_unit[pnum]) then
                    if not click_move_ignore[pnum] then
                        -- mouse held down:
                        if click_move_bool[pnum] then
                            click_move_held[pnum] = true
                            if not click_move_disabled[pnum] then
                                -- if held down, not paused, and a drag update was not recently issued:
                                click_move_preva[pnum] = click_move_unita[pnum]
                                click_move_prevx[pnum], click_move_prevy[pnum] = click_move_x[pnum], click_move_y[pnum]
                                click_move_tempx[pnum], click_move_tempy[pnum] = unitxy(click_move_unit[pnum])
                                click_move_tempx[pnum], click_move_tempy[pnum] = projectxy(click_move_tempx[pnum], click_move_tempy[pnum],
                                    click_move_project_dist, click_move_unita[pnum])
                                if not IsTerrainPathable(click_move_tempx[pnum], click_move_tempy[pnum], PATHING_TYPE_WALKABILITY) then
                                    issue_move_command(pnum)
                                end
                            end
                        end
                    end
                end
            end
            if click_move_debug then
                ClearTextMessages()
                print("mouse held?", click_move_held[1])
                print("movement paused?", click_move_disabled[1])
                print("x = ", click_move_x[1])
                print("y = ", click_move_y[1])
                print("unit x = ", unitx(click_move_unit[1]))
                print("unit y = ", unity(click_move_unit[1]))
                print("movement angle = ", click_move_unita[1])
            end
        end, "click move")
    end)
end


function hotkey:initializefootsteps(pnum)
    TimerStart(steptmr[pnum], click_move_footstep_cadence, true, function()
        debugfunc(function()
            if click_move_unit[pnum] then
                if isalive(click_move_unit[pnum]) then
                    prevstepx[pnum] = stepx[pnum]
                    prevstepy[pnum] = stepy[pnum]
                    stepx[pnum] = unitxy(click_move_unit[pnum])
                    stepy[pnum] = unitxy(click_move_unit[pnum])
                    stepcheck[pnum] = false
                    if prevstepx[pnum] == stepx[pnum] and prevstepy[pnum] == stepy[pnum] then
                        -- unit is not moving, do any no-movement actions here.
                    else
                        -- unit is moving, do any movement actions here.
                        playsound(udg_footsteps[math.random(#udg_footsteps)], Player(pnum-1))
                    end
                end
            else
                ReleaseTimer()
            end
        end, "movement timer")
    end)
end
