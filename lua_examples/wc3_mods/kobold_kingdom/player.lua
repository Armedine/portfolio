kobold           = {}
kobold.player    = {}


function kobold:init()
    self.player:init()
    self.lvlcap        = 60 -- the current level cap.
    self.playing       = {}
    self.trigger       = {}
    self.trigger.death = {}
    self.trigger.leave = CreateTrigger()
    TriggerAddAction(self.trigger.leave, function() kobold.player[utils.trigp()]:leftgame() end)
    for pnum = 1,kk.maxplayers do
        local p = Player(pnum-1)
        if GetPlayerController(p) == MAP_CONTROL_USER and GetPlayerSlotState(p) == PLAYER_SLOT_STATE_PLAYING then
            kobold.playing[p] = kobold.player:new(p)
        end
    end
    utils.setcambounds(gg_rct_mapinitbounds) -- requires kobold.playing object
end


function kobold.player:init()
    total_ids = 0
    local idf = function() total_ids = total_ids + 1 return total_ids end
    -- be converted into fixed values (for save/load).
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- global ids
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    p_stat_hp           = idf() -- int, health value
    p_stat_mana         = idf() -- int, mana value
    p_stat_wax          = idf() -- %, bonus wax
    p_stat_bms          = idf() -- %, bonus movement speed
    p_stat_bhp          = idf() -- %, bonus health
    p_stat_bmana        = idf() -- %, bonus mana
    -- main attributes
    p_stat_strength     = idf() -- int
    p_stat_wisdom       = idf() -- int
    p_stat_alacrity     = idf() -- int
    p_stat_vitality     = idf() -- int
    -- main attribute via items:
    p_stat_strength_b   = idf() -- int
    p_stat_wisdom_b     = idf() -- int
    p_stat_alacrity_b   = idf() -- int
    p_stat_vitality_b   = idf() -- int
    -- incompetence stats:
    p_stat_fear         = idf() -- int
    p_stat_cowardice    = idf() -- int
    p_stat_paranoia     = idf() -- int
    -- damage multipliers:
    p_stat_arcane       = idf() -- %
    p_stat_frost        = idf() -- %
    p_stat_fire         = idf() -- %
    p_stat_nature       = idf() -- %
    p_stat_shadow       = idf() -- %
    p_stat_phys         = idf() -- %
    -- damage resistances:
    p_stat_arcane_res   = idf() -- %
    p_stat_frost_res    = idf() -- %
    p_stat_nature_res   = idf() -- %
    p_stat_fire_res     = idf() -- %
    p_stat_shadow_res   = idf() -- %
    p_stat_phys_res     = idf() -- %
    -- utility properties:
    p_stat_healing      = idf() -- %, increased healing.
    p_stat_absorb       = idf() -- %, increased absorbs.
    p_stat_minepwr      = idf() -- %, mining power increase (attack damage).
    p_stat_minespd      = idf() -- %, `` speed.
    p_stat_eleproc      = idf() -- %, elemental proc chance.
    p_stat_thorns       = idf() -- int, deal x damage to attackers.
    p_stat_thorns_b     = idf() -- bonus thorns dmg.
    p_stat_shielding    = idf() -- int, absorb int damage after using ability.
    p_stat_dodge        = idf() -- %, chance to dodge non-spell attacks.
    p_stat_armor        = idf() -- %, reduction of non-spell attacks.
    -- secondary properties:
    p_stat_treasure     = idf() -- %, aka magic find.
    p_stat_digxp        = idf() -- %, bonus mission xp.
    p_stat_mislrange    = idf() -- %, max range of missile effects, etc.
    p_stat_abilarea     = idf() -- %, max radius of area-effect abils.
    p_stat_castspeed    = idf()
    p_stat_manartrn     = idf() -- %, mana returned on spellcast.
    p_stat_elels        = idf() -- %, elemental damage life steal.
    p_stat_physls       = idf() -- %, physical damage life steal.
    p_stat_potionpwr    = idf() -- %, increase healing potion effectiveness.
    p_stat_artifactpwr  = idf() -- %, increase mana potion effectiveness.
    p_stat_vendor       = idf() -- %, increases gold earned from selling items.
    p_stat_dmg_reduct   = idf() -- %, pure damage reduction (stacks with ele resists).
    -- added damage:
    p_stat_dmg_arcane   = idf()
    p_stat_dmg_frost    = idf()
    p_stat_dmg_nature   = idf()
    p_stat_dmg_fire     = idf()
    p_stat_dmg_shadow   = idf()
    p_stat_dmg_phys     = idf()
    -- minion keywords:
    p_stat_miniondmg    = idf()
    -- epic keywords:
    p_epic_arcane_mis   = idf()
    p_epic_frost_mis    = idf()
    p_epic_nature_mis   = idf()
    p_epic_fire_mis     = idf()
    p_epic_shadow_mis   = idf()
    p_epic_phys_mis     = idf()
    p_epic_heal_aoe     = idf()
    p_epic_aoe_stun     = idf()
    p_epic_hit_crit     = idf()
    p_epic_arcane_conv  = idf()
    p_epic_frost_conv   = idf()
    p_epic_nature_conv  = idf()
    p_epic_fire_conv    = idf()
    p_epic_shadow_conv  = idf()
    p_epic_phys_conv    = idf()
    p_epic_dmg_reduct   = idf()
    p_epic_demon        = idf()
    p_epic_arcane_aoe   = idf()
    p_epic_frost_aoe    = idf()
    p_epic_nature_aoe   = idf()
    p_epic_fire_aoe     = idf()
    p_epic_shadow_aoe   = idf()
    p_epic_phys_aoe     = idf()
    -- potion keywords:
    p_potion_life       = idf()
    p_potion_mana       = idf()
    p_potion_arcane_dmg = idf()
    p_potion_frost_dmg  = idf()
    p_potion_fire_dmg   = idf()
    p_potion_nature_dmg = idf()
    p_potion_shadow_dmg = idf()
    p_potion_phys_dmg   = idf()
    p_potion_dmgr       = idf()
    p_potion_fire_res   = idf()
    p_potion_frost_res  = idf()
    p_potion_nature_res = idf()
    p_potion_shadow_res = idf()
    p_potion_arcane_res = idf()
    p_potion_phys_res   = idf()
    p_potion_aoe_stun   = idf()
    p_potion_aoe_heal   = idf()
    p_potion_aoe_mana   = idf()
    p_potion_aoe_slow   = idf()
    p_potion_absorb     = idf()
    p_potion_armor      = idf()
    p_potion_dodge      = idf()
    p_potion_lifesteal  = idf()
    p_potion_thorns     = idf()
    --
    idf = nil
    -- oretype ids:
    ore_arcane          = 1
    ore_frost           = 2
    ore_nature          = 3
    ore_fire            = 4
    ore_shadow          = 5
    ore_phys            = 6
    ore_gold            = 7
    -- More secondary stat ideas:
    -- Spell on Hit - X chance to cast <spell> when dealing damage.
    --      (idea: spell could be initialized via ability templates and a damage modifier for its power could
    --      be added to the calc formula e.g. do 50% less damage).
    -- Spell when Damaged - X chance to cast <spell> when taking damage.
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- power attributes map
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    p_attr_map = {
        [1] = p_stat_strength,
        [2] = p_stat_wisdom,
        [3] = p_stat_alacrity,
        [4] = p_stat_vitality,
    }
    p_attr_b_map = {
        [1] = p_stat_strength_b,
        [2] = p_stat_wisdom_b,
        [3] = p_stat_alacrity_b,
        [4] = p_stat_vitality_b,
    }
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- lookup tables
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    p_dmg_lookup = { -- added bonus damage lookup table (by dmgtypeid 1-6)
        [1] = p_stat_dmg_arcane,
        [2] = p_stat_dmg_frost,
        [3] = p_stat_dmg_nature,
        [4] = p_stat_dmg_fire,
        [5] = p_stat_dmg_shadow,
        [6] = p_stat_dmg_phys,
    }
    p_resist_lookup = { -- mirrors p_dmg_lookup but for resistances
        [1] = p_stat_arcane_res,
        [2] = p_stat_frost_res,
        [3] = p_stat_nature_res,
        [4] = p_stat_fire_res,
        [5] = p_stat_shadow_res,
        [6] = p_stat_phys_res,
    }
    p_conv_lookup = { -- mirrors p_dmg_lookup but for resistances
        [p_epic_arcane_conv]    = 1,
        [p_epic_frost_conv]     = 2,
        [p_epic_nature_conv]    = 3,
        [p_epic_fire_conv]      = 4,
        [p_epic_shadow_conv]    = 5,
        [p_epic_phys_conv]      = 6,
    }
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- player data
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    self.basecastspeed = 0.51
    self.level          = 1
    self.nextlvlxp      = 100
    self.experience     = 0
    self.hasleft        = false
    self.defaulthp      = 256
    self.defaultmana    = 128
    self.defaultatk     = 26
    self.defaultatkspd  = 1.6
    self.defaultms      = 300 -- default movespeed
    self.unit           = nil -- player hero
    self.name           = ""  -- player name
    self.attrpoints     = 0   -- power attributes available.
    self.ancientfrag    = 0   -- ancient fragments
    self.downed         = false
    self.reseff         = speffect:new("Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl")
    self.lvleff         = speffect:new("Abilities\\Spells\\Other\\Levelup\\LevelupCaster.mdl")
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- player mission score data
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    self.score          = { -- statid mapping
        [1] = 0, -- damage
        [2] = 0, -- absorbed
        [3] = 0, -- healing
        [4] = 0, -- spells used
        [5] = 0, -- ore mined
        [6] = 0, -- revives
        xp  = 0, -- xp earned
        g   = 0, -- gold earned
    }
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- character panel details
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- character
    self[p_stat_hp]     = 512 -- starting base health
    self[p_stat_mana]   = 252 -- `` mana
    -- init empty stat indexes:
    for id = 3,total_ids do -- we init hp and mana (1 and 2) with fixed values, so skip them.
        self[id] = 0
    end
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- currency:
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    self.ore                 = {}
    self.gold                = 0
    self.ore[ore_arcane]     = 0
    self.ore[ore_frost]      = 0
    self.ore[ore_nature]     = 0
    self.ore[ore_fire]       = 0
    self.ore[ore_shadow]     = 0
    self.ore[ore_phys]       = 0
    self.ore[ore_gold]       = 0
    --
    self.__index = self
