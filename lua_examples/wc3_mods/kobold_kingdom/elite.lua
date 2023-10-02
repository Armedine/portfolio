elite               = {
    manamax  = 100.0,    -- reach this cap to cast an elite spell.
    managen  = 4.00,     -- determines how fast mana is capped.
    packmin  = 1,
    packmax  = 3,
    spelldmg = 21,       -- base spell damage.
    debug    = false,
    debugsp  = false,     -- disable ability adding to test maually.
}
elite.goon          = {} -- an elite's empowered minions.
elite.abils         = {} -- store possible abilities to add (controlled by AI script).
elite.goon.abils    = {} -- store possible abilities to add to goons.


function elite:init()
    self.__index            = self
    self.stack              = {}
    self.colort             = {
        [1] = PLAYER_COLOR_BLUE,
        [2] = PLAYER_COLOR_CYAN,
        [3] = PLAYER_COLOR_GREEN,
        [4] = PLAYER_COLOR_ORANGE,
        [5] = PLAYER_COLOR_PURPLE,
        [6] = PLAYER_COLOR_LIGHT_GRAY,
    }
    elite.goon.__index      = elite.goon
    setmetatable(elite.goon, elite)
    self:buildspells()
    self:deathtrig()
end


function elite:deathtrig()
    self.trig = trg:new("death", Player(PLAYER_NEUTRAL_AGGRESSIVE)) -- ondeath trig
    self.trig:regaction(function()
        -- award ore on elite death based on elite's enhanced element id:
        if elite.stack[utils.data(utils.trigu())] and not elite.stack[utils.data(utils.trigu())].isgoon then
            local u = utils.trigu()
            local oreid = map.block.oretypet[elite.stack[utils.data(u)].dmgtypeid]
            local count = math.ceil((1*map.mission.cache.setting[m_stat_treasure] + map.manager.diffid)/2)
            map.block:spawnore(1*map.manager.diffid, oreid, utils.unitxy(u))
            if math.random(0,10) < math.ceil(map.manager.diffid/2) then
                loot:generatelootpile(utils.unitx(u), utils.unity(u), math.random(1,2), Player(0))
            end
            -- chance to drop wax:
            candle:spawnwax(utils.unitx(u), utils.unity(u))
            utils.palertall(color:wrap(color.rarity.rare, "Empowered creature defeated!"), 4.0, true)
        end
    end)
    elite.deathtrig = nil
end


