function ForestTrollWarlordInit(unit, i)
    LUA_VAR_FTW_UNIT = unit
    LUA_VAR_FTW_ITEMBOOL = {}
    ForestTrollWarlord_Data = {}
    ForestTrollWarlordItemsInit(i)
    ForestTrollWarlordAbilsInit(i)
    udg_mbHeroIcon[i] = 'ReplaceableTextures\\CommandButtons\\BTNForestTroll.blp'
    LeaderboardUpdateHeroIcon(i)
    udg_heroCanRegenMana[i] = false
    LUA_TRG_FTW_MAX_MANA = ItemShopSetManaCap(i, 100)
end

function ForestTrollWarlordItemsInit(pInt)

    -- raw code and descriptions
    local itemTable = {
        "I0AW", -- 1 (Q) Energized Pendant
        "I0AZ", -- 2 (W) Mojo of Fire
        "I0B2", -- 3 (E) Shuffling Hook
        "I0B5", -- 4 (Trait) Toeless Jumpers
        "I0AX", -- 5 (Q) Ring of Fangs
        "I0B0", -- 6 (W) Mojo of Frost
        "I0B3", -- 7 (E) Weightless Troll Garb
        "I0B6", -- 8 (Trait) Fencing Plate
        "I0AY", -- 9 (Q) Pocket Axe
        "I0B1", -- 10 (W) Mojo of Fibers
        "I0B4" -- 11 (E) Armor-Piercing Barbs
    }
    local itemTableUlt = {
        "I0B7", -- 12 (Q) Harrowing Blade
        "I0B8", -- 13 (W) Mojo of Vampirism
        "I0B9", -- 14 (E) Spirit Sling
        "I0BA", -- 15 (Trait) Trinket of Jammin'
        "I0BB", -- 16 (R1) Skull Breaker
        "I0BC" -- 17 (R2) Blood Poker
    }

    -- non-itemBool custom effects
    local conditionsFunc = function(itemId)
        if (itemId == FourCC("I0B3")) then IncUnitAbilityLevel(LUA_VAR_FTW_UNIT,FourCC("A07G"))
        elseif (itemId == FourCC("I0B5")) then ForestTrollWarlord_Data.acrobatRange = 300.0
        elseif (itemId == FourCC("I0AY")) then
            ForestTrollWarlord_Data.qCharges.uses = ForestTrollWarlord_Data.qCharges.uses + 1
            SpellPackChargedRefresh(ForestTrollWarlord_Data.qCharges)
        elseif (itemId == FourCC("I0BB")) then ForestTrollWarlord_Data.rendingRequired = 2
        elseif (itemId == FourCC("I0BB")) then
            DestroyTrigger(LUA_TRG_FTW_MAX_MANA)
            LUA_TRG_FTW_MAX_MANA = ItemShopSetManaCap(GetConvertedPlayerId(GetOwningPlayer(GetTriggerUnit())), 125) end
    end

    ItemShopGenerateShop(pInt,itemTable,conditionsFunc,LUA_VAR_FTW_ITEMBOOL,itemTableUlt)

end