end


-- @p = player
function kobold.player:new(p)
    kobold.player[p]            = {}
    setmetatable(kobold.player[p], self)
    kobold.player[p].tcache     = {}
    kobold.player[p].items      = {} -- where items are stored.
    kobold.player[p].p          = p  -- player handle.
    kobold.player[p].pnum       = utils.pnum(p)  -- player number.
    kobold.player[p].name       = string.gsub(GetPlayerName(p), "(#.+)", "")
    kobold.player[p].level      = 1
    kobold.player[p].spell      = trg:new("spell", kobold.player[p].p)
    kobold.player[p].ore        = utils.shallow_copy(self.ore)   -- need to override tables since using metatable.
    kobold.player[p].score      = utils.shallow_copy(self.score) -- ``
    kobold.player[p]:regabilscore()
    kobold.player[p]:regabilabsorb()
    TriggerRegisterPlayerEvent(kobold.trigger.leave, p, EVENT_PLAYER_LEAVE)
    -- failed lethal check trigger:
    if not kobold.trigger.death[p] then
        kobold.trigger.death[p] = trg:new("death", p)
        kobold.trigger.death[p]:regaction(function()
            if kobold.player[p] and kobold.player[p].unit == utils.trigu() then
                ReviveHero(kobold.playing[p].unit, utils.unitx(kobold.playing[p].unit), utils.unity(kobold.playing[p].unit), false)
                kobold.playing[p]:down(true)
            end
        end)
    end
    kobold.player[p].ancients     = loot.ancient:newplayertable() -- store equipped ancient ids.
    kobold.player[p].ancientsdata = loot.ancient:newplayertable() -- store any additional data for effects.
    kobold.player[p].ancientscd   = {} -- store which ids' effects are on cooldown,
    -- initialize achievement values:
    kobold.player[p].badge = {}
    kobold.player[p].badgeclass = {}
    for id = 1,18 do
        kobold.player[p].badge[id] = 0
    end
    for id = 1,72 do
        kobold.player[p].badgeclass[id] = 0
    end
    return kobold.player[p]
