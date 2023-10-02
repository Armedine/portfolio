---@class ArmyHero
---Globally configures spawned player commanders and their attributes.
ArmyHero = {
    -- defaults:
    health = 500.0,
    mana = 25.0,
    attack = 30.0,
    attack_rate = 2.0,
    catalog = SyncedTable() -- lookup by FourCC.
}
ArmyHero.__index = ArmyHero


---Initialize a selectable army commander (player hero).
---@param unit_id string
---@param health? integer
---@param mana? integer
---@param attack? integer
---@param attack_rate? number
---@param armor? number
---@return ArmyHero
function ArmyHero:new(unit_id, health, mana, attack, attack_rate, armor)
    local o = setmetatable({}, self)
    o.unit_id = FourCC(unit_id)
    o.health = health or self.health
    o.mana = mana or self.mana
    o.attack = attack or self.attack
    o.attack_rate = attack_rate or self.attack_rate
    self.catalog[o.unit_id] = o
    return o
end


function ArmyHero:initialize_stats(sold_hero)
    local army_hero = ArmyHero.catalog[GetUnitTypeId(sold_hero)]
    SetUnitBaseDamage(sold_hero, 1, 0)
    BlzSetUnitIntegerField(sold_hero, UNIT_IF_AGILITY_PERMANENT, 1)
    BlzSetUnitIntegerField(sold_hero, UNIT_IF_STRENGTH_PERMANENT, 1)
    BlzSetUnitIntegerField(sold_hero, UNIT_IF_INTELLIGENCE_PERMANENT, 1)
    BlzSetUnitIntegerField(sold_hero, UNIT_IF_AGILITY, 1)
    BlzSetUnitIntegerField(sold_hero, UNIT_IF_STRENGTH, 1)
    BlzSetUnitIntegerField(sold_hero, UNIT_IF_INTELLIGENCE, 1)
    InitializeUnitState(sold_hero, army_hero.health, army_hero.mana, army_hero.attack+1, army_hero.attack_rate, nil, true)
end


function ArmyHero:initialize_for_player(player, sold_hero)
    if GetTriggerUnitTypeId() == FourCC("h009") and IsHero(sold_hero) then -- sold by hero picker.
        RemoveTriggerUnit()
        SelectUnitForPlayerSingle(sold_hero, player)
        IssueOrderMoveToXY(sold_hero, 0.0, 1000.0)
        NewEffect.teleport_void:play_at_unit(sold_hero)
        -- initialize player object settings:
        PlayerController:get_player(player):set_faction_color(sold_hero)
        PlayerController:get_player(player).has_picked_hero = true
        PlayerController:get_player(player).hero = GetSoldUnit()
        PlayerController:get_player(player).army_controller.hero = GetSoldUnit()
        ArmyHero:initialize_stats(sold_hero)
    end
    return self
end
