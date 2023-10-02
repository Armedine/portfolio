--
-- spell utils: do repetitive tasks with ease and return commonly-used local variables:
--

-- local caster, tarX, tarY, casterX, casterY = SpellPackSetupTargetAbil()
-- :: returns caster,tarX,tarY
function SpellPackSetupTargetAbil()

    local caster = GetTriggerUnit()
    local tarX = GetSpellTargetX()
    local tarY = GetSpellTargetY()
    local casterX = GetUnitX(caster)
    local casterY = GetUnitY(caster)

    return caster, tarX, tarY, casterX, casterY

end


-- local caster, casterX, casterY = SpellPackSetupInstantAbil()
-- :: returns caster,tarX,tarY
function SpellPackSetupInstantAbil()

    local caster = GetTriggerUnit()
    local casterX = GetUnitX(caster)
    local casterY = GetUnitY(caster)

    return caster, casterX, casterY

end


-- local caster, tarX, tarY, target, casterX, casterY = SpellPackSetupTargetUnitAbil()
-- :: returns caster,tarX,tarY
function SpellPackSetupTargetUnitAbil()

    local caster = GetTriggerUnit()
    local target = GetSpellTargetUnit()
    local tarX = GetUnitX(target)
    local tarY = GetUnitY(target)
    local casterX = GetUnitX(caster)
    local casterY = GetUnitY(caster)

    return caster, tarX, tarY, target, casterX, casterY

end


-- move units away so the outpost is centered properly
-- @x,y = where to check
-- @radius = check this radius, then move units this distance from center
-- @ancientsBool = should this ignore objective units? (ancient unit type)
function SpellPackClearArea(x,y,radius,ancientsBool)
    local g = CreateGroup()
    local centerLoc = Location(x,y)
    local r

    if (radius) then r = radius else r = 335.0 end

    if (ancientsBool ~= nil and ancientsBool) then
        GroupEnumUnitsInRange(g, x, y, r, Condition( function() return IsUnitAliveBJ(GetFilterUnit())
            and not IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE)
            and not IsUnitType(GetFilterUnit(),UNIT_TYPE_ANCIENT) end ) )
    else
        GroupEnumUnitsInRange(g, x, y, r, Condition( function() return IsUnitAliveBJ(GetFilterUnit())
            and not IsUnitType(GetFilterUnit(),UNIT_TYPE_STRUCTURE) end ) )
    end
    if (not IsUnitGroupEmptyBJ(g)) then
        local loc
        local newLoc
        local u = FirstOfGroup(g)
        local i = 0
        local angle
        repeat
            loc = GetUnitLoc(u)
            angle = AngleBetweenPoints(centerLoc, loc)
            newLoc = PolarProjectionBJ(centerLoc, r, angle)
            i = i + 1
            SetUnitX(u,GetLocationX(newLoc))
            SetUnitY(u,GetLocationY(newLoc))
            RemoveLocation(loc)
            RemoveLocation(newLoc)
            GroupRemoveUnit(g, u)
            u = FirstOfGroup(g)
        until (u == nil or i == 64)
        u = nil
      end
    DestroyGroup(g)
    RemoveLocation(centerLoc)
end


--:: sets a unit's attack damage and health based on attribute values
-- @sourceHero = unit to read attributes from
-- @targetUnit = unit to increase stats for
-- @heroAttribute = 0,1,2 for Str, Agi, Int
-- @damageMult = base damage; multiplier for @attribute (e.g. 1.0 x Str)
-- @healthMult = [optional] health; multiplier for @attribute (e.g. 7.5 x Str)
function SpellPackSetUnitStats(sourceHero,targetUnit,heroAttribute,damageMult,healthMult)
    if (healthMult ~= nil) then
        BlzSetUnitMaxHP(unit,math.floor(healthMult*GetHeroStatBJ(heroAttribute, sourceHero, true)))
        SetUnitState(targetUnit, UNIT_STATE_LIFE, math.ceil(BlzGetUnitMaxHP(targetUnit)))
    end
    local newdmg = math.floor(damageMult*GetHeroStatBJ(heroAttribute, sourceHero, true))
    BlzSetUnitBaseDamage( targetUnit, newdmg, 0 )