end


function kobold.player:leftgame()
    utils.textall(self.name.." has abandoned the dig!")
    self.hasleft = true
    RemoveUnit(self.unit)
    if kui.canvas.game.party.pill[self.pnum] then
        kui.canvas.game.party.pill[self.pnum]:hide()
        kui.canvas.game.party.pill[self.pnum].hpbar:hide()
        kui.canvas.game.party.pill[self.pnum].manabar:hide()
    end
    self:cleardata()
    if map.manager.activemap then
        map.manager.totalp = map.manager.totalp - 1
        map.manager:rundefeatcheck()
    end
end


function kobold.player:cleardata()
    for i,v in pairs(self.items) do
        self.items[i] = nil
    end
    for i,v in pairs(self) do
        self[i] = nil
    end
    for slotid = 1001,1010 do
        loot.item:unequip(self.p)
    end
    loot:clearitems(self.p)
end


function kobold.player:repick()
    if not map.manager.activemap and not scoreboard_is_active then
        self:cleardata()
    end
end


function kobold.player:endcooldowns()
    for i,v in pairs(self.ability.spells) do
        for _,spell in pairs(v) do
            BlzEndUnitAbilityCooldown(self.unit, spell.code)
            spell.cdactive = false
        end
    end
end


function kobold.player:updatecastspeed()
    BlzSetUnitRealField(self.unit, UNIT_RF_CAST_POINT, math.max(0.1,self.basecastspeed*(1-self[p_stat_castspeed]/100)))
    BlzSetUnitRealField(self.unit, UNIT_RF_CAST_BACK_SWING, math.max(0.1,self.basecastspeed*(1-self[p_stat_castspeed]/100)))
