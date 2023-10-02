function demomis()
    local angle = GetUnitFacing(GetTriggerUnit())
    local model = "Abilities\\Weapons\\CannonTowerMissile\\CannonTowerMissile.mdl"
    local mis   = missile:create_targetxy(GetOrderPointX(), GetOrderPointY(), GetTriggerUnit(), model, 25)
    mis.expl    = true
    mis.coleff  = "Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl"
end


function demoarc()
    local unit  = GetTriggerUnit()
    local x,y   = utils.unitxy(unit)
    local model = "Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl"
    local mis   = missile:create_arc(GetOrderPointX(), GetOrderPointY(), unit, model, 25)
end


function demomad()
    local unit  = GetTriggerUnit()
    local x,y   = utils.unitxy(unit)
    local model = "Abilities\\Weapons\\NecromancerMissile\\NecromancerMissile.mdl"
    local count = 50
    local inc   = 360.0/count
    local a     = 0
    local tarx,tary = 0, 0
    utils.timedrepeat(0.03, 5, function()
        for _ = 1,10 do
            local dir = math.random(0,1)
            tarx,tary = utils.projectxy(x, y, math.random(600,1200), a)
            local mis = missile:create_arc(tarx, tary, unit, model, 25)
            mis.vel   = 9
            mis.arch  = 450
            a = a + inc
        end
    end)
end


function demospn()
    local unit  = GetTriggerUnit()
    local x,y   = utils.unitxy(unit)
    local model = "Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl"
    local count = 50
    local inc   = 360.0/count
    local a     = 0
    local dur   = 6.0
    local tarx,tary = 0, 0
    utils.timedrepeat(0.03, 50, function()
        local dir = math.random(0,1)
        tarx,tary = utils.projectxy(x, y, 1200.0, a)
        local mis = missile:create_timedxy(tarx, tary, dur, unit, model, 25)
        mis.vel   = 20
        mis.func  = function(mis)
            if dir == 1 then
                mis.angle = mis.angle + math.random(1,15)
            else
                mis.angle = mis.angle - math.random(1,15)
            end
        end
        a = a + inc
    end)
end