end

--
-- util functions for setting up hero abilities:
--

-- @trigger = attach events and conditions to this trigger
-- @callback = function to run when conditions are met
-- @pInt = player number of trigger owner
-- @abilId = string raw code of ability being cast
-- @spellEventType = [optional] defaults to EVENT_PLAYER_UNIT_SPELL_EFFECT
function SpellPackCreateTrigger(trigger,callback,pInt,abilId,spellEventType)
    local eventType
    if (spellEventType ~= nil) then
        eventType = spellEventType
    else
        eventType = EVENT_PLAYER_UNIT_SPELL_EFFECT
    end
    TriggerRegisterPlayerUnitEvent(trigger,Player(pInt - 1),eventType, nil)
    TriggerAddCondition(trigger, Filter( function() return GetSpellAbilityId() == FourCC(abilId) end ) )
    TriggerAddAction(trigger,callback)
end


-- @trigger = attach events and conditions to this trigger
-- @pInt = player number of trigger owner
-- @abilId = string raw code of ability being cast
-- @func = callback function to run when abilId is learned by player's hero
function SpellPackCreateLearnTrigger(trigger, pInt, abilId, func)
    TriggerRegisterPlayerUnitEvent(trigger, Player(pInt - 1), EVENT_PLAYER_HERO_SKILL, nil)
    TriggerAddCondition(trigger, Filter( function() return GetLearnedSkillBJ() == FourCC(abilId) end ) )
    TriggerAddAction(trigger, function() func() end)
end


-- @trigger = attach events and conditions to this trigger
-- @callback = function to run when conditions are met
-- @pInt = player number of trigger owner
-- @boolexpr = conditions to be met for @trigger to run; default = source is udg_playerHero[pInt]
-- @realstring = [optional] real event to listen for (udg_DamageEvent, udg_DamageEventModifier, etc.); default = udg_DamageEvent
function SpellPackCreateDamageTrigger(trigger,callback,pInt,boolexpr,realstring)
    local realS = "udg_DamageEvent"
    local boolE
    if (realstring ~= nil) then
        realS = realstring
    end
    if (boolexpr ~= nil) then
        boolE = boolexpr
    else
        boolE = function() return udg_DamageEventSource == udg_playerHero[pInt] end
    end
    TriggerRegisterVariableEvent( trigger, realS, EQUAL, 1.00 )
    TriggerAddCondition(trigger, Filter( function() return
            boolE()
            and udg_DamageEventAmount > 1.0
        end ) )
    TriggerAddAction(trigger,callback)
end


-- @unit = unit casting the spell
-- @err = error text to display
function SpellPackInvalidMsg(unit,err)
    DisplayTimedTextToPlayer(GetOwningPlayer(unit),0,0,1.5,'|cffffc800' .. tostring(err) .. '|r')
end


-- :: create a dummy that uses a native lightning spell for a special effect
-- @unit = [required] owner of the dummy; effect start location.
-- @abilityId = [optional] e.g. "A00A" (should be a lightning spell); defaults to chain lightning.
-- @orderString = [optional] order string to use ability on unit (defaults to 'chainlightning').
-- @targetUnit = [required] target of the ability; if nil, dummy casts on self aka @unit.
-- :: example terse use: SpellPackLightningEffect(myHero,nil,nil,myTarget)
function SpellPackLightningEffect(unit,abilityId,orderString,targetUnit)
    local abilityId = abilityId or 'A075'
    local orderString = orderString or 'chainlightning'
    local x = GetUnitX(unit)
    local y = GetUnitY(unit)
    local d = DamagePackageCreateDummy(GetOwningPlayer(unit), 'e003', x, y)
    UnitApplyTimedLifeBJ( 2.0, FourCC('BTLF'), d )
    UnitAddAbility( d, FourCC(abilityId) )
    IssueTargetOrder( d, orderString, targetUnit )
end