end


function kobold.player:updatemovespeed()
    SetUnitMoveSpeed(self.unit, math.floor(self.defaultms*(1+self[p_stat_bms]/100)))
end


function kobold.player:updateattack()
    BlzSetUnitBaseDamage(self.unit, math.floor(self.defaultatk*(1+self[p_stat_minepwr]/100)), 0)
end


function kobold.player:updateattackspeed()
    BlzSetUnitAttackCooldown(self.unit, math.max(0.33, self.defaultatkspd*(1-self[p_stat_minespd]/100)), 0)
end


function kobold.player:updatehpmana()
    -- health/mana increase by 4 per assigned attr point:
    utils.setnewunithp(self.unit, (self.defaulthp + (self[p_stat_vitality_b]*4) + (self[p_stat_vitality]*4))*(1 + self[p_stat_bhp]/100))
    utils.setnewunitmana(self.unit, (self.defaultmana + (self[p_stat_wisdom_b]*4) + (self[p_stat_wisdom]*4))*(1 + self[p_stat_bmana]/100))
end


function kobold.player:updateallstats()
    utils.debugfunc(function()
        self:updatecastspeed()
        self:updatemovespeed()
        self:updateattackspeed()
        self:updateattack()
        self:updatehpmana()
        -- check equip-all badge:
        if self.badgeclass[badge:get_class_index(2, self.charid)] == 0 then
            local count = 0
            for slotid = 1001,1010 do
                if self.items[slotid] ~= nil then
                    count = count + 1
                end
            end
            if count == 10 then
                badge:earn(self, 2, self.charid)
            end
        end
    end)
