LuaMissileTimer     = NewTimer()    -- global missile Timer.
LuaMissileCadence   = .03           -- how fast the missile updates and checks for collision (higher = less accurate).
LuaMissileStack     = {}            -- where instances of missiles are stored.
LuaMissile          = {}            -- initialize class table.

--[[
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

 [required]

    @ownerUnit    = unit        = unit that creates the missile and who deals damage to targets on collision.
    @landingX     = float       = X of coord for missile to move towards.
    @landingY     = float       = Y of coord for missile to move towards.

 [optional] - see LuaMissile.create for defaults.

    @distance     = float       = how far should the missile travel.
    @duration     = float       = how long should the missile last (seconds).
    @damage       = float       = how much damage should the missile do.
    @hitRadius    = float       = how far should the missile check to count as a collision.
    @collides     = bool        = does the missile destroy itself on collision.
    @heroOnly     = bool        = does the missile only collide with heroes.
    @allies       = bool        = does the missile collide with allies instead of enemies.
    @excludeUnit  = unit        = should the missile not hit a target (e.g. the caster).
    @dmgFunc      = function    = should there be an extra effect on the unit when hit (callback); include unit as param: myDmgFunc(u).
    @effect       = effect      = the model of the missile.
    @effectDmg    = effect      = the special effect on collision.
    @height       = float       = offset from the ground (Z).
    @scale        = float       = scale of @effect.
    @timerFunc    = function    = should there be extra calculations on timer update; include object as param: myTimerFunc(o).
    @aType        = attacktype  = pass attack type for more advanced use cases.
    @dType        = damagetype  = pass damage type for more advanced use cases.

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
--]]
function LuaMissile.create(ownerUnit, landingX, landingY, distance, duration, damage, hitRadius, collides, heroOnly, allies,
                           excludeUnit,dmgFunc,effect,effectDmg,height,scale,timerFunc,aType,dType)

  local o = {}

  o.ownerUnit    = ownerUnit
  o.owner        = GetOwningPlayer(ownerUnit)
  o.landingX     = landingX
  o.landingY     = landingY
  o.missileX     = GetUnitX(ownerUnit)
  o.missileY     = GetUnitY(ownerUnit)
  o.missileZ     = 0.0
  o.traveled     = 0.0
  -- set values or defaults:
  o.effect       = effect       or 'Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl'
  o.effectDmg    = effectDmg    or 'Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl'
  o.height       = height       or 60.0
  o.scale        = scale        or 1.0
  o.duration     = duration     or 1.5
  o.distance     = distance     or 600.0
  o.damage       = damage       or 100.0
  o.hitRadius    = hitRadius    or 65.0
  o.collides     = collides     or false
  o.heroOnly     = heroOnly     or false
  o.allies       = allies       or false
  o.dmgFunc      = dmgFunc      or nil
  o.timerFunc    = timerFunc    or nil
  o.excludeUnit  = excludeUnit  or nil
  o.aType        = aType        or ATTACK_TYPE_NORMAL
  o.dType        = dType        or DAMAGE_TYPE_NORMAL
  --
  o.velocity     = distance / ( duration / LuaMissileCadence );
  o.angle        = AngleBetweenPointsXY(o.missileX, o.missileY, landingX, landingY)
  o.effect       = AddSpecialEffect(effect, o.missileX, o.missileY)
  o.searchGroup  = CreateGroup()
  o.damageGroup  = CreateGroup()
  if allies then
    o.filter = LuaMissile.filterAllies
  else
    o.filter = LuaMissile.filterEnemies
  end

  BlzSetSpecialEffectScale(o.effect, scale)
  LuaMissile.addToStack(o)

  return o
end


-- add the missile to the stack:
-- @o = missile object key
function LuaMissile.addToStack(o)
  table.insert(LuaMissileStack, o)
  LuaMissile.startTimer()
end


-- start or stop the Timer based on active missiles:
function LuaMissile.startTimer()
  if tablelength(LuaMissileStack) == 1 and TimerGetRemaining(LuaMissileTimer) == 0.0 then
    TimerStart(LuaMissileTimer, LuaMissileCadence, true, LuaMissile.updateStack)
  end
end

-- start or stop the Timer based on active missiles:
function LuaMissile.timerCheck()
  if tablelength(LuaMissileStack) < 1 then
    PauseTimer(LuaMissileTimer)
  end
end


-- run missile update for the stack:
function LuaMissile.updateStack()
  for o in pairs(LuaMissileStack) do
    if LuaMissileStack[o].traveled > LuaMissileStack[o].distance then
      LuaMissile.destroy(o)
    elseif LuaMissileStack[o] then
      LuaMissile.update(o)
    end
  end
