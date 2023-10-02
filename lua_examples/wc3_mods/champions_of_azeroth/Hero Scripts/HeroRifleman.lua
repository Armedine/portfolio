function RiflemanInit(unit, i)
    Rifleman_Data              = {}
    LUA_VAR_RIFLEMAN_UNIT      = unit
    LUA_VAR_RIFLEMAN_ITEMBOOL  = {}
    RiflemanItemsInit(i)
    RiflemanAbilsInit(i)
    udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNRifleman.blp'
    LeaderboardUpdateHeroIcon(i)
end

function RiflemanItemsInit(pInt)

    -- raw code and descriptions
    local itemTable = {
        "I0AF", -- 1 (Q) Boomerang Sling
        "I0AI", -- 2 (W) Dragonfire Barrel
        "I0AL", -- 3 (E) Gnomish Rocket Gloves
        "I0AO", -- 4 (Trait) Twin Barreled Flare Gun
        "I0AG", -- 5 (Q) Unstable Gunpowder
        "I0AJ", -- 6 (W) Binding Shells
        "I0AM", -- 7 (E) Scout Uniform
        "I0AP", -- 8 (Trait) Hunting Scope
        "I0AH", -- 9 (Q) Long Rifle
        "I0AK", -- 10 (W) Bouncing Vial
        "I0AN" -- 11 (E) Rationing Kit
    }
    local itemTableUlt = {
        "I0AQ", -- 12 (Q) Doomsday Cannon
        "I0AR", -- 13 (W) Doomsday Shells
        "I0AS", -- 14 (E) Inferno Treads
        "I0AT", -- 15 (Trait) Gnomish Autoloader
        "I0AU", -- 16 (R1) Squadron 88 Decal
        "I0AV" -- 17 (R2) Rocket Magnet
    }

    -- non-itemBool custom effects
    local conditionsFunc = function(itemId)
        if (itemId == FourCC('I0AR')) then
            Rifleman_Data.wCharges.uses = Rifleman_Data.wCharges.uses + 2
            SpellPackChargedConsumed(Rifleman_Data.wCharges)
        elseif (itemId == FourCC('I0AM')) then
            Rifleman_Data.eCharges = SpellPackChargedAbilityInit(udg_playerHero[pInt], 'A078', 1, 2, 16.0, 16.0)
            SpellPackChargedRefresh(Rifleman_Data.eCharges)
            IncUnitAbilityLevel(udg_playerHero[pInt],FourCC('A078'))
        elseif (itemId == FourCC('I0AO')) then
            IncUnitAbilityLevel(udg_playerHero[pInt],FourCC('A07C'))
        end
    end

    ItemShopGenerateShop(pInt,itemTable,conditionsFunc,LUA_VAR_RIFLEMAN_ITEMBOOL,itemTableUlt)

end

