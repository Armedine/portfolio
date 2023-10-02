buffy = {}


function buffy:buildbuffs()
    -- order id list: https://github.com/nestharus/JASS/blob/master/jass/Systems/OrderIds/script.j
    bf_slow             = buffy:new('A01S', 'Bslo', 852075, false, true)
    bf_slow.name        = 'Slowed'
    bf_slow.icon        = 'ReplaceableTextures\\CommandButtons\\BTNSlow.blp'
    bf_slow.descript    = 'Reduced movespeed'
    bf_ms               = buffy:new('A01T', 'B000', 852101, false, false) -- NOTE: these use empty buff effects
    bf_ms.name          = 'Sprint'
    bf_ms.icon          = 'ReplaceableTextures\\CommandButtons\\BTNBoots.blp'
    bf_ms.descript      = 'Increased movespeed'
    bf_msmax            = buffy:new('A03C', 'B000', 852101, false, false) -- NOTE: these use empty buff effects
    bf_msmax.name       = 'Max Sprint'
    bf_msmax.icon       = 'ReplaceableTextures\\CommandButtons\\BTNBootsOfSpeed.blp'
    bf_msmax.descript   = 'Movespeed increased to maximum'
    bf_armor            = buffy:new('A01R', 'Binf', 852066, false, false)
    bf_armor.name       = 'Armored'
    bf_armor.icon       = 'ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne.blp'
    bf_armor.descript   = 'Increased physical resistance'
    bf_invis            = buffy:new('A01Q', 'Binv', 852069, false, false)
    bf_invis.name       = 'Invisible'
    bf_invis.icon       = 'ReplaceableTextures\\CommandButtons\\BTNInvisibility.blp'
    bf_invis.descript   = 'Enemies cannot detect you'
    bf_stun             = buffy:new('A01U', 'BPSE', 852095, false, false)
    bf_stun.name        = 'Stunned'
    bf_stun.icon        = 'ReplaceableTextures\\CommandButtons\\BTNStun.blp'
    bf_stun.descript    = 'Unable to take action'
    bf_freeze           = buffy:new('A01J', 'B001', 852171, false, true)
    bf_freeze.name      = 'Frozen'
    bf_freeze.icon      = 'ReplaceableTextures\\CommandButtons\\BTNFreezingBreath.blp'
    bf_freeze.descript  = 'Unable to move or attack'
    bf_root             = buffy:new('A01X', 'B002', 852171, false, true)
    bf_root.name        = 'Rooted'
    bf_root.icon        = 'ReplaceableTextures\\CommandButtons\\BTNEntanglingRoots.blp'
    bf_root.descript    = 'Unable to move'
    bf_silence          = buffy:new('A01W', 'B000', 852668, false, false) -- NOTE: these use empty buff effects
    bf_silence.name     = 'Silenced'
    bf_silence.icon     = 'ReplaceableTextures\\CommandButtons\\BTNSilence.blp'
    bf_silence.descript = 'Cannot cast spells'
    -- AoE:
    bf_a_atk            = buffy:new('A01Y', 'BNht', 852588, true)
    bf_a_atk.name       = 'Hasty Hands'
    bf_a_atk.icon       = 'ReplaceableTextures\\CommandButtons\\BTNGlove.blp'
    bf_a_atk.descript   = 'Increased mining speed'
end


function buffy:preload()
    local tar = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), FourCC("hfoo"), 18000, 17000, 270)
    local debugtar
    if self.debug then debugtar = CreateUnit(Player(0), FourCC("hfoo"), 18000, 17000, 270) end
    for i = 1,#self.stack do
        if not self.stack[i].aoe then
            self.stack[i]:apply(tar, 1.0)
        else
            self.stack[i]:applyaoe(tar, 1.0)
        end
        if self.debug then self.stack[i]:apply(debugtar, i+1.0) end
    end
    self.preloading = nil
    RemoveUnit(tar)
end


