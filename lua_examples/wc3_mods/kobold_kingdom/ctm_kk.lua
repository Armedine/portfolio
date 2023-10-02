do
    ctm = {}
    ctm.sys = {}


    function ctm.sys:create()
        ctm.__index = ctm
        ctm.sys.__index = ctm.sys
        -- primary config:
        ctm.enabled = true            -- manually disable system.
        ctm.debug = false              -- print debug info.
        ctm.min_player_number = 1       -- max player number to enable system for.
        ctm.max_player_number = 3       -- `` min player number.
        -- options:
        ctm.exclusion_radius = 48.      -- radius around the unit where movement is prevented (stops in-place jittering and infinite run).
        ctm.pathing_block_radius = 64. -- how far to check for pathability (prevents jittering near pathing blockers)
        ctm.quick_turn_angle = 30.      -- change in angle at which a move update is forced when click move is held.
        ctm.tmr_cadence = 0.03          -- drag detection update frequency.
        ctm.move_update_pause_ticks = 8 -- the minimum timer ticks before a new move update can be issued (while mouse held down).
        ctm.move_pause_drag_ticks = 14  -- prevents drag mechanics when a non-move order is fired.
        -- temporary variables:
        ctm.calc_x = 0.
        ctm.calc_y = 0.
        ctm.calc_a = 0.
        ctm.id = 0
        -- player current mouse x,y:
        ctm.mouse_x = {}
        ctm.mouse_y = {}
        -- player previous x,y during mouse held:
        ctm.mouse_prev_x = {}
        ctm.mouse_prev_y = {}
        ctm.mouse_prev_angle = {}
        -- player hero unit:
        ctm.unit = {}
        ctm.unit_x = {}
        ctm.unit_y = {}
        ctm.unit_angle = {}
        -- mouse fields:
        ctm.mouse_btn_is_down = {}
        ctm.mouse_being_dragged = {}
        ctm.update_allowed = {}
        ctm.update_ticks = {}
        ctm.drag_allowed = {}
        ctm.drag_ticks = {}
        ctm.stop_next_mouse_up = {}
        ctm.tmr = CreateTimer()
        -- initialize mouse triggers:
        ctm.mouse_up_trig = CreateTrigger()
        ctm.mouse_down_trig = CreateTrigger()
        ctm.mouse_drag_trig = CreateTrigger()
        for n = ctm.min_player_number, ctm.max_player_number do
            local p = Player(n-1)
            ctm.unit[n] = udg_click_move_unit[n] -- controlled in GUI init.
            ctm.drag_allowed[n] = true
            ctm.update_ticks[n] = 0
            ctm.drag_ticks[n] = 0
            ctm.mouse_prev_angle[n] = getface(ctm.unit[n])
            TriggerRegisterPlayerEvent(ctm.mouse_up_trig, p, EVENT_PLAYER_MOUSE_UP)
            TriggerRegisterPlayerEvent(ctm.mouse_down_trig, p, EVENT_PLAYER_MOUSE_DOWN)
            TriggerRegisterPlayerEvent(ctm.mouse_drag_trig, p, EVENT_PLAYER_MOUSE_MOVE)
            trg:new("order", Player(n-1)):regaction(function()
                ctm.id = GetIssuedOrderId()
                if ctm.id ~= 851986 then
                    ctm.sys:pause_mouse_drag(n)
                    ctm.stop_next_mouse_up[n] = true
                else
                    ctm.sys:allow_drag_update(n)
                end
            end)
            trg:new("startcast", Player(n-1)):regaction(function()
                ctm.sys:pause_move_update(n, ctm.move_pause_drag_ticks)
            end)
        end
        TriggerAddAction(ctm.mouse_up_trig, function() debugfunc(function() ctm.sys:mouse_up(trigpnum()) end, "mouse up") end)
        TriggerAddAction(ctm.mouse_down_trig, function() debugfunc(function() ctm.sys:mouse_down(trigpnum()) end, "mouse down") end)
        TriggerAddAction(ctm.mouse_drag_trig, function() debugfunc(function() ctm.sys:mouse_drag(trigpnum()) end, "mouse move") end)
        ctm.sys:update_timer(n)
    end


    function ctm.sys:update_timer(n)
        TimerStart(ctm.tmr, ctm.tmr_cadence, true, function() debugfunc(function()
            if ctm.enabled then
                for n = ctm.min_player_number, ctm.max_player_number do
                    -- mouse held down:
                    if ctm.mouse_btn_is_down[n] and not kobold.player[Player(n-1)].downed then
                        -- check if updates are allowed:
                        ctm.sys:update_timer_ticks(n)
                        -- mouse auto click to move:
                        if ctm.drag_allowed[n] then
                            ctm.sys:get_previous_mouse_xy(n)
                            if ctm.sys:is_mouse_within_exclusion_radius(n) then
                                -- mouse is within exclusion radius, stop:
                                IssueImmediateOrderById(ctm.unit[n], 851972)
                            elseif ctm.update_allowed[n] and ctm.sys:is_mouse_held_in_same_xy(n) then
                                -- mouse is held down in same x/y:
                                ctm.mouse_being_dragged[n] = false
                                ctm.calc_x, ctm.calc_y = ctm.sys:get_current_unit_xy(n)
                                ctm.calc_x, ctm.calc_y = projectxy(ctm.calc_x, ctm.calc_y, 256.0, ctm.unit_angle[n])
                                ctm.sys:issue_movement_update(n, ctm.calc_x, ctm.calc_y)
                                ctm.sys:pause_move_update(n)
                                -- fake where the mouse position is:
                                ctm.mouse_x[n], ctm.mouse_y[n] = ctm.calc_x, ctm.calc_y
                            else
                                -- mouse moved to new x/y:
                                ctm.mouse_being_dragged[n] = true
                                if ctm.sys:is_unit_eligible_for_quick_turn(n) then
                                    -- if unit to mouse angle greatly changes, force a move update for responsive feeling:
                                    ctm.sys:issue_movement_update(n)
                                elseif ctm.update_allowed[n] and ctm.sys:get_dist_from_prev_xy(n) >= ctm.exclusion_radius then
                                    -- mouse is at a new x,y and a move command was not recently given, update move:
                                    ctm.sys:issue_movement_update(n)
                                    ctm.sys:pause_move_update(n)
                                end
                            end
                        end
                    end
                end
            end
            if ctm.debug then
                ClearTextMessages()
                print("mouse btn down? = ", ctm.mouse_btn_is_down[1])
                print("mouse dragged? = ", ctm.mouse_being_dragged[1])
                print("drag allowed? = ", ctm.drag_allowed[1])
                print("drag ticks = ", ctm.drag_ticks[1])
                print("update allowed? = ", ctm.update_allowed[1])
                print("update ticks = ", ctm.update_ticks[1])
                print("mouse x = ", ctm.mouse_x[1])
                print("mouse y = ", ctm.mouse_y[1])
                print("mouse prev x = ", ctm.mouse_prev_x[1])
                print("mouse prev y = ", ctm.mouse_prev_y[1])
                print("unit x = ", ctm.unit_x[1])
                print("unit y = ", ctm.unit_y[1])
            end
        end, "update_timer") end)
    end


    function ctm.sys:update_timer_ticks(n)
        if ctm.update_ticks[n] > 0 then
            ctm.update_ticks[n] = ctm.update_ticks[n] - 1
        else
            ctm.sys:allow_move_update(n)
        end
        if ctm.drag_ticks[n] > 0 then
            ctm.drag_ticks[n] = ctm.drag_ticks[n] - 1
        else
            ctm.sys:allow_drag_update(n)
        end
    end


    function ctm.sys:issue_movement_update(n, _x, _y)
        SetUnitFacingTimed(ctm.unit[n], anglexy(unitx(ctm.unit[n]), unity(ctm.unit[n]), _x or ctm.mouse_x[n], _y or ctm.mouse_y[n]), 0.0)
        issmovexy(ctm.unit[n], _x or ctm.mouse_x[n], _y or ctm.mouse_y[n])
    end


    function ctm.sys:get_current_mouse_xy(n)
        ctm.mouse_x[n], ctm.mouse_y[n] = BlzGetTriggerPlayerMouseX(), BlzGetTriggerPlayerMouseY()
        return ctm.mouse_x[n], ctm.mouse_y[n]
    end


    function ctm.sys:get_current_unit_xy(n)
        ctm.unit_x[n], ctm.unit_y[n] = unitxy(ctm.unit[n])
        return ctm.unit_x[n], ctm.unit_y[n]
    end


    function ctm.sys:get_dist_from_mouse_to_unit(n)
        return distxy(ctm.mouse_x[n], ctm.mouse_y[n], ctm.sys:get_current_unit_xy(n))
    end


    function ctm.sys:get_dist_from_prev_xy(n)
        return distxy(ctm.mouse_x[n], ctm.mouse_y[n], ctm.mouse_prevx, ctm.mouse_prevy)
    end


    function ctm.sys:get_angle_from_unit_to_mouse(n)
        ctm.unit_angle[n] = anglexy(unitx(ctm.unit[n]), unity(ctm.unit[n]), ctm.mouse_x[n], ctm.mouse_y[n])
        return ctm.unit_angle[n]
    end


    function ctm.sys:get_previous_mouse_xy(n)
        ctm.mouse_prev_x[n], ctm.mouse_prev_y[n] = ctm.mouse_x[n], ctm.mouse_y[n]
        return ctm.mouse_prev_x[n], ctm.mouse_prev_y[n]
    end


    function ctm.sys:cmod(a, n)
        return a - math.floor(a/n) * n
    end


    function ctm.sys:delta_angle(a1, a2)
        return math.abs(ctm.sys:cmod((a1 - a2) + 180, 360) - 180)
    end


    function ctm.sys:is_unit_eligible_for_quick_turn(n)
        -- check if within quick turn angle:
        if ctm.sys:delta_angle(ctm.sys:get_angle_from_unit_to_mouse(n), getface(ctm.unit[n])) > ctm.quick_turn_angle then
            -- check if a turn was recently submitted (prevents spamming move orders):
            if ctm.sys:delta_angle(ctm.mouse_prev_angle[n], ctm.unit_angle[n]) > 3. then
                ctm.mouse_prev_angle[n] = ctm.unit_angle[n]
                return true
            end
        end
        return false
    end


    function ctm.sys:is_mouse_held_in_same_xy(n)
        return (ctm.mouse_prev_x[n] == ctm.mouse_x[n] and ctm.mouse_prev_y[n] == ctm.mouse_y[n])
    end


    function ctm.sys:is_mouse_offset_pathable(n)
        -- prototype function, not in use
        ctm.calc_a = anglexy(unitx(ctm.unit[n]), unity(ctm.unit[n]), ctm.mouse_x[n], ctm.mouse_y[n])
        ctm.calc_x, ctm.calc_y = projectxy(unitx(ctm.unit[n]), unity(ctm.unit[n]), ctm.pathing_block_radius, ctm.calc_a)
        return not IsTerrainPathable(ctm.calc_x, ctm.calc_y, PATHING_TYPE_WALKABILITY)
    end


    function ctm.sys:is_mouse_within_exclusion_radius(n)
        return distxy(ctm.mouse_x[n], ctm.mouse_y[n], unitxy(ctm.unit[n])) < ctm.exclusion_radius
    end


    function ctm.sys:mouse_down(n)
        if ctm.enabled and ctm.sys:is_mouse_btn(1) then
            ctm.mouse_btn_is_down[n] = true
            ctm.sys:get_current_mouse_xy(n)
            ctm.sys:get_angle_from_unit_to_mouse(n)
            -- to prevent a fast click from triggering a false drag, temporarily pause updates:
            ctm.sys:pause_move_update(n, ctm.move_cmd_order_ticks)
        else
            ctm.mouse_btn_is_down[n] = false
        end
    end


    function ctm.sys:mouse_up(n)
        if ctm.sys:is_mouse_btn(1) then
            ctm.mouse_btn_is_down[n] = false
            if not ctm.stop_next_mouse_up[n] then
                if ctm.enabled and ctm.mouse_being_dragged[n] then
                    ctm.sys:get_current_mouse_xy(n)
                    ctm.sys:get_angle_from_unit_to_mouse(n)
                    ctm.sys:issue_movement_update(n)
                    ctm.sys:allow_move_update(n)
                end
                ctm.mouse_being_dragged[n] = false
            else
                ctm.stop_next_mouse_up[n] = false
            end
        end
    end


    function ctm.sys:mouse_drag(n)
        if ctm.enabled and ctm.mouse_btn_is_down[n] then
            ctm.sys:get_current_mouse_xy(n)
            ctm.sys:get_angle_from_unit_to_mouse(n)
        end
    end


    function ctm.sys:pause_move_update(n, _ticks)
        ctm.update_allowed[n] = false
        ctm.update_ticks[n] = _ticks or ctm.move_update_pause_ticks
    end


    function ctm.sys:pause_mouse_drag(n, _ticks)
        ctm.drag_allowed[n] = false
        ctm.drag_ticks[n] = _ticks or ctm.move_pause_drag_ticks
    end


    function ctm.sys:allow_move_update(n)
        ctm.update_allowed[n] = true
        ctm.update_ticks[n] = 0
    end


    function ctm.sys:allow_drag_update(n)
        ctm.drag_allowed[n] = true
        ctm.drag_ticks[n] = 0
    end


    function ctm.sys:is_mouse_btn(bit_is_right_btn)
        if bit_is_right_btn == 0 then
            return BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT
        elseif bit_is_right_btn == 1 then
            return BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT
        else
            print("error: is_mouse_btn 'bit_is_right_btn' should be 0 or 1")
        end
    end
end