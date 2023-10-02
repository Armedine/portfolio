--[[-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
   :: a very simple KB system that moves the unit in a direction over time, extensible with custom data and function arguments.
   :: by Planetary @hiveworkshop.com :: CC0 :: no credit required.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --]]

LUA_KB_DATA     = {}  -- where we store global data for KB instances.
LUA_KB_CONFIG   = {}  -- default configuration data.

LUA_KB_CONFIG.collisionSize         = 32.0          -- x,y offset to check for walkable pathability.
LUA_KB_CONFIG.tickRate              = 0.03          -- KB timer update period. recommend to keep at .03 minimum or bugs may occur. higher values = less accurate collision.
LUA_KB_CONFIG.destroyDest           = true          -- should destructables be destroyed? if false, meeting a destructable will count as a collision using collisionSize.
LUA_KB_CONFIG.destPlayEffect        = true          -- if a destructable is destroyed, should a special effect be played? plays LUA_KB_CONFIG.effect.
LUA_KB_CONFIG.destCheckSize         = 192.0         -- rect width/height which checks for destructables to destroy.
LUA_KB_CONFIG.tickFailsafe          = 256           -- overly-cautious hard-break cap; if this number of timer completions is exceeded, the KB will end.
LUA_KB_CONFIG.effectTickRate        = 6             -- how often the special effect occurs (1 tick = .03 sec) to control for screen quality and efficiency.
LUA_KB_CONFIG.abilCode              = FourCC('Arav')-- crow ability that simulates no collision (added and removed on update).
LUA_KB_CONFIG.effect                = 'Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl'    -- the special effect to use under the KB unit.
LUA_KB_CONFIG.destEffect            = LUA_KB_CONFIG.effect                                                          -- special effect to use on destroyed destructables.

--[[-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

      readme (if not needed, delete to save on file size):

      an example use of a basic KB as a custom script: BasicKnockback(udg_tempunit, udg_tempangle, 300, true, .66, nil, nil)
      alternatively, a basic KB shorthand would read as: BasicKnockback(udg_tempunit, udg_tempangle, 300, true, .66)

      an example use of a more complex KB with custom data: BasicKnockback(udg_tempunit, udg_tempangle, 300, true, .66, nil, customData)
      where customData = { ['collisionSize'] = 44, ['effect'] = 'Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl' }

      how would you use custom data?
      :: let's say you want a knockback that has a certain velocity and distance based on custom RPG stats: you could override the base KB calcs with
      :: raw values that you calculate and pass in via customData (kb.velocity and kb.distance).
      :: your table would look something like (placeholder math): local myTable = { ['velocity'] = udg_myAgilityStat*.1, ['distance'] = udg_myStrengthStat*10 }

      any piece of kb data can be overwritten with the customData argument. however, these are the key calculated points you may want to alter:
      :: tickRate
      :: velocity
      :: distance
      :: destroyDest
      :: destPlayEffect
      :: destEffect
      :: angle
      
      kb data reference:
      :: kb.collisionSize     int     = radius to detect collision with terrain.
      :: kb.tickRate          real    = KB periodic update cadence.
      :: kb.destroyDest       bool    = should destructables be destroyed.
      :: kb.destPlayEffect    bool    = should an effect be played on destroyed destructables?
      :: kb.destEffect        str     = effect to play on destructables (defaults to kb effect; overwrite with custom data)
      :: kb.destCheckSize     int     = radius to detect destructables to destroy.
      :: kb.tickFailsafe      int     = max timer updates before a force exit.
      :: kb.effectTickRate    real    = how often the special effect plays (every X tickRate updates).
      :: kb.abilCode          ability = ability code added to unit that removes collision.
      :: kb.effect            str     = effect played under KB unit.
      :: kb.rect              rect    = rect to determine destructables in range.
      :: kb.unit              real    = KB unit.
      :: kb.unitX             real    = KB unit current X.
      :: kb.unitY             real    = KB unit current Y.
      :: kb.distance          real    = remaining distance to travel for KB unit.
      :: kb.angle             real    = trajectory angle.
      :: kb.velocity          real    = distance traveled per tickRate.
      :: kb.velocityOffset    real    = collisionSize offset from current velocity.
      :: kb.pathCheckX        real    = coord for pathing check at velocityOffset.
      :: kb.pathCheckY        real    = coord for pathing check at velocityOffset.
      :: kb.ticks             int     = total tickRate completions.
      :: kb.update            bool    = force existing timer to update to a new KB instance.

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --]]