-- NOTE: currently has zero multiplayer support.
function buffy:buildpanel()
    self.fr = kui.frame:newbytype("BACKDROP", kui.canvas.game.skill)
    self.fr:setbgtex(kui.tex.invis)
    self.fr:setfp(fp.bl, fp.b, kui.worldui, -kui:px(368), kui:px(185))
    self.fr:setsize(kui:px(284), kui:px(25))
    self.fr.stack = {}
    local startx, starty, xoff, pad  = -368, 185, 0, 4
    for buffid = 1,20 do
        if buffid == 11 then
            startx, starty, xoff = -368, 185 + 25 + 4, 0
        end
        self.fr.stack[buffid] = kui.frame:newbtntemplate(kui.canvas.game.skill, kui.tex.invis)
        self.fr.stack[buffid]:setfp(fp.bl, fp.b, kui.worldui, kui:px(startx + xoff), kui:px(starty))
        self.fr.stack[buffid]:setsize(kui:px(25), kui:px(25))
        self.fr.stack[buffid].btn:assigntooltip("buff")
        self.fr.stack[buffid].btn.hoverarg = buffid
        self.fr.stack[buffid]:hide()
        xoff = xoff + 25 + pad
    end
end


function buffy:add_indicator(p, name, icon, dur, descript, _effect, _attachpoint)
    -- find first open slot:
    self:start_indicator_timer()
    if _effect then _effect:attachu(kobold.player[p].unit, dur, _attachpoint) end
    if utils.islocalp(p) then
        if not self:check_for_duplicate(name, dur) then
            for buffid = 1,20 do
                if not self.fr.stack[buffid].data then
                    self.fr.stack[buffid]:setbgtex(icon)
                    self.fr.stack[buffid].data          = {}
                    self.fr.stack[buffid].data.descript = descript
                    self.fr.stack[buffid].data.name     = name
                    self.fr.stack[buffid].data.dur      = dur
                    self.fr.stack[buffid].data.icon     = icon
                    self.fr.stack[buffid].data.elapsed  = 0
                    self.fr.stack[buffid]:show()
                    self.fr.stack[buffid]:setalpha(255)
                    break
                end
            end
        end
    end
end


function buffy:check_for_duplicate(name, dur)
    for buffid = 1,20 do
        if self.fr.stack[buffid].data and self.fr.stack[buffid].data.name == name then
            self.fr.stack[buffid].data.dur     = dur
            self.fr.stack[buffid].data.elapsed = 0
            return true
        end
    end
    return false
end


function buffy:start_indicator_timer()
    buffy_dur_check = 0
    -- init timer:
    if not self.tmr then
        self.tmr = NewTimer()
        TimerStart(self.tmr, 0.21, true, function()
            utils.debugfunc(function()
                buffy_total_check = 20
                for buffid = 1,20 do
                    if self.fr.stack[buffid].data then
                        self.fr.stack[buffid].data.elapsed = self.fr.stack[buffid].data.elapsed + 0.21
                        -- check for depletion:
                        if self.fr.stack[buffid].data.elapsed >= self.fr.stack[buffid].data.dur then
                            self.fr.stack[buffid].data = nil
                            -- sort empty slots to beginning:
                            for currentid = buffid,20 do
                                if self.fr.stack[currentid + 1] and self.fr.stack[currentid + 1].data then
                                    self.fr.stack[currentid].data = self.fr.stack[currentid + 1].data
                                    self.fr.stack[currentid + 1].data = nil
                                end
                            end
                        end
                    end
                end
                -- filter icons to correct positions:
                for buffid = 1,20 do
                    if self.fr.stack[buffid].data then
                        -- decorate transparency for "almost over" indication:
                        buffy_dur_check = self.fr.stack[buffid].data.elapsed/self.fr.stack[buffid].data.dur
                        if buffy_dur_check > 0.8 then
                            self.fr.stack[buffid]:setalpha(90)
                        elseif buffy_dur_check > 0.65 then
                            self.fr.stack[buffid]:setalpha(150)
                        elseif buffy_dur_check > 0.5 then
                            self.fr.stack[buffid]:setalpha(200)
                        else
                            self.fr.stack[buffid]:setalpha(255)
                        end
                        -- re-show if hidden:
                        self.fr.stack[buffid]:setbgtex(self.fr.stack[buffid].data.icon)
                        self.fr.stack[buffid]:show()
                    else
                        self.fr.stack[buffid]:setbgtex(kui.tex.invis)
                        self.fr.stack[buffid]:hide()
                        buffy_total_check = buffy_total_check - 1
                    end
                end
                if buffy_total_check <= 0 then ReleaseTimer() self.tmr = nil end
            end, "buffy timer")
        end)
    end
