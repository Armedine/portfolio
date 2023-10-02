---@class AilmentController
---Controls debuffs applied to units, which have a variety of consequences.
AilmentController = {
    units_armor_damaged = {},
    units_armor_broken = {},
    units_armor_destroyed = {},

    units_weapon_damaged = {},
    units_weapon_broken = {},
    units_weapon_destroyed = {},

    units_sick_sickly = {},
    units_sick_diseased = {},
    units_sick_rotting = {},

    units_tired_fatigued = {},
    units_tired_exhausted = {},
    units_tired_incapacitated = {},

    units_mad_paranoid = {},
    units_mad_hallucinating = {},
    units_mad_insanity = {},
}
AilmentController.__index = AilmentController


---Create a new ailment type.
---@param name any
---@param buff_spell_id any
---@return AilmentController
function AilmentController:new(name, buff_spell_id)
    local o = setmetatable({}, self)
    o.name = name
    o.buff_id = FourCC(buff_spell_id)
    return o
end


---Apply this ailment to a unit.
---@param u unit
function AilmentController:apply_to_unit(u)
    --TODO
end


---Apply this ailment to a group of units.
---@param unit_group UnitGroup
function AilmentController:apply_to_unit_group(unit_group)
    unit_group:action(function()
        AilmentController:apply_to_unit(unit_group.unit)
    end)
end


function AilmentController:end_of_round_update()
    -- TODO: run update for each player's army unit catalog:
    
    -- TODO: apply end-of-round effects e.g. diseased:

    -- TODO: worsen conditions if they are present by checking if units have buff ids:

    -- TODO: shuffle units around to appropriate tables.
end

--[[ ideas

 * Damaged Armor: Unit loses 25% of its armor. Worsens to Broken Armor after 1 round.
    -> Broken Armor: Unit loses 50% of its armor. Worsens to Destroyed Armor after 1 round.
        -> Destroyed Armor: Unit loses 100% of its armor.

 * Damaged Weapon: Unit loses 10% of its attack damage. Worsens to Broken Weapon after 1 round.
    -> Broken Weapon: Unit loses 25% of its attack damage. Worsens to Destroyed Weapon after 1 round.
        -> Destroyed Weapon: Unit loses 75% of its attack damage.

 * Sickly: Unit restores 25% less health from Requisitions and end-of-round effects. Worsens to Diseased after 1 round.
    -> Diseased: Unit restores 50% less health from Requisitions and end-of-round effects. Has a chance to spread after each round. Worsens to Rotting after 1 round.
        -> Rotting: Unit restores no health from Requisitions and end-of-round effects, and loses 10% instead. Has a chance to spread after each round.

 * Fatigued: 10% reduced movement speed. Worsens to Exhausted after 1 round.
    -> Exhausted: 25% reduced movement speed and attack speed. Worsens to Incapacitated after 1 round.
        -> Incapacitated: 75% reduced movement speed and attack speed.

 * Paranoid: 10% chance to miss with attacks. Worsens to Hallucinating after 1 round.
    -> Hallucinating: 25% chance to miss with attacks. Worsens to Insanity after 1 round.
        -> Insanity: 50% chance to miss with attacks. This unit will abandon your army roster at the end of the next round if not cured.

]]