end


function kobold.player:getitem(slotid)
    return self.items[slotid]
end


function kobold.player:setlvl(lvl)
    self.level = lvl
    SetHeroLevel(self.unit, lvl)
    self:updatelevel()
end


-- @count = [optional] add this many levels, default: 1
function kobold.player:addlevel(count, _skipeffect, _isloading)
    local count = count or 1
    for i = 1,count do
        local remainder = 0
        if self.experience > self.nextlvlxp then -- overflow
            remainder = self.experience - self.nextlvlxp
        end 
        SetHeroLevel(self.unit, GetHeroLevel(self.unit) + 1)
        if not _isloading then -- don't add points if character is loaded from save file.
            self:addattrpoint(5)
            self.mastery:addpoint()
        end
        self.level      = self.level + 1
        self.experience = 0
        self:updatelevel()
        self:abilityunlockcheck()
        if remainder > 0 then -- recursively apply overflow xp.
            self:awardxp(remainder)
        end
    end
    -- show alert eyecandy for player so they know they have earned things:
    kui.canvas.game.skill.alerticon[1]:show() -- char page alert
    kui.canvas.game.skill.alerticon[3]:show() -- mastery page alert
    if not _skipeffect then self.lvleff:playu(self.unit) end
end


function kobold.player:abilityunlockcheck()
    local unlock = false
    if math.fmod(self.level - 1, 3) == 0 then
        if self:islocal() then
            for row = 1,3 do
                for col = 1,4 do
                    if kui.canvas.game.abil.slot[row][col].btn.disabled then
                        kui.canvas.game.abil.slot[row][col].btn:show()
                        kui.canvas.game.abil.slot[row][col].lock:hide()
                        kui.canvas.game.abil.slot[row][col].btn.disabled = false
                        kui.canvas.game.abil.slot[row][col]:setnewalpha(255)
                        unlock = true
                        -- automatically learn abilities to fill empty bar:
                        if self.level < 11 then
                            self.ability:learn(row, col)
                        end
                        break
                    end
                end
                if unlock then
                    kui.canvas.game.skill.alerticon[4]:show() -- show new ability alert eyecandy on menu.
                    break
                end
            end
        end
    end
end


function kobold.player:addattrpoint(val)
    -- add power attributes when player levels up
    self.attrpoints = self.attrpoints + val
    self:updateattrui()
end


function kobold.player:autoapplyattr(_attrid)
    -- apply attributes automatically in even distribution (optional @_attrid: apply to only 1).
    utils.debugfunc(function()
        if self.attrpoints > 0 then -- duplicate click prevention.
            for i = 1,self.attrpoints do
                if _attr then
                    self:applyattrpoint(_attrid, true)
                else
                    self:applyattrpoint(p_stat_strength, true)
                    self:applyattrpoint(p_stat_wisdom, true)
                    self:applyattrpoint(p_stat_alacrity, true)
                    self:applyattrpoint(p_stat_vitality, true)
                end
            end
            utils.playsound(kui.sound.selnode, self.p)
        else
            self.attrpoints = 0
            if self:islocal() then kui.canvas.game.char.autoattr:hide() end
        end
    end)
end


function kobold.player:applyattrpoint(statid, _sndsuppress)
    utils.debugfunc(function()
        if self.attrpoints > 0 then -- duplicate click prevention.
            self.attrpoints = self.attrpoints - 1
            self:modstat(statid, true, 1)
            if not _sndsuppress then utils.playsound(kui.sound.selnode, self.p) end
            self:updateattrui()
        else
            self.attrpoints = 0
        end
    end)
end


