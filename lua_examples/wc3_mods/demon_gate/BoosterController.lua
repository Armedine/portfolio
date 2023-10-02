---@class BoosterController
---Generates the army picker screen and controls rolls, unit availability, rarity types, etc.
BoosterController = {
    -- roll config:
    odds_common     = 0.30, --0.60,
    odds_uncommon   = 0.20, --0.30,
    odds_rare       = 0.20, --0.06,
    odds_epic       = 0.20, --0.03,
    odds_legendary  = 0.10, --0.01,
    roll_base_floor = 1,    -- minimum roll value
    roll_base_ceil  = 1000,  -- `` maximum.
    -- class:
    player = nil,           -- owner of this BoosterController.
    booster_regions = nil,  -- where selectable army units will appear.
    booster_rect = nil,     -- for player camera bounds.
    booster_camera = nil,   -- booster screen camera.
    chest_list = nil,       -- booster decoration.
    lever_list = nil,       -- lever for selecting units (when clicked).
    has_finished= false,    -- flag for if the active booster sequence is finished.
    has_clicked = false,    -- flag for the between timer effect of lever selection.
    units_placed = false,   -- are all booster units placed? (prevent early lever click)
    series_pool = nil,      -- booster draw table.
    camera_timer = nil,     -- individual timer for player's camera lock.
    drawn_army_units = nil, -- army_units occupying active draw slots.
    drawn_units = nil,      -- actual game units.
    drawn_effects = nil,    -- special effect halos.
    rarity_type_ids = { common=1, uncommon=2, rare=3, epic=4, legendary=5 },
    rarity_type_names = { [1] = "common", [2] = "uncommon", [3] = "rare", [4] = "epic", [5] = "legendary" },
    booster_cameras = nil,
    lever_unit_id = FourCC('h00C'),
    chest_unit_id = FourCC('h00D'),
}
BoosterController.__index = BoosterController


---Create a new BoosterController.
---@param p player -- owner of this booster pack controller.
---@param booster_regions table -- table of the 1-4 regions where booster options decorate.
---@param chest_list table -- `` chest unit decorators.
---@param lever_list table -- `` lever unit decorators.
---@return BoosterController
function BoosterController:new(p, booster_regions, chest_list, lever_list)
    local o = setmetatable({}, BoosterController)
    o.player = p
    o.booster_regions = booster_regions
    o.chest_list = chest_list
    o.lever_list = lever_list
    o.booster_camera = BoosterController.booster_cameras[GetConvertedPlayerId(p)]
    o.booster_rect = Rect(
        GetRectMinX(o.booster_regions[1]), GetRectMinY(o.booster_regions[1]),
        GetRectMaxX(o.booster_regions[4]), GetRectMaxY(o.booster_regions[4])
    )
    o.camera_timer = CreateTimer()
    -- draw results storage:
    o.drawn_units = {}
    o.drawn_army_units = {}
    o.drawn_effects = {}
    return o
end


function BoosterController:initialize_series()
    -- initialize draw table for this player's booster class:
    self.series_pool = {
        common      = { draw_size = 0, odds = self.odds_common, draw_pool = {} },
        uncommon    = { draw_size = 0, odds = self.odds_uncommon, draw_pool = {} },
        rare        = { draw_size = 0, odds = self.odds_rare, draw_pool = {} },
        epic        = { draw_size = 0, odds = self.odds_epic, draw_pool = {} },
        legendary   = { draw_size = 0, odds = self.odds_legendary, draw_pool = {} }
    }
    -- add eligible units:
    local faction_id = self:get_player_controller().faction_id
    if ArmyUnit.faction_stack[faction_id] then
        for _,army_unit in ipairs(ArmyUnit.faction_stack[faction_id]) do
            local series_t = self:get_rarity_series_table(army_unit.rarity_id)
            -- print("Added unit "..army_unit.unit_name.." with rarity_id "..tostring(army_unit.rarity_id))
            -- increment the stored size of the draw table:
            series_t.draw_size = #series_t + 1
            -- add the unit to the draw table:
            if army_unit.faction_id == faction_id then
                series_t.draw_pool[series_t.draw_size] = army_unit
            end
        end
    else
        print_error("Selected faction_id is not in the faction_stack table.")
    end
    -- print("Series initialized for faction_id", self:get_player_controller().faction_id)
    -- print("Results:")
    -- for rarity_name,t in pairs(self.series_pool) do
    --     print("Rarity "..rarity_name..":")
    --     if t.draw_pool[1] then
    --         for idx,army_unit in ipairs(t.draw_pool) do
    --             print(tostring(idx).." = "..army_unit.unit_name)
    --         end
    --     end
    -- end
