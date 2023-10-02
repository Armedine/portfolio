do
    ---@class FactionController
    FactionController = {factions={}, faction_id=nil, faction_name=nil, hero_list=nil, faction_selector_unit_id=nil, faction_color_pid=nil }
    FactionController.__index = FactionController


    ---Create a new faction that players can use.
    ---@param faction_id integer -- sequential integer id.
    ---@param faction_selector_unit_id string -- the selling structure for faction placeholders.
    ---@param faction_name string -- name.
    ---@param faction_color_pid integer -- converted player id to get faction color.
    ---@param hero_list table<ArmyHero> -- table of ArmyHeroes this faction can choose from.
    ---@return table
    function FactionController:new(faction_id, faction_selector_unit_id, faction_name, faction_color_pid, hero_list)
        local o = setmetatable({
            faction_id = faction_id,
            faction_name = faction_name,
            hero_list = hero_list,
            faction_selector_unit_id = FourCC(faction_selector_unit_id),
            faction_color = GetPlayerColor(Player(faction_color_pid-1))
        }, self)
        self.factions[faction_id] = o
        return o
    end


    function FactionController:add_selectable_heroes(to_building_unit)
        -- heroes:
        for _,hero in ipairs(self.hero_list) do
            AddUnitToStockBJ(hero.unit_id, to_building_unit, 1, 1)
        end
        -- go back button:
        AddUnitToStockBJ(FourCC("h00E"), to_building_unit, 1, 1)
        return self
    end


    function FactionController:show_faction_pickers(show_bool)
        for index,_ in pairs(PlayerController.player_table) do
            if not PlayerController.player_table[index].has_picked_hero then
                ShowUnit(udg_faction_picker[index+1], show_bool)
            end
        end
    end
end


TimerQueue:call_delayed(0.03, function()
    Try(function()
        for i=0,3 do
            -- select starting faction picker or remove it:
            if not DetectPlayers.player_user_table[i] then
                RemoveUnit(udg_faction_picker[i+1])
            end
            -- create faction select triggers:
            TriggerHelper:new("unit", "sell", Player(i), function()
                Try(function()
                    -- go back button:
                    if GetSoldUnitTypeId() == FourCC("h00E") then
                        local p = GetOwningPlayer(GetSoldUnit())
                        local pnum, x, y = GetConvertedPlayerId(p), GetTriggerUnitXY()
                        RemoveUnit(udg_faction_picker[pnum])
                        RemoveUnit(GetSoldUnit())
                        udg_faction_picker[pnum] = CreateUnit(p, FourCC("h008"), x, y, 270.0)
                        SelectUnitForPlayerSingle(udg_faction_picker[pnum], p)
                        return
                    end
                    -- faction selection:
                    if GetTriggerUnitTypeId() == FourCC("h008") then
                        local p, sold_unit_id = GetOwningPlayer(GetSoldUnit()), GetSoldUnitTypeId()
                        local pnum, x, y = GetConvertedPlayerId(p), GetTriggerUnitXY()
                        RemoveTriggerUnit()
                        RemoveSoldUnit()
                        -- create hero selection:
                        udg_faction_picker[pnum] = CreateUnit(p, FourCC("h009"), x, y, 270.0)
                        SelectUnitForPlayerSingle(udg_faction_picker[pnum], p)
                        for _,faction in ipairs(FactionController.factions) do
                            if faction.faction_selector_unit_id == sold_unit_id then
                                faction:add_selectable_heroes(udg_faction_picker[pnum])
                                PlayerController:get_player(p).faction = faction
                                PlayerController:get_player(p).faction_id = faction.faction_id
                                -- hero selection:
                                TriggerHelper:new("unit", "sell", GetOwningPlayer(GetSoldUnit()), function()
                                    ArmyHero:initialize_for_player(GetOwningPlayer(GetSoldUnit()), GetSoldUnit())
                                    PlayerController:get_player(p).booster_controller:initialize_series()
                                end)
                            end
                        end
                    end
                end)
            end)
        end
    end)
end)