function kobold.player:modstat(statid, addbool, _val)
    -- add or remove stats from a player, checking for special stat operations to run (e.g. attributes):
    utils.debugfunc(function() 
        local val = _val or 1
        if addbool then
            if statid == p_stat_strength_b or statid == p_stat_strength then
                self:modstat(p_stat_armor, true, val)
                self:modstat(p_stat_absorb, true, val)
            elseif statid == p_stat_wisdom_b or statid == p_stat_wisdom then
                ModifyHeroStat(bj_HEROSTAT_INT, self.unit, bj_MODIFYMETHOD_ADD, val)
            elseif statid == p_stat_alacrity_b or statid == p_stat_alacrity then
                self:modstat(p_stat_minepwr, true, val)
                self:modstat(p_stat_dodge, true, val)
            elseif statid == p_stat_vitality_b or statid == p_stat_vitality then
                ModifyHeroStat(bj_HEROSTAT_STR, self.unit, bj_MODIFYMETHOD_ADD, val)
            end
            self[statid] = self[statid] + val
        else
            if statid == p_stat_strength_b or statid == p_stat_strength then
                self:modstat(p_stat_armor, false, val)
                self:modstat(p_stat_absorb, false, val)
            elseif statid == p_stat_wisdom_b or statid == p_stat_wisdom then
                ModifyHeroStat(bj_HEROSTAT_INT, self.unit, bj_MODIFYMETHOD_SUB, val)
            elseif statid == p_stat_alacrity_b or statid == p_stat_alacrity then
                self:modstat(p_stat_minepwr, false, val)
                self:modstat(p_stat_dodge, false, val)
            elseif statid == p_stat_vitality_b or statid == p_stat_vitality then
                ModifyHeroStat(bj_HEROSTAT_STR, self.unit, bj_MODIFYMETHOD_SUB, val)
            end
            self[statid] = self[statid] - val
        end
        tooltip:updatecharpage(self.p)
        self:updateallstats()
    end, "modstat")
end


function kobold.player:calcminiondmg(amount)
    return math.floor(amount*(1+self[p_stat_miniondmg]/100))
end


function kobold.player:calcarmor()
     -- explained: every level = 1% less effective per active point (500 @ 60 = 40% reduced) (100 @ 20 = 16%)
    return math.ceil((self[p_stat_armor]-(self[p_stat_armor]*(self.level*0.01)))/5)
end


function kobold.player:calcdodge()
     -- explained: every level = 1.25% less effective per active point (500 @ 60 = 25% chance) (100 @ 20 = 15%)
    return math.ceil((self[p_stat_dodge]-(self[p_stat_dodge]*(self.level*0.0125)))/5)*10 -- dodge is 1000-based in the damage engine calculation (thus mult by 10).
end


function kobold.player:calceleproc()
    -- return math.ceil((self[p_stat_eleproc]-(self[p_stat_eleproc]*(self.level*0.0133)))/5)*10
    return self[p_stat_eleproc]
end


function kobold.player:updateattrui()
    -- update points available and toggle add (+) buttons.
    if self:islocal() then
        if self.attrpoints > 0 then
            kui.canvas.game.char.points:settext("Points Available: "..color:wrap(color.tooltip.good,self.attrpoints))
            kui.canvas.game.char.pointsbd:show()
            kui.canvas.game.char.autoattr:show()
            for i = 1,4 do kui.canvas.game.char.attr[i].addbd:setbgtex(kui.tex.addatrgrn) end
        else
            kui.canvas.game.char.points:settext("Points Available: "..color:wrap(color.txt.txtdisable,"0"))
            kui.canvas.game.char.pointsbd:hide()
            kui.canvas.game.char.autoattr:hide()
            for i = 1,4 do kui.canvas.game.char.attr[i].addbd:setbgtex(kui.tex.addatr) end
        end
    end
end


function kobold.player:updatelevel()
    self:calcnextlvlxp()
    if self:islocal() then
        kui.canvas.game.char.lvl:settext(color:wrap(color.tooltip.alert, self.level))
    end
end