end


---Get the rarity table under self.series_pool with rarity_id.
---@param rarity_id integer
---@return table
function BoosterController:get_rarity_series_table(rarity_id)
    return self.series_pool[self:get_rarity_name(rarity_id)]
end


---Returns a 100-based odds number for a rarity_id.
---@param rarity_id integer
---@return integer
function BoosterController:get_odds(rarity_id)
    return self:get_rarity_series_table(rarity_id).odds*self.roll_base_ceil
end



function BoosterController:get_rarity_name(rarity_id)
    return self.rarity_type_names[rarity_id]
end


function BoosterController:get_slot_xy(draw_id)
    return GetRectCenterX(self.booster_regions[draw_id]), GetRectCenterY(self.booster_regions[draw_id])
end


function BoosterController:set_effect_color_by_rarity(e, rarity_id)
    AllCurrentLocalPlayers(function(p)
        if rarity_id == 1 then
            BlzSetSpecialEffectColor(e, 255, 255, 255)
        elseif rarity_id == 2 then
            BlzSetSpecialEffectColor(e, 50, 50, 255)
        elseif rarity_id == 3 then
            BlzSetSpecialEffectColor(e, 50, 255, 255)
        elseif rarity_id == 4 then
            BlzSetSpecialEffectColor(e, 255, 50, 255)
        elseif rarity_id == 5 then
            BlzSetSpecialEffectColor(e, 255, 50, 50)
        end
        BlzSetSpecialEffectZ(e, BlzGetLocalSpecialEffectZ(e) - 24) -- effect has a float effect by default.
        if BlzGetSpecialEffectScale(e) ~= 1.5 then
            BlzSetSpecialEffectScale(e, 1.5)
        end
    end)
end


function BoosterController:get_player_controller()
    return PlayerController:get_player(self.player)
end


---Increase the odds to roll a certain rarity type.
---@param rarity_id integer -- id to target.
---@param amount number -- 1.0-based value (e.g. 0.1 for 10% bonus odds).
function BoosterController:adjust_odds(rarity_id, amount)
    self:get_rarity_series_table(rarity_id).odds = self:get_rarity_series_table(rarity_id).odds + amount
end


function BoosterController:remove_placeholder_unit(draw_id)
    if self.drawn_units[draw_id] then
        for _,u in ipairs(self.drawn_units[draw_id]) do
            if u then
                RemoveUnit(u)
            end
        end
        self.drawn_units[draw_id] = nil
    end
end


function BoosterController:draw(draw_id)
    local random_roll
    for rarity_id = 5,1,-1 do
        random_roll = math.random(self.roll_base_floor, self.roll_base_ceil)
        -- results calculate in reverse, remainder is common:
        if rarity_id == 1 or random_roll <= self:get_odds(rarity_id) then
            self:draw_army_unit(draw_id, rarity_id)
            break
        end
    end
end


