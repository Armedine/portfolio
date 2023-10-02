local dmgtrig = CreateTrigger()
TriggerRegisterAnyUnitEventBJ(dmgtrig, EVENT_PLAYER_UNIT_DAMAGING)
TriggerAddCondition(dmgtrig, Filter(function()
    utils.debugfunc(function()
        ArcingTextTag(math.floor(GetEventDamage()), BlzGetEventDamageTarget())
    end)
    return true
end))
