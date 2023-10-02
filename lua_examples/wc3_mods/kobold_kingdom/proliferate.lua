-- this class controls what happens for the elemental proc chance effects (p_stat_eleproc)
-- if the proc occurs on the damage type (in the damage engine), run the corresponding damage id effect below.
proliferate = {}


-- arcane: deals 25% bonus damage and slows the target for 3 sec.
proliferate[1] = function(e)
    dmg.type.stack[atypelookup[e.atktype]]:pdeal(e.sourcep, e.amount*0.20, e.target)
    bf_slow:apply(e.target, 3.0)
end


-- frost: deals 15% of its original damage as bonus AoE damage in a 3m radius, freezing the main target for 1.5 sec.
proliferate[2] = function(e)
    spell:gdmgxy(e.sourcep, dmg.type.stack[atypelookup[e.atktype]], e.amount*0.15, utils.unitx(e.target), utils.unity(e.target), 300.0)
    bf_freeze:apply(e.target, 1.5)
end


-- nature: deals 25% bonus damage and restores 2.5% of your max health.
proliferate[3] = function(e)
    dmg.type.stack[atypelookup[e.atktype]]:pdeal(e.sourcep, e.amount*0.25, e.target)
    utils.addlifep(e.source, 2.5, true, e.source)
end


-- fire: creates a pool of fire that damages targets for 50% of its original damage over 3 sec in a 3m radius.
proliferate[4] = function(e)
    local d,p,x,y,dtype = e.amount/3, e.sourcep, utils.unitx(e.target), utils.unity(e.target), dmg.type.stack[atypelookup[e.atktype]]
    speff_liqfire:play(utils.unitx(e.target), utils.unity(e.target), 3.0, 1.1)
    utils.timedrepeat(1.0, 3, function() dmg.overtime = true spell:gdmgxy(p, dtype, d, x, y, 300.0) end,
        function() dtype = nil end)
end


-- shadow: summons a demon which attacks for 10% of the original damage for 6 sec.
proliferate[5] = function(e)
    if kobold.player[e.sourcep] then
        local x,y = utils.projectxy(utils.unitx(e.target), utils.unity(e.target), math.random(0,100), math.random(0,360))
        ai:new(utils.unitatxy(e.sourcep, x, y, 'n00J', math.random(0,360)))
            :initcompanion(900.0, kobold.player[e.sourcep]:calcminiondmg(e.amount*0.10), p_stat_shadow)
            :timed(6.0)
        speff_deathpact:play(x, y)
    end
end


-- physical: deals 20% bonus damage, if the target is under 20% health, they take 100% bonus damage.
proliferate[6] = function(e)
    if utils.getlifep(e.target) < 20 then
        dmg.type.stack[atypelookup[e.atktype]]:pdeal(e.sourcep, e.amount*1.0, e.target)
    else
        dmg.type.stack[atypelookup[e.atktype]]:pdeal(e.sourcep, e.amount*0.20, e.target)
    end
end
