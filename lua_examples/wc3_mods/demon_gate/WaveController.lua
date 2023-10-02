---@class WaveController
---WaveController is responsible for the properties, type, count, and cadence of enemy units entering the arena.
WaveController = {
    -- round influencers:
    total_waves_active = 0,                 -- dynamic value for round conditions.
    total_waves_complete = 0,               -- ``.
    -- wave properties:
    army_power = 3,                         -- determines how strong the wave is, and limits the number of each unit type based on their assigned power.
    has_commander = false,                  -- determines if the wave is eligible for commander rounds.
    multiplier_health = 1.0,                -- scales units spawned.
    multiplier_damage = 1.0,                -- ``
    -- spawn properties:
    previous_spawn_region_id = nil,         -- where enemies were last spawned at.
    current_spawn_region_id = 1,            -- `` currently spawning.
    current_spawn_region = nil,             -- 
    next_spawn_region_id = 1,               -- `` next spawn point.
    -- cluster spawning:
    spawn_as_cluster = false,               -- if the units should be randomly placed in a region, or spawn clustered around a point.
    spawn_as_cluster_distance = 600.0,      -- `` the default radius.
    -- spawn over time:
    spawn_units_over_time = true,           -- if clustering should be ignored, add X units every Y seconds.
    spawn_units_over_time_cadence = 0.25,   -- `` how fast to spawn.
    -- other:
    enemy_groups = nil,                     -- (table) what types of EnemyUnits can spawn.
    catalog = {}
}
WaveController.__index = WaveController
OnGlobalInit(function() WaveController.region_table = { gg_rct_WaveSpawnPosition1, gg_rct_WaveSpawnPosition2, gg_rct_WaveSpawnPosition3, gg_rct_WaveSpawnPosition4 } end)


---Create a new wave that the RoundController can deploy during a round.
---@param army_power integer -- determines ratio of units to unit types selected.
---@param enemy_groups table<EnemyGroup> -- determines what units will spawn for this wave.
---@return WaveController
function WaveController:new(army_power, multiplier_health, multiplier_damage, enemy_groups)
    local o = setmetatable({}, self)
    o.enemy_groups = enemy_groups
    o.army_power = math.floor(army_power)
    o.units_table = {}
    o.units_alive = 0
    o.multiplier_health = multiplier_health
    o.multiplier_damage = multiplier_damage
    WaveController.catalog[#WaveController.catalog+1] = o
    return o
end


---Cycles through each of the 4 region to spawn units into.
function WaveController:set_spawn_point()
    -- use the global class setting not self values.
    if not WaveController.region_table[WaveController.next_spawn_region_id] then
        WaveController.next_spawn_region_id = 2
        WaveController.current_spawn_region_id = 1
    else
        WaveController.current_spawn_region_id = WaveController.next_spawn_region_id
        WaveController.next_spawn_region_id = WaveController.next_spawn_region_id + 1
    end
    -- print("WaveController.next_spawn_region_id", WaveController.next_spawn_region_id)
    -- print("WaveController.current_spawn_region_id", WaveController.current_spawn_region_id)
    WaveController.current_spawn_x = GetRectCenterX(WaveController.region_table[WaveController.current_spawn_region_id])
    WaveController.current_spawn_y = GetRectCenterY(WaveController.region_table[WaveController.current_spawn_region_id])
end


---Sets the wave army strength based on the # of players present.
function WaveController:get_players_present_scaling()
    return self.army_power*GameController:get_setting("players_present_enemy_count_scaling")
end


---Starts sending units to the Demon Gate as defined by this wave type.
---@return WaveController
function WaveController:start_wave()
    -- initialize wave settings:
    self:set_spawn_point()
    -- create units:
    self:spawn_units(ProjectXY(self.current_spawn_x, self.current_spawn_y, math.random(1,300), math.random(1,360)))
    return self
end


---Create units for this wave.
---@param x number -- coordinate where spawn will take place.
---@param y number -- ``
function WaveController:spawn_units(x, y)
    local army_power_used = 0
    local army_power_available = self:get_players_present_scaling()
    if self.spawn_units_over_time then
        -- spawn individually as a stream:
        TimerQueue:call_echo(self.spawn_units_over_time_cadence, function()
            army_power_available = self:create_random_unit(x, y, army_power_available)
            if army_power_available <= 0 then
                GameController.wave_id_current = GameController.wave_id_current + 1
                -- print("Wave finished.. id is now ", GameController.wave_id_current)
            end
            return army_power_available <= 0
        end)
    else
        -- spawn instantly as cluster:
        for _ = 1,army_power_available do
            army_power_available = self:create_random_unit(x, y, army_power_available)
            if army_power_used >= army_power_available then
                GameController.wave_id_current = GameController.wave_id_current + 1
                break
            end
        end
    end
end


---Create a random wave unit in the game world at a coordinate (pulls from self.enemy_groups).
---@param x number -- coordinate.
---@param y number -- ``
---@param army_power_available integer -- determines maximum units that can spawn based on EnemyUnit.army_power settings.
---@return integer -- returns new army power value after subtracting @army_power_available
function WaveController:create_random_unit(x, y, army_power_available)
    -- ? idea: this opens up easy use of mutators or skills (bosses?) to spawn in extra units.
    local x2, y2 = ProjectXY(x, y, math.random(32, self.spawn_as_cluster_distance), math.random(1,360))
    self.last_random_group_id = math.random(1, #self.enemy_groups)
    self.last_random_enemy_id = math.random(1, #self.enemy_groups[self.last_random_group_id])
    self.enemy_groups[self.last_random_group_id][self.last_random_enemy_id]:spawn(x2, y2)
    InterfaceController:set_wave_bar_progress()
    return army_power_available - self.enemy_groups[self.last_random_group_id][self.last_random_enemy_id].army_power
end
