combat = {

    --[[
        configurable settings:
    --]]

    allowitems      = true,     -- if an item is used by a player, end their turn.

    unitspacing     = 132.0,    -- (distance) each unit's distance apart from one another.

    turnsound       = true,     -- play a sound when turns begin.
    aggrosound      = true,     -- play a sound when encounters begin.

    turnspeed       = 2.66,     -- (sec) speed to play turns (*note: making this very low can have consequences).
    fadedelay       = 1.33,     -- (sec) when an an encounter initiates, wait this long to pan to arena.
    startdelay      = 1.66,     -- (sec) `` wait this long to award first turn.
    placedelay      = 0.66,     -- (sec) the delay between placing party units (eye-candy).
    turndelay       = 1.21,     -- (sec) the delay after a turn ends, before another begins.

    introanim       = true,     -- play an intro animation when units enter the arena.
    introanimstr    = "spell",  -- the animation to play when enabled.

    --[[
        configurable effects:
    --]]
    effect = {
        -- (effect path) attached effect for units who have current turn:
        turn    = "Abilities\\Spells\\Other\\Aneu\\AneuCaster.mdl",
        -- (effect path) attached effect for stunned units:
        stun    = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl",
        -- (effect path) attached effect for blinded units:
        blind   = "Abilities\\Spells\\Orc\\StasisTrap\\StasisTotemTarget.mdl",
        -- (effect path) play this effect when units are placed:
        place   = "Abilities\\Spells\\Items\\AIim\\AIimTarget.mdl",
    },
}
combat.manager = {} -- sub class for managing the combat system.
combat.unit    = {} -- `` unit data.
combat.party   = {} -- `` party units.
combat.status  = {} -- `` status effect types.

--[[

    -- Quick reference documentation --

    Combat Manager:

        .defendparty    = starts on the left side.
        .attackparty    = `` the right side.
        .rect           = the arena bounds.

        toggled flags:
            .pauseturns = (bool) prevents the next turn from starting until set back to false or the unit's turn ends.

    Combat Party:

        .temp           = (bool) default false; when true, the party and its combat units will be destroyed when combat ends (and have units removed).
        .combatactive   = (bool) is the party currently in combat?

        for preplaced parties:
            .rect       = (region) the region/rect that is holding the preplaced group.

        for NPC groups:
            .npc        = (table) holds details regarding a replaced or randomized encounter (if needed)
                ``.trig   = (trigger) the trigger controlling the group encounter (starts on rect enter)
                ``.level  = (int) the level of the group, for end user manipulation (if needed)
    
--]]

function combat:init()
    self.debug              = true
    self:initmeta()
    self.partylookupt       = {} -- for finding a unit's assigned party.
    self.trig               = CreateTrigger()
    self.arenarect          = gg_rct_arenacontainer
    TriggerRegisterVariableEvent(self.trig, "udg_combat_event", EQUAL, 6.0) -- turn action
    TriggerRegisterVariableEvent(self.trig, "udg_combat_event", EQUAL, 5.0) -- defender defeated
    TriggerRegisterVariableEvent(self.trig, "udg_combat_event", EQUAL, 4.0) -- attacker defeated
    TriggerRegisterVariableEvent(self.trig, "udg_combat_event", EQUAL, 3.0) -- encounter end
    TriggerRegisterVariableEvent(self.trig, "udg_combat_event", EQUAL, 2.0) -- encounter start
    TriggerRegisterVariableEvent(self.trig, "udg_combat_event", EQUAL, 1.0) -- turn start
    TriggerRegisterVariableEvent(self.trig, "udg_combat_event", EQUAL, -1.0) -- initiative rolled
    self.statuseffect = {
        stun        = combat.status:new(),
        dmg         = combat.status:new(),
        blind       = combat.status:new(),
        heal        = combat.status:new(),
    }
end


function combat:initmeta()
    self.__index            = self
    self.unit.__index       = self.unit
    self.manager.__index    = self.manager
    self.party.__index      = self.party
    self.status.__index     = self.status
    self.unit.stack         = {}
    self.manager.stack      = {}
    self.party.stack        = {}
    self.status.stack       = {}
end


function combat.manager:initarena()
    local maxx, minx = GetRectMaxX(self.rect), GetRectMinX(self.rect)
    local offset     = (math.abs(maxx - minx))*0.4
    self.anchor = {
        attacker = {
            x = GetRectCenterX(self.rect) + offset,
            y = GetRectCenterY(self.rect),
        },
        defender = {
            x = GetRectCenterX(self.rect) - offset,
            y = GetRectCenterY(self.rect),
        },
    }
    self.face = {
        attacker = 180.0,
        defender = 0.0,
    }