---Create the unit representation of a drawn army unit in the corresponding draw slot.
---@param draw_id integer
---@param rarity_id integer
function BoosterController:draw_army_unit(draw_id, rarity_id)
    -- see if a unit exists:
    if self:get_rarity_series_table(rarity_id).draw_pool[1] then
        -- if any previous units exist, remove them:
        if self.drawn_units[draw_id] then
            self:remove_placeholder_unit(draw_id)
        end
        -- draw a random army unit:
        local random_index = math.random(1,#self:get_rarity_series_table(rarity_id).draw_pool)
        local x, y = self:get_slot_xy(draw_id)
        -- create and initialize unit representation:
        self.drawn_army_units[draw_id] = self:get_rarity_series_table(rarity_id).draw_pool[random_index]
        self.drawn_units[draw_id] = {}
        for u_index = 1,self.drawn_army_units[draw_id].squad_size do
            self.drawn_units[draw_id][u_index] = CreateUnit(self.player, self.drawn_army_units[draw_id].unit_id, x, y, 270.)
            FadeUnitHide(self.drawn_units[draw_id][u_index], false, 0.75)
            SetUnitUseFood(self.drawn_units[draw_id][u_index], false)
            self:get_player_controller():set_faction_color(self.drawn_units[draw_id][u_index])
        end
        -- to allow proper unit stacking, apply locust and pause after:
        for u_index = 1,self.drawn_army_units[draw_id].squad_size do
            UnitAddAbility(self.drawn_units[draw_id][u_index], locust_id)
            PauseUnit(self.drawn_units[draw_id][u_index], true)
        end
        -- run effects:
        NewEffect["shining_flare"]:play(self:get_slot_xy(draw_id))
        self.drawn_effects[draw_id] = NewEffect["spell_marker_gray"]:play_persist(self:get_slot_xy(draw_id))
        self:set_effect_color_by_rarity(self.drawn_effects[draw_id], rarity_id)
    else
        print("Rolled rarity_id "..tostring(rarity_id).." for draw_id "..tostring(draw_id).." but no ArmyUnits are in the table yet.")
    end
end


function BoosterController:run_booster_select_screen()
    -- TODO: add has_picked_hero check here after dev testing.
    self.has_finished= false
    self.has_clicked = false
    self.units_placed = false
    self.stored_camera = GetCurrentCameraSetup()
    -- initialize camera:
    self:get_player_controller():set_camera_bounds_to_booster()
    TimerStart(self.camera_timer, 0.03, true, function()
        if self.has_finished then
            PauseTimer(self.camera_timer)
            self:get_player_controller():set_camera_bounds_to_arena()
            self:get_player_controller():pan_to_demon_gate()
            CameraSetupApplyForPlayer(true, self.stored_camera, self.player, 0)
            self.stored_camera = nil
        else
            CameraSetupApplyForPlayer(true, self.booster_camera, self.player, 0)
        end
    end)
    self:create_pack()
end


function BoosterController:initialize_eyecandy_unit(u, starting_alpha)
    ShowUnitShow(u)
    ResetUnitAnimation(u)
    SetUnitVertexColor(u, 255, 255, 255, starting_alpha)
end


function BoosterController:initialize_booster_screen()
    -- initialize eyecandy:
    for draw_id = 1,4 do
        self:initialize_eyecandy_unit(self.lever_list[draw_id], 0)
        self:initialize_eyecandy_unit(self.chest_list[draw_id], 255)
    end
end


function BoosterController:create_pack()
    self:initialize_booster_screen()
    -- lever index: 4=stand, 0=morph
    -- chest index: 0=stand, 2=alternate
    if self:get_player_controller().has_picked_hero then
        for draw_id = 1,4 do
            TimerQueue:call_delayed(draw_id*0.19, function()
                math.randomseed(GameController.randomseed_val)
                -- eyecandy:
                SetUnitAnimationByIndex(self.chest_list[draw_id], 2)
                FadeUnitHide(self.lever_list[draw_id], false, 0.75)
                FadeUnitHide(self.chest_list[draw_id], true, 0.75)
                -- draw a unit:
                self:draw(draw_id)
                if draw_id == 4 then
                    self.units_placed = true
                end
            end)
        end
    end
end


---Create the selected widget for the player based on the lever clicked (1-4).
---@param picked_draw_id integer
function BoosterController:select_option(picked_draw_id)
    local pick_effect = NewEffect["teleport_void_portal"]:play_persist(self:get_slot_xy(picked_draw_id))
    for draw_id = 1,4 do
        if draw_id ~= picked_draw_id then
            self:remove_placeholder_unit(draw_id)
            GameEffect:destroy(self.drawn_effects[draw_id])
            NewEffect["dark_ritual"]:play(self:get_slot_xy(draw_id))
        end
    end
    TimerQueue:call_delayed(1.33, function()
        self.has_finished= true
        self:add_to_army_roster(picked_draw_id)
        self:remove_placeholder_unit(picked_draw_id)
        GameEffect:destroy(self.drawn_effects[picked_draw_id])
        GameEffect:destroy(pick_effect)
        self:initialize_booster_screen()
    end)
end


---Add a selected option to a player's army.
---@param draw_id integer
function BoosterController:add_to_army_roster(draw_id)
    if self.drawn_army_units[draw_id] then
        self.drawn_army_units[draw_id]:place_squad(self.player, 0, 1500., NewEffect["teleport_void"])
    else
        print_error("self.drawn_army_units[draw_id] was empty.")
    end
end


function BoosterController:create_select_trigger()
    self:initialize_booster_screen()
    -- booster pack options:
    self.trig = TriggerHelper:new("unit", "selected", self.player, function()
        if GetTriggerUnitPlayer() == self.player and not self.has_clicked and not self.has_finished then
            if self.units_placed and GetTriggerUnitTypeId() == self.lever_unit_id then
                for draw_id = 1,4 do
                    if self.lever_list[draw_id] == GetTriggerUnit() then
                        self.has_clicked = true
                        -- effects:
                        NewEffect["missile_ballista"]:play_at_unit(self.lever_list[draw_id])
                        SetUnitAnimationByIndex(self.lever_list[draw_id], 0)
                        -- initiate unit selection:
                        self:select_option(draw_id)
                        break
                    end
                end
            end
        end
    end)
end
