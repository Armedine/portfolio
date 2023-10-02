LuaMissile          = {}            -- initialize class table.
LuaMissileStack     = {}            -- where instances of missiles are stored.
LuaMissileTimer     = NewTimer()    -- global missile Timer.
LuaMissileCadence   = .03           -- how fast the missile updates and checks for collision (higher = less accurate).

--[[
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

 [required]

    @ownerUnit    = unit        = unit that creates the missile and who deals damage to targets on collision.
    @landingX     = float       = X of coord for missile to move towards.
    @landingY     = float       = Y of coord for missile to move towards.

 [optional] - see LuaMissile:create for defaults.

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

function LuaMissile:init()
  -- set defaults:
  self.effect       = 'Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl'
  self.effectDmg    = 'Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl'
  self.height       = 60.0
  self.scale        = 1.0
  self.duration     = 1.5
  self.distance     = 600.0
  self.damage       = 100.0
  self.hitRadius    = 65.0
  self.collides     = false
  self.heroOnly     = false
  self.allies       = false
  self.dmgFunc      = nil
  self.timerFunc    = nil
  self.excludeUnit  = nil
  self.aType        = ATTACK_TYPE_NORMAL
  self.dType        = DAMAGE_TYPE_NORMAL
  self.missileZ     = 0.0
  self.traveled     = 0.0
  self.filter       = LuaMissile.filterEnemies
end


-- to make a missile target allies, set the filter i.e. myMissile.filter = LuaMissile:filterAllies
function LuaMissile:create(ownerUnit, landingX, landingY, effect, distance, duration)

  local o = {}
  setmetatable(o, self)

  self.owner        = GetOwningPlayer(ownerUnit)
  self.missileX     = GetUnitX(ownerUnit)
  self.missileY     = GetUnitY(ownerUnit)
  --
  self.velocity     = distance / ( duration / LuaMissileCadence );
  self.angle        = AngleBetweenPointsXY(self.missileX, self.missileY, landingX, landingY)
  self.effect       = AddSpecialEffect(effect, self.missileX, self.missileY)
  self.searchGroup  = CreateGroup()
  self.damageGroup  = CreateGroup()
  --
  self.__index      = self

  LuaMissile:addToStack(o)

  return o
end


-- add the missile to the stack:
-- @o = missile object key
function LuaMissile:addToStack(o)
  table.insert(LuaMissileStack, o)
  LuaMissile:startTimer()
end


-- start or stop the Timer based on active missiles:
function LuaMissile:startTimer()
  if tablelength(LuaMissileStack) == 1 and TimerGetRemaining(LuaMissileTimer) == 0.0 then
    TimerStart(LuaMissileTimer, LuaMissileCadence, true, LuaMissile.updateStack)
  end
end

-- start or stop the Timer based on active missiles:
function LuaMissile:timerCheck()
  if tablelength(LuaMissileStack) < 1 then
    PauseTimer(LuaMissileTimer)
  end
end


-- run missile update for the stack:
function LuaMissile:updateStack()
  for o in pairs(LuaMissileStack) do
    if o.traveled > o.distance then
      LuaMissile:destroy(o)
    elseif LuaMissileStack[o] then
      LuaMissile:update(o)
    end
  end
end


-- move the missile:
-- @o = missile object key
function LuaMissile:update(o)
  self.traveled = self.traveled + self.velocity
  self.missileX,self.missileY = PolarProjectionXY(self.missileX, self.missileY,
    self.velocity, self.angle)
  self.missileZ = GetTerrainCliffLevel(self.missileX,self.missileY)*128 - 256 + self.height
  BlzSetSpecialEffectYaw(self.effect, self.angle*bj_DEGTORAD) --  update facing angle of missile
  BlzSetSpecialEffectX(self.effect, self.missileX)
  BlzSetSpecialEffectY(self.effect, self.missileY)
  BlzSetSpecialEffectZ(self.effect, self.missileZ)
  if self.timerFunc ~= nil then
    self.timerFunc(o)
  end
  LuaMissile:collisionCheck(o)
end


-- check if missile should do damage:
-- @o = missile object key
function LuaMissile:collisionCheck(o)
  GroupEnumUnitsInRange(self.searchGroup, self.missileX, self.missileY, self.hitRadius,
    Condition( function() return self.filter(o, GetFilterUnit()) and GetFilterUnit() ~= self.excludeUnit end ) )
  if BlzGroupGetSize(self.searchGroup) > 0 then 
    GroupUtilsAction(self.searchGroup, function()
      if not IsUnitInGroup(LUA_FILTERUNIT,self.damageGroup) then
        LuaMissile:collision(o, LUA_FILTERUNIT) end
      end)
  end
end


-- deal damage to the unit:
-- @o = missile object key
-- @u = unit to damage
function LuaMissile:collision(o, u)
  UnitDamageTarget(self.ownerUnit, u, self.damage, true, false, self.aType, self.dType, WEAPON_TYPE_WHOKNOWS)
  if self.dmgFunc ~= nil then
    self.dmgFunc(u, o)
  end
  if self.effectDmg then
    DestroyEffect(AddSpecialEffect(self.effectDmg,GetUnitX(u),GetUnitY(u)))
  end
  if self.collides then
    LuaMissile:destroy(o)
  else
    GroupUtilsAction(self.searchGroup, function()
      GroupAddUnit(self.damageGroup,LUA_FILTERUNIT)
      GroupRemoveUnit(self.searchGroup,LUA_FILTERUNIT)
    end)
  end
end


-- destroy the missile instance:
-- @o = missile object key
function LuaMissile:destroy(o)
  DestroyEffect(self.effect)
  DestroyGroup(self.damageGroup)
  DestroyGroup(self.searchGroup)
  LuaMissileStack[o] = nil
  LuaMissile:timerCheck()
end


-- @o = missile object key
-- @u = unit to check
function LuaMissile:filterEnemies(o, u)
  return  IsUnitEnemy(u,self.owner)
          and not IsUnitDeadBJ(u)
          and not IsUnitType(u,UNIT_TYPE_STRUCTURE)
          and not IsUnitType(u,UNIT_TYPE_MAGIC_IMMUNE)
          and not IsUnitInGroup(u, self.damageGroup)
end


-- @o = missile object key
-- @u = unit to check
function LuaMissile:filterAllies(o, u)
  return  IsUnitAlly(u,self.owner)
          and not IsUnitDeadBJ(u)
          and not IsUnitType(u,UNIT_TYPE_STRUCTURE)
          and not IsUnitInGroup(u, self.damageGroup)
end
