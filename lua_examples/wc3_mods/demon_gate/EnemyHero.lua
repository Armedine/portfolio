---@class EnemyHero:EnemyUnit
---Configures commanders, which are the boss wave units; inherits EnemyUnit.
EnemyHero = {
    max_health = 10000,
    max_mana = 100,
    attack_damage = 50,
    attack_speed = 1.75,
}
EnemyHero.__index = EnemyUnit


function EnemyHero:new(max_health, max_mana, attack_damage, attack_speed)
    local o = setmetatable({}, self)
    o.max_health = max_health
    o.max_mana = max_mana
    o.attack_damage = attack_damage
    o.attack_speed = attack_speed
    return o
end


function EnemyHero:spawn_commander(x, y)
    self.unit = self:spawn(x, y)
    SetState(self.unit, "max_health", self.max_health)
    SetState(self.unit, "max_mana", self.max_mana)
    SetState(self.unit, "all", 1.0, true)
    BlzSetUnitWeaponIntegerField(self.unit, UNIT_WEAPON_IF_ATTACK_DAMAGE_BASE, 0, math.floor(self.attack_damage))
    BlzSetUnitWeaponRealField(self.unit, UNIT_WEAPON_RF_ATTACK_BASE_COOLDOWN, 0, self.attack_speed)
end
