dmg        = {}
dmg.event  = {}
dmg.type   = {}
dmg.absorb = {}


-- default constants mapping:
-- DEFENSE_TYPE_DIVINE     ATTACK_TYPE_MAGIC        DAMAGE_TYPE_MAGIC       -- arcane       dmgid: 1
-- DEFENSE_TYPE_NORMAL     ATTACK_TYPE_MELEE        DAMAGE_TYPE_COLD        -- frost        dmgid: 2 -- TYPE_MELEE = 'Normal'
-- DEFENSE_TYPE_LARGE      ATTACK_TYPE_PIERCE       DAMAGE_TYPE_PLANT       -- nature       dmgid: 3
-- DEFENSE_TYPE_LIGHT      ATTACK_TYPE_CHAOS        DAMAGE_TYPE_FIRE        -- fire         dmgid: 4
-- DEFENSE_TYPE_FORT       ATTACK_TYPE_SIEGE        DAMAGE_TYPE_DEATH       -- shadow       dmgid: 5
-- DEFENSE_TYPE_MEDIUM     ATTACK_TYPE_HERO         DAMAGE_TYPE_FORCE       -- physical     dmgid: 6
-- unused:
-- DEFENSE_TYPE_HERO       ATTACK_TYPE_NORMAL


function dmg:init()
    self.debug   = false
    --
    self.trig    = CreateTrigger()
    self.history = {}   -- store events
    self.txtdur  = 1.66 -- text duration
    self.histmax = 3   -- how many?
    self.buffer  = 5    -- when do we start culling?
    self.overage = self.histmax + self.buffer
    self.passive = Player(PLAYER_NEUTRAL_PASSIVE)
    self.cacheon = false -- cache damage values
    self.pdmg    = false -- flag for working with players on dealing damage.
    self.phit    = false -- `` on taking damage.
    self.crit    = false -- `` on crit damage.
    self.thorns  = false -- `` returned damage.
    self.convert = false -- `` converted damage.
    self.hexp    = 0
    self.hext    = {
        [0] = "|cffffffff", -- universal
        [1] = "|cff0b39ff", -- arcane
        [2] = "|cff00eaff", -- frost
        [3] = "|cff00ff12", -- nature
        [4] = "|cffff9c00", -- fire
        [5] = "|cff7214ff", -- shadow
        [6] = "|cffff2020", -- physical
    }
    dmg.event:init()
    dmg.absorb:init()
    -- initialize damage type lookup table:
    dtypelookup = {
        [DAMAGE_TYPE_MAGIC]     = 1,
        [DAMAGE_TYPE_FIRE]      = 2,
        [DAMAGE_TYPE_FORCE]     = 3,
        [DAMAGE_TYPE_PLANT]     = 4,
        [DAMAGE_TYPE_DEATH]     = 5,
        [DAMAGE_TYPE_COLD]      = 6,
    }
    atypelookup = {
        [ATTACK_TYPE_MAGIC]     = 1,
        [ATTACK_TYPE_MELEE]     = 2,
        [ATTACK_TYPE_PIERCE]    = 3,
        [ATTACK_TYPE_CHAOS]     = 4,
        [ATTACK_TYPE_SIEGE]     = 5,
        [ATTACK_TYPE_HERO]      = 6,
    }
    deftypelookup = {
        [DEFENSE_TYPE_DIVINE]   = 1,
        [DEFENSE_TYPE_NORMAL]   = 2,
        [DEFENSE_TYPE_LARGE]    = 3,
        [DEFENSE_TYPE_LIGHT]    = 4,
        [DEFENSE_TYPE_FORT]     = 5,
        [DEFENSE_TYPE_MEDIUM]   = 6,
    }
    atypenamet = {
        [ATTACK_TYPE_MAGIC]     = "arcane",
        [ATTACK_TYPE_MELEE]     = "frost",
        [ATTACK_TYPE_PIERCE]    = "nature",
        [ATTACK_TYPE_CHAOS]     = "fire",
        [ATTACK_TYPE_SIEGE]     = "shadow",
        [ATTACK_TYPE_HERO]      = "physical",
    }
    -- create damage event listener:
    TriggerRegisterAnyUnitEventBJ(self.trig, EVENT_PLAYER_UNIT_DAMAGING)
    TriggerAddCondition(self.trig, Filter(function()
        utils.debugfunc(function()
            local e = dmg.event:new()
            if e.amount ~= 0 then
                local pobj
                -----------------------------------------------
                -- player-specific calc for taking damage:
                -----------------------------------------------
                if IsUnitType(e.target, UNIT_TYPE_HERO) and utils.pnum(e.targetp) <= kk.maxplayers then
                    if map.manager.isactive and map.manager.success then -- if map was won, zero out lingering damage.
                        e.amount = 0
                    else -- do normal damage
                        pobj = kobold.player[e.targetp]
                        pobj.score[3] = pobj.score[3] + math.floor(e.amount)
                        self.phit = true
                        -- see if pure damage reduction should be applied (a separate percentage reduction stat).
                        if pobj[p_stat_dmg_reduct] ~= 0 then
                            e.amount = math.max(e.amount*(1-pobj[p_stat_dmg_reduct]/100), e.amount*0.1) -- max 90% reduction.
                        end
                        -- see if thorns should be applied:
                        if pobj[p_stat_thorns] > 0 then
                            self.thorns = true
                            dmg.type.stack[dmg_phys]:pdeal(e.targetp, pobj[p_stat_thorns], e.source)
                        end
                        -- resistances calc:
                        if dtypelookup[e.dmgtype] then
                            e.amount = dmg.type.stack[dtypelookup[e.dmgtype]]:calctake(pobj, e.amount)
                        elseif atypelookup[e.atktype] then
                            e.amount = dmg.type.stack[atypelookup[e.atktype]]:calctake(pobj, e.amount)
                        end
                        -- player lethal check:
                        if e.amount >= utils.life(e.target) and not pobj.downed then
                            e:void()
                            pobj:down(true)
                            ArcingTextTag(color:wrap(color.tooltip.bad, "Downed"), e.target, self.txtdur)
                        elseif e.dmgtype == DAMAGE_TYPE_NORMAL then
                            -- armor reduction for non-spell attacks:
                            if not e:dodgecalc(pobj) then
                                e:armorcalc(pobj)
                            else
                                e.dodged = true
                            end
                        end
                        -- wrap up with ancient effects:
                        loot.ancient:raiseevent(ancient_event_damagetake, pobj, false, e)
                    end
                end
                -----------------------------------------------
                -- player-specific calc for dealing damage:
                -----------------------------------------------
                if not self.thorns and IsUnitType(e.source, UNIT_TYPE_HERO) and utils.pnum(e.sourcep) <= kk.maxplayers then
                    pobj = kobold.player[e.sourcep]
                    self.pdmg = true
                    -- see if spell damage; if not, calc dmgtype bonus to auto attacks:
                    if atypelookup[e.atktype] == dmg_phys or atypelookup[e.dmgtype] == dmg_phys then -- is physical attack.
                        if not self.bonusdmg and pobj[p_stat_physls] > 0 then
                            local h = e.amount*(pobj[p_stat_physls]/100)
                            utils.addlifeval(e.source, h, true, e.source)
                            pobj.score[4] = pobj.score[4] + h
                        end
                        if e.weptype ~= WEAPON_TYPE_WHOKNOWS then -- is melee attack, apply physical modifier.
                            e.amount = d_lookup_atk[e.atktype]:calcdeal(e.sourcep, e.amount, e.target)
                        end
                    else -- is spell.
                        if not self.bonusdmg and pobj[p_stat_elels] > 0 then
                            local h = e.amount*(pobj[p_stat_elels]/100)
                            utils.addlifeval(e.source, h, true, e.source)
                            pobj.score[4] = pobj.score[4] + h
                        end
                    end
                    -- see if bonus damage should be applied:
                    if not self.bonusdmg and e.targetp ~= self.passive then
                        for typeid,pstat in ipairs(p_dmg_lookup) do
                            if pobj[pstat] > 0 then
                                self.bonusdmg = true
                                dmg.type.stack[typeid]:pdeal(e.sourcep, e.amount*pobj[pstat]/100, e.target)
                            end
                        end
                        -- see if non-bonus damage should be type converted:
                        if not self.convert then
                            for convid = p_epic_arcane_conv, p_epic_phys_conv do
                                if pobj[convid] > 0 then
                                    e.amount = e.amount - e.amount*pobj[convid]/100
                                    if e.amount > 0 then
                                        self.convert = true
                                        dmg.type.stack[p_conv_lookup[convid]]:pdeal(e.sourcep, e.amount*pobj[convid]/100, e.target)
                                    end
                                end
                            end
                        end
                    else
                        self.bonusdmg = false
                    end
                    -- see if an ele proc should occur:
                    -- proliferation calc:
                    if not self.overtime and GetUnitTypeId(e.source) ~= FourCC("n00J") then -- is not a recursive-prone DoT effect (e.g. fire profilerate); is not a prolif demon.
                        if not self.eleproc and not self.bonusdmg and not self.pmin and not self.pminrep and not self.thorns and not self.convert then -- see if ele proc should roll.
                            if not self.prolifcd then
                                if e.amount > 10 and pobj[p_stat_eleproc] > 0 and (e.amount/utils.maxlife(e.target) >= 0.05
                                or GetUnitTypeId(e.target) == kk.ymmudid or IsUnitType(e.target, UNIT_TYPE_ANCIENT)) then
                                    if math.random(0,100) < math.min(75, pobj:calceleproc()) then -- 75% max chance to proc.
                                        self.eleproc = true
                                        ArcingTextTag(color:wrap(color.dmgid[atypelookup[e.atktype]], "Proc!"), e.target, 1.0)
                                        proliferate[atypelookup[e.atktype]](e) -- proc effect.
                                        orb_prolif_stack[atypelookup[e.atktype]]:playu(e.target) -- special effect.
                                        self.prolifcd = true
                                        TimerStart(NewTimer(), 0.33, false, function() self.prolifcd = false end)
                                    end
                                end
                            end
                        end
                    end
                    if not self.crit and pobj[p_epic_hit_crit] > 0 then
                        if math.random(1,100) <= pobj[p_epic_hit_crit] then
                            self.crit = true
                            e.amount  = e.amount *1.50
                        end
                    end
                    -- wrap up with ancient effects:
                    loot.ancient:raiseevent(ancient_event_damagedeal, pobj, true, e)
                elseif not utils.ishero(e.source) and utils.pnum(e.sourcep) <= kk.maxplayers then
                    -- is a player minion (consume player modifiers):
                    self.pmin = true
                    self.bonusdmg = false
                end
                -----------------------------------------------
                -- elite ability helper:
                -----------------------------------------------
                if not self.pdmg and elite.stack[utils.data(e.target)] and utils.ishero(e.source) then
                    if utils.getmanap(e.target) == 100 then IssueTargetOrderById(e.target, 852075, e.source) end
                end
                -----------------------------------------------
                -- absorb calc:
                -----------------------------------------------
                if not e.dodged and dmg.absorb.stack[utils.data(e.target)] and e.amount > 0 then
                    dmg.absorb.stack[utils.data(e.target)]:absorb(e)
                end
                -----------------------------------------------
                -- wrap-up and damage control override:
                -----------------------------------------------
                if self.pdmg then
                    e.amount = math.random(math.floor(e.amount*0.98), math.floor(e.amount*1.02))
                end
                if self.pmin and not self.pminrep and e.sourcep then -- replace minion damage with player-calculated damage.
                    -- override with a new player-sourced event (to roll up p_stat modifiers).
                    self.pmin = false
                    self.pminrep = true
                    dmg.type.stack[atypelookup[e.atktype]]:pdeal(e.sourcep, e.amount*(1+kobold.player[e.sourcep][p_stat_miniondmg]/100), e.target)
                    e.amount = 0
                end
                BlzSetEventDamage(e.amount)
                if dmg.cacheon then dmg:cache(e) end
                if dmg.debug then e:debug() end
                -----------------------------------------------
                -- floating combat text:
                -----------------------------------------------
                if not e.dodged and e.amount > 0 then
                    if e.dmgtype == DAMAGE_TYPE_MAGIC or e.atktype == ATTACK_TYPE_MAGIC then
                        self.hexp = 1 -- arcane
                    elseif e.dmgtype == DAMAGE_TYPE_COLD  or e.atktype == ATTACK_TYPE_MELEE then -- == ATTACK_TYPE_MELEE is ATTACK_TYPE_NORMAL
                        self.hexp = 2 -- frost
                    elseif e.dmgtype == DAMAGE_TYPE_PLANT or e.atktype == ATTACK_TYPE_PIERCE then
                        self.hexp = 3 -- nature
                    elseif e.dmgtype == DAMAGE_TYPE_FIRE or e.atktype == ATTACK_TYPE_CHAOS then
                        self.hexp = 4 -- fire
                    elseif e.dmgtype == DAMAGE_TYPE_DEATH or e.atktype == ATTACK_TYPE_SIEGE then
                        self.hexp = 5 -- shadow
                    elseif e.dmgtype == DAMAGE_TYPE_FORCE or e.atktype == ATTACK_TYPE_HERO then
                        self.hexp = 6 -- physical
                    else
                        self.hexp = 0
                    end
                    if self.crit then
                        ArcingTextTag(self.hext[self.hexp]..math.floor(e.amount).."|cffff3e3e!", e.target, self.txtdur)
                    else
                        ArcingTextTag(self.hext[self.hexp]..math.floor(e.amount), e.target, self.txtdur)
                    end
                    if self.pdmg  and map.manager.activemap then pobj.score[1] = pobj.score[1] + e.amount end
                elseif e.dodged then
                    ArcingTextTag(color:wrap(color.txt.txtwhite, "Dodge"), e.target, self.txtdur)
                    if self.phit and map.manager.activemap then pobj.score[2] = pobj.score[2] + e.amount end
                elseif e.amount < 0 then
                    -- colorize healing text:
                    ArcingTextTag(color:wrap(color.tooltip.good, "+"..math.ceil(e.amount)), e.target, self.txtdur)
                    if self.pdmg and map.manager.activemap then pobj.score[4] = pobj.score[4] + e.amount end
                end
                -- flag cleanup:
                self.pdmg       = false
                self.phit       = false
                self.thorns     = false
                self.convert    = false
                self.crit       = false
                self.pmin       = false
                self.eleproc    = false
                self.pminrep    = false
                self.overtime   = false
                pobj            = nil
            end
        end, "dmg")
        return true
    end))
    --
    self.attacktypestring = {
        [0] = "ATTACK_TYPE_NORMAL",
        [1] = "ATTACK_TYPE_MELEE",
        [2] = "ATTACK_TYPE_PIERCE",
        [3] = "ATTACK_TYPE_SIEGE",
        [4] = "ATTACK_TYPE_MAGIC",
        [5] = "ATTACK_TYPE_CHAOS",
        [6] = "ATTACK_TYPE_HERO"
    }
    self.damagetypestring = {
        [0] = "DAMAGE_TYPE_UNKNOWN",
        [4] = "DAMAGE_TYPE_NORMAL",
        [5] = "DAMAGE_TYPE_ENHANCED",
        [8] = "DAMAGE_TYPE_FIRE",
        [9] = "DAMAGE_TYPE_COLD",
        [10] = "DAMAGE_TYPE_LIGHTNING",
        [11] = "DAMAGE_TYPE_POISON",
        [12] = "DAMAGE_TYPE_DISEASE",
        [13] = "DAMAGE_TYPE_DIVINE",
        [14] = "DAMAGE_TYPE_MAGIC",
        [15] = "DAMAGE_TYPE_SONIC",
        [16] = "DAMAGE_TYPE_ACID",
        [17] = "DAMAGE_TYPE_FORCE",
        [18] = "DAMAGE_TYPE_DEATH",
        [19] = "DAMAGE_TYPE_MIND",
        [20] = "DAMAGE_TYPE_PLANT",
        [21] = "DAMAGE_TYPE_DEFENSIVE",
        [22] = "DAMAGE_TYPE_DEMOLITION",
        [23] = "DAMAGE_TYPE_SLOW_POISON",
        [24] = "DAMAGE_TYPE_SPIRIT_LINK",
        [25] = "DAMAGE_TYPE_SHADOW_STRIKE",
        [26] = "DAMAGE_TYPE_UNIVERSAL"
    }
    self.weapontypestring = {
        [0] = "WEAPON_TYPE_WHOKNOWS",
        [1] = "WEAPON_TYPE_METAL_LIGHT_CHOP",
        [2] = "WEAPON_TYPE_METAL_MEDIUM_CHOP",
        [3] = "WEAPON_TYPE_METAL_HEAVY_CHOP",
        [4] = "WEAPON_TYPE_METAL_LIGHT_SLICE",
        [5] = "WEAPON_TYPE_METAL_MEDIUM_SLICE",
        [6] = "WEAPON_TYPE_METAL_HEAVY_SLICE",
        [7] = "WEAPON_TYPE_METAL_MEDIUM_BASH",
        [8] = "WEAPON_TYPE_METAL_HEAVY_BASH",
        [9] = "WEAPON_TYPE_METAL_MEDIUM_STAB",
        [10] = "WEAPON_TYPE_METAL_HEAVY_STAB",
        [11] = "WEAPON_TYPE_WOOD_LIGHT_SLICE",
        [12] = "WEAPON_TYPE_WOOD_MEDIUM_SLICE",
        [13] = "WEAPON_TYPE_WOOD_HEAVY_SLICE",
        [14] = "WEAPON_TYPE_WOOD_LIGHT_BASH",
        [15] = "WEAPON_TYPE_WOOD_MEDIUM_BASH",
        [16] = "WEAPON_TYPE_WOOD_HEAVY_BASH",
        [17] = "WEAPON_TYPE_WOOD_LIGHT_STAB",
        [18] = "WEAPON_TYPE_WOOD_MEDIUM_STAB",
        [19] = "WEAPON_TYPE_CLAW_LIGHT_SLICE",
        [20] = "WEAPON_TYPE_CLAW_MEDIUM_SLICE",
        [21] = "WEAPON_TYPE_CLAW_HEAVY_SLICE",
        [22] = "WEAPON_TYPE_AXE_MEDIUM_CHOP",
        [23] = "WEAPON_TYPE_ROCK_HEAVY_BASH"
    }
    self.defensetypestring = {
        [0] = "LIGHT",
        [1] = "MEDIUM",
        [2] = "HEAVY",
        [3] = "FORTIFIED",
        [4] = "NORMAL",
        [5] = "HERO",
        [6] = "DIVINE",
        [7] = "UNARMORED",
    }
    dmg.type:init()