function RiflemanAbilsInit(pInt)

    Rifleman_Flare  = CreateTrigger()
    Rifleman_Shot   = CreateTrigger()
    Rifleman_Bomb   = CreateTrigger()
    Rifleman_Vault  = CreateTrigger()
    Rifleman_Strike = CreateTrigger()
    Rifleman_Big    = CreateTrigger()

    Rifleman_Data.oilCoords     = {}
    Rifleman_Data.qCharges      = SpellPackChargedAbilityInit(udg_playerHero[pInt], 'A077', 0, 3, 8.0, 8.0)
    Rifleman_Data.wCharges      = SpellPackChargedAbilityInit(udg_playerHero[pInt], 'A079', 0, 2, 12.0, 12.0)


    local Rifleman_Flare_f = function()
        if LUA_VAR_RIFLEMAN_ITEMBOOL[8] then
            local caster, tarX, tarY, casterX, casterY = SpellPackSetupTargetAbil()
            local g = CreateGroup()
            GroupEnumUnitsInRange(g, tarX, tarY, 600.0, Condition( function() return BasicDamageExpr(GetOwningPlayer(caster)) end ) )
            GroupUtilsAction(g, function() DamagePackageDummyTarget(caster,'A04S','faeriefire', LUA_FILTERUNIT) end)
            DestroyGroup(g)
        end
    end


    local Rifleman_Shot_Ignite_Dmg_f = function(u,o)
        -- pass this in for ignited missiles
        DamagePackageDealAOE(LuaMissileStack[o].ownerUnit, LuaMissileStack[o].missileX, LuaMissileStack[o].missileY, 
            200.0, LuaMissileStack[o].damage*0.50, false, false,
            '', '', '', 1.0)
        DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl',
            LuaMissileStack[o].missileX, LuaMissileStack[o].missileY))
        if LUA_VAR_RIFLEMAN_ITEMBOOL[6] and not LuaMissileStack[o].binding then
            LuaMissileStack[o].binding = true
            DamagePackageDummyTarget(LuaMissileStack[o].ownerUnit,'A07D','slow',u)
        end
    end

    local Rifleman_Shot_Ignite_f = function(o)
        local length = tablelength(Rifleman_Data.oilCoords)
        if LuaMissileStack[o].ignited == nil and length > 0 then
            for i = 1,length do
                if Rifleman_Data.oilCoords[i] ~= nil then
                    if DistanceBetweenXY(Rifleman_Data.oilCoords[i].x,Rifleman_Data.oilCoords[i].y,
                        LuaMissileStack[o].missileX, LuaMissileStack[o].missileY) <= 100.0 then
                        LuaMissileStack[o].ignited = true
                        -- timer func for LuaMissile to ignite missiles
                        DestroyEffect(LuaMissileStack[o].effect)
                        LuaMissileStack[o].effect = AddSpecialEffect('Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl',
                            LuaMissileStack[o].missileX, LuaMissileStack[o].missileY)
                        -- to prevent skipping animations, reset height:
                        BlzSetSpecialEffectZ(LuaMissileStack[o].effect, LuaMissileStack[o].missileZ)
                        -- assign on hit func:
                        LuaMissileStack[o].dmgFunc = Rifleman_Shot_Ignite_Dmg_f
                        if LUA_VAR_RIFLEMAN_ITEMBOOL[5] and not LuaMissileStack[o].enhanced then
                            LuaMissileStack[o].enhanced = true
                            LuaMissileStack[o].collides = false
                            LuaMissileStack[o].damage   = LuaMissileStack[o].damage*1.10
                        end
                        break
                    end
                end
            end
        end
        if LUA_VAR_RIFLEMAN_ITEMBOOL[1] and not LuaMissileStack[o].reflected
            and LuaMissileStack[o].traveled > (LuaMissileStack[o].distance - 40.0) then
            LuaMissileStack[o].reflected    = true
            LuaMissileStack[o].traveled     = 0.0
            LuaMissileStack[o].angle        = LuaMissileStack[o].angle - 180.0
            GroupClear(LuaMissileStack[o].damageGroup)
        end
    end

    local Rifleman_Shot_f = function()
        local caster, tarX, tarY, casterX, casterY = SpellPackSetupTargetAbil()
        local maxShots      = 3
        local range         = 600.0
        if LUA_VAR_RIFLEMAN_ITEMBOOL[12] then
            maxShots = maxShots + 2
        end
        if LUA_VAR_RIFLEMAN_ITEMBOOL[9] then
            range = range + 300.0
        end
        local angleOffset   = 11.0*(maxShots - 1)
        local angle         = AngleBetweenXY(casterX,casterY,tarX,tarY) - angleOffset/2.0
        local dmg           = GetHeroStatBJ(bj_HEROSTAT_AGI, caster, true)*0.40
        local str           = 'Abilities\\Weapons\\CannonTowerMissile\\CannonTowerMissile.mdl'
        local x,y
        for i = 1,maxShots do
            x,y = PolarProjectionXY(casterX, casterY, range, angle)
            LuaMissile.create(caster,x,y,range,0.75,dmg,50.0,true,false,false,nil,nil,str,str,50.0,0.75,Rifleman_Shot_Ignite_f,nil,nil)
            angle = angle + 11.0
        end
        SpellPackChargedConsumed(Rifleman_Data.qCharges)
    end


    local Rifleman_Bomb_Oil_f = function(u,x,y,d,owner)
        -- create pool of oil with timer
        local effect        = AddSpecialEffect('Abilities\\Spells\\Orc\\LiquidFire\\Liquidfire.mdl',x,y)
        -- since a dummy instance gets removed, we need to reference the hero:
        local owner         = udg_playerHero[GetConvertedPlayerId(GetOwningPlayer(u))]
        local dmgInitial    = GetHeroStatBJ(bj_HEROSTAT_AGI, owner, true)*0.50
        local dmgTime       = GetHeroStatBJ(bj_HEROSTAT_AGI, owner, true)*0.15
        local i             = 0
        local duration      = 9.0
        local length        = tablelength(Rifleman_Data.oilCoords) + 1
        if LUA_VAR_RIFLEMAN_ITEMBOOL[2] then
            dmgInitial      = dmgInitial*1.30
            duration        = duration + 3.0
        end
        Rifleman_Data.oilCoords[length]   = {}
        Rifleman_Data.oilCoords[length].x = x
        Rifleman_Data.oilCoords[length].y = y
        DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl',x,y))
        DamagePackageDealAOE(owner, x, y, 200.0, dmgInitial, false, false, '', '', '', 0.5)
        -- only remove charges when the hero uses the ability:
        if IsUnitType(u,UNIT_TYPE_HERO) then
            
        end
        TimerStart(NewTimer(),1.0,true,function()
            DamagePackageDealAOE(owner, x, y, 200.0, dmgTime, false, false, '', '', '', 0.5)
            i = i + 1
            if i >= duration then
                DestroyEffect(effect)
                Rifleman_Data.oilCoords[length] = nil
                ReleaseTimer() end
        end)
    end

    local Rifleman_Bomb_f = function()
        local caster, tarX, tarY, casterX, casterY = SpellPackSetupTargetAbil()
        local distance = DistanceBetweenXY(casterX, casterY, tarX, tarY)
        local x2,y2
        local shouldBounce = false
        if IsUnitType(caster,UNIT_TYPE_HERO) then
            SpellPackChargedConsumed(Rifleman_Data.wCharges)
            if LUA_VAR_RIFLEMAN_ITEMBOOL[10] then
                shouldBounce = true
            end
        end
        TimerStart(NewTimer(),distance/815,false,function()
            -- abil effects after missile lands
            Rifleman_Bomb_Oil_f(caster,tarX,tarY)
            if shouldBounce then
                x2,y2 = PolarProjectionXY(tarX, tarY, distance, AngleBetweenPointsXY(casterX, casterY, tarX, tarY))
                DamagePackageDummyAoE(caster, 'A079', 'clusterrockets', nil, tarX, tarY, x2, y2, nil)
            end
            ReleaseTimer()
        end)
    end


    local Rifleman_Vault_f = function()
        local caster, tarX, tarY, casterX, casterY = SpellPackSetupTargetAbil()
        if LUA_VAR_RIFLEMAN_ITEMBOOL[14] then
            DamagePackageDummyTarget(caster,'A05G','bloodlust')
        end
        if LUA_VAR_RIFLEMAN_ITEMBOOL[11] then
            if Rifleman_Data.qCharges.consumed > 0 then
                SpellPackChargedRefresh(Rifleman_Data.qCharges)
            end
        end
        if LUA_VAR_RIFLEMAN_ITEMBOOL[3] then
            local length = tablelength(Rifleman_Data.oilCoords)
            if length > 0 then
                for i = 1,length do
                    if Rifleman_Data.oilCoords[i] ~= nil then
                        if DistanceBetweenXY(Rifleman_Data.oilCoords[i].x,Rifleman_Data.oilCoords[i].y,casterX,casterY) <= 100.0 then
                            tarX,tarY = PolarProjectionXY(tarX,tarY,300.0,AngleBetweenXY(casterX, casterY, tarX, tarY))
                            DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl',casterX, casterY))
                            break
                        end
                    end
                end
            end
        end
        -- run the leap code; if it fails, reduce charges consumed if charges item is enabled:
        if not HeroLeapTargetPoint(caster,0.33,tarX,tarY,nil,nil) and Rifleman_Data.eCharges then
            SpellPackChargedRefresh(Rifleman_Data.eCharges)
        end
        if Rifleman_Data.eCharges then
            SpellPackChargedConsumed(Rifleman_Data.eCharges)
        end
    end


    local Rifleman_Strike_f = function()
        local caster, tarX, tarY, casterX, casterY = SpellPackSetupTargetAbil()
        local angle     = AngleBetweenPointsXY(casterX,casterY,tarX,tarY)
        local distance  = DistanceBetweenXY(casterX,casterY,tarX,tarY) -- this can't be over the ability range because of its cast range
        local x2,y2     = PolarProjectionXY(tarX, tarY, 600.0, angle) -- 600.0 offset from chosen location
        local copter    = DamagePackageCreateDummy(GetOwningPlayer(caster), 'h00G', casterX, casterY, angle, 6.0)
        local i         = 0
        SetUnitMoveSpeed(copter,300.0)
        IssuePointOrder(copter,"move",tarX,tarY)
        TimerStart(NewTimer(),0.03,true,function()
            if DistanceBetweenXY(GetUnitX(copter),GetUnitY(copter),tarX,tarY) < 200.0 then
                IssuePointOrder(copter,"move",x2,y2)
                TimerStart(NewTimer(),0.33,true,function()
                    i = i + 1
                    if i < 9 and IsUnitAliveBJ(copter) then
                        Rifleman_Bomb_Oil_f(caster,GetUnitX(copter),GetUnitY(copter))
                    else
                        RemoveUnit(copter)
                        ReleaseTimer()
                    end
                end)
                ReleaseTimer()
            elseif not IsUnitAliveBJ(copter) then
                ReleaseTimer()
            end
        end)
        if LUA_VAR_RIFLEMAN_ITEMBOOL[16] and IsUnitType(caster,UNIT_TYPE_HERO) then
            local x3,y3,x4,y4
            x3,y3 = PolarProjectionXY(casterX, casterY, 150.0, angle - 90)
            x4,y4 = PolarProjectionXY(x3, y3, distance-3.0, angle) -- nudge distance so it's definitely in range
            DamagePackageDummyAoE(caster, 'A07A', 'flamestrike', nil, x3, y3, x4, y4, nil)
            x3,y3 = PolarProjectionXY(casterX, casterY, 150.0, angle + 90)
            x4,y4 = PolarProjectionXY(x3, y3, distance-3.0, angle)
            DamagePackageDummyAoE(caster, 'A07A', 'flamestrike', nil, x3, y3, x4, y4, nil)
        end
    end


    local Rifleman_Big_Hit_f = function(u, o)
        -- when Big One hits an enemy do:
        DamagePackageDummyTarget(u,'A04O','thunderbolt',u)
    end

    local Rifleman_Big_Bounds_f = function(o)
        if math.fmod(Rifleman_Data.bigEffect,14) == 0 then
            DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl',
                LuaMissileStack[o].missileX, LuaMissileStack[o].missileY))
            Rifleman_Data.bigEffect = 1
        else
            Rifleman_Data.bigEffect = Rifleman_Data.bigEffect + 1
        end
        -- item effects:
        if LUA_VAR_RIFLEMAN_ITEMBOOL[17] and LuaMissileStack[o].reflected == nil and LuaMissileStack[o].traveled > 1600.0 then
            LuaMissileStack[o].reflected = true
            GroupClear(LuaMissileStack[o].damageGroup) -- allow damage again
            LuaMissileStack[o].angle = LuaMissileStack[o].angle - 180.0
            DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Other\\Charm\\CharmTarget.mdl',
                LuaMissileStack[o].missileX, LuaMissileStack[o].missileY))
        end
        -- destroy missile or do other things when it exits map bounds
        if not RectContainsCoords(bj_mapInitialPlayableArea,LuaMissileStack[o].missileX,LuaMissileStack[o].missileY) then
            RemoveUnit(Rifleman_Data.bigVision)
            LuaMissile.destroy(o)
        else
            SetUnitX(Rifleman_Data.bigVision,LuaMissileStack[o].missileX)
            SetUnitY(Rifleman_Data.bigVision,LuaMissileStack[o].missileY)
        end
    end

    local Rifleman_Big_f = function()
        local caster, tarX, tarY, casterX, casterY = SpellPackSetupTargetAbil()
        local dmg        = GetHeroStatBJ(bj_HEROSTAT_AGI, caster, true)*3.50
        local str        = 'Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl'
        local mis = LuaMissile.create(caster,tarX,tarY,99999.0,1.5,dmg,150.0,false,false,false,nil,Rifleman_Big_Hit_f,
            str,str,100.0,2.0,Rifleman_Big_Bounds_f,nil,nil)
        Rifleman_Data.bigVision = DamagePackageCreateDummy(GetOwningPlayer(caster), 'e004', casterX, casterY, 270.0, 45.0)
        Rifleman_Data.bigEffect = 1
        mis.velocity = 20.5
        mis = nil
    end

    SpellPackCreateTrigger(Rifleman_Flare,Rifleman_Flare_f,pInt,    'A07C')
    SpellPackCreateTrigger(Rifleman_Shot,Rifleman_Shot_f,pInt,      'A077')
    SpellPackCreateTrigger(Rifleman_Bomb,Rifleman_Bomb_f,pInt,      'A079')
    SpellPackCreateTrigger(Rifleman_Vault,Rifleman_Vault_f,pInt,    'A078')
    SpellPackCreateTrigger(Rifleman_Strike,Rifleman_Strike_f,pInt,  'A07A')
    SpellPackCreateTrigger(Rifleman_Big,Rifleman_Big_f,pInt,        'A07B')

end