end


function buffy:init()
    utils.debugfunc(function()
        self.__index  = self
        self.unit     = {}
        self.stack    = {}
        self.dummyid  = FourCC("h008")
        self.isbuff   = true    -- NOTE: not currently in use, but differentiates positive/negative for targeting purposes.
        self.debug    = false
        self.playeff  = false   -- play a negative eye candy effect on application (targeted only).
        self.eff      = speff_debuffed
        self.deflvl   = 0       -- cast this ability level by default
        self.dummy    = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), self.dummyid, 19000, 18000, 270)
        self.pdummy   = {}      -- for dummy abilities that have casting time, cast per player.
        self.pdummy[25] = self.dummy -- in case gen_ suite is used with neutral hostile.
        self:buildbuffs()
        self.preloading = true
        self:preload()
    end)
end


function buffy:new(rawcode, buffcode, orderid, isaoe, playeffect)
    local o     = setmetatable({}, self)
    o.code      = FourCC(rawcode)
    o.buffcode  = FourCC(buffcode)
    o.orderid   = orderid
    o.playeff   = playeffect or false
    o.aoe       = isaoe or false
    self.stack[#self.stack+1] = o
    return o
end


function buffy:verify_dummy()
    if not self.dummy or not utils.isalive(self.dummy) then
        self.dummy = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), self.dummyid, 19000, 18000, 270)
    end
end


function buffy:new_absorb_indicator(p, name, icon, amount, dur, _descript)
    buffy:add_indicator(p, name.." Shield", icon, dur, _descript or "Absorbs up to "..tostring(amount).." damage")
end


function buffy:new_p_stat_indicator(p, p_stat, dur)
    if loot.statmod.pstatstack[p_stat] then
        local statname, icon = "", nil
        if p_stat == p_epic_hit_crit then
            statname = "Critical Hit Chance"
            icon = "ReplaceableTextures\\CommandButtons\\BTNCriticalStrike.blp"
        elseif p_stat == p_epic_demon then
            statname = "Chance to Summon Demon"
            icon = "ReplaceableTextures\\CommandButtons\\BTNRevenant.blp"
        elseif loot.statmod.pstatstack[p_stat].buffname then
            statname = loot.statmod.pstatstack[p_stat].buffname
            icon = loot.statmod.pstatstack[p_stat].icon
        else
            statname = loot.statmod.pstatstack[p_stat].name
            icon = loot.statmod.pstatstack[p_stat].icon
        end
        buffy:add_indicator(p, "+"..statname, icon or "ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp",
            dur, "Temporarily increased "..statname)
    end
end


function buffy:new_buff_indicator(p, dur)
    buffy:add_indicator(p, self.name, self.icon, dur, self.descript)
end


-- apply a buff to a @unit for @dur sec.
function buffy:apply(unit, dur, _preventstacking, _ignorebuff)
    utils.debugfunc(function()
        self:verify_dummy()
        if _preventstacking and UnitHasBuffBJ(unit, self.buffcode) then
            return
        else
            self:updatesettings(unit, dur)
            self:cast(unit)
            if self.playeff then self.eff:play(utils.unitxy(unit)) end
            UnitRemoveAbility(self.dummy, self.code)
            if not _ignorebuff and not self.preloading and utils.pnum(utils.powner(unit)) <= kk.maxplayers then
                self:new_buff_indicator(utils.powner(unit), dur)
            end
        end
    end)
end


-- cast an area-effect buff from @unit's location for @dur sec.
-- use @ownerunit to decide the spell's targets (ally or enemy).
function buffy:applyaoe(ownerunit, dur, _diameter)
    utils.debugfunc(function()
        self:verify_dummy()
        SetUnitOwner(self.dummy, utils.powner(ownerunit), false)
        self:updatesettings(ownerunit, dur, _diameter)
        self:castaoe()
        UnitRemoveAbility(self.dummy, self.code)
        SetUnitOwner(self.dummy, Player(PLAYER_NEUTRAL_AGGRESSIVE), false)
    end)
