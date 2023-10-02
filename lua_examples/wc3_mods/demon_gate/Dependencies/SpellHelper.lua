---@class Spell
---Assists with creating new spells for heroes and units.
---Requires: TriggerHelper
Spell = {}
Spell.__index = Spell


OnMapInit(function()
    Spell.trig_spell_cast = TriggerHelper:new("any_unit", "spell_cast", function()
        -- TODO
    end)
    Spell.trig_spell_effect = TriggerHelper:new("any_unit", "spell_effect", function()
        -- TODO
    end)
    Spell.trig_spell_finish = TriggerHelper:new("any_unit", "spell_finish", function()
        -- TODO
    end)
    Spell.trig_spell_endcast = TriggerHelper:new("any_unit", "spell_endcast", function()
        -- TODO
    end)
end)