end


function dmg:cache(event)
    self.history[#self.history+1] = event
    if #self.history > self.overage then
        for i = 1,self.buffer do
            self.history[i] = nil
        end
        utils.tablecollapse(self.history)
    end
end


function dmg:recent()
    print("::: "..self.buffer.." most recent damage events :::")
    print(" ")
    for i = #self.history-self.buffer,#self.history do
        if self.history[i] then
            print(" ")
            print("::: event " .. i .. " :::")
            self.history[i]:debug()
        else
            print("caution: no event data was found in the cache for index "..i)
        end
    end
end


function dmg:getdef(unit)
   return BlzGetUnitIntegerField(unit, UNIT_IF_DEFENSE_TYPE)
end


function dmg:convertdmgtype(unit, dmgtypeid)
    for atktype,dmgid in pairs(atypelookup) do
        if dmgid == dmgtypeid then
            BlzSetUnitWeaponIntegerField(unit, UNIT_WEAPON_IF_ATTACK_ATTACK_TYPE, 0, GetHandleId(atktype))
            break
        end
    end
    for deftype,dmgid in pairs(deftypelookup) do
        if dmgid == dmgtypeid then
            BlzSetUnitIntegerField(unit, UNIT_IF_DEFENSE_TYPE, GetHandleId(deftype))
            break
        end
    end
end


function dmg.event:init()
    self.__index = self
end


function dmg.event:new()
    local o = {}
    o.source  = GetEventDamageSource()
    o.amount  = GetEventDamage()
    o.target  = BlzGetEventDamageTarget()
    o.atktype = BlzGetEventAttackType()
    o.dmgtype = BlzGetEventDamageType()
    o.weptype = BlzGetEventWeaponType()
    o.sourcep = utils.powner(o.source)
    o.targetp = utils.powner(o.target)
    setmetatable(o, self)
    self.__index = self
    return o
end


function dmg.absorb:init()
    -- initialize absorb listener
    self.debug    = false -- print debug messages.
    self.stack    = {}
    self.hex      = "|cffffffff"
    self.instance = 0
    self.endfuncs = {}
    self.__index  = self
    return o
end


-- @unit       = attach absorbs to this unit.
-- @dur        = how long does the effect last?
-- @dmgtypet   = pass in dmg types to absorb as a table using dmgtype names e.g. {physical = 500, fire = 500}.
-- @custeffect = [optional] override the default shield special effect.
-- example: { nature = 100, fire = 50 }
-- for ALL damage types: { all = 50 }
function dmg.absorb:new(unit, dur, dmgtypet, custeffect)
    utils.debugfunc(function()
        -- absorb damage for this unit based on index, add shield effect.
        local dex     = utils.data(unit)
        local t       = dmgtypet
        if kobold.player[utils.powner(unit)] then
            for dmgname,absorbval in pairs(t) do
                t[dmgname] = absorbval*(1+(kobold.player[utils.powner(unit)][p_stat_absorb]/400)) -- each point is worth 0.25 perc bonus.
            end
        end
        if not self.stack[dex] then
            -- build absorb object:
            self.stack[dex]          = {}
            self.stack[dex].absorbed = 0
            self.stack[dex].vals     = utils.shallow_copy(t)
            self.stack[dex].dex      = dex
            self.stack[dex].p        = utils.powner(unit)
            self.stack[dex].unit     = unit
            setmetatable(self.stack[dex], self)
            if self.debug then self.stack[dex]:debugprint('self.stack[dex] init') end
        else
            if self.debug then
                print("attempting to merge t: ")
                for i,v in pairs(t) do
                    print("i = ",i)
                    print("v = ",v)
                end
            end
            self.stack[dex]:merge(t)
        end
        self.stack[dex]:addeffect(dur, custeffect)
        TimerStart(NewTimer(), dur, false, function()
            utils.debugfunc(function()
                if self.stack[dex] then
                    if self.stack[dex].vals then
                        for n,val in pairs(t) do
                            if self.stack[dex].vals[n] > 0 then
                                if self.stack[dex].vals[n] > val then
                                    self.stack[dex].vals[n] = self.stack[dex].vals[n] - (self.stack[dex].vals[n] - val)
                                elseif self.stack[dex].vals[n] <= val then
                                    self.stack[dex].vals[n] = 0
                                end
                            end
                        end
                        t = nil -- destroy dmgtypet
                    end
                    if self.debug then self.stack[dex]:debugprint('timer before verify') end
                    self.stack[dex]:verify()
                end
            end, "absorb timer")
        end)
    end,"absorb new")
end


function dmg.absorb:addeffect(dur, custeffect)
    if custeffect == speff_shield and self.effect then BlzSetSpecialEffectAlpha(self.effect, 0) DestroyEffect(self.effect) end
    if custeffect then
        self.effect = custeffect:attachu(self.unit, dur)
    else
        self.effect = speff_shield:attachu(self.unit, dur)
    end
end


-- @newdmgtypet = merge this table with the existing absorb table.
function dmg.absorb:merge(newdmgtypet)
    -- merge a new absorb event with an existing one.
    for n,val in pairs(newdmgtypet) do
        -- if value not yet initialized, add it:
        if not self.vals[n] then
            self.vals[n] = 0
        else
            self.vals[n] = self.vals[n] + val
        end
        if self.debug then
            print("new merged absorb:")
            print("new damage type found = "..n)
            print("added val = "..val)
            print("new self.vals[n] = "..self.vals[n])
        end
    end
    if self.debug then self:debugprint('merge') end
end


function dmg.absorb:verify()
    -- check if trigger should be enabled or not
    self.emptycheck = true
    for name,val in pairs(self.vals) do
        if val > 0 then self.emptycheck = false else self.vals[name] = 0 end
        if self.debug then print("verify "..name.." "..val) end
    end
    if self.emptycheck then
        self:destroy()
    end
end


function dmg.absorb:debugprint(str)
    print('debugprint for:',str)
    for n,v in pairs(self.vals) do
        print(self.vals)
        print(n.." = "..v)
    end
end


function dmg.absorb:absorb(event)
    -- absorb any damage type first:
    local atype = atypenamet[event.atktype]
    -- check if absorb table has matching damage type > 0 or absorbs all damage:
    -- "all" dmg type is consumed first.
    if (self.vals.all and self.vals.all > 0) or self.vals[atype] then
        local amount    = event.amount
        local absorbed  = 0
        local remainder = 0
        if self.debug then
            print(GetHandleId(event.atktype))
            print(dmg.attacktypestring[GetHandleId(event.atktype)])
            print(self.vals[atype])
        end
        if self.vals.all then
            self.vals.all = self.vals.all - amount
            if self.vals.all < 0 then
                remainder = -self.vals.all
                self.vals.all = 0
            end
            absorbed = amount - remainder
        end
        -- for dealing with remainders, run individual element check separately:
        if absorbed ~= amount and self.vals[atype] and self.vals[atype] > 0 then
            -- separately calculate if a remainder should be deducted if "all" absorbed most of it first:
            if remainder > 0 then
                self.vals[atype] = self.vals[atype] - remainder
            else
                self.vals[atype] = self.vals[atype] - amount
            end
            if self.vals[atype] < 0 then
                remainder = -self.vals[atype]
                self.vals[atype] = 0
            end
            absorbed = amount - remainder
        end
        -- total absorbed amount:
        self.absorbed = self.absorbed + absorbed
        self:verify()
        if absorbed > 0 then
            ArcingTextTag(self.hex.."("..math.floor(self.absorbed)..")", event.target, dmg.txtdur)
            if dmg.phit and map.manager.activemap then
                kobold.player[event.targetp].score[2] = kobold.player[event.targetp].score[2] + absorbed - remainder
            end
            event.amount = amount - absorbed + remainder
        end
    end
end


function dmg.absorb:destroy()
    DestroyEffect(self.effect)
    self.stack[self.dex].val = nil
    self.stack[self.dex]     = nil
    if self.debug then print("destroyed absorb instance") end
end


function dmg.event:void()
    self.amount = 0
end


------------------------------------------------------------------------


function dmg.event:armorcalc(pobj)
    self.armorval = pobj:calcarmor()
    self.amount = math.floor(self.amount*math.max(1-self.armorval/100, 0.25)) -- armor has a 75 perc cap.
end


function dmg.event:dodgecalc(pobj)
    if pobj[p_stat_dodge] > 0 then
        self.dodgeval = pobj:calcdodge()
        if math.random(0,1000) < math.min(self.dodgeval, 750) then -- dodge has a 75 perc cap.
            self.amount = 0
            return true
        else -- failed to dodge
            return false
        end
    else
        return false
    end
end


------------------------------------------------------------------------


function dmg.event:debug()
    print("source = "  .. GetHandleId(self.source)  .. " (" .. GetUnitName(self.source) .. " - Player " .. utils.pidunit(self.source) .. ")")
    print("target = "  .. GetHandleId(self.target)  .. " (" .. GetUnitName(self.target) .. " - Player " .. utils.pidunit(self.target) .. ")")
    print("atktype = " .. dmg.attacktypestring[GetHandleId(self.atktype)] )
    print("dmgtype = " .. dmg.damagetypestring[GetHandleId(self.dmgtype)] )
    print("weptype = " .. dmg.weapontypestring[GetHandleId(self.weptype)] )
    print("amount = "  .. self.amount)
    print(" ")
end


function dmg.type:init()
    self.debug      = false
    --
    self.__index    = self
    self.stack      = {}
    self.weptype    = WEAPON_TYPE_WHOKNOWS
    -- group cosntants:
    dmg_g_elemental = 1
    dmg_g_physical  = 2
    -- type contants:
    dmg_arcane      = 1
    dmg_frost       = 2
    dmg_nature      = 3
    dmg_fire        = 4
    dmg_shadow      = 5
    dmg_phys        = 6
    -- globals:
    dmg_max_res     = 0.25 -- minimum damage that can be taken (75% = 0.25)
    
    self[dmg_arcane]    = dmg.type:new("Arcane",    DAMAGE_TYPE_MAGIC,  dmg_g_elemental,    p_stat_arcane,      p_stat_arcane_res,      color.dmg.arcane)
    self[dmg_arcane]:inittype         (ATTACK_TYPE_MAGIC,   DEFENSE_TYPE_DIVINE)
    self[dmg_arcane].id = dmg_arcane

    self[dmg_frost]     = dmg.type:new("Frost",     DAMAGE_TYPE_COLD,   dmg_g_elemental,    p_stat_frost,       p_stat_frost_res,       color.dmg.frost)
    self[dmg_frost]:inittype          (ATTACK_TYPE_MELEE,   DEFENSE_TYPE_NORMAL)
    self[dmg_frost].id  = dmg_frost

    self[dmg_nature]    = dmg.type:new("Nature",    DAMAGE_TYPE_PLANT,  dmg_g_elemental,    p_stat_nature,      p_stat_nature_res,      color.dmg.nature)
    self[dmg_nature]:inittype         (ATTACK_TYPE_PIERCE,  DEFENSE_TYPE_LARGE)
    self[dmg_nature].id = dmg_nature

    self[dmg_fire]      = dmg.type:new("Fire",      DAMAGE_TYPE_FIRE,   dmg_g_elemental,    p_stat_fire,        p_stat_fire_res,        color.dmg.fire)
    self[dmg_fire]:inittype           (ATTACK_TYPE_CHAOS,   DEFENSE_TYPE_LIGHT)
    self[dmg_fire].id   = dmg_fire

    self[dmg_shadow]    = dmg.type:new("Shadow",    DAMAGE_TYPE_DEATH,  dmg_g_elemental,    p_stat_shadow,      p_stat_shadow_res,      color.dmg.shadow)
    self[dmg_shadow]:inittype         (ATTACK_TYPE_SIEGE,   DEFENSE_TYPE_FORT)
    self[dmg_shadow].id = dmg_shadow

    self[dmg_phys]      = dmg.type:new("Physical",  DAMAGE_TYPE_FORCE,  dmg_g_physical,     p_stat_phys,        p_stat_phys_res,        color.dmg.physical)
    self[dmg_phys]:inittype           (ATTACK_TYPE_HERO,    DEFENSE_TYPE_MEDIUM)
    self[dmg_phys].id   = dmg_phys

    dmg.type:buildlookupt()
    spell:assigndmgtypes()
end


function dmg.type:new(strname, dmgtype, dmggroup, p_stat, p_stat_res, txtcolor)
    local o = {}
    setmetatable(o, self)
    o.name    = strname
    o.dmgtype = dmgtype
    o.group   = dmggroup
    o.p_stat  = p_stat
    o.p_res   = p_stat_res
    o.color   = txtcolor
    o.effect  = nil
    self.stack[#self.stack+1] = o
    return o
end


function dmg.type:inittype(atktype, deftype)
    -- init mapped gameplay constant types.
    self.atktype = atktype
    self.deftype = deftype
end


function dmg.type:buildlookupt()
    d_lookup_atk = {}
    d_lookup_def = {}
    for id,o in pairs(self) do
        if type(o) == "table" and o.atktype and o.deftype then
            d_lookup_atk[o.atktype] = o
            d_lookup_def[o.deftype] = o
        end
    end
end


function dmg.type:basecalc(amount)
    -- returns hypothetical damage for descriptions.
    return math.floor(amount*(1+self.p_stat/100))
end


-- *NOTE: this returns a value, it doesn't deal damage.
function dmg.type:calcdeal(p, amount, target)
    -- player deals damage to mobs formula.
    local resistmul = 1
    -- *note: we pass in a cached armor val beacuse we override the default armor system.
    if BlzGetUnitIntegerField(target, UNIT_IF_DEFENSE_TYPE) == GetHandleId(self.deftype) then -- has resist type
        resistmul = 1 - BlzGetUnitArmor(target)*0.01
    end
    if kobold.player[p] then
        if self.debug then print("player calcdeal:",math.floor(amount*(1+kobold.player[p][self.p_stat]/100)*resistmul)) end
        return math.floor(amount*(1+kobold.player[p][self.p_stat]/100)*resistmul)
    else
        if self.debug then print("non-player calcdeal:",math.floor(amount*resistmul)) end
        return math.floor(amount*resistmul)
    end
end


function dmg.type:calctake(pobj, amount)
    -- player takes damage from mobs formula.
    if pobj[self.p_res] ~= 0 then
        if self.debug then print("calctake:",math.floor(math.max(amount*(1-pobj[self.p_res]/100), amount*dmg_max_res))) end
        return math.floor(math.max(amount*(1-pobj[self.p_res]/100), amount*dmg_max_res))
    end
    return amount
end


function dmg.type:pdeal(p, amount, target)
    if not utils.isinvul(target) then
        -- damage a target with this damage type.
        if self.debug then print("dmg.type:pdeal calc: "..self:calcdeal(p, amount, target)) end
        local amt        = self:calcdeal(p, amount, target)
        -- because we use a custom damage formula, we need to ignore the default armor calc:
        local cachearmor = BlzGetUnitArmor(target)
        BlzSetUnitArmor(target, 0)
        UnitDamageTarget(kobold.player[p].unit, target, amt, false, false, self.atktype, self.dmgtype, self.weptype)
        BlzSetUnitArmor(target, cachearmor)
    end
end


function dmg.type:ptake(p, amount, dealer)
    if not utils.isinvul(kobold.player[p].unit) then
        -- damage a player's kobold with this damage type.
        UnitDamageTarget(dealer, kobold.player[p].unit, self:calctake(p, amount), false, false, self.atktype, self.dmgtype, self.weptype)
    end
end


function dmg.type:dealdirect(dealer, target, amount)
    if not utils.isinvul(target) then
        UnitDamageTarget(dealer, target, amount, true, false, self.atktype, self.dmgtype, self.weptype)
    end
end


function dmg.type:getrandomtype()
    return self.stack[math.random(1, #self.stack)]
end
