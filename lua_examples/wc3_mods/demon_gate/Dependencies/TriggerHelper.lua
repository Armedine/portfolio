do
    ---@class TriggerHelper
    ---@diagnostic disable: undefined-doc-param
    -- TriggerHelper by Planetary @ hiveworkshop.com
    -- Assists with code readability and easement of trigger design process.
    -- Last updated: 28 Dec 2022
    -- Requirements:
    --      DetectPlayers
    TriggerHelper = {
        debug = false,
        trig = nil,         -- trigger attached to new trigger objects.
        actions = nil,      -- `` actions.
        stack_count = 0,    -- for GC.
        stack = {},
        event_type = {
            player = {
                event_def = {
                    trigger_register_event = function(...) return TriggerRegisterPlayerEvent(...) end,
                    trigger_register_args = {"player", "event_sub_type"},
                },
                state_limit = EVENT_PLAYER_STATE_LIMIT,
                alliance_changed = EVENT_PLAYER_ALLIANCE_CHANGED,
                defeat = EVENT_PLAYER_DEFEAT,
                victory = EVENT_PLAYER_VICTORY,
                leave = EVENT_PLAYER_LEAVE,
                chat = EVENT_PLAYER_CHAT,
                end_cinematic = EVENT_PLAYER_END_CINEMATIC,
                arrow_left_down = EVENT_PLAYER_ARROW_LEFT_DOWN,
                arrow_left_up = EVENT_PLAYER_ARROW_LEFT_UP,
                arrow_right_down = EVENT_PLAYER_ARROW_RIGHT_DOWN,
                arrow_right_up = EVENT_PLAYER_ARROW_RIGHT_UP,
                arrow_down_down = EVENT_PLAYER_ARROW_DOWN_DOWN,
                arrow_down_up = EVENT_PLAYER_ARROW_DOWN_UP,
                arrow_up_down = EVENT_PLAYER_ARROW_UP_DOWN,
                arrow_up_up = EVENT_PLAYER_ARROW_UP_UP,
                mouse_down = EVENT_PLAYER_MOUSE_DOWN,
                mouse_up = EVENT_PLAYER_MOUSE_UP,
                mouse_move = EVENT_PLAYER_MOUSE_MOVE,
                sync_data = EVENT_PLAYER_SYNC_DATA,
                key = EVENT_PLAYER_KEY,
                key_down = EVENT_PLAYER_KEY_DOWN,
                key_up = EVENT_PLAYER_KEY_UP
            },
            unit = {
                event_def = {
                    trigger_register_event = function(...) return TriggerRegisterPlayerUnitEvent(...) end,
                    trigger_register_args = {"player", "event_sub_type"},
                },
                sell = EVENT_PLAYER_UNIT_SELL,
                change_owner = EVENT_PLAYER_UNIT_CHANGE_OWNER,
                sell_item = EVENT_PLAYER_UNIT_SELL_ITEM,
                channel = EVENT_PLAYER_UNIT_SPELL_CHANNEL,
                spell_cast = EVENT_PLAYER_UNIT_SPELL_CAST,
                spell_effect = EVENT_PLAYER_UNIT_SPELL_EFFECT,
                spell_finish = EVENT_PLAYER_UNIT_SPELL_FINISH,
                spell_endcast = EVENT_PLAYER_UNIT_SPELL_ENDCAST,
                pawn_item = EVENT_PLAYER_UNIT_PAWN_ITEM,
                stack_item = EVENT_PLAYER_UNIT_STACK_ITEM,
                attacked = EVENT_PLAYER_UNIT_ATTACKED,
                rescued = EVENT_PLAYER_UNIT_RESCUED,
                death = EVENT_PLAYER_UNIT_DEATH,
                decay = EVENT_PLAYER_UNIT_DECAY,
                detected = EVENT_PLAYER_UNIT_DETECTED,
                hidden = EVENT_PLAYER_UNIT_HIDDEN,
                selected = EVENT_PLAYER_UNIT_SELECTED,
                deselected = EVENT_PLAYER_UNIT_DESELECTED,
                construct_start = EVENT_PLAYER_UNIT_CONSTRUCT_START,
                construct_cancel = EVENT_PLAYER_UNIT_CONSTRUCT_CANCEL,
                construct_finish = EVENT_PLAYER_UNIT_CONSTRUCT_FINISH,
                upgrade_start = EVENT_PLAYER_UNIT_UPGRADE_START,
                upgrade_cancel = EVENT_PLAYER_UNIT_UPGRADE_CANCEL,
                upgrade_finish = EVENT_PLAYER_UNIT_UPGRADE_FINISH,
                train_start = EVENT_PLAYER_UNIT_TRAIN_START,
                train_cancel = EVENT_PLAYER_UNIT_TRAIN_CANCEL,
                train_finish = EVENT_PLAYER_UNIT_TRAIN_FINISH,
                research_start = EVENT_PLAYER_UNIT_RESEARCH_START,
                research_cancel = EVENT_PLAYER_UNIT_RESEARCH_CANCEL,
                research_finish = EVENT_PLAYER_UNIT_RESEARCH_FINISH,
                issued_order = EVENT_PLAYER_UNIT_ISSUED_ORDER,
                issued_point_order = EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER,
                issued_target_order = EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER,
                issued_unit_order = EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER,
                level = EVENT_PLAYER_HERO_LEVEL,
                skill = EVENT_PLAYER_HERO_SKILL,
                revivable = EVENT_PLAYER_HERO_REVIVABLE,
                revive_start = EVENT_PLAYER_HERO_REVIVE_START,
                revive_cancel = EVENT_PLAYER_HERO_REVIVE_CANCEL,
                revive_finish = EVENT_PLAYER_HERO_REVIVE_FINISH,
                summon = EVENT_PLAYER_UNIT_SUMMON,
                drop_item = EVENT_PLAYER_UNIT_DROP_ITEM,
                pickup_item = EVENT_PLAYER_UNIT_PICKUP_ITEM,
                use_item = EVENT_PLAYER_UNIT_USE_ITEM,
                loaded = EVENT_PLAYER_UNIT_LOADED,
                damaged = EVENT_PLAYER_UNIT_DAMAGED,
                damaging = EVENT_PLAYER_UNIT_DAMAGING
            },
            any_unit = {
                event_def = {
                    trigger_register_event = function(...) return TriggerRegisterAnyUnitEventBJ(...) end,
                    trigger_register_args = {"event_sub_type"},
                },
                sell = EVENT_PLAYER_UNIT_SELL,
                change_owner = EVENT_PLAYER_UNIT_CHANGE_OWNER,
                sell_item = EVENT_PLAYER_UNIT_SELL_ITEM,
                channel = EVENT_PLAYER_UNIT_SPELL_CHANNEL,
                spell_cast = EVENT_PLAYER_UNIT_SPELL_CAST,
                spell_effect = EVENT_PLAYER_UNIT_SPELL_EFFECT,
                spell_finish = EVENT_PLAYER_UNIT_SPELL_FINISH,
                spell_endcast = EVENT_PLAYER_UNIT_SPELL_ENDCAST,
                pawn_item = EVENT_PLAYER_UNIT_PAWN_ITEM,
                stack_item = EVENT_PLAYER_UNIT_STACK_ITEM,
                damaged = EVENT_UNIT_DAMAGED,
                damaging = EVENT_UNIT_DAMAGING,
                death = EVENT_UNIT_DEATH,
                decay = EVENT_UNIT_DECAY,
                detected = EVENT_UNIT_DETECTED,
                hidden = EVENT_UNIT_HIDDEN,
                selected = EVENT_UNIT_SELECTED,
                deselected = EVENT_UNIT_DESELECTED,
                state_limit = EVENT_UNIT_STATE_LIMIT,
                acquired_target = EVENT_UNIT_ACQUIRED_TARGET,
                target_in_range = EVENT_UNIT_TARGET_IN_RANGE,
                attacked = EVENT_UNIT_ATTACKED,
                rescued = EVENT_UNIT_RESCUED,
                construct_cancel = EVENT_UNIT_CONSTRUCT_CANCEL,
                construct_finish = EVENT_UNIT_CONSTRUCT_FINISH,
                upgrade_start = EVENT_UNIT_UPGRADE_START,
                upgrade_cancel = EVENT_UNIT_UPGRADE_CANCEL,
                upgrade_finish = EVENT_UNIT_UPGRADE_FINISH,
                train_start = EVENT_UNIT_TRAIN_START,
                train_cancel = EVENT_UNIT_TRAIN_CANCEL,
                train_finish = EVENT_UNIT_TRAIN_FINISH,
                research_start = EVENT_UNIT_RESEARCH_START,
                research_cancel = EVENT_UNIT_RESEARCH_CANCEL,
                research_finish = EVENT_UNIT_RESEARCH_FINISH,
                issued_order = EVENT_UNIT_ISSUED_ORDER,
                issued_point_order = EVENT_UNIT_ISSUED_POINT_ORDER,
                issued_target_order = EVENT_UNIT_ISSUED_TARGET_ORDER,
                hero_level = EVENT_UNIT_HERO_LEVEL,
                hero_skill = EVENT_UNIT_HERO_SKILL,
                hero_revivable = EVENT_UNIT_HERO_REVIVABLE,
                hero_revive_start = EVENT_UNIT_HERO_REVIVE_START,
                hero_revive_cancel = EVENT_UNIT_HERO_REVIVE_CANCEL,
                hero_revive_finish = EVENT_UNIT_HERO_REVIVE_FINISH,
                summon = EVENT_UNIT_SUMMON,
                drop_item = EVENT_UNIT_DROP_ITEM,
                pickup_item = EVENT_UNIT_PICKUP_ITEM,
                use_item = EVENT_UNIT_USE_ITEM,
                loaded = EVENT_UNIT_LOADED
            },
            widget = {
                event_def = {
                    trigger_register_event = function(...) return TriggerRegisterDeathEvent(...) end,
                    trigger_register_args = {"widget"},
                },
                death = EVENT_WIDGET_DEATH
            },
            dialog = {
                event_def = {
                    trigger_register_event = function(...) return TriggerRegisterDialogEvent(...) end,
                    trigger_register_args = {"dialog"},
                },
                button_click = EVENT_DIALOG_BUTTON_CLICK,
                click = EVENT_DIALOG_CLICK
            },
            game_state = {
                event_def = {
                    trigger_register_event = function(...) return TriggerRegisterGameEvent(...) end,
                    trigger_register_args = {"event_sub_type"},
                },
                victory = EVENT_GAME_VICTORY,
                end_level = EVENT_GAME_END_LEVEL,
                variable_limit = EVENT_GAME_VARIABLE_LIMIT,
                state_limit = EVENT_GAME_STATE_LIMIT,
                timer_expired = EVENT_GAME_TIMER_EXPIRED,
                enter_region = EVENT_GAME_ENTER_REGION, -- these are bugged for some reason.
                leave_region = EVENT_GAME_LEAVE_REGION, -- these are bugged for some reason.
                trackable_hit = EVENT_GAME_TRACKABLE_HIT,
                trackable_track = EVENT_GAME_TRACKABLE_TRACK,
                show_skill = EVENT_GAME_SHOW_SKILL,
                build_submenu = EVENT_GAME_BUILD_SUBMENU,
                loaded = EVENT_GAME_LOADED,
                tournament_finish_soon = EVENT_GAME_TOURNAMENT_FINISH_SOON,
                tournament_finish_now = EVENT_GAME_TOURNAMENT_FINISH_NOW,
                save = EVENT_GAME_SAVE,
                custom_ui_frame = EVENT_GAME_CUSTOM_UI_FRAME
            },
            enter_rect = {
                event_def = {
                    trigger_register_event = function(...) return TriggerRegisterEnterRectSimple(...) end,
                    trigger_register_args = {"rect"},
                },
                any = "",
            },
            leave_rect = {
                event_def = {
                    trigger_register_event = function(...) return TriggerRegisterLeaveRectSimple(...) end,
                    trigger_register_args = {"rect"},
                },
                any = "",
            },
        }
    }
    TriggerHelper.__index = TriggerHelper

    --[[--------------------------------------------------------------------------------------
        Name: TriggerHelper:new
        Args: event_type, event_name[, action, trigger, player, unit, widget, for_all_players, limitop, real]
        Desc: Simplifies trigger events to allow the creation of any trigger type with unordered arguments.
    ----------------------------------------------------------------------------------------]]
    ---@param event_type string         -- player_event e.g. player_chat, widget_death, unit_state, unit_event, unit_range
    ---@param event_name string         -- the event sub-type (i.e. the trigger event using the primary event type).
    ---@param action? function          -- attach this action.
    ---@param trigger? trigger          -- use this trigger instead of a new one.
    ---@param player? player            -- for this player only.
    ---@param unit? unit                -- for this unit if event_type is unit.
    ---@param widget? widget            -- for this widget if event_type is widget.
    ---@param dialog? dialog            -- for this dialog if event_type is dialog.
    ---@param all_players? boolean      -- for any player?
    ---@param limitop? limitop          -- comparison using a limitop?
    ---@param real? number              -- comparison using a real?
    ---@return TriggerHelper
    function TriggerHelper:new(event_type, event_name, ...)
        local o = setmetatable({event_type_string = event_type, event_name_string = event_name, actions = {}}, self)
        local args = SyncedTable.create({...})
        local f, t, u, w, b, d, p, l, r, re, rc = nil, nil, nil, nil, false, nil, nil, nil, nil, nil, nil
        -- fetch unordered arguments:
        if args then
            for _,v in pairs(args) do
                if         Wc3Type(v) == "function" or type(v) == "function" then f = v
                    elseif Wc3Type(v) == "number" or type(v) == "real" then r = v
                    elseif Wc3Type(v) == "rect"     then rc = v
                    elseif Wc3Type(v) == "region"   then re = v
                    elseif Wc3Type(v) == "trigger"  then t = v
                    elseif Wc3Type(v) == "unit"     then u = v
                    elseif Wc3Type(v) == "widget"   then w = v
                    elseif Wc3Type(v) == "boolean"  then b = v
                    elseif Wc3Type(v) == "dialog"   then d = v
                    elseif Wc3Type(v) == "player"   then p = v
                    elseif Wc3Type(v) == "limitop"  then l = v
                end
            end
        end
        -- check if the trigger type and sub-type are supported:
        if self.event_type[event_type] == nil then
            print_error("'event_type' not found in TriggerHelper list of eligible event types.")
        elseif self.event_type[event_type] and self.event_type[event_type][event_name] == nil then
            print_error("'event_name' not found in TriggerHelper list of eligible event names.")
        end
        -- register the trigger's source event and action:
        if not t then
            o.trig = CreateTrigger()
        else
            o.trig = t
        end
        o:assign_event(event_type, event_name, b, p, u, w, d, l, r, re, rc)
        o:assign_action(f)
        args = nil
        self.stack_count = self.stack_count + 1
        self.id = self.stack_count
        self.stack[self.id] = o
        return o
    end


    function TriggerHelper:destroy()
        if self.trig then
            DestroyTrigger(self.trig)
        end
        if self.actions then
            self.actions = nil
        end
        self.stack[self.id] = nil
    end


    --[[--------------------------------------------------------------------------------------
        Name: TriggerHelper:assign_event
        Args: event_type, event_name, all_players[, unit, widget, dialog, player, limitop, real]
        Desc: 
    ----------------------------------------------------------------------------------------]]
    ---@param event_type string
    ---@param event_name string
    ---@param all_players boolean
    ---@param ... any
    ---@return TriggerHelper
    function TriggerHelper:assign_event(event_type, event_name, all_players, ...)
        local args, ordered_args, ordered_player_index = SyncedTable.create({...}), {}, nil
        if self.debug then
            print("-- TriggerHelper:"..event_type, "||", event_name, "|| all_players =", all_players)
            print_table(args)
        end
        local event_sub_type = self.event_type[event_type][event_name]
        for ordered_arg_index,ordered_arg_type in ipairs(self.event_type[event_type]["event_def"]["trigger_register_args"]) do
            if self.debug then
                print("=try: "..ordered_arg_type.." at position "..ordered_arg_index)
            end
            if ordered_arg_type == "event_sub_type" then
                -- check if the sub type should be fetched from the main table:
                ordered_args[ordered_arg_index] = event_sub_type
                if self.debug then print("->found matching sub type: ", ordered_arg_type) end
            elseif args then
                for __,arg in pairs(args) do
                    if Wc3Type(arg) == ordered_arg_type then
                        -- if not, assign any matching arg:
                        ordered_args[ordered_arg_index] = arg
                        if self.debug then print("->found matching arg: ", ordered_arg_type) end
                        -- if we should add this event for each player, store where we override the player value:
                        if all_players and ordered_arg_type == "player" then
                            ordered_player_index = ordered_arg_index
                        end
                    end
                end
            end
        end
        if self.debug then print("=try to assign arguments for trigger: "..tostring(self.trig)) print_table(ordered_args, true) end
        if not all_players or not ordered_player_index then
            -- assign an event for the target player:
            self.event_type[event_type]["event_def"]["trigger_register_event"](self.trig, table.unpack(ordered_args))
        elseif all_players and ordered_player_index then
            -- assign an event for each eligible player:
            for _,present_player in pairs(DetectPlayers.player_user_table) do
                ordered_args[ordered_player_index] = present_player
                self.event_type[event_type]["event_def"]["trigger_register_event"](self.trig, table.unpack(ordered_args))
            end
        else
            print_error("Failed to set up 'TriggerHelper:assign_event', 'ordered_player_index' was nil.")
        end
        args, ordered_args = nil, nil
        return self
    end


    ---Add a function to a trigger event.
    ---@param action function -- function to run.
    ---@param _action_name? string -- lets you look up this specific function through self.actions[_action_name].
    ---@return TriggerHelper
    function TriggerHelper:assign_action(action, _action_name)
        if self.debug then print("=assigned action: "..(_action_name or "<name not provided>")) end
        if action then
            if _action_name then
                self.actions[_action_name] = {}
            end
            if self.trig and not self.actions[_action_name] then
                if _action_name then
                    self.actions[_action_name] = TriggerAddAction(self.trig, function() Try(action) end)
                else
                    self.actions[#self.actions+1] = TriggerAddAction(self.trig, function() Try(action) end)
                end
            else
                print_error("Attempted to assign an action but there was no trigger.")
            end
        end
        return self
    end


    ---Set a trigger to destroy when triggered (one-time event).
    ---@return TriggerHelper
    function TriggerHelper:is_temporary()
        TriggerAddAction(self.trig, function() self:destroy() end)
        return self
    end
end