end


function buffy:updatesettings(unit, dur, _diameter)
    utils.setxy(self.dummy, utils.unitxy(unit))
    UnitAddAbility(self.dummy, self.code)
    local abil = BlzGetUnitAbility(self.dummy, self.code)
    local dur  = dur or 3.0
    -- 0-based:
    if BlzGetAbilityRealLevelField(abil, ABILITY_RLF_DURATION_NORMAL, self.deflvl) then
        BlzSetAbilityRealLevelField(abil, ABILITY_RLF_DURATION_NORMAL, self.deflvl, dur)
        BlzSetAbilityRealLevelField(abil, ABILITY_RLF_DURATION_HERO, self.deflvl, dur)
    else
        if self.debug then print("error: no real field for "..tostring(abil).." at lvl "..self.deflvl) end
    end
    if _diameter then
        BlzSetAbilityRealLevelField(abil, ABILITY_RLF_AREA_OF_EFFECT, self.deflvl, _diameter or 500.0)
    end
end


function buffy:cast(unit)
    IssueTargetOrderById(self.dummy, self.orderid, unit)
end


function buffy:castaoe()
    if self.debug then
        print(tostring(IssueImmediateOrderById(self.dummy, self.orderid)))
    else
        IssueImmediateOrderById(self.dummy, self.orderid)
    end
end


function buffy:gen_cast_instant(unit, abilcode, orderstr)
    local pnum, bool = utils.pnum(utils.powner(unit)), false
    self:gen_init(abilcode, unit, orderstr, pnum)
    bool = IssueImmediateOrder(self.pdummy[pnum], orderstr)
    self:gen_cleanup(abilcode, pnum)
    return bool
end


function buffy:gen_cast_point(unit, abilcode, orderstr, x, y)
    local pnum, bool = utils.pnum(utils.powner(unit)), false
    self:gen_init(abilcode, unit, orderstr, pnum)
    SetUnitFacing(self.pdummy[pnum], utils.anglexy(utils.unitx(self.pdummy[pnum]), utils.unity(self.pdummy[pnum]), x, y))
    bool = IssuePointOrder(self.pdummy[pnum], orderstr, x, y)
    self:gen_cleanup(abilcode, pnum)
    return bool
end


function buffy:gen_cast_unit(unit, abilcode, orderstr, target)
    local pnum, bool = utils.pnum(utils.powner(unit)), false
    self:gen_init(abilcode, unit, orderstr, pnum)
    SetUnitFacing(self.pdummy[pnum], utils.anglexy(utils.unitx(self.pdummy[pnum]), utils.unity(self.pdummy[pnum]), utils.unitxy(target)))
    bool = IssueTargetOrder(self.pdummy[pnum], orderstr, target)
    self:gen_cleanup(abilcode, pnum)
    return bool
end


function buffy:create_dummy(p, x, y, id, dur)
    local u = utils.unitatxy(p, x, y, id, 270.0)
    UnitApplyTimedLife(u, FourCC('BTLF'), dur)
    return u
end


function buffy:gen_init(abilcode, unit, orderstr, pnum)
    if not self.pdummy[pnum] then self.pdummy[pnum] = CreateUnit(Player(pnum-1), self.dummyid, 19000, 18000, 270) end
    utils.setxy(self.pdummy[pnum], utils.unitxy(unit))
    UnitAddAbility(self.pdummy[pnum], abilcode)
end


function buffy:gen_cleanup(abilcode, pnum)
    UnitRemoveAbility(self.pdummy[pnum], abilcode)
end


function buffy:gen_reset(unit, abilcode)
    local unit, abilcode = unit, abilcode
    utils.palert(utils.powner(unit), "Ability failed to cast (invalid target)!", 0.25)
    utils.timed(0.21, function() BlzEndUnitAbilityCooldown(unit, abilcode) end)
    utils.addmanaval(unit, BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, abilcode), ABILITY_ILF_MANA_COST, 0), false)
end