-- :: force an ability to be constrained to charge mechanics (on its X use, it will incur its cooldown)
-- @unit            = casting unit
-- @abilId          = abil rawcode (string)
-- @abilLevel       = level of ability using 0-based index (0 is level 1)
-- @uses            = total charges
-- @abilCooldown    = triggered abil timer when @uses reached
-- @abilRefresh      = when the charges reset by default
function SpellPackChargedAbilityInit(unit, abilId, abilLevel, uses, abilCooldown, abilRefresh)
    local t     = {}
    t.unit      = unit
    t.uses      = uses  -- usable charges
    t.consumed  = 0     -- data that updates
    t.abilId    = FourCC(abilId)
    t.abilLvl   = abilLevel
    t.abilCD    = abilCooldown
    t.refreshCD = abilRefresh
    t.timer     = NewTimer()
    return t
end


-- :: queue ability to refresh its stacks if they aren't used
-- @t = chargedAbil object from SpellPackChargedAbility
function SpellPackChargedTimer(t)
    ReleaseTimer(t.timer)
    t.timer = NewTimer()
    TimerStart(t.timer,t.refreshCD,false,function()
        if t.consumed > 0 then
            t.consumed = 0
            -- remove the cooldown to allow uses until it is triggered:
            BlzSetUnitAbilityCooldown( t.unit, t.abilId, t.abilLvl, 0.0 )
        end
        ReleaseTimer()
    end)
end


-- :: run on use of a charged spell, consuming a charge and checking its refresh state
-- @t = chargedAbil object from SpellPackChargedAbility
function SpellPackChargedConsumed(t)
    t.consumed = t.consumed + 1
    if t.consumed >= t.uses then
        BlzSetUnitAbilityCooldown( t.unit, t.abilId, t.abilLvl, t.abilCD )
        BlzStartUnitAbilityCooldown( t.unit, t.abilId, t.abilCD )
    else
        SpellPackChargedTimer(t)
    end
end


-- :: regenerate a charge and refresh the ability cooldown if needed
-- @t = chargedAbil object from SpellPackChargedAbility
function SpellPackChargedRefresh(t)
    t.consumed = t.consumed - 1
    if t.consumed < t.uses then
        if t.consumed < 0 then
            t.consumed = 0
        end
        BlzSetUnitAbilityCooldown( t.unit, t.abilId, t.abilLvl, 0.0 )
        BlzEndUnitAbilityCooldown( t.unit, t.abilId )
    else
        SpellPackChargedTimer(t)
    end
end


-- :: create a special effect with a parabolic trajectory
-- @x,y         = originating location.
-- @x2,y2       = landing location.
-- @maxHeight   = determines max vertex location.
-- @duration    = trajectory completion time.
-- @effect      = missile effect
-- @scale       = scale of missile
-- @func        = [optional] callback function when the projectile lands. should accept x and y as parameters for the landing location e.g. myFunc(x,y).
-- :: returns the generate special effect.
function SpellPackParabolicMissile(x,y,x2,y2,maxHeight,duration,effect,scale,func)
    -- r(t) = (x(t), y(t), z(t))
    -- can't figure out the math right now so it's just a triangle with derp math.
    local d      = DistanceBetweenXY(x,y,x2,y2)
    local a      = AngleBetweenXY(x,y,x2,y2)
    local e      = AddSpecialEffect(effect,x,y)
    local dHalf  = d/2                           -- where we inverse the derp triangle.
    local z      = 0                             -- starting and calc'd height.
    local Vz     = (maxHeight/(duration/0.03))*2 -- z velocity using derp math.
    local Vx     = d/(duration/0.03)             -- x velocity using derp math.
    local t      = 0                             -- traveled so far (velocity per cadence).
    local x,y    = x,y
    BlzSetSpecialEffectScale(e,scale)
    TimerStart(NewTimer(),0.03,true,function()
        t = t + Vx
        if t > dHalf then
            z = z - Vz
        else
            z = z + Vz
        end
        x,y = PolarProjectionXY(x,y,Vx,a)
        BlzSetSpecialEffectYaw(e, a*bj_DEGTORAD)
        BlzSetSpecialEffectX(e, x)
        BlzSetSpecialEffectY(e, y)
        BlzSetSpecialEffectZ(e, z + GetTerrainCliffLevel(x,y)*128 - 256)
        if t >= d then
            if func then func(x2,y2) end
            DestroyEffect(e)
            ReleaseTimer()
        end
    end)
    return e
end
