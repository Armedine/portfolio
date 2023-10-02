OnGameStart(function()
    local function get_dev_player()
        return PlayerController:get_player(Player(0))
    end
    dev_command_table = {
        ["wr"] = function()
            GameController.rounds_completed = GameController:get_total_rounds()
            print(tostring(GameController.rounds_completed/GameController:get_total_rounds()))
        end,
        ["lose"] = function()
            GameObjective:modify_lives(-100)
        end,
        ["win"] = function()
            GameObjective:end_game(true)
        end,
        ["super"] = function()
            SetHeroLevel(get_dev_player().hero, 20, false)
            for _ = 1,6 do UnitAddItemById(get_dev_player().hero, FourCC('I001')) end
        end,
        ["b"] = function()
            get_dev_player().booster_controller:run_booster_select_screen()
        end,
        ["pick"] = function ()
            get_dev_player().booster_controller.has_finished = true
        end,
        ["pack"] = function ()
            get_dev_player().booster_controller:create_pack()
        end,
        ["res"] = function ()
            get_dev_player().army_controller:revive_all_units(NewEffect["resurrect"])
            if not IsUnitAlive(get_dev_player().hero) then
                ReviveHero(get_dev_player().hero, 0, 1500, true)
            else
                NewEffect["resurrect_caster"]:play_at_unit(get_dev_player().hero)
            end
        end,
        ["heal"] = function ()
            get_dev_player().army_controller:heal_all_units(0.1, NewEffect["holy_light"])
        end,
        ["kill"] = function ()
            UnitGroup:all_player_units(GameController.demon_player, function(u)
                KillUnit(u)
            end)
        end,
    }
    local dev_trig = CreateTrigger()
    TriggerRegisterPlayerChatEvent(dev_trig, Player(0), "-", false)
    TriggerAddAction(dev_trig, function()
        Try(function()
            dev_last_command = string.sub(GetEventPlayerChatString(),2)
            if dev_command_table[dev_last_command] then
                dev_command_table[dev_last_command]()
                print("Dev command '"..dev_last_command.."' SUCCESS!")
            else
                print("Dev command '"..dev_last_command.."' is not valid.")
            end
        end)
    end)
end)