-- @KBunit = unit to kb.
-- @KBdirectionAngle = angle of KB movement.
-- @KBdistance = distance to travel.
-- @KBpause = should it pause the unit.
-- @KBduration = (seconds) how long it takes to get from point A to B. determines velocity; velocity = (KBdistance/KBduration)/(1.0/kb.tickRate)
-- @KBcollisionFunc = [optional] function to pass that does things to the unit when they collide with terrain. pass 'id' as an argument e.g. myFunc(id).
-- @KBcustomData = [optional] = override any 'kb' data (e.g. 'velocity', 'effect', etc.) with a data table, using kb data index values as the lookup.
function BasicKnockback(KBunit, KBdirectionAngle, KBdistance, KBpause, KBduration, KBcollisionFunc, KBcustomData)

    if (not IsUnitType(KBunit, UNIT_TYPE_STRUCTURE) and not IsUnitType(KBunit, UNIT_TYPE_ANCIENT)) then -- KB system hard cancellations.
        local id = GetUnitUserData(KBunit)      -- fetch unit index data.
        local kb = {}                           -- temp table for readability.

        if (LUA_KB_DATA[id] == nil) then        -- if no KB instance is active, instantiate one.
            LUA_KB_DATA[id] = {}
        else
            LUA_KB_DATA[id].update = true       -- flag the kb timer to overwrite its local data with the new KB instance.
            kb = LUA_KB_DATA[id]                -- with a global table, we can simply overwrite existing KB timer data for a new trajectory.
        end

        if (KBcustomData ~= nil) then -- if custom data is passed, assign where matches occur.
            for index, value in pairs(LUA_KB_CONFIG) do
                if ( DoesTableContainIndex(KBcustomData,index) ) then
                    kb[index] = KBcustomData[index]
                else
                    kb[index] = value -- assigns kb.collisionSize, kb.effect, etc.
                end
            end
        else -- custom data does not exist, initialize defaults 
            for index, value in pairs(LUA_KB_CONFIG) do
                kb[index] = value -- assigns kb.collisionSize, kb.effect, etc.
            end
        end

        if (not kb.rect) then kb.rect = Rect(0, 0, kb.destCheckSize, kb.destCheckSize) end -- create destructables check rect if one doesn't already exist.
        kb.unit = KBunit
        kb.unitX = GetUnitX(KBunit)
        kb.unitY = GetUnitY(KBunit)
        kb.distance = KBdistance
        kb.angle = KBdirectionAngle
        kb.velocity = (KBdistance/KBduration)/(1.0/kb.tickRate) -- convert tickrate timer to distance traveled per sec (velocity).
        kb.velocityOffset = kb.velocity + kb.collisionSize -- precalc pathing/dest check for efficiency.
        kb.pathCheckX,kb.pathCheckY = PolarProjectionXY(kb.unitX,kb.unitY,kb.velocityOffset,kb.angle) -- check for pathing and destructables.
        kb.ticks = 0 -- the number of times the timer has completed (to control special effect cadence and the forced-break safety limit).

        if (KBcollisionFunc ~= nil) then
            kb.collisionFunc = KBcollisionFunc  -- if the collision function exists, initialize it.
        else
            kb.collisionFunc = nil      -- default to nil.
        end

        if (KBpause) then
            PauseUnit(kb.unit,true)
        end

         -- if custom data is passed for calculation overwrites, assign the new values.
         -- since few overwrites are expected, we allow inefficient replacement.
        if (KBcustomData ~= nil) then
            for index, value in pairs(KBcustomData) do
                if ( DoesTableContainIndex(kb,index) ) then
                    kb[index] = value
                end
            end
        end

        LUA_KB_DATA[id] = kb    -- update the global kb instance data.

        -- -----------------------------------------------------------------------------------------------------------------------------------------------
        -- [[ KB TIMER ]] --------------------------------------------------------------------------------------------------------------------------------
        -- -----------------------------------------------------------------------------------------------------------------------------------------------

        if (kb.timer == nil and not LUA_KB_DATA[id].update) then -- if no timer exists, generate one.

            kb.timer = TimerStart(NewTimer(),kb.tickRate,true,function()

                if (LUA_KB_DATA[id].update) then    -- if an overwrite event occurred, update the local timer data.
                    kb = LUA_KB_DATA[id]
                    LUA_KB_DATA[id].update = false  -- allow future updates again.
                end

                kb.pathCheckX,kb.pathCheckY = PolarProjectionXY(kb.unitX,kb.unitY,kb.velocityOffset,kb.angle) -- increment offset to check for upcoming pathing check.
                kb.ticks = kb.ticks + 1

                if ( IsTerrainPathable(kb.pathCheckX,kb.pathCheckY,PATHING_TYPE_WALKABILITY) and not IsUnitType(kb.unit,UNIT_TYPE_FLYING) ) then -- check pathing.
                    kb.hitTerrainBool = true
                    if (kb.collisionFunc ~= nil) then
                        kb.collisionFunc(id)
                    end
                end

                -- run appropriate checks to destroy the KB instance:
                if (not IsUnitType(kb.unit, UNIT_TYPE_DEAD) and not kb.hitTerrainBool and kb.distance > 0 and kb.ticks < kb.tickFailsafe ) then

                    -- ---------------------------- --
                    -- [[ run effect, move unit  ]] --
                    -- ---------------------------- --
                    BasicKnockbackCheckDest(kb.pathCheckX,kb.pathCheckY,id)

                    kb.distance = kb.distance - kb.velocity
                    kb.unitX,kb.unitY = PolarProjectionXY(kb.unitX,kb.unitY,kb.velocity,kb.angle)

                    if (ModuloInteger(kb.ticks,kb.effectTickRate) == 0) then -- limit special effect creation for performance.
                        DestroyEffect(AddSpecialEffect(kb.effect,kb.unitX,kb.unitY))
                    end

                    UnitAddAbility(kb.unit,kb.abilCode)
                    SetUnitX(kb.unit,kb.unitX)
                    SetUnitY(kb.unit,kb.unitY)
                    UnitRemoveAbility(kb.unit,kb.abilCode)
                    -- ---------------------------- --
                    -- ---------------------------- --

                else -- end effect
                    if (IsUnitPaused(kb.unit)) then
                        PauseUnit(kb.unit,false)
                    end
                    RemoveRect(kb.rect)     -- cleanup
                    kb = nil                -- cleanup
                    LUA_KB_DATA[id] = nil   -- cleanup
                    ReleaseTimer()
                end

            end)
        end

        -- -----------------------------------------------------------------------------------------------------------------------------------------------
        -- [[ END KB TIMER ]] ----------------------------------------------------------------------------------------------------------------------------
        -- -----------------------------------------------------------------------------------------------------------------------------------------------
    end