end


-- move the missile:
-- @o = missile object key
function LuaMissile.update(o)
  LuaMissileStack[o].traveled = LuaMissileStack[o].traveled + LuaMissileStack[o].velocity
  LuaMissileStack[o].missileX,LuaMissileStack[o].missileY = PolarProjectionXY(LuaMissileStack[o].missileX, LuaMissileStack[o].missileY,
    LuaMissileStack[o].velocity, LuaMissileStack[o].angle)
  LuaMissileStack[o].missileZ = GetTerrainCliffLevel(LuaMissileStack[o].missileX,LuaMissileStack[o].missileY)*128 - 256 + LuaMissileStack[o].height
  BlzSetSpecialEffectYaw(LuaMissileStack[o].effect, LuaMissileStack[o].angle*bj_DEGTORAD) --  update facing angle of missile
  BlzSetSpecialEffectX(LuaMissileStack[o].effect, LuaMissileStack[o].missileX)
  BlzSetSpecialEffectY(LuaMissileStack[o].effect, LuaMissileStack[o].missileY)
  BlzSetSpecialEffectZ(LuaMissileStack[o].effect, LuaMissileStack[o].missileZ)
  if LuaMissileStack[o].timerFunc ~= nil then
    LuaMissileStack[o].timerFunc(o)
  end
  LuaMissile.collisionCheck(o)
end


-- check if missile should do damage:
-- @o = missile object key
function LuaMissile.collisionCheck(o)
  GroupEnumUnitsInRange(LuaMissileStack[o].searchGroup, LuaMissileStack[o].missileX, LuaMissileStack[o].missileY, LuaMissileStack[o].hitRadius,
    Condition( function() return LuaMissileStack[o].filter(o, GetFilterUnit()) and GetFilterUnit() ~= LuaMissileStack[o].excludeUnit end ) )
  if BlzGroupGetSize(LuaMissileStack[o].searchGroup) > 0 then 
    GroupUtilsAction(LuaMissileStack[o].searchGroup, function()
      if not IsUnitInGroup(LUA_FILTERUNIT,LuaMissileStack[o].damageGroup) then
        LuaMissile.collision(o, LUA_FILTERUNIT) end
      end)
  end
end


-- deal damage to the unit:
-- @o = missile object key
-- @u = unit to damage
function LuaMissile.collision(o, u)
  UnitDamageTarget(LuaMissileStack[o].ownerUnit, u, LuaMissileStack[o].damage, true, false, LuaMissileStack[o].aType, LuaMissileStack[o].dType, WEAPON_TYPE_WHOKNOWS)
  if LuaMissileStack[o].dmgFunc ~= nil then
    LuaMissileStack[o].dmgFunc(u, o)
  end
  if LuaMissileStack[o].effectDmg then
    DestroyEffect(AddSpecialEffect(LuaMissileStack[o].effectDmg,GetUnitX(u),GetUnitY(u)))
  end
  if LuaMissileStack[o].collides then
    LuaMissile.destroy(o)
  else
    GroupUtilsAction(LuaMissileStack[o].searchGroup, function()
      GroupAddUnit(LuaMissileStack[o].damageGroup,LUA_FILTERUNIT)
      GroupRemoveUnit(LuaMissileStack[o].searchGroup,LUA_FILTERUNIT)
    end)
  end
end


-- destroy the missile instance:
-- @o = missile object key
function LuaMissile.destroy(o)
  DestroyEffect(LuaMissileStack[o].effect)
  DestroyGroup(LuaMissileStack[o].damageGroup)
  DestroyGroup(LuaMissileStack[o].searchGroup)
  LuaMissileStack[o] = nil
  LuaMissile.timerCheck()
end


-- @o = missile object key
-- @u = unit to check
function LuaMissile.filterEnemies(o, u)
  return  IsUnitEnemy(u,LuaMissileStack[o].owner)
          and not IsUnitDeadBJ(u)
          and not IsUnitType(u,UNIT_TYPE_STRUCTURE)
          and not IsUnitType(u,UNIT_TYPE_MAGIC_IMMUNE)
          and not IsUnitInGroup(u, LuaMissileStack[o].damageGroup)
end


-- @o = missile object key
-- @u = unit to check
function LuaMissile.filterAllies(o, u)
  return  IsUnitAlly(u,LuaMissileStack[o].owner)
          and not IsUnitDeadBJ(u)
          and not IsUnitType(u,UNIT_TYPE_STRUCTURE)
          and not IsUnitInGroup(u, LuaMissileStack[o].damageGroup)
end
