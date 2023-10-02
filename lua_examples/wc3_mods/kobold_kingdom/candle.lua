candle              = {}
candle.__index      = candle
candle.thresh       = { -- at what percent candle light does a wave and commander spawn?
    [1] = 0.60,
    [2] = 0.30,
    [3] =  0.0,
}
candle.size         = { -- how many creatures to spawn with the darkness elite?
    [1] = 3,
    [2] = 5,
    [3] = 7,
}
candle.scale        = { -- how much more stronger are the creatures spawned?
    [1] = 1.00,
    [2] = 1.15,
    [3] = 1.30,
}
candle.cadence      = 1.25 -- how fast candle light burns (1 per cadence in sec).
candle.despawn      = 21.0  -- sec until wax canisters despawn.
candle.precalc      = {}  -- pre-calculated wave breakpoints (performance).
candle.spawned      = {}  -- store bool if the wave was already triggered.
candle.canister     = {}  -- collectible wax.
candle.canister[FourCC('I00A')] = 5
candle.canister[FourCC('I000')] = 10
candle.canister[FourCC('I001')] = 15
candle.canister[FourCC('I002')] = 30


function candle:init()
    local o = {}
    setmetatable(o, self)
    if not self.trig then
        self.trig = CreateTrigger()
        utils.playerloop(function(p) TriggerRegisterPlayerUnitEventSimple(self.trig, p, EVENT_PLAYER_UNIT_PICKUP_ITEM) end)
        TriggerAddAction(self.trig, function()
            utils.debugfunc(function() candle:collectwax() map.block:collectore() loot:collectloot() shrine:collectfragment() end, "collect wax or ore")
        end)
    end
    return o
end


function candle:load()
    for i = 1,3 do self.spawned[i] = false end
    self.default = 180 -- default wax total (1 pt == 1 x cadence).
    self.bossb   = 60  -- bonus wax added for boss fights.
    self.current = 0   -- the current candle light value.
    self.total   = self.default
    self.pobj    = kobold.player[Player(0)] -- NOTE: how to fix in multiplayer?
    -- only enable candle for non-boss fights:
    self:setcapacity()
    self.current  = self.total -- do before ui.
    self:updateui()
    if self.exhaustmr then ReleaseTimer(self.exhaustmr) end
    -- figure out what light levels trigger what waves:
    for waveid = 1,3 do
        self.precalc[waveid] = math.floor(self.thresh[waveid] * self.total)
        self.spawned[waveid] = false
        utils.looplocalp(function(p) BlzFrameSetVertexColor(map.manager.candlewave[waveid].fh, BlzConvertColor(255, 255, 255, 255)) end)
    end
end


function candle:updateui()
    utils.looplocalp(function()
        BlzFrameSetText(map.manager.candletxt, self.current.."/"..self.total)
        BlzFrameSetValue(map.manager.candlebar.fh, math.floor(100*self.current/self.total))
    end)
end


function candle:add(val, _u)
    -- add to a player's current wax.
    self.current = self.current + val
    if self.current > self.total then self.current = self.total end
    self:updateui()
    if _u then
        ArcingTextTag(color:wrap(color.ui.wax, "+"..tostring(val).." Wax"), _u)
    end
end


function candle:burn(val)
    -- reduce a player's candle capacity per 1 sec.
    if self.current > 0 then
        self.current = math.floor(self.current - val)
    else
        self.current = 0
    end
    self:updateui()
    self:check()
end


function candle:setcapacity()
    if map.mission.cache.id == m_type_boss_fight then
        self.total = math.floor(self.default*(1 + self.pobj[p_stat_wax]/100)) + self.bossb -- TODO: how to merge in multiplayer?
    else
        self.total = math.floor(self.default*(1 + self.pobj[p_stat_wax]/100))
    end
end


function candle:check()
    utils.debugfunc(function()
        for waveid = 1,3 do
            if not self.spawned[waveid] and self.current <= self.precalc[waveid] then
                self.spawned[waveid] = true
                if self.pobj:islocal() then
                    BlzFrameSetVertexColor(map.manager.candlewave[waveid].fh, BlzConvertColor(100, 255, 255, 255))
                end
                if map.mission.cache and map.mission.cache.id == m_type_boss_fight and map.mission.cache.boss then
                    alert:new(color:wrap(color.tooltip.alert, "The Darkness consumes your foe..."), 3.33)
                    map.mission.cache.boss:assign_darkness_spell(waveid)
                else
                    self:spawnwave(waveid)
                end
            end
        end
    end, "spawnwave")
end