end


-- @x,y = check this coord.
-- @id = for this KB instance.
function BasicKnockbackCheckDest(x,y,id)
    MoveRectTo(LUA_KB_DATA[id].rect,x,y)
    if (LUA_KB_DATA[id].destroyDest) then
        EnumDestructablesInRect(LUA_KB_DATA[id].rect, nil, function() BasicKnockbackDest(id) end)
    else
        EnumDestructablesInRect(LUA_KB_DATA[id].rect, nil, function() BasicKnockbackDestCollision(id) end)
    end
end


-- destroy enum destructables.
function BasicKnockbackDest(id)
    bj_destRandomCurrentPick = GetEnumDestructable() -- for efficiency, hook a disposable blizzard global.
    if (GetWidgetLife(bj_destRandomCurrentPick) > .405) then -- add any desired special conditions.
        if (LUA_KB_DATA[id].destPlayEffect and LUA_KB_DATA[id].destEffect ~= nil) then
            DestroyEffect(AddSpecialEffect( LUA_KB_DATA[id].destEffect,
                GetWidgetX(bj_destRandomCurrentPick),
                GetWidgetY(bj_destRandomCurrentPick) ) )
        end
        SetWidgetLife(bj_destRandomCurrentPick,0)
    end
end


-- find out if there is a nearby destructable to collide with.
function BasicKnockbackDestCollision(id)
    bj_destRandomCurrentPick = GetEnumDestructable() -- for efficiency, hook a disposable blizzard global.
    if (bj_destRandomCurrentPick ~= nil and GetWidgetLife(bj_destRandomCurrentPick) > .405) then
        local x = GetWidgetX(bj_destRandomCurrentPick)
        local y = GetWidgetY(bj_destRandomCurrentPick)
        if (IsUnitInRangeXY(LUA_KB_DATA[id].unit,x,y,LUA_KB_DATA[id].collisionSize)) then -- only stop if collisionSize met.
            LUA_KB_DATA[id].hitTerrainBool = true   -- set the flag to end the KB instance.
            LUA_KB_DATA[id].update = true           -- pass in the flag to update the running timer.
        end
    end
end


-- :: PolarProjectionBJ converted to x,y.
-- @x1,y1 = origin coord.
-- @d = distance between origin and direction.
-- @a = angle to project.
function PolarProjectionXY(x1,y1,d,a)
    local x = x1 + d * Cos(a * bj_DEGTORAD)
    local y = y1 + d * Sin(a * bj_DEGTORAD)

    return x,y
end


-- :: helper function to check if table has index value.
-- @t = table to search.
-- @v = value to search for, returns true if it exists; false if not.
function DoesTableContainIndex(t,v)
    for index, value in pairs(t) do
        if index == v then
            return true
        end
    end
    return false
end