end


function combat.manager:flagevent(value)
    udg_combat_event = value
    udg_combat_event = 0.0
end


-- create a unit instance of combat between two players.
function combat.manager:new(defendingparty, attackingparty)
    utils.debugfunc(function()
        local o = setmetatable({}, self)
        o.turnorder   = {}              -- array containing units by turn sequence ([1] = goes first).
        o.attackparty = attackingparty  -- the attacking party.
        o.defendparty = defendingparty  -- the defending party.
        o.attackparty.combatactive = true
        o.defendparty.combatactive = true
        -- store the unit locations where the engagement began (to move back afterwards):
        o.xycache = {
            attacker = {
                x = GetUnitX(attackingparty.captain), y = GetUnitY(attackingparty.captain)
            },
            defender = {
                x = GetUnitX(defendingparty.captain), y = GetUnitY(defendingparty.captain)
            }
        }
        o:startencounter()
        self.stack[#self.stack + 1] = o
        return o
    end, "combat.manager:new")
end


function combat.manager:startencounter()
    utils.debugfunc(function()
        -- if desired, passed a different rect for the encounter (e.g. manager multiple combat instances):
        if udg_arena_override then
            -- *note: if arena override is used in multiplayer, end user needs to manage rects currently in use.
            self.rect = udg_arena_override_rect
            udg_arena_override = false
        else
            self.rect = combat.arenarect
        end
        self:initarena()
        if combat.aggrosound then
            utils.playsound(udg_sound_aggro, self.attackparty.owner)
            utils.playsound(udg_sound_aggro, self.defendparty.owner)
        end
        -- prevent fiddling until arena is set up:
        utils.disableuicontrol(self.attackparty.owner, true)
        utils.disableuicontrol(self.defendparty.owner, true)
        utils.timed(combat.fadedelay, function()
            utils.timed(combat.startdelay, function()
                utils.timed(combat.placedelay, function()
                    self:placeunits(self.attackparty, "attacker")
                    utils.timed(combat.placedelay, function()
                        self:placeunits(self.defendparty, "defender")
                        utils.timed(combat.placedelay, function()
                            utils.debugfunc(function()
                                self:rollinitiative()
                                self:startcombat()
                                self:flagevent(2.0) -- GUI hook, encounter started
                            end, "timer")
                        end)
                    end)
                end)
            end)
        end)
    end, "startencounter")
end


function combat.manager:placeunits(party, lookupstr)
    utils.debugfunc(function()
        local offset    = combat.unitspacing
        local face      = self.face[lookupstr]
        local x, y      = self.anchor[lookupstr].x, self.anchor[lookupstr].y
        local inc, dir  = 0.0, 1
        if not x then
            assert(false, "error: a rect was not initialized for an instance of combat.")
        end
        party:loop(function(unit)
            dir = -dir
            y   = y + inc
            inc = dir*(inc + offset)
            utils.setxy(unit, x, y)
            utils.speffect(combat.effect.place, x, y)
            if combat.playintroanim then
                SetUnitAnimation(unit, combat.introanim)
                QueueUnitAnimation(unit, "stand")
            end
        end)
    end, "palceunits")
end


-- determine who goes first.
function combat.manager:rollinitiative()
    local tempt = {}
    for _,v in pairs(self.attackparty) do
        if v.unit then
            tempt[#tempt+1] = v
        end
    end
    for _,v in pairs(self.defendparty) do
        if v.unit then
            tempt[#tempt+1] = v
        end
    end
    table.sort(tempt, function(a, b) return a.haste > b.haste end)
    -- set turn order based on haste:
    for index,cu in ipairs(tempt) do
        self.turnorder[index] = cu
    end
    udg_combat_initiative_unit = self.turnorder[1]
    self:flagevent(-1.0)
    tempt = nil
end


-- initiate combat system (pan camera, roll initiative, select first unit).
function combat.manager:startcombat()
    utils.disableuicontrol(self.attackparty.owner, false)
    utils.disableuicontrol(self.defendparty.owner, false)
    utils.setcambounds(self.attackparty.owner, self.rect)
    utils.setcambounds(self.defendparty.owner, self.rect)
end


function combat.manager:endencounter()
    ReleaseTimer(self.camtmr)
    utils.setcambounds(self.attackparty.owner, bj_mapInitialPlayableArea)
    utils.setcambounds(self.defendparty.owner, bj_mapInitialPlayableArea)
    self.attackparty.combatactive = false
    self.defendparty.combatactive = false
    self:flagevent(3.0) -- GUI hook, encounter ended
end


-- shift turn sequence to a party
function combat.manager:beginpartyphase()
    if combat.turnsound then
        utils.playsound(udg_sound_turn, self.attackparty.owner)
        utils.playsound(udg_sound_turn, self.defendparty.owner)
    end
end


-- @combatunit = begin the turn phase for this unit.
function combat.manager:beginturn(combatunit)
    -- .pauseturns can be passed by abilities to run longer effect chains.
    if not self.pauseturns then
        self:turnstarteffects(combatunit)
        if not utils.isalive(combatunit.unit) then
            combatunit.dead = true
            self.shouldskip   = true
        end
        -- listen a 2nd time in case end user used a custom skip action from a status effect:
        if not self.shouldskip then
            self.turnunit = combatunit
        else
            self:skipturn(combatunit.owner, self.skipmessage or nil)
            self.shouldskip = false
            return
        end
        -- queue a timer that checks for errant deaths of a unit from user input:
        self.safetytmr = utils.timedrepeat(1.0, nil, function()
            if not utils.isalive(combatunit.unit) then
                self:skipturn(GetUnitName(combatunit.unit).." died! Their turn has ended.")
            end
        end)
    else
        -- run recurring timer to resume turn phase when pause is disabled:
        utils.timedrepeat(2.0, nil, function()
            if not self.pauseturns then
                self:beginturn(combatunit)
                ReleaseTimer()
            end
        end)
    end
end


-- @_message = (optional) transmit this message to a player on why the turn was skipped.
function combat.manager:skipturn(message)
    if message then
        self:msg(message, 2.5, udg_sound_skip)
    end
    self:endturn(self.turnunit)
end


-- @combatunit = end the turn phase for this unit.
function combat.manager:endturn(combatunit)
    self.pauseturns = false
    self:turnendeffects(combatunit)
    if not utils.isalive(combatunit.unit) then
        combatunit.dead = true
    end
    ReleaseTimer(self.safetytmr)
end


-- @combatunit = run through status effects for a unit's end of turn phase.
function combat.manager:turnstarteffects(combatunit)
    if self.turnunit == combatunit.unit then
        for _,status in pairs(combatunit.status) do
            if status.turns > 0 and status.startfunc then
                if not self.shouldskip and utils.isalive(combatunit.unit) then
                   self:skipturn()
                   break
                else
                    status.startfunc(combatunit.unit)
                    status.turns = status.turns - 1
                    if status.effect then
                        utils.speffect(status.effect, utils.unitxy(combatunit.unit))
                    end
                end
            end
        end
    end
end


-- @combatunit = run through status effects for a unit's beginning of turn phase.
function combat.manager:turnendeffects(combatunit)
    if self.turnunit == combatunit.unit then
        if utils.isalive(combatunit.unit) then
            for _,status in pairs(combatunit.status) do
                if status.turns > 0 and status.endfunc then
                    status.endfunc(combatunit.unit)
                    status.turns = status.turns - 1
                    if status.effect then
                        utils.speffect(status.effect, utils.unitxy(combatunit.unit))
                    end
                end
            end
        else
            self:skipturn()
        end
    end
end


-- display a message to both party players.
-- @message = this message.
-- @dur     = for this many seconds.
-- @snd     = [optional] play a sound
function combat.manager:msg(message, dur, _snd)
    utils.palert(self.defendparty.owner, message, 2.5, _snd or nil)
    utils.palert(self.attackparty.owner, message, 2.5, _snd or nil)
end


function combat.manager:getalliancegroups()
    if utils.tablecontains(self.attackparty, self.turnunit) then
        GroupClear(udg_combat_turn_ally_grp)
        self.attackparty:loop(function(unit)
            GroupAddUnit(udg_combat_turn_ally_grp, unit)
        end)
    else
        GroupClear(udg_combat_turn_enemy_grp)
        self.attackparty:loop(function(unit)
            GroupAddUnit(udg_combat_turn_enemy_grp, unit)
        end)
    end
end


function combat.manager:destroy()
    for i,v in pairs(self) do
        v = nil
        i = nil
    end
    self.stack[self] = nil
end


-- @unit = the unit to create a unit object for.
function combat.unit:new(unit)
    print("making new combat unit for "..GetUnitName(unit))
    local o     = {}
    o.unit      = unit
    o.owner     = utils.powner(unit)
    o.dead      = false
    o.haste     = 10.0
    o.status    = {
        stun        = combat.status:new(),
        turndmg     = combat.status:new(),
        blind       = combat.status:new(),
        heal        = combat.status:new(),
    }
    self.stack[o] = o
    return setmetatable({}, self)
end


function combat.unit:destroy()
    RemoveUnit(self.unit)
    for _,status in pairs(self.status) do
        status:destroy()
    end
    utils.tabledeepdestroy(self)
    self.stack[self] = nil
end


-- create a new party object that houses a party's units.
function combat.party:new()
    local o = setmetatable({}, self)
    self.temp     = false -- when true, the party and its units will be destroyed when defeated.
    self.stack[o] = o
    return o
end


function combat.party:destroy()
    if self.temp then
        for i,v in pairs(self) do
            if type(v) == "table" and v.destroy then
                v:destroy()
            end
        end
    end
    -- destroy any attached npc components:
    if self.npc then
        self.npc.trig:destroy()
        utils.tabledeepdestroy(self.npc)
    end
    self.stack[self] = nil
end


-- @combatunit = add this unit object to the party.
-- *note: accepts combatunit or unit (makes a new combatunit if passed a unit!)
function combat.party:add(unit)
    if type(unit) == "table" then
        self[#self+1] = unit
    else
        self[#self+1] = combat.unit:new(unit)
    end
    -- set assigned party in lookup table:
    combat.partylookupt[GetUnitUserData(self[#self].unit)] = self
end


-- assign a main character to a party, and also set the party's ownership.
-- accepts combatunit or unit (*note: makes a new combatunit when passed a unit!)
function combat.party:addcaptain(unit)
    if self.captain then
        self.captain = nil
    end
    if type(unit) == "table" then
        self.captain = unit
    else
        self.captain = combat.unit:new(unit)
    end
    self.owner   = utils.powner(self.captain.unit)
end


function combat.party:remove(combatunit)
    for i,v in pairs(self) do
        if v == combatunit then
            table.remove(self, i)
        end
    end
end


function combat.party:size()
    local i = 0
    for _,v in ipairs(self) do
        if v ~= nil then
            i = i + 1
        end
    end
    return i
end


-- run a function on a party's units (passes unit as argument).
function combat.party:loop(func)
    utils.debugfunc(function()
        for _,unit in ipairs(self) do
            func(unit)
        end
    end, "loop")
end


-- return a unit's assigned party.
function combat.party:getunitparty(unit)
    return combat.partylookupt[GetUnitUserData(unit)]
end


function combat.party:incombat()
    return self.combatactive
end


function combat.party:newfromrect(rect)
    local o   = combat.party:new()
    local grp = g:newbyrect(nil, nil, rect)
    if grp:getsize() > 0 then
        local lvl = 1
        grp:action(function()
            o:add(combat.unit:new(grp.unit))
            lvl = lvl + GetUnitLevel(grp.unit)
        end)
        lvl = math.floor(lvl/grp:getsize())
        o.rect  = rect
        o.level = lvl
    else
        print("caution: could not make party from rect due to no units present")
    end
    grp:destroy()
    return o
end


function combat.party:genpreplaced()
    if not self.encounterlist then
        self.encounterlist = {}
    end
    for _,rect in pairs(udg_preplaced_party_rect) do
        print(tostring(rect))
        self.encounterlist[#self.encounterlist+1] = combat.party:newfromrect(rect)
        self.encounterlist[#self.encounterlist].initialized = true
    end
    for _,party in pairs(self.encounterlist) do
        if not party.initialized then
            party:initencounter()
        end
    end
end


function combat.party:initencounter()
    if self.rect then
        if not self.npc then
            self.npc = {}
            self.npc.trig = trg:new("rect", nil, self.rect)
            local encounter = function()
                print("enter found")
                utils.debugfunc(function()
                    if not combat.party:getunitparty(GetTriggerUnit()):incombat() then
                        combat.manager:new(combat.party:getunitparty(GetTriggerUnit()), self)
                    end
                end, "encounter trigger")
            end
            self.npc.trig:regaction(encounter)
        else
            print("caution: combat.party:initencounter attempted to initialize object "..tostring(self).." a second time")
        end
    else
        assert(false, "error: combat.party:initencounter could not find an attached rect to initialize; table: "..tostring(self))
    end
end


function combat.status:new()
    local o = setmetatable({}, self)
    o.amount        = 0
    o.turns         = 0
    o.endfunc       = nil -- called from :turnstarteffects.
    o.startfunc     = nil -- called from :turnendeffects.
    o.effect        = nil -- play this special effect when called.
    self.stack[o] = o
    return o
end


function combat.status:destroy()
    utils.tabledeepdestroy(self)
    self.stack[self] = nil
end
