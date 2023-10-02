LUA_VAR_SANC_DATA               = {}
LUA_VAR_SANC_DATA.restoreGroup  = CreateGroup() -- restore health.
LUA_VAR_SANC_DATA.checkGroup    = CreateGroup() -- recycled check if rects are empty.
LUA_VAR_SANC_DATA.trigEnterH    = CreateTrigger() -- enter Horde (some bugs with registering 2 enter events, so split in two)
LUA_VAR_SANC_DATA.trigEnterA    = CreateTrigger() -- enter Alliance
LUA_VAR_SANC_DATA.trigLeave     = CreateTrigger()
LUA_VAR_SANC_DATA.timer         = NewTimer()

function SanctuaryPackageEnter(u)
    SetUnitInvulnerable(u,true)
    GroupAddUnit(LUA_VAR_SANC_DATA.restoreGroup, u)
    SanctuaryPackageTimer()
end


function SanctuaryPackageLeave(u)
    if udg_heroCanBecomeVulnerable[GetConvertedPlayerId(GetOwningPlayer(u))] then
        SetUnitInvulnerable(u,false)
    end
    GroupRemoveUnit(LUA_VAR_SANC_DATA.restoreGroup, u)
end


function SanctuaryPackageRestoration(u)
    if udg_heroCanRegenMana[GetConvertedPlayerId(GetOwningPlayer(u))] and GetUnitManaPercent(u) < 100.0 then
        DamagePackageAddMana(u,20.0,true)
    end
    if GetUnitLifePercent(u) < 100.0 then
        DamagePackageRestoreHealth(u,20.0,true,'Abilities\\Spells\\NightElf\\MoonWell\\MoonWellCasterArt.mdl')
    end
end


function SanctuaryPackageTimer()
    if BlzGroupGetSize(LUA_VAR_SANC_DATA.restoreGroup) > 0 then
        TimerStart(LUA_VAR_SANC_DATA.timer,1.0,true,function()
            if SanctuaryPackageTimerCheck() then
                GroupUtilsAction(LUA_VAR_SANC_DATA.restoreGroup, function() SanctuaryPackageRestoration(LUA_FILTERUNIT) end)
            end
            GroupEnumUnitsInRect(LUA_VAR_SANC_DATA.checkGroup,gg_rct_baseHordeRegen, Condition( function() return
                IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO) and not IsUnitType(GetTriggerUnit(),UNIT_TYPE_MECHANICAL) end))
            GroupEnumUnitsInRect(LUA_VAR_SANC_DATA.checkGroup,gg_rct_baseAllianceRegen, Condition( function() return
                IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO) and not IsUnitType(GetTriggerUnit(),UNIT_TYPE_MECHANICAL) end))
            if BlzGroupGetSize(LUA_VAR_SANC_DATA.checkGroup < 1) then
                GroupClear(LUA_VAR_SANC_DATA.restoreGroup)
                SanctuaryPackageTimerCheck()
            end
            GroupClear(LUA_VAR_SANC_DATA.checkGroup)
        end)
    end
end


function SanctuaryPackageTimerCheck()
    if BlzGroupGetSize(LUA_VAR_SANC_DATA.restoreGroup) < 1 then
        PauseTimer(LUA_VAR_SANC_DATA.timer)
        return false
    else
        return true
    end
end


function SanctuaryPackageInit()
    -- enter horde:
    TriggerRegisterEnterRectSimple(LUA_VAR_SANC_DATA.trigEnterH,gg_rct_baseHordeRegen)
    TriggerAddCondition(LUA_VAR_SANC_DATA.trigEnterH, Condition( function() return
        not IsUnitType(GetTriggerUnit(),UNIT_TYPE_MECHANICAL)
        and IsUnitType(GetTriggerUnit(),UNIT_TYPE_HERO)
        and IsUnitAlly(GetTriggerUnit(),Player(12))
    end))
    TriggerAddAction(LUA_VAR_SANC_DATA.trigEnterH, function()
        SanctuaryPackageEnter(GetTriggerUnit())
    end)
    -- enter alliance:
    TriggerRegisterEnterRectSimple(LUA_VAR_SANC_DATA.trigEnterA,gg_rct_baseAllianceRegen)
    TriggerAddCondition(LUA_VAR_SANC_DATA.trigEnterA, Condition( function() return
        not IsUnitType(GetTriggerUnit(),UNIT_TYPE_MECHANICAL)
        and IsUnitType(GetTriggerUnit(),UNIT_TYPE_HERO)
        and IsUnitAlly(GetTriggerUnit(),Player(13))
    end))
    TriggerAddAction(LUA_VAR_SANC_DATA.trigEnterA, function()
        SanctuaryPackageEnter(GetTriggerUnit())
    end)
    -- leave either:
    TriggerRegisterLeaveRectSimple(LUA_VAR_SANC_DATA.trigLeave,gg_rct_baseHordeRegen)
    TriggerRegisterLeaveRectSimple(LUA_VAR_SANC_DATA.trigLeave,gg_rct_baseAllianceRegen)
    TriggerAddCondition(LUA_VAR_SANC_DATA.trigLeave, Condition( function() return IsUnitType(GetTriggerUnit(),UNIT_TYPE_HERO)
        and IsUnitInGroup(GetTriggerUnit(),LUA_VAR_SANC_DATA.restoreGroup) end))
    TriggerAddAction(LUA_VAR_SANC_DATA.trigLeave, function()
        SanctuaryPackageLeave(GetTriggerUnit())
    end)
end