function ForestTrollWarlordAbilsInit(pInt)

    ForestTrollWarlord_Acrobatic    = CreateTrigger()
    ForestTrollWarlord_Rending      = CreateTrigger()
    ForestTrollWarlord_Taz          = CreateTrigger()
    ForestTrollWarlord_Grapple      = CreateTrigger()
    ForestTrollWarlord_Skull        = CreateTrigger()
    ForestTrollWarlord_Flurry       = CreateTrigger()
    ForestTrollWarlord_Skull_learn  = CreateTrigger()
    ForestTrollWarlord_Flurry_learn = CreateTrigger()
    ForestTrollWarlord_Auto         = CreateTrigger()

    ForestTrollWarlord_Data.qCharges         = SpellPackChargedAbilityInit(udg_playerHero[pInt], 'A07E', 0, 2, 12.0, 12.0)
    ForestTrollWarlord_Data.traitTimer       = NewTimer()
    ForestTrollWarlord_Data.flurryTimer      = NewTimer()
    ForestTrollWarlord_Data.cleaver          = 0 -- # skull cleaver active
    ForestTrollWarlord_Data.rendingCasts     = 0 -- skull cleaver proc
    ForestTrollWarlord_Data.rendingRequired  = 3 -- casts required
    ForestTrollWarlord_Data.R1               = false
    ForestTrollWarlord_Data.R2               = false
    ForestTrollWarlord_Data.fireAttacks      = 0
    ForestTrollWarlord_Data.frostAttacks     = 0
    ForestTrollWarlord_Data.fiberAttacks     = 0
    ForestTrollWarlord_Data.acrobatRange     = 200.0
    SpellPackChargedRefresh(ForestTrollWarlord_Data.qCharges)

    ForestTrollWarlord_Acrobatic_l  = CreateTrigger()
    TriggerRegisterPlayerUnitEvent(ForestTrollWarlord_Acrobatic_l,Player(pInt-1),EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, nil)
    TriggerAddCondition(ForestTrollWarlord_Acrobatic_l, Condition( function() return
        GetOrderedUnit() == udg_playerHero[pInt]
        and (GetIssuedOrderIdBJ() == 851986 or GetIssuedOrderIdBJ() == 851971) end)) -- 'move' or 'smart'
    TriggerAddAction(ForestTrollWarlord_Acrobatic_l, function()
        local caster        = GetOrderedUnit()
        local tarX          = GetOrderPointX()
        local tarY          = GetOrderPointY()
        local landX,landY   = PolarProjectionXY(GetUnitX(caster),GetUnitY(caster),ForestTrollWarlord_Data.acrobatRange,
            AngleBetweenXY(GetUnitX(caster),GetUnitY(caster),tarX,tarY))
        DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Human\\FlakCannons\\FlakTarget.mdl',landX,landY))
        HeroLeapTargetPoint(caster,0.15,landX,landY,nil,nil)
        PauseTimer(ForestTrollWarlord_Data.traitTimer)
        if LUA_VAR_FTW_ITEMBOOL[8] then DamagePackageDummyTarget(caster,'A053','innerfire') end
        if LUA_VAR_FTW_ITEMBOOL[15] then
            DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageCaster.mdl',GetUnitX(caster),GetUnitY(caster)))
            UnitAddAbility(caster, FourCC('A07O')) -- 100% evasion
            TimerStart(NewTimer(),0.33,false,function() UnitRemoveAbility(caster, FourCC('A07O')) ReleaseTimer() end)
        end
        DisableTrigger(ForestTrollWarlord_Acrobatic_l)
    end)
    DisableTrigger(ForestTrollWarlord_Acrobatic_l)


    -- on-use trait
    local ForestTrollWarlord_Acrobatic_f = function()
        ForestTrollWarlord_Acrobatic_activate()
    end


    -- activate dash
    function ForestTrollWarlord_Acrobatic_activate()
        EnableTrigger(ForestTrollWarlord_Acrobatic_l)
        TimerStart(ForestTrollWarlord_Data.traitTimer,6.0,false,function()
            DisableTrigger(ForestTrollWarlord_Acrobatic_l)
        end)
    end


    -- convert to melee attacks
    function ForestTrollWarlord_melee_activate(u)
        SetPlayerTechResearchedSwap( FourCC('R00D'), 1, GetOwningPlayer(u) )
        TimerStart(ForestTrollWarlord_Data.flurryTimer,12.0,false,function()
            ForestTrollWarlord_melee_deactivate(u)
        end)
        DamagePackageDummyTarget(u,'A07P','bloodlust') -- add melee eyecandy buff
    end


    -- convert to ranged attacks
    function ForestTrollWarlord_melee_deactivate(u)
        SetPlayerTechResearchedSwap( FourCC('R00D'), 0, GetOwningPlayer(u) )
        PauseTimer(ForestTrollWarlord_Data.flurryTimer)
        UnitRemoveBuffBJ( FourCC('B01Y'), u ) -- remove melee eyecandy buff
    end


    local ForestTrollWarlord_Rending_f = function()
        local caster, tarX, tarY, casterX, casterY = SpellPackSetupTargetAbil()
        local dmgEffect    = 'Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl'
        local dmg          = GetHeroStatBJ(bj_HEROSTAT_AGI, caster, true)*1.15
        local dur          = 6.0
        if LUA_VAR_FTW_ITEMBOOL[5] and DistanceBetweenXY(casterX, casterY, tarX, tarY) >= 400.0 then
            dmg = dmg*1.25
        end
        if LUA_VAR_FTW_ITEMBOOL[12] then
            dmg = dmg*1.2
            dur = dur + 6.0
        end

        if ForestTrollWarlord_Data.R1 then -- hero has Skull Cleaver learned
            ForestTrollWarlord_Data.rendingCasts = ForestTrollWarlord_Data.rendingCasts + 1
            if ForestTrollWarlord_Data.rendingCasts > ForestTrollWarlord_Data.rendingRequired then -- every 4th use, activate Skull Cleaver
                ForestTrollWarlord_Data.rendingCasts = 0
                ForestTrollWarlord_Skull_update(1)
            end
        end

        local landFunc = function(x,y)
            -- land effect:
            DestroyEffect(AddSpecialEffect(dmgEffect,x,y))
            DamagePackageDealAOE(caster, x, y, 150.0, dmg, false, false, '', '', dmgEffect, 1.0)
            -- axe collection glow eye candy:
            local glow = AddSpecialEffect('Abilities\\Spells\\Human\\Brilliance\\Brilliance.mdl',x,y)
            BlzSetSpecialEffectScale( glow, 0.6 )
            BlzSetSpecialEffectAlpha( glow, 175 )
            -- axe dummy:
            local axe = DamagePackageCreateDummy(GetOwningPlayer(caster),'e00V', x, y, AngleBetweenXY(casterX,casterY,tarX,tarY), 6.0)
            local trig = CreateTrigger()
            -- collection trigger:
            TriggerRegisterUnitInRangeSimple( trig, 65.0, axe )
            TriggerAddCondition(trig, Condition( function() return GetTriggerUnit() == caster end ) )
            -- collect func:
            TriggerAddAction(trig, function()
                DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl',GetUnitX(caster), GetUnitY(caster)))
                if UnitHasBuffBJ(caster,FourCC('B01W')) then -- Jungle Flurry active, buff AS and MS.
                    if UnitHasBuffBJ(caster,FourCC('B01G')) then -- apply again after 3 sec if it should "stack" on 2 quick collections.
                        TimerStart(NewTimer(),3.0,false,function()
                            DamagePackageDummyTarget(caster,'A063','bloodlust') ReleaseTimer() end)
                    end
                    DamagePackageDummyTarget(caster,'A063','bloodlust')
                else -- normal collection, reset charges
                    SpellPackChargedRefresh(ForestTrollWarlord_Data.qCharges)
                end
                if axe then RemoveUnit(axe) end
                if glow then BlzSetSpecialEffectZ(glow, 3000) DestroyEffect(glow) end -- effect doesn't fade immediately, so do Z trick.
                -- if a charge is recovered, convert to ranged:
                if LUA_VAR_FTW_ITEMBOOL[1] then DamagePackageAddMana(caster,10,false) end
            end)
            TimerStart(NewTimer(),dur,false,function()
                if axe then RemoveUnit(axe) end
                if glow then BlzSetSpecialEffectZ(glow, 3000) DestroyEffect(glow) end
                ReleaseTimer()
            end)
            -- wait to pause anim, orient axe in the ground:
            TimerStart(NewTimer(),0.12,false,function() SetUnitTimeScalePercent( axe, 0.00 ) ReleaseTimer() end)
        end

        if ForestTrollWarlord_Data.cleaver <= 0 then -- R2
            SpellPackParabolicMissile(casterX,casterY,tarX,tarY,250.0,0.75,'Abilities\\Weapons\\Axe\\AxeMissile.mdl',1.33,landFunc)
        else
            g = CreateGroup()
            local cleaverFunc = function(x,y)
                GroupEnumUnitsInRange(g,x,y,150.0, Condition(function() return
                    BasicDamageExpr(GetOwningPlayer(caster))
                    and not IsUnitType(GetFilterUnit(),UNIT_TYPE_ANCIENT) end))
                GroupUtilsAction(g, function()
                    local dmg = GetUnitState(LUA_FILTERUNIT, UNIT_STATE_MAX_LIFE)*0.08
                    DestroyEffect(AddSpecialEffect('Objects\\Spawnmodels\\Orc\\OrcSmallDeathExplode\\OrcSmallDeathExplode.mdl',
                        GetUnitX(LUA_FILTERUNIT),GetUnitY(LUA_FILTERUNIT)))
                    UnitDamageTargetBJ(caster,LUA_FILTERUNIT,dmg,ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)
                    DamagePackageDummyTarget(caster,'A009','slow',LUA_FILTERUNIT)
                end)
                DestroyGroup(g)
            end
            local e = SpellPackParabolicMissile(casterX,casterY,tarX,tarY,250.0,0.75,'Abilities\\Weapons\\Axe\\AxeMissile.mdl',2.25,landFunc)
            BlzSetSpecialEffectColor(e, 255, 90, 90)
            -- additional special effect:
            SpellPackParabolicMissile(casterX,casterY,tarX,tarY,250.0,0.75,'Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl',1.25,cleaverFunc)
            ForestTrollWarlord_Skull_update(-1)
        end

        SpellPackChargedConsumed(ForestTrollWarlord_Data.qCharges)
        -- if charges are expended, convert to melee:
        if ForestTrollWarlord_Data.qCharges.consumed >= ForestTrollWarlord_Data.qCharges.uses then
            ForestTrollWarlord_melee_activate(caster)
        end
        -- activate trait:
        ForestTrollWarlord_Acrobatic_activate()
    end


    local ForestTrollWarlord_Taz_f = function()
        local caster, casterX, casterY = SpellPackSetupInstantAbil()
        DamagePackageDummyTarget(caster,'A07N','bloodlust')
        DamagePackageDummyAoE(caster,'A07K','roar')
        ForestTrollWarlord_Data.fireAttacks  = 0
        ForestTrollWarlord_Data.frostAttacks = 0
        ForestTrollWarlord_Data.fiberAttacks = 0
    end


    local ForestTrollWarlord_Grapple_f = function()
        local caster, tarX, tarY, casterX, casterY = SpellPackSetupTargetAbil()
        local target = GetSpellTargetUnit() or nil
        if LUA_VAR_FTW_ITEMBOOL[3] and target and IsUnitAlly(target, GetOwningPlayer(caster))
          and IsUnitType(target,UNIT_TYPE_HERO) and not IsUnitType(target,UNIT_TYPE_ANCIENT) then
            -- ally effects:
            HeroLeapTargetPoint(target,0.33,casterX,casterY,nil,nil)
            DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Orc\\FeralSpirit\\feralspiritdone.mdl',GetUnitX(target), GetUnitY(target)))
        elseif target and IsUnitEnemy(target, GetOwningPlayer(caster))
          and not IsUnitType(target,UNIT_TYPE_ANCIENT) then
                if (not HeroLeapTargetPoint(caster,0.33,tarX,tarY,nil,nil)) then
                    DamagePackageAddMana(caster,50)
                else
                    DestroyEffect(AddSpecialEffect('Abilities\\Spells\\Orc\\FeralSpirit\\feralspiritdone.mdl',GetUnitX(target), GetUnitY(target)))
                    -- enemy effects:
                    if LUA_VAR_FTW_ITEMBOOL[11] then
                        DamagePackageDummyTarget(caster,'A04S','faeriefire',target)
                    end
                    if LUA_VAR_FTW_ITEMBOOL[14] then
                        DamagePackageDummyTarget(caster,'A03H','thunderbolt',target)
                        TimerStart(NewTimer(),1.0,false,function() DamagePackageDummyTarget(caster,'A009','slow',target) end)
                    end
                end            
        else
            -- target ground:
            if (not HeroLeapTargetPoint(caster,0.33,tarX,tarY,nil,nil)) then
                DamagePackageAddMana(caster,50)
            end
        end
    end


    -- amount = 1 or -1
    function ForestTrollWarlord_Skull_update(amount) -- don't allow more than 2 stored charges
        ForestTrollWarlord_Data.cleaver = ForestTrollWarlord_Data.cleaver + amount
        if ForestTrollWarlord_Data.cleaver > 2 then
            ForestTrollWarlord_Data.cleaver = 2
        elseif ForestTrollWarlord_Data.cleaver < 0 then
            ForestTrollWarlord_Data.cleaver = 0
        end
    end


    local ForestTrollWarlord_Skull_f = function()
        ForestTrollWarlord_melee_deactivate(GetTriggerUnit())
        SpellPackChargedRefresh(ForestTrollWarlord_Data.qCharges)
        ForestTrollWarlord_Data.qCharges.consumed = 0
        ForestTrollWarlord_Skull_update(1)
    end


    local ForestTrollWarlord_Flurry_f = function()
        local caster, tarX, tarY, target, casterX, casterY = SpellPackSetupTargetUnitAbil()
        if (not HeroLeapTargetPoint(caster,0.33,tarX,tarY,nil,nil)) then
            DamagePackageAddMana(caster,50)
        else
            -- wait for charge to land:
            TimerStart(NewTimer(),0.33,false,function()
                DamagePackageDummyTarget(caster,'A07M','slow',target)
                IssueTargetOrderById(caster,851983,target)
                ReleaseTimer()
            end)
        end
    end

    ForestTrollWarlord_Auto_f = function()
        if UnitHasBuffBJ(udg_DamageEventSource,FourCC('B01X')) then
            if LUA_VAR_FTW_ITEMBOOL[2] then -- fire
                ForestTrollWarlord_Data.fireAttacks = ForestTrollWarlord_Data.fireAttacks + 1
                if math.fmod(ForestTrollWarlord_Data.fireAttacks,2) == 0 then
                    ForestTrollWarlord_Data.fireAttacks = 0
                    DamagePackageDealAOE(udg_DamageEventSource, GetUnitX(udg_DamageEventTarget), GetUnitY(udg_DamageEventTarget), 
                        150.0, udg_DamageEventAmount*0.50, false, false, '', '', 'Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl', 0.7)
                end
            end
            if LUA_VAR_FTW_ITEMBOOL[6] then -- frost
                ForestTrollWarlord_Data.frostAttacks = ForestTrollWarlord_Data.frostAttacks + 1
                if math.fmod(ForestTrollWarlord_Data.frostAttacks,2) == 0 then
                    ForestTrollWarlord_Data.frostAttacks = 0
                    DamagePackageDealAOE(udg_DamageEventSource, GetUnitX(udg_DamageEventTarget), GetUnitY(udg_DamageEventTarget), 
                        150.0, udg_DamageEventAmount*0.25, false, true, 'A07D', 'slow', 'Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl', 0.7)
                end
            end
            if LUA_VAR_FTW_ITEMBOOL[10] then -- fibers
                ForestTrollWarlord_Data.fiberAttacks = ForestTrollWarlord_Data.fiberAttacks + 1
                if math.fmod(ForestTrollWarlord_Data.fiberAttacks,2) == 0 then
                    ForestTrollWarlord_Data.fiberAttacks = 0
                    DamagePackageRestoreHealth(udg_DamageEventSource,10.0,true,'Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl',udg_DamageEventSource)
                end
            end
            if LUA_VAR_FTW_ITEMBOOL[13] then
                DamagePackageRestoreHealth(udg_DamageEventSource,udg_DamageEventAmount*0.35,false,
                    'Objects\\Spawnmodels\\Other\\BeastmasterBlood\\BeastmasterBlood.mdl',udg_DamageEventSource)
            end
            if LUA_VAR_FTW_ITEMBOOL[17] and UnitHasBuffBJ(udg_DamageEventSource,FourCC('B01W')) then -- has jungle flurry
                UnitDamageTargetBJ(udg_DamageEventSource,udg_DamageEventTarget,GetUnitState(udg_DamageEventTarget,UNIT_STATE_MAX_LIFE)*0.02,
                    ATTACK_TYPE_NORMAL,DAMAGE_TYPE_NORMAL)
                DestroyEffect(AddSpecialEffect('Objects\\Spawnmodels\\Orc\\OrcSmallDeathExplode\\OrcSmallDeathExplode.mdl',
                    GetUnitX(udg_DamageEventTarget),GetUnitY(udg_DamageEventTarget)))
            end
        end
    end

    local boolexpr = function() return udg_DamageEventSource == udg_playerHero[pInt] and udg_DamageEventAttackT == udg_ATTACK_TYPE_HERO
        and udg_IsDamageMelee end
    SpellPackCreateDamageTrigger(ForestTrollWarlord_Auto,ForestTrollWarlord_Auto_f,pInt,boolexpr,nil)

    SpellPackCreateTrigger(ForestTrollWarlord_Acrobatic,ForestTrollWarlord_Acrobatic_f,pInt,'A07L')
    SpellPackCreateTrigger(ForestTrollWarlord_Rending,ForestTrollWarlord_Rending_f,pInt,    'A07E')
    SpellPackCreateTrigger(ForestTrollWarlord_Taz,ForestTrollWarlord_Taz_f,pInt,            'A07F')
    SpellPackCreateTrigger(ForestTrollWarlord_Grapple,ForestTrollWarlord_Grapple_f,pInt,    'A07G')
    SpellPackCreateTrigger(ForestTrollWarlord_Skull,ForestTrollWarlord_Skull_f,pInt,        'A07H')
    SpellPackCreateTrigger(ForestTrollWarlord_Flurry,ForestTrollWarlord_Flurry_f,pInt,      'A07I')
    local R1func = function() ForestTrollWarlord_Data.R1 = true end
    local R2func = function() ForestTrollWarlord_Data.R2 = true end
    SpellPackCreateLearnTrigger(ForestTrollWarlord_Skull_learn, pInt, 'A07H', R1func)
    SpellPackCreateLearnTrigger(ForestTrollWarlord_Flurry_learn, pInt, 'A07I', R2func)

end