function kobold.player:updatexpbar()
    if self:islocal() then
        BlzFrameSetValue(kui.canvas.game.skill.xpbar.fh, math.floor(100*self.experience/self.nextlvlxp))
    end
end


function kobold.player:resetscore()
    if self.score then for i,v in pairs(self.score) do v = nil end else self.score = {} end
end


function kobold.player:regabilscore()
    self.spell:regaction(function()
        if map.manager.activemap then self.score[5] = self.score[5] + 1 end
    end)
end


function kobold.player:regabilabsorb()
    -- see if player has absorb on spell stat.
    self.spell:regaction(function()
        if self[p_stat_shielding] > 0 and not self.shieldingpause then
            local amount = self[p_stat_shielding]*(1+self[p_stat_absorb]/100)
            self.shieldingpause = true
            dmg.absorb:new(utils.trigu(), 6.0, {all = amount}, nil, nil)
            utils.timed(3.0, function() self.shieldingpause = nil end)
            buffy:new_absorb_indicator(self.p, "Absorb on Cast", "ReplaceableTextures\\CommandButtons\\BTNNeutralManaShield.blp", nil, 6.0,
                "Absorbs "..tostring(math.floor(amount)).." damage (stacks)")
        end
    end)
end


function kobold.player:getlootodds()
    local findtotal = self[p_stat_treasure]
    -- if active mission, add mission treasure find:
    if map.mission.setting and map.mission.setting[m_stat_treasure] then
        findtotal = findtotal + map.mission.setting[m_stat_treasure]
    end
    return (findtotal*100)/4 -- convert to 10,000-based rolls; each point of TF makes rarity rolls 2.5 percent more effective.
end


function kobold.player:awardoretype(oreid, val, _showalert)
    -- print(val.." ore awarded for "..oreid)
    self.ore[oreid] = self.ore[oreid] + val
    if self.ore[oreid] < 0 then self.ore[oreid] = 0 end
    self:updateorepane()
    shop:updateframes()
    if _showalert then
        alert:new("You received "..color:wrap(color.tooltip.good, val).." "..tooltip.orename[oreid], 4)
    end
end


function kobold.player:updateorepane()
    if self:islocal() then
        for oreid,val in pairs(self.ore) do
            if kui.canvas.game.curr.txt[oreid] then
                if val < 0 
                    then val = 0
                elseif val == 0 then
                    kui.canvas.game.curr.txt[oreid]:settext(color:wrap(color.txt.txtdisable, "0"))
                else
                    kui.canvas.game.curr.txt[oreid]:settext(color:wrap(color.tooltip.good, val))
                end
            end
        end
    end
end


function kobold.player:awardxp(val)
    self.experience = math.floor(self.experience + val)
    if self.level < kobold.lvlcap then
        if self.experience >= self.nextlvlxp then
            utils.debugfunc( function() self:addlevel() end, "levelup" )
            self:calcnextlvlxp()
        end
    else
        self.experience = 0
    end
    self:updatexpbar()
end


function kobold.player:awardgold(val)
    self.gold = math.floor(self.gold + val)
    if self.gold < 0 then self.gold = 0 end
    if self:islocal() then kui.canvas.game.inv.goldtxt:settext(math.floor(self.gold)) end
    shop:updateframes()
end


function kobold.player:awardfragment(val, _hidealert)
    self.ancientfrag = math.floor(self.ancientfrag + val)
    if self.ancientfrag < 0 then self.ancientfrag = 0 end
    if self:islocal() then kui.canvas.game.inv.fragtxt:settext(math.floor(self.ancientfrag)) end
    shop:updateframes()
    if not _hidealert and val > 0 then
        if val > 1 then
            ArcingTextTag("+"..color:wrap(color.rarity.ancient, "Fragments"), self.unit)
        else
            ArcingTextTag("+"..color:wrap(color.rarity.ancient, "Fragment"), self.unit)
        end
    end
end