function candle:spawnwave(waveid)
    -- create a cluster of darkness minions under wave 3:
    if waveid < 3 then
        local biomeid     = map.manager.biome.id
        local px,py       = utils.unitxy(self.pobj.unit)
        local x,y         = utils.projectxy(px, py, 1200, utils.anglexy(px, py, 0, 1000) + math.randomneg(-3,3))
        local rect        = Rect(0,0,0,0)
        -- darkness minions:
        local units  = creature.cluster.biome[biomeid][math.random(1, #creature.cluster.biome[biomeid])]:spawn(x, y, self.size[waveid], self.size[waveid]+2)
        for _,unit in ipairs(units) do self:updateunit(unit, waveid) end
        local grp  = g:newbytable(units)
        grp.temp   = true
        -- darkness elite:
        local elite = creature.darkt[math.random(1, #creature.darkt)]:create(x, y)
        grp:add(elite)
        self:updateunit(elite, waveid)
        UnitAddAbility(elite, FourCC('A03D')) -- aura effect
        -- run effect and clear blocks:
        utils.timedrepeat(0.21, 7, function(c)
            x,y = utils.projectxy(x, y, c*121, utils.anglexy(x, y, px, py))
            mis_voidballhge:playradius(300, 3, x, y)
            utils.setrectradius(rect, x, y, 500)
            utils.dmgdestinrect(rect, 99999)
        end, function() RemoveRect(rect) end)
        alert:new(color:wrap(color.tooltip.alert, "Your light is fading... minions of The Darkness approach..."), 3.33)
        utils.timedrepeat(6.0, nil, function()
            utils.debugfunc(function()
                grp:verifyalive()
                if grp and grp:getsize() > 0 then
                    if map.manager.activemap then
                        grp:attackmove(utils.unitxy(self.pobj.unit))
                    else
                        grp:completepurge()
                    end
                else
                    ReleaseTimer()
                end
            end, "timer")
        end)
    -- spawn The Darkness for wave 3:
    elseif waveid == 3 then
        self:spawndarkness()
    end
    return elite, grp
end


function candle:spawndarkness()
    -- if a player's candle light hit 0, begin sending recurring waves that get stronger.
    utils.playsoundall(kui.sound.darkwarning)
    alert:new(color:wrap(color.tooltip.alert, "Strange sounds can be heard... The Darkness approaches..."), 3.33)
    utils.timed(2.75, function()
        if map.manager.downp < map.manager.totalp then -- make sure players didn't die during the delay.
            local rect      = Rect(0,0,0,0)
            local x,y       = utils.unitxy(self.pobj.unit)
            x,y             = utils.projectxy(x, y, 1000, utils.anglexy(x, y, 0, 1000) + math.randomneg(-3,3))
            self.darkness   = utils.unitatxy(Player(24), x, y, 'n01O', math.random(0,360))
            UnitAddAbility(self.darkness, FourCC('A03D')) -- aura effect
            SetUnitPathing(self.darkness, false)
            utils.playerloop(function(p) UnitShareVisionBJ(true, self.darkness, p) end)
            -- spawn in effect:
            local x2,y2 = 0,0
            utils.timedrepeat(0.21, 12, function()
                if map.manager.activemap and self.darkness and rect then
                    x2,y2 = utils.projectxy(utils.unitx(self.darkness), utils.unity(self.darkness), math.random(300,900), math.random(0,360))
                    utils.setrectradius(rect, x2, y2, 400)
                    utils.dmgdestinrect(rect, 1000)
                    mis_voidballhge:playradius(600, 5, x, y)
                end
            end)
            -- constant attack move timer:
            self.exhaustmr = utils.timedrepeat(2.75, nil, function()
                -- spawn recurring wave and increment strength (wave changes reset on map load).
                if map.manager.activemap and self.darkness then
                    local x,y = utils.unitxy(self.darkness)
                    utils.setrectradius(rect, x, y, 400)
                    utils.dmgdestinrect(rect, 1000)
                    mis_voidballhge:playradius(600, 5, x, y)
                    utils.issatkxy(self.darkness, utils.unitxy(self.pobj.unit))
                else
                    if self.darkness then RemoveUnit(self.darkness) end
                    RemoveRect(rect)
                    ReleaseTimer()
                end
            end)
        end
    end)
end


function candle:updateunit(unit, waveid)
    SetUnitVertexColor(unit, 0, 0, 0, 255) -- make dark.
    SetUnitMoveSpeed(unit, math.ceil( GetUnitDefaultMoveSpeed(unit)*0.75) ) -- slower units due to strength
    BlzSetUnitMaxHP(unit,  math.ceil( BlzGetUnitMaxHP(unit)*self.scale[waveid]) )
    utils.scaleatk(unit, self.scale[waveid])
    -- SetUnitPathing(unit, false)
    UnitAddAbility(unit, FourCC('A009'))
    utils.restorestate(unit)
    utils.issatkxy(unit, utils.unitxy(self.pobj.unit))
    dmg:convertdmgtype(unit, dmg_shadow)
end


function candle:collectwax()
    local id = GetItemTypeId(GetManipulatedItem())
    if candle.canister[id] and map.manager.activemap then
        candle:add(candle.canister[id], utils.trigu())
    end
end


function candle:spawnwax(x, y, _size)
    local itm,inc
    if _size and _size == "large" then
        itm = CreateItem(FourCC('I002'), x, y)
    elseif _size and _size == "medium" then
        itm = CreateItem(FourCC('I001'), x, y)
    elseif _size and _size == "tiny" then
        itm = CreateItem(FourCC('I00A'), x, y)
    else
        itm = CreateItem(FourCC('I000'), x, y)
    end
    utils.timedrepeat(0.21, self.despawn/0.21, function(c)
        inc = math.floor((255*(c/(self.despawn/0.21))))
        -- BlzSetItemIntegerFieldBJ(itm, ITEM_IF_TINTING_COLOR_RED, 255)
        BlzSetItemIntegerFieldBJ(itm, ITEM_IF_TINTING_COLOR_GREEN, 255 - inc)
        BlzSetItemIntegerFieldBJ(itm, ITEM_IF_TINTING_COLOR_BLUE, 255 - inc)
    end, function() if itm then RemoveItem(itm) end end)
end