-- @unit        = the unit to roll into an elite.
-- @dmgtypeid   = the element type to use.
-- @cluster     = creature cluster table used to determine goon types (e.g. creature.cluster.creatures.normal).
function elite:new(unit, dmgtypeid, cluster)
    local packmin, packmax = self.packmin, self.packmax
    local o     = setmetatable({}, self)
    o.unit      = unit
    o.dmgtypeid = dmgtypeid -- element id.
    o.creaturet = creaturet -- store in case we want abils to spawn more units etc.
    o.dex       = utils.data(unit)
    o.goons     = {}        -- where goons are stored for AI purposes.
    -- create goon squad:
    for _ = packmin, math.random(packmin, packmax) do
        local packmax = packmax
        if map.manager.diffid > 3 then
            -- -- Heroic or higher difficulty, density is increased:
            packmax = packmax*map.mission.cache.setting[m_stat_elite_pack]
        end
        local x,y = utils.projectxy(utils.unitx(unit), utils.unity(unit), math.random(128,256), math.random(0,360))
        -- clear destructables in the way to keep pack inside a workable arena:
        map.grid:excavate(x, y, 256)
        if map.manager.diffid > 3 then
            -- Heroic or higher difficulty, add passives:
            local abilroll = math.random(1, #elite.goon.abils[dmgtypeid])
            if cluster.creatures.normal and #cluster.creatures.normal > 0 then
                elite.goon:new(cluster.creatures.normal[math.random(1,#cluster.creatures.normal)]:create(x, y), dmgtypeid, o):addpassive(abilroll)
            elseif cluster.creatures.weak and #cluster.creatures.weak > 0 then
                elite.goon:new(cluster.creatures.weak[math.random(1,#cluster.creatures.weak)]:create(x, y), dmgtypeid, o):addpassive(abilroll)
            end
        else
            -- Greenwhisker or Normal difficulty, no passives:
            if cluster.creatures.normal and #cluster.creatures.normal > 0 then
                elite.goon:new(cluster.creatures.normal[math.random(1,#cluster.creatures.normal)]:create(x, y), dmgtypeid, o)
            elseif cluster.creatures.weak and #cluster.creatures.weak > 0 then
                elite.goon:new(cluster.creatures.weak[math.random(1,#cluster.creatures.weak)]:create(x, y), dmgtypeid, o)
            end
        end
    end
    -- init elite unit:
    o:addglow()
    o:updateatkdef()
    o:addeliteabil(dmgtypeid)
    -- spell:addenchant(unit, dmgtypeid)
    if map.manager.diffid > 3 then
        -- Heroic or higher difficulty, elites cast more often:
        o.managen = self.managen*map.mission.cache.setting[m_stat_elite_str] -- pull in lethality modifier.
    end
    utils.scaleatk(unit, map.mission.cache.setting[m_stat_elite_str])
    utils.setnewunitmana(unit, self.manamax)
    BlzSetUnitRealField(unit, UNIT_RF_MANA_REGENERATION, o.managen)
    SetUnitScale(unit, 1.25, 1.25, 1.25)
    elite.stack[o.dex] = o
    return o
end


function elite:destroy()
    utils.shallow_destroy(self)
    elite.stack[self.dex] = nil
end


-- after a map ends, destroy all elite objects
function elite:cleanup()
    for _,e in pairs(self.stack) do
        if e.isgoon then 
            e:destroygoon()
        else
            e:destroy()
        end
    end
end


function elite:addglow()
    UnitAddAbility(self.unit, sp_enchant_elite[self.dmgtypeid])
    SetUnitColor(self.unit, self.colort[self.dmgtypeid])
end


function elite:addeliteabil()
    if not elite.debugsp then
        UnitAddAbility(self.unit, elite.abils[math.random(1, #elite.abils)].code)
    end
end


-- update an elite unit to have its attack and defense match its assigned dmgtypeid.
function elite:updateatkdef(_isgoon)
    dmg:convertdmgtype(self.unit, self.dmgtypeid)
    BlzSetUnitWeaponStringField(self.unit, UNIT_WEAPON_SF_ATTACK_PROJECTILE_ART, 0, mis_ele_stack2[self.dmgtypeid].effect) -- attack art.
    BlzSetUnitArmor(self.unit, math.floor(BlzGetUnitArmor(self.unit)+(5*(map.manager.diffid-1))))
    if _isgoon then
        utils.setnewunithp(self.unit, math.ceil(BlzGetUnitMaxHP(self.unit)*2.50), true)
        utils.scaleatk(self.unit, 1.50)
    else
        utils.setnewunithp(self.unit, math.ceil(BlzGetUnitMaxHP(self.unit)*1.50), true)
        utils.scaleatk(self.unit, 1.10)
    end
end


function elite:buildspells()
    local p
    if elite.debug then
        p = Player(0)
        print("caution: elite debug mode is on (spells activate for Player 1)")
    else
        p = Player(PLAYER_NEUTRAL_AGGRESSIVE)
    end

--[[
    ELITE ABILS  -----------------------------------------------------------------------------
--]]
    elite.abils = {}

    -- ELEMENTAL ORBS --
    -- spawns orbs which create swirling elemental tethers, damaging players caught in the tether.
    elite.abils[1] = spell:new(casttype_unit, p, FourCC('A02B'))
    elite.abils[1]:addaction(function()
        local caster    = elite.abils[1].caster
        local dmgtypeid = elite.stack[utils.data(caster)].dmgtypeid
        local dps       = elite.spelldmg*map.mission.cache.setting[m_stat_attack]
        local dmgtype   = dmg.type.stack[dmgtypeid]
        local x,y,x2,y2,vel,a,a2,e,e2,start,sc,t = {},{},{},{},{},{},{},{},{},math.random(0,360),0.49,0
        for i = 1,3 do
            a[i]        = start+((i-1)*120)
            a2[i]       = a[i]
            x[i], y[i]  = utils.projectxy(elite.abils[1].casterx, elite.abils[1].castery, math.random(32,128), a[i])
            e[i]        = orb_eff_stack[dmgtypeid]:create(x[i], y[i])
            vel[i]      = math.random(5,8)
            BlzSetSpecialEffectScale(e[i], sc)
        end
        -- begin moving orbs into position
        utils.timedrepeat(0.03, 51, function()
            utils.debugfunc(function()
                for i = 1,3 do
                    x[i], y[i] = utils.projectxy(x[i], y[i], vel[i], a[i])
                    utils.seteffectxy(e[i], x[i], y[i])
                end
            end)
        end, function()
            -- queue charge effect indicator:
            for i = 1,3 do
                speff_boosted:play(x[i], y[i])
            end
            utils.timedrepeat(0.03, 51, function()
                utils.debugfunc(function()
                    -- scale the orbs until they activate:
                    for i = 1,3 do
                        sc = sc + 0.01
                        BlzSetSpecialEffectScale(e[i], sc)
                    end
                end)
            end, function()
                utils.debugfunc(function()
                    -- create tethers and queue activation indicator:
                    for i = 1,3 do
                        speff_generate:play(x[i], y[i])
                        e2[i] = teth_gate_stack[dmgtypeid]:create(x[i], y[i])
                        a2[i] = math.random(0,360)
                    end
                    utils.timedrepeat(0.03, 300*map.mission.cache.setting[m_stat_elite_str], function()
                        utils.debugfunc(function()
                            t = t + 1
                            -- spin the tethers and deal damage:
                            for i = 1,3 do
                                a2[i] = a2[i] + 1.15
                                x2[i], y2[i] = utils.projectxy(x[i], y[i], 164, a2[i])
                                utils.seteffectxy(e2[i], x2[i], y2[i])
                                BlzSetSpecialEffectYaw(e2[i], (a2[i]+90.0)*bj_DEGTORAD)
                                if math.fmod(t, 12) == 0 then
                                    spell:creepgdmgxy(caster, dmgtype, dps, x2[i], y2[i], 128)
                                end
                            end
                        end)
                    end, function()
                        for i = 1,3 do DestroyEffect(e[i]) DestroyEffect(e2[i]) end
                        x,y,x2,y2,vel,a,a2,e,e2,dmgtype = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
                    end)
                end)
            end)
        end)
    end)

    -- MORTAR SHELLS --
    -- queues mortars to fire over time in a line at each player nearby.
    elite.abils[2] = spell:new(casttype_unit, p, FourCC('A029'))
    elite.abils[2]:addaction(function()
        local rand = {}
        local grp  = g:newbyxy(p, g_type_dmg, elite.abils[2].casterx, elite.abils[2].castery, 1200.0)
        grp:action(function()
            if utils.ishero(grp.unit) then
                rand[#rand+1] = grp.unit
            end
        end)
        grp:destroy()
        -- select random player to target if present:
        if #rand > 0 then
            local miscount  = 6
            local caster    = elite.abils[2].caster
            local dmgtypeid = elite.stack[utils.data(caster)].dmgtypeid
            local dmgtype   = dmg.type.stack[dmgtypeid]
            local spelldmg  = elite.spelldmg*1.66*map.mission.cache.setting[m_stat_attack]
            utils.timedrepeat(0.66, #rand, function()
                local lastmis   = miscount+1
                local x,y,e     = {},{},{}
                local index     = math.random(1,#rand)
                local selunit   = rand[index]
                local a         = utils.anglexy(utils.unitx(caster), utils.unity(caster), utils.unitxy(selunit))
                table.remove(rand, index)
                for i = 1,miscount do
                    a = a - math.random(1,18)
                    a = a + math.random(1,18)
                    x[i], y[i] = utils.projectxy(utils.unitx(caster), utils.unity(caster), i*math.random(75,150)+256, a)
                    e[i] = area_marker_stack[dmgtypeid]:create(x[i], y[i])
                    BlzSetSpecialEffectScale(e[i],0.75)
                end
                -- place 1 shell directly on the player (force them to react):
                x[lastmis], y[lastmis] = utils.unitxy(selunit)
                e[lastmis] = area_marker_stack[dmgtypeid]:create(x[lastmis], y[lastmis])
                BlzSetSpecialEffectScale(e[lastmis],0.75)
                utils.timed(1.72, function()
                    local inc = miscount+1 -- add the direct mortar.
                    -- begin launching mortar missiles:
                    utils.timedrepeat(0.51, miscount+1, function()
                        DestroyEffect(e[inc])
                        if utils.isalive(caster) then
                            local mis   = spell:pmissile_custom_xy(
                                caster, utils.unitx(caster), utils.unity(caster), x[inc], y[inc], mis_bolt_stack[dmgtypeid], spelldmg)
                            mis:initarcing()
                            mis.explr   = 128
                            mis.dmgtype = dmgtype
                        end
                        inc         = inc - 1
                    end, function()
                        x,y,e,s = nil,nil,nil,nil
                    end)
                end)
            end, function()
                dmgtype,rand = nil,nil,nil
            end)
        else
            rand,s = nil,nil
        end
    end)

    -- STORM STRIKE --
    -- sends out moving markers that create a lightning strike every 2 sec for 10 sec.
    elite.abils[3] = spell:new(casttype_unit, p, FourCC('A02I'))
    elite.abils[3]:addaction(function()
        local caster    = elite.abils[3].caster
        local count     = 4
        local dmgtypeid = elite.stack[utils.data(caster)].dmgtypeid
        local spelldmg  = elite.spelldmg*2.33*map.mission.cache.setting[m_stat_attack]
        local dmgtype   = dmg.type.stack[dmgtypeid]
        local vel       = 6
        local x,y,e,a,d,t,start = {},{},{},{},{},0,math.random(0,360)
        for i = 1,count do
            if math.random(1,2) == 1 then d[i] = 1 else d[i] = -1 end
            a[i]       = start+(i-1)*(360/count)
            x[i], y[i] = utils.projectxy(utils.unitx(caster), utils.unity(caster), (i*48)+math.random(196,512), a[i])
            e[i]       = area_marker_stack[dmgtypeid]:create(x[i], y[i])
            BlzSetSpecialEffectScale(e[i],1.15)
        end
        utils.timed(1.00, function()
            utils.timedrepeat(0.03, 330, function()
                t = t + 1
                for i = 1,count do
                    a[i]        = a[i] + d[i]*1.5
                    x[i], y[i]  = utils.projectxy(x[i], y[i], vel, a[i])
                    utils.seteffectxy(e[i], x[i], y[i])
                    if math.fmod(t, 66) == 0 then
                        area_storm_stack[dmgtypeid]:play(x[i], y[i])
                        spell:creepgdmgxy(caster, dmgtype, spelldmg, x[i], y[i], 176)
                    end
                end
            end, function()
                for i = 1,count do DestroyEffect(e[i]) end
                x,y,e,a,d = nil,nil,nil,nil,nil
            end)
        end)
    end)

--[[
    GOON ABILS --------------------------------------------------------------------------------
--]]
    elite.goon.abils = {}

    elite.goon.abils[dmg_arcane] = {}
    elite.goon.abils[dmg_arcane][#elite.goon.abils[dmg_arcane]+1]   = FourCC('A024') -- energy shield
    elite.goon.abils[dmg_arcane][#elite.goon.abils[dmg_arcane]+1]   = FourCC('A022') -- manathirst

    elite.goon.abils[dmg_frost] = {}
    elite.goon.abils[dmg_frost][#elite.goon.abils[dmg_frost]+1]     = FourCC('A027') -- chilled touch

    elite.goon.abils[dmg_nature] = {}
    elite.goon.abils[dmg_nature][#elite.goon.abils[dmg_nature]+1]   = FourCC('A020') -- overcharged

    elite.goon.abils[dmg_fire] = {}
    elite.goon.abils[dmg_fire][#elite.goon.abils[dmg_fire]+1]       = FourCC('A028') -- immolated
    elite.goon.abils[dmg_fire][#elite.goon.abils[dmg_fire]+1]       = FourCC('A023') -- infernal weapons

    elite.goon.abils[dmg_shadow] = {}
    elite.goon.abils[dmg_shadow][#elite.goon.abils[dmg_shadow]+1]   = FourCC('A026') -- envenomed
    elite.goon.abils[dmg_shadow][#elite.goon.abils[dmg_shadow]+1]   = FourCC('A025') -- undeath

    elite.goon.abils[dmg_phys] = {}
    elite.goon.abils[dmg_phys][#elite.goon.abils[dmg_phys]+1]       = FourCC('A007') -- critical wounds
    elite.goon.abils[dmg_phys][#elite.goon.abils[dmg_phys]+1]       = FourCC('A006') -- staggering blows
    elite.goon.abils[dmg_phys][#elite.goon.abils[dmg_phys]+1]       = FourCC('A01Z') -- thorns

    elite.buildspells = nil
end


-- @unit        = the unit to roll into a goon.
-- @dmgtypeid   = the element rolled for this elite.
-- @eliteowner  = the leader of the elite pack.
function elite.goon:new(unit, dmgtypeid, eliteowner)
    local o     = setmetatable({}, self)
    o.unit      = unit
    o.isgoon    = true
    o.dmgtypeid = dmgtypeid
    o.chief     = eliteowner
    o.dex       = utils.data(unit)
    o:updateatkdef(true)
    spell:addenchant(unit, dmgtypeid)
    SetUnitColor(self.unit, self.colort[self.dmgtypeid])
    elite.stack[o.dex] = o
    eliteowner.goons[#eliteowner.goons+1] = o
    return o
end


function elite.goon:destroygoon()
    utils.shallow_destroy(self)
    elite.stack[self.dex] = nil
end


-- @rollid = pass in the rolled index for the ability so each goon has the same effect (allowing predictability for players).
function elite.goon:addpassive(rollid)
    UnitAddAbility(self.unit, elite.goon.abils[self.dmgtypeid][rollid])
end