function kobold.player:calcnextlvlxp()
    self.nextlvlxp = math.ceil(100 + (self.level^1.02*12))
end


function kobold.player:down(bool)
    SetUnitInvulnerable(self.unit, bool)
    ResetUnitAnimation(self.unit)
    UnitRemoveBuffs(self.unit, true, true)
    PauseUnit(self.unit, bool)
    self.downed = bool
    if bool then
        SetUnitPathing(self.unit, false)
        kui.canvas.game.party.pill[self.pnum].downskull:show()
        map.manager.downp = map.manager.downp + 1
        map.manager:rundefeatcheck()
        utils.setlifep(self.unit, 1)
        utils.setmanap(self.unit, 0)
        SetUnitAnimation(self.unit, "death")
        if not self.downtmr then self.downtmr = NewTimer() end
        TimerStart(self.downtmr, 0.23, true, function()
            utils.setlifep(self.unit, 1)
            utils.setmanap(self.unit, 0)
        end)
        utils.palertall(color:wrap(color.tooltip.alert, self.name).." has been downed!", 3.0, true)
    else
        SetUnitPathing(self.unit, true)
        kui.canvas.game.party.pill[self.pnum].downskull:hide()
        map.manager.downp = map.manager.downp - 1
        self.reseff:playu(self.unit)
        ReleaseTimer(self.downtmr)
        utils.setlifep(self.unit, 20)
        utils.setmanap(self.unit, 0)
    end
end


function kobold.player:fetchcachedloot()
    -- retrieve loot that couldn't be transfered due to bag space, etc.
    if #self.tcache > 0 then -- prevent duplicate frame clicks.
        local flag = false   -- prevent error msg spam.
        for k,lootfunc in pairs(self.tcache) do
            if not loot:isbagfull(self.p) then
                lootfunc()
                self.tcache[k] = nil
                -- utils.palert(self.p, "Success! Previous treasure placed in your inventory.", 2.5, true)
                utils.playsound(kui.sound.itemsel, self.p)
            else
                if not flag then
                    flag = true
                    utils.palert(self.p, "Your bag is full! Free up space to accept this reward.")
                end
            end
        end
    end
    utils.tablecollapse(self.tcache)
    if utils.tablelength(self.tcache) == 0 then
        if self:islocal() then kui.canvas.game.inv.tcache:hide() end
    end
end


function kobold.player:islocal()
    return self.p == utils.localp()
end


function kobold.player:freeplaymode()
    self:addlevel(44, true)
    self:awardgold(100000)
    self:awardfragment(1000, true)
    for slotid = 1001,1010 do
        local item = loot:generate(self.p, self.level, slotid, rarity_rare)
        self.selslotid = 1
        item:equip(self.p)
    end -- how to do if we do multiplayer?
    for i = 1,6 do
        quest:addoreaward(200, i, false)
    end
    kui.canvas.game.equip.save:hide()
    kui.canvas.game.dig.mappiece:show()
    kui.canvas.game.dig.card[5]:show()
    for i = 1,5 do
        loot:generatedigkey(self.p, 1, i)
    end
    placeproject('shiny1')
    placeproject('shiny2')
    placeproject('shiny3')
    placeproject('ele1')
    placeproject('ele2')
    placeproject('ele3')
    placeproject('boss1')
    placeproject('boss2')
    placeproject('boss3')
    placeproject('boss4')
    placeproject('boss5')
    quest_shinykeeper_unlocked      = true
    quest_shinykeeper_upgrade_1     = true
    quest_shinykeeper_upgrade_2     = true
    quest_elementalist_unlocked     = true
    quest_elementalist_upgrade_1    = true
    quest_elementalist_upgrade_2    = true
    quest.socialfr.shinshop:show()
    quest.socialfr.eleshop:show()
    quest.socialfr.speakto:hide()
    utils.restorestate(self.unit)
    quest:disablequests()
    UnitRemoveAbility(self.unit, quest.speakcode)
end
