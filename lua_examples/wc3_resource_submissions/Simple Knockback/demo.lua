function demokb1()
    local unit   = GetTriggerUnit()
    local x, y   = unitxy(unit)
    local grp    = UnitGroup:newbyxy(GetOwningPlayer(unit), G_TYPE_DMG, x, y, 300.0)
    Knockback:new_group(grp, x, y)
    grp:destroy()
end


function demokb2()
    local x, y   = unitxy(GetTriggerUnit())
    local x2, y2 = unitxy(GetSpellTargetUnit())
    local angle  = anglexy(x, y, x2, y2)
    local k = Knockback:new(GetSpellTargetUnit(), angle, 1200, 1.25)
    k.destroydest = false
    k.colfunc = function(k)
        k.interrupt = true
        Knockback:new(k.unit, k.angle - math.random(160,200), math.floor(k.dist*0.9), 1.25)
    end
end
