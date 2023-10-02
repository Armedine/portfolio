---@class GameEffect -- Allows easy manipulation of special effects without having to worry about effect handles or a massive heap.
---
--- Requires: DetectPlayers, UnitIndexer, Total Initialization Lite
---
--- Recommend sub-typing with emmy annotations: NewEffect = GameEffect.catalog  ---@type table<string,GameEffect>
---
--- Then use: NewEffect["your_named_effect"]:play(x, y)
---
--- Or: NewEffect["your_named_effect"]:play_at_unit(some_unit)
GameEffect = {active_effects={}, recycled_effects={}, catalog={}, recycle_max=30, effect=nil, path=nil, alpha_destroy=false, scale=1.0, active_effect_count=0}
GameEffect.__index = GameEffect
GameEffect.timer = CreateTimer() -- TODO: implement advanced effects with scaling and movement over time etc.


---Stash a new special effect for future use and place it in the catalog for easy lookups.
---@param path string
---@param effect_name string
---@param _default_scale? number
---@return GameEffect
function GameEffect:new(effect_name, path, _default_scale)
    local o = setmetatable({}, self)
    o.path = path
    o.scale = _default_scale or self.scale
    -- store in NewEffect:
    self.catalog[effect_name] = o
    return o
end


---Play a special effect.
---@param x number
---@param y number
---@param _duration? number
---@return effect
function GameEffect:play(x, y, _duration)
    return self:create_at_xy(x, y, _duration)
end


---Play a special effect that persists.
---@param x number
---@param y number
---@return effect
function GameEffect:play_persist(x, y)
    return self:create_at_xy(x, y, "persist")
end


---Play an effect at a unit location.
---@param u unit
---@param _duration? number
---@return effect
function GameEffect:play_at_unit(u, _duration)
    local x, y = GetUnitXY(u)
    return self:play(x, y, _duration)
end


---Attach an effect to a unit; it is destroyed on death automatically.
---@param u any
---@param _attachment_point any
---@param _duration any
---@return effect
function GameEffect:attach_to_unit(u, _attachment_point, _duration)
    local udex = GetUnitIndex(u)
    local e = AddSpecialEffectTargetUnitBJ(_attachment_point or "origin", u, self.path)
    if not self.active_effects[udex] then
        self.active_effects[udex] = {}
    end
    local index = #self.active_effects[udex]+1
    self.active_effects[udex][index] = e
    if _duration then
        TimerQueue:call_delayed(_duration, function()
            if e then
                GameEffect:destroy(e)
            end
            if self.active_effects[udex] and self.active_effects[udex][index] then
                table.remove(self.active_effects[udex], index)
            end
        end)
    end
    return e
end


---Create an effect at location x,y with option to destroy after a duration.
---@param x number -- coord
---@param y number -- coord
---@param _duration? number|string -- seconds to persist; use string literal 'persist' to not destroy.
---@return effect
function GameEffect:create_at_xy(x, y, _duration)
    GameEffect.active_effect_count = GameEffect.active_effect_count + 1
    local e = AddSpecialEffect(self.path, x, y)
    BlzSetSpecialEffectScale(e, self.scale)
    if _duration == "persist" then
        return e
    elseif _duration then
        TimerQueue:call_delayed(_duration, function() self:destroy(e) end)
    else
        self:destroy(e)
    end
    if not self.printed_leak_warning and self.active_effect_count > 1000 then
        print_error("WARNING - GameEffect leak detected, active effects count greater than 1,000!")
        self.printed_leak_warning = true
    end
end


---Should be used for any destroy effect call. Tracks total effects to prevent leakage.
---@param special_effect effect
function GameEffect:destroy(special_effect)
    if self.alpha_destroy then
        BlzSetSpecialEffectAlpha(special_effect, 0)
    end
    DestroyEffect(special_effect)
    GameEffect.active_effect_count = GameEffect.active_effect_count - 1
end


function GameEffect:destroy_attached_effects(u)
    if GameEffect.active_effects[GetUnitIndex(u)] then
        for _,e in ipairs(GameEffect.active_effects[GetUnitIndex(u)]) do
            if e then
                GameEffect:destroy(e)
            end
        end
        GameEffect.active_effects[GetUnitIndex(u)] = nil
    end
end


local old_remove_unit = RemoveUnit
function RemoveUnit(u)
    GameEffect:destroy_attached_effects(u)
    old_remove_unit(u)
end


OnGameStart(function()
    local trig = CreateTrigger()
    TriggerRegisterAnyUnitEventBJ(trig, EVENT_PLAYER_UNIT_DEATH)
    TriggerAddAction(trig, function()
        GameEffect:destroy_attached_effects(GetTriggerUnit())
    end)
end)
