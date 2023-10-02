map         = {} -- level data class.
map.block   = {} -- placed block class.
map.diff    = {} -- difficulty class.
map.mission = {} -- mission (dig objective) class.
map.manager = {} -- class for managing UI -> map load.
map.grid    = {} -- map grid management.
map.biome   = {} -- store biome metadata.


function map:init()
    self.__index = self
    map.mission:init()
    map.diff:init()
    map.manager:init()
    map.grid:init()
    map.block:init()
    -- generate biomes:
    self.biome.biomet       = {}
    self.devmode            = false -- speeds up timers etc. when on.
    biome_id_foss           = 1
    biome_id_slag           = 2
    biome_id_mire           = 3
    biome_id_ice            = 4
    biome_id_vault          = 5
    self.biomemap   = { -- to retrieve name by id.
        [biome_id_foss]     = "Fossil Gorge",
        [biome_id_slag]     = "The Slag Pit",
        [biome_id_mire]     = "The Mire",
        [biome_id_ice]      = "Glacier Cavern",
        [biome_id_vault]    = "The Vault",
    }
    self.biomeportal = {
        [biome_id_foss]     = speff_voidport[6],
        [biome_id_slag]     = speff_voidport[4],
        [biome_id_mire]     = speff_voidport[3],
        [biome_id_ice]      = speff_voidport[2],
        [biome_id_vault]    = speff_voidport[5],
    }
    -- id 1 - fossile gorge
    biome_foss              = map.biome:new(biome_id_foss)
    biome_foss.dirt         = t_udgrd_rock
    biome_foss.terraint     = t_desert_g
    biome_foss.blockt       = { [1] = b_petrified, [2] = b_stone }
    biome_foss.oret         = { [1] = b_ore_gold, [2] = b_ore_phys, [3] = b_ore_arcane }
    -- id 2 - slag pit
    biome_slag              = map.biome:new(biome_id_slag)
    biome_slag.dirt         = t_udgrd_rock
    biome_slag.terraint     = t_slag_g
    biome_slag.blockt       = { [1] = b_slag, [2] = b_volc }
    biome_slag.oret         = { [1] = b_ore_gold, [2] = b_ore_fire, [3] = b_ore_shadow }
    -- id 3 - the mire
    biome_mire              = map.biome:new(biome_id_mire)
    biome_mire.dirt         = t_udgrd_rock
    biome_mire.terraint     = t_marsh_g
    biome_mire.blockt       = { [1] = b_shroom, [2] = b_stone }
    biome_mire.oret         = { [1] = b_ore_gold, [2] = b_ore_nature, [3] = b_ore_arcane }
    -- id 4 - glacier cavern
    biome_ice               = map.biome:new(biome_id_ice)
    biome_ice.dirt          = t_udgrd_rock
    biome_ice.terraint      = t_ice_g
    biome_ice.blockt        = { [1] = b_ice, [2] = b_stone }
    biome_ice.oret          = { [1] = b_ore_gold, [2] = b_ore_frost, [3] = b_ore_arcane }
    -- id 5 - the vault
    biome_vault             = map.biome:new(biome_id_vault)
    biome_vault.dirt        = t_udgrd_tile
    biome_vault.terraint    = t_vault_g
    biome_vault.blockt      = { [1] = b_stone, [2] = b_ore_gold }
    biome_vault.oret        = { [1] = b_ore_gold, [2] = b_ore_gold, [3] = b_ore_gold }
end


function map.biome:new(id)
    local o        = {}
    self.__index   = self
    self.dirt      = nil -- excavation marker.
    self.blockt    = nil -- ipairs, blocks that can be randomized in generation.
    o.id           = id
    self.biomet[#self.biomet + 1] = o
    setmetatable(o, self)
    return o
end


function map.grid:init()
    self.__index  = self
    self.yoff     = 512 -- the map isn't dead-center due to bottom base offset
    self.blockw   = 256
    self.rect     = Rect(0,0,0,0)
    self.leaverect= Rect(0,0,0,0)
    self.digrect  = Rect(0,0,0,0)
    self.start    = { x = 0, y = 0 } -- where players are spawned.
    self.coord    = {}
    self.center   = {}
    self.center.x, self.center.y = utils.rectxy(gg_rct_enterdigsite)
end


-- @xsize,@ysize = int; grid size in blocks.
-- @iscircle     = bool; make it a circle instead of a square.
function map.grid:build(xsize, ysize, iscircle)
    local wrapsize = 4 -- bedrock wrapper.
    self.maxx = math.floor(xsize/2)
    self.maxy = math.floor(ysize/2)
    self.minx = -self.maxx
    self.miny = -self.maxy
    for xb = self.minx,self.maxx do
        self.coord[xb] = {}
        for yb = self.miny,self.maxy do
            self.coord[xb][yb] = {}
        end
    end
    if iscircle then
        -- ( x - h )^2 + ( y - k )^2 = r^2
        self.r      = (-self.minx) - 1 -- remove 1 to be safe
        local step  = 2*math.pi/360
        local h,k   = 1/(2*math.pi),self.r/(2*math.pi)
        for theta = step, 360, step do
            local ptx, pty = math.floor(h + self.r*math.cos(theta)), math.floor(self.r*math.sin(theta))
            self.coord[ptx][pty].edge = true
        end
    else
        print('no square yet')
    end
    utils.debugfunc(function() self:runprocedures() end, "runprocedures")
    utils.debugfunc(function() self:wrapbedrock(wrapsize) end, "wrapbedrock")
    utils.debugfunc(function() self:setrectbounds(wrapsize) end, "setrectbounds")
    utils.debugfunc(function() self:setleavebounds() end, "setleavebounds")
    utils.debugfunc(function() self:clearunitsall(self.rect) end, "clearunitsall")
    utils.debugfunc(function() utils.setcambounds(self.rect) end, "setcambounds")
    -- register out of bounds event:
    self.boundstrig = CreateTrigger()
    TriggerRegisterLeaveRectSimple(self.boundstrig, self.leaverect, nil)
    TriggerAddAction(self.boundstrig, function()
        local p = utils.unitp()
        if utils.pnum(p) < 5 then -- is player
            spell.interrupt[utils.pnum(p)] = true -- interrupt certain spells.
            local u     = GetTriggerUnit()
            local ux,uy = utils.unitx(u),utils.unity(u)
            local x,y   = utils.projectxy(ux,uy,2248,utils.anglexy(ux,uy,GetRectCenterX(self.leaverect),GetRectCenterY(self.leaverect)))
            PauseUnit(u, true)
            utils.setxy(u, x, y)
            utils.palert(p, "You've exited the dig area! You are disabled for 6 seconds.")
            TimerStart(NewTimer(), 6.0, false, function() PauseUnit(u, false) spell.interrupt[utils.pnum(p)] = false end)
        elseif p == Player(PLAYER_NEUTRAL_AGGRESSIVE) and not utils.isancient(utils.trigu()) then
            RemoveUnit(utils.trigu())
        end
    end)
    map.manager:addprogress(10)
end


function map.grid:setrectbounds(wrapwidth)
    -- expand rect 256 x 256 to make absolutely sure we delete everything within it.
    SetRect(self.rect,
        self:getx(self.minx) - wrapwidth*256 - 256,
        self:gety(self.miny) + wrapwidth*256 - 256,
        self:getx(self.maxx) + wrapwidth*256 + 256,
        self:gety(self.maxy) - wrapwidth*256 + 256)
end


function map.grid:setleavebounds(wrapwidth)
    -- expand rect by 128 units to allow a small exit range.
    SetRect(self.leaverect,
        self:getx(self.minx) - 96,
        self:gety(self.miny) - 96,
        self:getx(self.maxx) + 96,
        self:gety(self.maxy) + 96)
end


function map.grid:purge()
    utils.debugfunc(function()
        if map_cleanup_func then map_cleanup_func() map_cleanup_func = nil end
        elite:cleanup()
        self:cleardest(self.rect, true)
        self:clearunitsall(self.rect)
        for xb = self.minx,self.maxx do
            for yb = self.miny,self.maxy do
                terrain:paint(self:getx(xb), self:gety(yb), t_udgrd_dirt, 3)
                self.coord[xb][yb] = nil
            end
            self.coord[xb] = nil
        end
    end, "map.grid:purge")
end


function map.grid:pickstart(r)
    if map.mission.cache.id == m_type_monster_hunt then
        self.a          = math.random(1,360)
        local r         = math.random(math.floor(r*0.7), math.floor(r*0.8))
        local ptx, pty  = math.floor(r*math.cos(self.a)), math.floor(r*math.sin(self.a))
        self.coord[ptx][pty].start = true
        self.start.x = self:getx(ptx)
        self.start.y = self:gety(pty)
    elseif map.mission.cache.id == m_type_boss_fight then
        self.start.x = self.center.x
        self.start.y = self.center.y - 1200.0
    elseif map.mission.cache.id == m_type_gold_rush then
        self.start.x = self.center.x
        self.start.y = self.center.y
    elseif map.mission.cache.id == m_type_candle_heist then
        self.start.x = self.center.x
        self.start.y = self.center.y
    end
end


function map.grid:clearstart()
    self:excavate(self.start.x, self.start.y, 1792, map.manager.biome.dirt)
    if map.mission.cache.id ~= m_type_boss_fight then
        self:clearunits(self.start.x, self.start.y, 2304)
    end
end


function map.grid:excavate(x, y, radius, _terrainid, _clearbedrock)
    -- move the dig rect then clear blocks at this spot.
    SetRect(self.digrect, x - radius/2, y - radius/2, x + radius/2, y + radius/2)
    self:cleardest(self.digrect, _clearbedrock)
    if _terrainid then
        terrain:paint(x, y, _terrainid, math.floor(radius/256))
    end
end


function map.grid:tilepaint(xb, yb, radius, terrainid)
    -- paint new tiles at a block location in a radius.
    terrain:paint(self:getx(xb), self:getx(yb), terrainid, math.floor(radius/256))
end


function map.grid:cleardest(rect, _bedrockbool)
    EnumDestructablesInRect(rect, nil, function()
        if _bedrockbool then -- clear every block type.
            RemoveDestructable(GetEnumDestructable())
        elseif GetDestructableTypeId(GetEnumDestructable()) ~= b_bedrock.code then -- ignore bedrock blocks.
            RemoveDestructable(GetEnumDestructable())
        end
    end)
end


function map.grid:clearunits(x, y, radius, _ignoreobjectives)
    SetRect(self.digrect, x - radius/2, y - radius/2, x + radius/2, y + radius/2)
    self:clearunitsall(self.digrect, _ignoreobjectives)
end


function map.grid:clearunitsall(rect, _ignoreobjectives)
    local grp = g:newbyrect(nil, nil, rect)
    if _ignoreobjectives then
        grp:action(function()
            if GetUnitTypeId(grp.unit) == FourCC("h00J") or GetUnitTypeId(grp.unit) == FourCC("o000") or GetUnitTypeId(grp.unit) == FourCC("n01V")
            or GetUnitTypeId(grp.unit) == FourCC("n005") or GetUnitTypeId(grp.unit) == FourCC("ngol") then
                grp:remove(grp.unit)
            end
        end)
    end
    grp:completepurge()
end


function map.grid:runprocedures()
    local funcs = {}
    -- pick a start location (*note: must be done before funcs that rely on map.mission.cache):
    funcs[#funcs+1] = function() self:pickstart(self.r) end
    -- pre-clear any lingering destructables and units not caught in cleanup:
    funcs[#funcs+1] = function()
        self:clearunits(0, 1000, 27*512)
        self:excavate(0, 1000, 27*512, nil, true)
    end
    -- wrap edge in bedrock:
    funcs[#funcs+1] = function()
        self:gridloop(function(xb, yb)
            if self.coord[xb][yb].edge then
                b_bedrock:place(xb,yb)
            end
        end)
    end
    -- fill rest of grid with bedrock:
    funcs[#funcs+1] = function() -- traverse down
        for xb = self.minx,self.maxx,1 do
            for yb = self.miny,self.maxy do
                if self.coord[xb][yb].edge then
                    break
                else
                    b_bedrock:place(xb,yb)
                end
            end
        end
    end
    funcs[#funcs+1] = function() -- traverse up
        for xb = self.minx,self.maxx do
            for yb = self.maxy,self.miny,-1 do
                if self.coord[xb][yb].edge then
                    break
                else
                    b_bedrock:place(xb,yb)
                end
            end
        end
    end
    -- decorate with biome-specific terrain:
    funcs[#funcs+1] = function()
        self:gridloop(function(xb, yb)
            if not self.coord[xb][yb].code then
                self:tilepaint(xb, yb, 768, self:randomterrain())
            end
        end)
    end

    --[[
    ***************************************************
    *************mission-specific generators***********
    ***************************************************
    --]]

    -- build mission:
    if map.mission.debug then print("running block generator for missionid",map.mission.cache.id) end
    -- fill out map with blocks if mission is eligible:
    if map.mission.cache.id ~= m_type_boss_fight then
        -- fill map with excavation blocks:
        funcs[#funcs+1] = function()
            self:gridloop(function(xb, yb)
                if not self.coord[xb][yb].code then
                    self:randomblock():place(xb,yb)
                end
            end)
        end
        -- run random excavation throughout map:
        funcs[#funcs+1] = function() self:randomexcavate() end
        -- place random ore deposits on map:
        funcs[#funcs+1] = function() self:randomdeposits() end
        if map.mission.cache.id ~= m_type_gold_rush then
            -- generate random creatures:
            funcs[#funcs+1] = function() self:randomcreatures(map.manager.biome.id, self.center.x, self.center.y) end
        end
    end
    -- implement mission-specific components:
    if map.mission.cache.id == m_type_gold_rush then
        funcs[#funcs+1] = function() self:placegoldrush() end
    elseif map.mission.cache.id == m_type_candle_heist then
        funcs[#funcs+1] = function() self:placecandleheist() end
    elseif map.mission.cache.id == m_type_boss_fight then
        -- do nothing, empty arena.
    end
    -- clear start location of blocks and creatures for non-boss missions:
    if map.mission.cache.id ~= m_type_boss_fight and map.mission.cache.id ~= m_type_gold_rush then
        funcs[#funcs+1] = function() self:clearstart() end
    end
    -- place objective elements on the map:
    funcs[#funcs+1] = function() map.mission.cache:placeobj() end
    -- queue and run procedures:
    local i = 0
    TimerStart(NewTimer(),0.25,true,function()
        utils.debugfunc(function()
            i = i + 1
            map.manager:addprogress(math.floor(90/#funcs))
            funcs[i]()
            if i == #funcs then
                map.manager:loadend()
                for func in pairs(funcs) do func = nil end
                funcs = nil
                ReleaseTimer()
            end
         end, "grid funcs[i]() timer")
    end)
end


function map.grid:placecandleheist()
    self.rushwave = 1
    if map.mission.cache.level < 10 then
        self.grwavemin, self.grwavemax = 2, 3
    elseif map.mission.cache.level < 20 then
        self.grwavemin, self.grwavemax = 3, 4
    else
        self.grwavemin, self.grwavemax = 4, 5
    end
    self.chpylon = {}
    -- place pylons and wax canisters:
    local starta,x,y,x2,y2,z = math.random(0,360),0,0,0,0,z
    for i = 1,3 do
        x,y = utils.projectxy(0, 0, 2675, starta + i*120)
        -- clear nearby blocks:
        map.grid:excavate(x, y, 512, t_udgrd_tile)
        map.grid:clearunits(x, y, 300.0)
        -- initialize pylon objects:
        self.chpylon[i]             = {}
        self.chpylon[i].unit        = {}
        self.chpylon[i].lightn      = {}
        self.chpylon[i].icon        = CreateMinimapIconBJ(x, y, 255, 0, 255, "UI\\Minimap\\MiniMap-ControlPoint.mdl", FOG_OF_WAR_MASKED)
        self.chpylon[i].e           = speff_waxcan:create(x, y, 2.0)
        self.chpylon[i].destroyed   = 0
        utils.seteffectxy(self.chpylon[i].e, x, y, utils.getcliffz(x, y, 425.0))
        for b = 1,3 do
            -- init center point and clear blocks/units:
            self.chpylon[i].x,self.chpylon[i].y = utils.projectxy(x, y, 384, b*120)
            map.grid:excavate(self.chpylon[i].x, self.chpylon[i].y, 512, t_udgrd_tile)
            map.grid:clearunits(self.chpylon[i].x, self.chpylon[i].y, 300.0)
            -- place pylon and lightning effects:
            self.chpylon[i].unit[b] = utils.unitatxy(Player(24), self.chpylon[i].x, self.chpylon[i].y, map.mission.darkkobpylonid, 270.0)
            utils.setnewunithp(self.chpylon[i].unit[b], (map.mission.chpylonhp + (((map.mission.cache.level-1)^1.2)*1.2))*(1+map.manager.diffid*0.3), true)
            z = utils.getcliffz(self.chpylon[i].x, self.chpylon[i].y, 240.0)
            self.chpylon[i].lightn[b] = AddLightningEx("CLPB", false, self.chpylon[i].x, self.chpylon[i].y, z, x, y, utils.getcliffz(x, y, 490.0))
            SetLightningColorBJ(self.chpylon[i].lightn[b], 1, 0, 1, 1)
        end
    end
    -- destroy a pylon:
    if not self.chtrig then
        self.chtrig = trg:new('death', Player(24))
        self.chtrig:regaction(function()
            if utils.triguid() == FourCC(map.mission.darkkobpylonid) and map.manager.activemap and not map.manager.objiscomplete then
                local x,y = utils.unitxy(utils.trigu())
                map.grid:spawnattackwave(utils.trigu(), nil, cl_vault_dkobold, 400, 1.21, 600.0)
                -- check which unit died and destroy lightning linkage:
                if self.chpylon then
                    for i = 1,3 do
                        if self.chpylon[i] then
                            for b = 1,3 do
                                if self.chpylon[i].unit[b] and utils.trigu() == self.chpylon[i].unit[b] then
                                    DestroyLightning(self.chpylon[i].lightn[b])
                                    self.chpylon[i].destroyed = self.chpylon[i].destroyed + 1
                                    if self.chpylon[i].destroyed == 3 then -- all nearby pylons are dead, recover the wax canister.
                                        self.grwavemin = self.grwavemin + 1
                                        self.grwavemax = self.grwavemax + 1
                                        if map.mission.cache.objdone == 2 then -- before marking progress on 3 completed pylons, do a 15 sec survival timer.
                                            alert:new(color:wrap(color.tooltip.good, "Teleport inbound! Survive for 15 seconds!"), 13.0)
                                            utils.timed(15.0, function()
                                                if map.manager.downp ~= map.manager.totalp then -- players are still alive
                                                    map.mission.cache:objstep()
                                                end
                                            end)
                                        else
                                            map.mission.cache:objstep()
                                        end
                                        DestroyEffect(self.chpylon[i].e)
                                        DestroyMinimapIcon(self.chpylon[i].icon)
                                        local x,y,t = 0,0,2
                                        if map.manager.diffid == 5 then t = t + 1 end -- add some more padding for tyrannical.
                                        for i2 = 1, t do
                                            x,y = utils.projectxy(self.chpylon[i].x, self.chpylon[i].y, math.random(50,80), math.random(0,360))
                                            candle:spawnwax(x, y)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
    map_cleanup_func = function()
        self:candleheistcleanup()
    end
    -- place shrines:
    for i = 1,3 do
        local a = utils.anglexy(self.chpylon[i].x, self.chpylon[i].y, 0, 0) + math.random(23,65)
        local sx,sy = utils.projectxy(self.chpylon[i].x, self.chpylon[i].y, math.random(1300,2000), a)
        shrine:placerandom(sx, sy)
    end
end


function map.grid:candleheistcleanup()
    for i = 1,3 do
        if self.chpylon[i].e then DestroyEffect(self.chpylon[i].e) end
        if self.chpylon[i].icon then DestroyMinimapIcon(self.chpylon[i].icon) end
        for b = 1,3 do
            if self.chpylon[i].lightn[b] then DestroyLightning(self.chpylon[i].lightn[b]) end
            if self.chpylon[i].unit[b] then RemoveUnit(self.chpylon[i].unit[b]) end
        end
        self.chpylon[i] = nil
    end
    self.chpylon = nil
end


function map.grid:placegoldrush()
    -- config creature wave size based on level:
    if map.mission.cache.level < 10 then
        self.grwavemin, self.grwavemax = 1, 3
    elseif map.mission.cache.level < 20 then
        self.grwavemin, self.grwavemax = 2, 4
    else
        self.grwavemin, self.grwavemax = 3, 4
    end
    self.grwavemax = self.grwavemax + ((map.manager.totalp-1)*2) -- if multiplayer, add to wave size
    -- place collection point at random angle from center:
    local x1,y1,a = self.start.x, self.start.y, math.random(0,360)
    map.grid:excavate(x1, y1, 1150, t_udgrd_tile)
    map.grid:clearunits(x1, y1, 2100.0)
    self.grunit = {}
    -- place hall:
    local x2,y2 = utils.projectxy(x1, y1, 384, math.random(0-360))
    map.grid:excavate(x2, y2, 1150, t_udgrd_tile)
    self.grunit[1] = utils.unitatxy(Player(11), x2, y2, map.mission.koboldhallid)
    utils.playerloop(function(p) UnitShareVisionBJ(true, self.grunit[1], p) end)
    self.gricon    = CreateMinimapIconBJ(x2, y2, 255, 255, 0, "UI\\Minimap\\Minimap-QuestObjectiveBonus.mdl", FOG_OF_WAR_MASKED)
    -- place mine:
    x2, y2 = utils.projectxy(x2, y2, 1024, a - 180.0)
    map.grid:excavate(x2, y2, 1150, t_udgrd_tile)
    self.grunit[2] = utils.unitatxy(Player(11), x2, y2, map.mission.goldmineid)
    utils.playerloop(function(p) UnitShareVisionBJ(true, self.grunit[2], p) end)
    -- create defensive towers:
    local ta, tx, ty = utils.angleunits(self.grunit[1], self.grunit[2]), utils.unitxy(self.grunit[1])
    local tx2, ty2 = utils.projectxy(tx, ty, 384, ta - 67)
    local tx3, ty3 = utils.projectxy(tx, ty, 384, ta + 67)
    self.grunit[3] = utils.unitatxy(Player(11), tx2, ty2, map.mission.koboldtowerid)
    self.grunit[4] = utils.unitatxy(Player(11), tx3, ty3, map.mission.koboldtowerid)
    for i = 3,4 do
        BlzSetUnitBaseDamage(self.grunit[i], 6 + math.floor(map.mission.cache.level^1.15*0.25*(1+map.manager.diffid*0.2)), 0)
        utils.setnewunithp(self.grunit[i], (map.mission.grtowerhp + (((map.mission.cache.level-1)^1.4)*1.60))*(1+map.manager.diffid*0.35), true)
    end
    -- create workers:
    for i = 5,9 do
        self.grunit[i] = map.grid:placegoldrushworker(x1, y1)
        utils.setnewunithp(self.grunit[i], (map.mission.grworkerhp + (((map.mission.cache.level-1)^1.4)*1.33))*(1+map.manager.diffid*0.25), true)
    end
    -- tyrannical modifiers:
    if map.manager.diffid == 5 then
        for i = 3,9 do
            utils.setnewunithp(self.grunit[i], math.floor(utils.maxlife(self.grunit[i])*2.0), true)
        end
    end
    -- worker death listener:
    if not self.grtrig then
        self.grtrig = trg:new('death', Player(11))
        self.grtrig:regaction(function()
            if utils.triguid() == FourCC(map.mission.koboldworkerid) and map.manager.activemap and not map.manager.objiscomplete then
                local x,y = utils.unitxy(self.grunit[1])
                utils.timed(18.0, function()
                    if map.manager.activemap and not scoreboard_is_active and map.mission.cache and map.mission.cache.id == m_type_gold_rush then
                        if not map.manager.objiscomplete and not map.manager.success then
                            speff_dustcloud:play(x, y) speff_pothp:play(x, y)
                            utils.setnewunithp(map.grid:placegoldrushworker(x, y), map.mission.grworkerhp + (((map.mission.cache.level-1)^1.5)*1.5), true)
                        end
                    end
                end)
            end
        end)
    end
    -- reset gold state and queue gold listener timer:
    SetPlayerStateBJ(Player(11), PLAYER_STATE_RESOURCE_GOLD, 0)
    if self.rushtmr then ReleaseTimer(self.rushtmr) end
    self.rushtick = 0
    self.rushwave = 1
    self.rushtmr  = TimerStart(NewTimer(), 1.0, true, function()
        utils.debugfunc(function()
            if not map.manager.success and not map.manager.objiscomplete and not scoreboard_is_active then
                self.rushtick = self.rushtick + 1
                self.rushgold = GetPlayerState(Player(11), PLAYER_STATE_RESOURCE_GOLD)
                if self.rushgold > 0 then
                    SetPlayerStateBJ(Player(11), PLAYER_STATE_RESOURCE_GOLD, 0) -- "consume" gold and add it to the objective step.
                    map.mission.cache:objstep(nil, true)
                    self.rushgold = 0
                end
                -- spawn features:
                if math.fmod(self.rushtick, 45) == 0 then
                    candle:spawnwax(utils.unitx(self.grunit[1]), utils.unity(self.grunit[1]))
                end
                if math.fmod(self.rushtick, 23) == 0 then
                    map.grid:spawnattackwave(self.grunit[1])
                end
                if math.fmod(self.rushtick, 48) == 0 then
                    self.rushwave = self.rushwave + 1
                end
            else
                ReleaseTimer()
            end
        end, "gold rush timer")
    end)
    map_cleanup_func = function()
        if map.grid.grunit then map.grid.grunit = nil end
        if map.grid.rushtmr then ReleaseTimer(map.grid.rushtmr) end
        if map.grid.gricon then DestroyMinimapIcon(map.grid.gricon) end
    end
    -- place shrines:
    local a = math.random(0,360)
    for i = 1,2 do
        local sx,sy = utils.unitprojectxy(self.grunit[1], math.random(1500,1900), a)
        shrine:placerandom(sx, sy)
        a = a + math.random(160,200)
    end
end


-- spawn a creature cluster near @unit and attack move to @unit.
function map.grid:spawnattackwave(unit, _wavecount, _cluster, _spawndist, _delay, _attackradius)
    local x2,y2,biomeid = 0,0,map.manager.biome.id
    local delay   = _delay or 4.0
    local radius  = _attackradius or 2400
    local dist    = _spawndist or math.random(900,1000)
    local cluster = _cluster or creature.cluster.biome[biomeid][math.random(1, #creature.cluster.biome[biomeid])]
    local x,y = utils.projectxy(utils.unitx(unit), utils.unity(unit), dist, math.random(0,360))
    map.biomeportal[biomeid]:play(x, y, 10.0, 1.5)
    local dmy = buffy:create_dummy(Player(PLAYER_NEUTRAL_PASSIVE), x, y, 'h008', 15.0)
    utils.timed(delay, function()
        utils.timedrepeat(2.0, _wavecount or self.rushwave, function()
            if not map.manager.success and not map.manager.objiscomplete and not scoreboard_is_active then
                x2,y2 = utils.projectxy(x, y, math.random(50,200), math.random(0,360))
                cluster:spawn(x2, y2, self.grwavemin, self.grwavemax, port_yellowtp)
                utils.setrectradius(map.grid.digrect, x2, y2, 512)
                utils.dmgdestinrect(map.grid.digrect, 3000)
                utils.issueatkmoveall(Player(24), radius, x2, y2, unit)
            else
                ReleaseTimer()
            end
        end)
    end)
end


function map.grid:placegoldrushworker(x, y)
    -- for use with gold rush: place worker and order to harvest.
    if self.grunit[2] then -- gold mine exists.
        local u = utils.unitatxy(Player(11), x, y, map.mission.koboldworkerid)
        IssueTargetOrderById(u, 852018, self.grunit[2]) -- command to gather gold.
        return u
    end
end


function map.grid:wrapbedrock(width)
    -- place bedrock around the outside arena.
    for xb = self.minx-width, self.maxx+width do
        for i = 1,width do
            b_bedrock:place(xb,self.miny - i)
            b_bedrock:place(xb,self.maxy + i)
        end
    end
    for yb = self.miny, self.maxy do
        for i = 1,width do
            b_bedrock:place(self.minx - i,yb)
            b_bedrock:place(self.maxx + i,yb)
        end
    end
end


function map.grid:randomterrain()
    self.rand = math.random(1,100)
    if self.rand > 50 then
        return map.manager.biome.terraint[1]
    elseif self.rand > 25 then
        return map.manager.biome.terraint[2]
    else
        return map.manager.biome.terraint[3]
    end
end


function map.grid:randomexcavate()
    map.grid:gridloop(function(xb, yb)
        self.rand = math.random(0, 100)
        if self.rand < 18 and self.coord[xb][yb].code ~= b_bedrock.code then
            self.rand = math.random(256, 768)
            self:excavate(self:getx(xb), self:gety(yb), self.rand)
        end
    end)
end


function map.grid:randomdeposits()
    map.grid:gridloop(function(xb, yb)
        self.rand = math.random(0, 100)
        -- TODO : IDEA : threshold for ore could be a map stat mod.
        if self.rand < math.floor(2*map.mission.cache.setting[m_stat_oredensity]) and self.coord[xb][yb].code ~= b_bedrock.code then
            self.rand = math.random(1,100)
            self:excavate(self:getx(xb), self:gety(yb), 256)
            if self.rand < 24 then
                map.manager.biome.oret[1]:place(xb, yb)
            elseif self.rand < 62 then
                map.manager.biome.oret[2]:place(xb, yb)
            elseif self.rand < 100 then
                map.manager.biome.oret[3]:place(xb, yb)
            end
        end
    end)
end


function map.grid:randomcreatures(biomeid, centerx, centery)
    local x,y,a = 0,0,0
    local l     = math.ceil(self.r*256/creature.cluster.dist.max/3.14)-- # of radials required to fill arena.
    local c     = math.ceil(l*3.14*2) -- clusters required to complete a radial.
    local rpos  = self.r/(l+1)/self.r -- position on radius to generate cluster when traversing circle.
    local rinc  = rpos
    for radial = 1,l do
        local cmax = c*radial
        local ainc = math.floor(360/cmax)
        for _ = 1,cmax do
            a   = a + math.random(math.floor(ainc*0.9), ainc) -- give some variation with randomness.
            x,y = utils.projectxy(centerx, centery, math.random(256*self.r*rpos, 256*self.r*rpos*1.1), a)
            creature.cluster.biome[biomeid][math.random(1, #creature.cluster.biome[biomeid])]:spawn(x, y)
        end
        rpos = rpos + rinc
    end
end


function map.grid:gridloop(func, _xdir, _ydir)
    self.gridbreak = false
    -- initialize default loop directions:
    local xdir, ydir = _xdir or 1, _ydir or 1
    local minx, maxx, miny, maxy = self.minx, self.maxx, self.miny, self.maxy
    -- reverse the loop if params are passed:
    if xdir == -1 then minx, maxx = self.maxx, self.minx end
    if ydir == -1 then miny, maxy = self.maxy, self.miny end
    -- run loop code:
    for xb = minx, maxx, xdir do
        for yb = miny, maxy, ydir do
            func(xb, yb)
            if self.gridbreak then break end
        end
    end
end


function map.grid:randomblock()
    self.rand = math.random(1,100)
    if self.rand > 20 then
        return map.manager.biome.blockt[1]
    else
        return map.manager.biome.blockt[2]
    end
end


function map.grid:debugfill()
    for xb = self.minx,self.maxx do
        for yb = self.miny,self.maxy do
            if not self.coord[xb][yb].edge and not self.coord[xb][yb].code then
                AddSpecialEffect('Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl', self:getx(xb), self:gety(yb))
            end
        end
    end
end


--@x,y = convert this grid.coord location to in-game units.
function map.grid:getxy(xb,yb)
    return map.grid:getx(xb), map.grid:gety(yb)
end


function map.grid:getx(xb)
    return self.center.x + xb*self.blockw
end


function map.grid:gety(yb)
    return self.center.y - yb*self.blockw
end


function map.block:init()
    self.__index  = self
    self.blockt   = {}
    self.vars     = 1        -- the number of possible variants.
    self.code     = nil      -- FourCC() id.
    self.hp       = 50       -- mining damage required (auto attack).
    self.lvlmulthp= 0.03     -- hp multiplier based on map level.
    self.scale    = 1.5
    self.invul    = false
    self.size     = map.grid.blockw
    self.effect   = speffect:new('Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl', 1.66)
    -- type constants:
    btype_dest    = 0
    btype_unit    = 1
    self.btype    = btype_dest -- default.
    -- generate block types:
    b_bedrock     = map.block:new('B000', 6,  true, btype_dest, 1.80)
    b_stone       = map.block:new('B001', 6)
    b_volc        = map.block:new('B007', 1,  false, btype_dest, 0.6)
    b_slag        = map.block:new('B008', 6)
    b_ice         = map.block:new('B002', 6,  false, btype_dest, 0.85)
    b_shroom      = map.block:new('B004', 8,  false, btype_dest, 1.0)
    b_petrified   = map.block:new('B009', 10, false, btype_dest, 0.94)
    -- objective blocks:
    b_trove       = map.block:new('n005', 1, false, btype_unit)
    -- mineral blocks:
    b_ore_arcane  = map.block:new('h007', 1, false, btype_unit)
    b_ore_frost   = map.block:new('h004', 1, false, btype_unit)
    b_ore_nature  = map.block:new('h006', 1, false, btype_unit)
    b_ore_fire    = map.block:new('h003', 1, false, btype_unit)
    b_ore_shadow  = map.block:new('h002', 1, false, btype_unit)
    b_ore_phys    = map.block:new('h005', 1, false, btype_unit)
    b_ore_gold    = map.block:new('h001', 1, false, btype_unit)
    b_ore_arcane.hp = 64
    b_ore_fire.hp   = 64
    b_ore_frost.hp  = 64
    b_ore_nature.hp = 64
    b_ore_shadow.hp = 64
    b_ore_phys.hp   = 64
    b_ore_gold.hp   = 64
    self.oreitemid = {
        [1] = FourCC('I003'),
        [2] = FourCC('I004'),
        [3] = FourCC('I005'),
        [4] = FourCC('I006'),
        [5] = FourCC('I007'),
        [6] = FourCC('I008'),
        [7] = FourCC('I009'),
    }
    self.itemoreid = {
        [FourCC('I003')] = 1,
        [FourCC('I004')] = 2,
        [FourCC('I005')] = 3,
        [FourCC('I006')] = 4,
        [FourCC('I007')] = 5,
        [FourCC('I008')] = 6,
        [FourCC('I009')] = 7,
    }
    -- create player ore lookup table:
    self.oretypet   = {} -- look up ore by dmgtypeid/elementid.
    self.orepstat   = {} -- look up ore by ore block's unit raw code.
    self.orepstat[b_ore_arcane.code]    = ore_arcane
    self.orepstat[b_ore_frost.code]     = ore_frost
    self.orepstat[b_ore_nature.code]    = ore_nature
    self.orepstat[b_ore_fire.code]      = ore_fire
    self.orepstat[b_ore_shadow.code]    = ore_shadow
    self.orepstat[b_ore_phys.code]      = ore_phys
    self.orepstat[b_ore_gold.code]      = ore_gold
    self.oretypet[dmg_arcane]           = ore_arcane
    self.oretypet[dmg_frost]            = ore_frost
    self.oretypet[dmg_nature]           = ore_nature
    self.oretypet[dmg_fire]             = ore_fire
    self.oretypet[dmg_shadow]           = ore_shadow
    self.oretypet[dmg_phys]             = ore_phys
    -- ore gather trigger:
    self.oretrig  = trg:new("death", utils.passivep()) -- listens for destroyed ore blocks.
    self.oretrig:regaction(function()
        if utils.pnum(utils.powner(utils.killu())) <= kk.maxplayers and self.orepstat[utils.triguid()] then
            local x,y   = utils.unitxy(utils.trigu())
            local oreid = self.orepstat[utils.triguid()]
            local count = 3
            if map.mission.cache then
                count = math.ceil((1*map.mission.cache.setting[m_stat_treasure] + map.manager.diffid)/2)
            end
            if oreid ~= ore_gold then
                mis_bolt_stack[oreid]:play(x, y)
            else
                speff_goldburst:play(x, y)
            end
            map.block:spawnore(count, oreid, x, y)
            candle:spawnwax(x, y, "tiny")
        end
    end)
end


function map.block:collectore()
    -- NOTE: this event is fired within the candle wax collection trigger, to reduce trigger clutter.
    local id = GetItemTypeId(GetManipulatedItem())
    if self.itemoreid[id] then
        local oreid = self.itemoreid[id]
        if oreid ~= 7 then -- picked up ore.
            utils.playerloop(function(p) kobold.player[p]:awardoretype(oreid, 1, false) end)
            ArcingTextTag(color:wrap(color.tooltip.good, '+1 ')..tooltip.orename[oreid], utils.trigu(), 1.75)
        else -- picked up gold.
            utils.playerloop(function(p) kobold.player[p]:awardgold(5*map.manager.diffid) end)
            ArcingTextTag(color:wrap(color.tooltip.good, '+10 ')..tooltip.orename[oreid], utils.trigu(), 1.75)
        end
        kobold.player[utils.unitp()].score[6] = kobold.player[utils.unitp()].score[6] + 1
    end
end


-- spawn ore chunks to collect around a point.
function map.block:spawnore(count, oreid, x, y)
    local size,tangle,incangle,x2,y2 = nil,math.random(0,360),360/count,0,0
    local itm = {}
    local dmy = buffy:create_dummy(Player(PLAYER_NEUTRAL_PASSIVE), x, y, 'h008', 3.0)
    for i = 1,count do
        local mis
        x2,y2 = utils.projectxy(x, y, math.random(16,96), tangle + math.randomneg(-10,10))
        if oreid == 7 then
            mis = missile:create_arc(x2, y2, dmy, 'war3mapImported\\mdl-GoldIngot.mdl', 0)
        else
            mis = missile:create_arc(x2, y2, dmy, 'war3mapImported\\mdl-BagItem.mdx', 0)
        end
        mis.time = 0.90
        mis.height = 20.0
        mis:initduration()
        mis.explfunc = function()
            if map.manager.activemap then
                itm[#itm+1] = CreateItem(self.oreitemid[oreid], mis.x, mis.y)
            end
        end
        tangle = tangle + incangle
    end
    -- clean up items left behind after a delay:
    utils.timed(30.0, function()
        if itm then
            for _,i in ipairs(itm) do
                if i then RemoveItem(i) end
            end
        end
        itm = nil
    end)
end


function map.block:new(rawcode, _variants, _isinvul, _btype, _scale)
    local o = {}
    setmetatable(o, self)
    o.code  = FourCC(rawcode)
    o.btype = _btype    or self.btype
    o.invul = _isinvul  or self.invul
    o.vars  = _variants or self.vars
    o.scale = _scale    or self.scale
    self.blockt[o.code] = o
    return o
end


function map.block:get(rawcode)
    return self.blockt[rawcode]
end


-- @xb,yb = coord on the grid to place.
function map.block:place(xb, yb)
    if self.btype == btype_dest then
        local dest = CreateDestructable(
            self.code,
            map.grid:getx(xb),
            map.grid:gety(yb),
            math.floor(math.random(0,360)),
            math.random(self.scale*100, self.scale*110)/100,
            math.random(1,self.vars) )
        if self.invul then
            SetDestructableInvulnerable(dest, true)
        else
            utils.setnewdesthp(dest, self.hp*map.mission.cache.setting[m_stat_blockhp]*(1 + map.mission.cache.level*self.lvlmulthp/2) )
        end
        if map.grid.coord[xb] and map.grid.coord[xb][yb] then map.grid.coord[xb][yb].code = self.code end
        return dest
    else
        local unit = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), self.code, map.grid:getx(xb), map.grid:gety(yb), 270.0)
        utils.setnewunithp(unit, self.hp*map.mission.cache.setting[m_stat_blockhp]*(1 + map.mission.cache.level*self.lvlmulthp), true)
        return unit
    end
end


-- @x,y = in-game coordinate (*note: does not get recorded in grid)
function map.block:placexy(x, y)
    if self.btype == btype_dest then
        local dest = CreateDestructable(
            self.code,
            x,
            y,
            math.floor(math.random(0,360)),
            math.random(self.scale*100, self.scale*133)/100,
            math.random(1,self.vars) )
        if self.invul then
            SetDestructableInvulnerable(dest, true)
        else
            utils.setnewdesthp(dest, self.hp*map.mission.cache.setting[m_stat_blockhp]*(1 + map.mission.cache.level*self.lvlmulthp) )
        end
    else
        local unit = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), self.code, x, y, 270.0)
        utils.setnewunithp(unit, self.hp*map.mission.cache.setting[m_stat_blockhp]*(1 + map.mission.cache.level*self.lvlmulthp), true)
        return unit
    end
end


function map.manager:init()
    -- TODO: how do we handle dig sites with multiple players? hide? show? vote?
    -- Idea: the host can initiate a dig, while other players can select a map to
    --  place a visual "vote" marker on a map for the host.
    self.owner      = Player(0) -- the host.
    self.totalp     = 0         -- total players present.
    self.downp      = 0         -- total players downed.
    self.success    = false     -- flag for mission completed or failed.
    self.debug      = false     -- overrides loading splash
    self.activemap  = false     -- are players currently in a map?
    self.selectedid = nil       -- the currently selected map type id.
    self.diffid     = 2         -- 1 = Greenwhisker, 2 = Standard, 3 = Heroic, 4 = Vicious, 5 = Tyrannical
    self.prevdiffid = nil       -- the difficulty last completed (for post-mission logic). ``
    self.difftimer  = false     -- only allow difficulty changes every few sec (prevent msg spam).
    self.loadstate  = 0         -- 0 of 100 loading screen progress.
    self.candletmr  = NewTimer()-- wax countdown
    self.__index    = self
end


function map.manager:rundefeatcheck()
    -- check if all players are down.
    if map.mission.cache then
        if self.downp >= self.totalp then
            map.mission.cache:objfailed()
            if map.mission.cache.boss then
                utils.setinvul(map.mission.cache.boss.unit, true)
            end
        end
    end
end


function map.manager:initframes()
    -- ran in kui so we have proper context.
    self.loadsplash  = kui.frame:newbytype("FRAME", kui.worldui) -- for disabling player clicks, etc.
    self.loadgraphic = kui.frame:newbysimple("SimpleLoadingSplash", kui.worldui)
    self.loadbar     = kui.frame:newbysimple("DigSiteLoadBar", kui.worldui)
    self.loadbar:setabsfp(fp.c, kui.position.centerx, 0.1)
    self.loadbar:setlvl(5)
    self.candlebar   = kui.frame:newbysimple("CandleLightBar", kui.worldui)
    self.candlebar:setabsfp(fp.c, kui.position.centerx, 0.60 - kui:px(66))
    self.candletxt   = BlzGetFrameByName("CandleLightBarText",0)
    self.candlewave  = {}
    for waveid = 1,3 do self.candlewave[waveid] = kui.frame:convert("CandleLightBarWave"..waveid, 0) end
    local sfh = BlzGetFrameByName("SimpleLoadingSplash",0)
    -- run locally since client w/h are checked:
    utils.looplocalp(function() kui:setfullscreen(self.loadgraphic.fh) end)
    utils.looplocalp(function() kui:setfullscreen(sfh) end)
    -- wrap up:
    self.loadsplash.hidefunc = function() self.loadgraphic:hide() self.loadbar:hide() map.manager:resetloadbar() end
    self.loadsplash.showfunc = function() self.loadgraphic:show() self.loadbar:show() map.manager:resetloadbar() end
    self.loadsplash:hide()
    self.candlebar:hide()
    -- build score screen:
    self.scoreboard        = kui.frame:newbytype("PARENT", kui.gameui)
    self.scoreboard.card   = {}
    self.scoreboard.tmrtxt = self.scoreboard:createheadertext("30")
    self.scoreboard.tmrtxt:setabsfp(fp.c, kui.position.centerx, 0.60 - kui:px(66))
    -- fail/success header:
    self.scoreboard.objstate = self.scoreboard:createheadertext("Mission Success")
    self.scoreboard.objstate:setabsfp(fp.c, kui.position.centerx, 0.60 - kui:px(196))
    -- continue btn:
    self.scoreboard.skipbtn = kui.frame:creategluebtn("Continue", self.scoreboard)
    self.scoreboard.skipbtn:setfp(fp.c, fp.c, self.scoreboard.tmrtxt, 0, -kui:px(60))
    local skipclick = function() map.manager:scoreboardskip() end
    self.scoreboard.skipbtn:addevents(nil, nil, skipclick, nil, false)
    local labels = {
        [1] = "Damage Done:",
        [2] = "Damage Absorbed:",
        [3] = "Damage Taken:",
        [4] = "Healing Done:",
        [5] = "Abilities Used:",
        [6] = "Ore Gathered:",
        [7] = "Loot Found:"
    }
    for pnum = 1,kk.maxplayers do -- generate score card templates.
        self.scoreboard.card[pnum] = kui.frame:newbytype("BACKDROP", self.scoreboard)
        self.scoreboard.card[pnum]:addbgtex("war3mapImported\\scoreboard-card.blp")
        self.scoreboard.card[pnum]:setsize(kui:px(316), kui:px(445))
        if is_single_player then -- center score card.
            self.scoreboard.card[pnum]:setfp(fp.c, fp.c, kui.gameui, 0, -kui:px(280))
        else
            self.scoreboard.card[pnum]:setfp(fp.c, fp.c, kui.gameui, -kui:px(474 - ((pnum-1)*316)), -kui:px(280))
        end
        --self.scoreboard.card[pnum]:setabsfp(fp.c, 0.4, 0.24)
        -- score bd containers:
        self.scoreboard.card[pnum].score = {}
        for i = 1,6 do
            -- score backdrops:
            self.scoreboard.card[pnum].score[i] = kui.frame:newbytype("BACKDROP", self.scoreboard.card[pnum])
            self.scoreboard.card[pnum].score[i]:addbgtex(kui.color.black)
            self.scoreboard.card[pnum].score[i]:setnewalpha(170)
            self.scoreboard.card[pnum].score[i]:setsize(kui:px(245), kui:px(27))
            if i > 1 then
                self.scoreboard.card[pnum].score[i]:setfp(fp.c, fp.c, self.scoreboard.card[pnum].score[i-1], 0, -kui:px(30))
            else
                self.scoreboard.card[pnum].score[i]:setfp(fp.c, fp.c, self.scoreboard.card[pnum], 0, kui:px(149))
            end
            -- add score text:
            self.scoreboard.card[pnum].score[i].label = self.scoreboard.card[pnum]:createtext(labels[i])
            self.scoreboard.card[pnum].score[i].label:setfp(fp.l, fp.l, self.scoreboard.card[pnum].score[i], kui:px(8), 0)
            self.scoreboard.card[pnum].score[i].val   = self.scoreboard.card[pnum].score[i]:createtext("0")
            self.scoreboard.card[pnum].score[i].val:setfp(fp.r, fp.r, self.scoreboard.card[pnum].score[i], -kui:px(8), 0)
            BlzFrameSetTextAlignment(self.scoreboard.card[pnum].score[i].val.fh, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_RIGHT)
        end
        -- loot bd container:
        self.scoreboard.card[pnum].loot = kui.frame:newbytype("BACKDROP", self.scoreboard.card[pnum])
        self.scoreboard.card[pnum].loot:addbgtex(kui.color.black)
        self.scoreboard.card[pnum].loot:setnewalpha(170)
        self.scoreboard.card[pnum].loot:setsize(kui:px(245), kui:px(106))
        self.scoreboard.card[pnum].loot:setfp(fp.t, fp.c, self.scoreboard.card[pnum].score[6], 0, -kui:px(17))
        -- loot icons:
        for i = 1,3 do
            self.scoreboard.card[pnum].loot[i] = kui.frame:newbytype("BACKDROP", self.scoreboard.card[pnum].loot)
            self.scoreboard.card[pnum].loot[i]:addbgtex("ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp")
            self.scoreboard.card[pnum].loot[i]:setsize(kui:px(65), kui:px(65))
            if i > 1 then
                self.scoreboard.card[pnum].loot[i]:setfp(fp.c, fp.c, self.scoreboard.card[pnum].loot[i-1], kui:px(80), 0)
            else
                self.scoreboard.card[pnum].loot[i]:setfp(fp.c, fp.c, self.scoreboard.card[pnum], -kui:px(80), -kui:px(80))
            end
            self.scoreboard.card[pnum].loot[i].rarity = kui.frame:newbytype("BACKDROP", self.scoreboard.card[pnum].loot[i])
            self.scoreboard.card[pnum].loot[i].rarity:addbgtex("war3mapImported\\rarity-gem-icons_01.blp")
            self.scoreboard.card[pnum].loot[i].rarity:setfp(fp.c, fp.b, self.scoreboard.card[pnum].loot[i], 0.0, 0.0011)
            self.scoreboard.card[pnum].loot[i].rarity:setsize(0.0125, 0.0125)
        end
        -- loot txt:
        self.scoreboard.card[pnum].lootlab = self.scoreboard.card[pnum]:createtext(labels[7])
        self.scoreboard.card[pnum].lootlab:setfp(fp.l, fp.tl, self.scoreboard.card[pnum].loot, kui:px(8), -kui:px(14))
        -- XP and gold text:
        self.scoreboard.card[pnum].goldtxt = self.scoreboard.card[pnum]:createbtntext("Gold Payment: 0")
        self.scoreboard.card[pnum].goldtxt:setfp(fp.c, fp.c, self.scoreboard.card[pnum], 0, -kui:px(151))
        self.scoreboard.card[pnum].xptxt   = self.scoreboard.card[pnum]:createbtntext("XP Earned: 0")
        self.scoreboard.card[pnum].xptxt:setfp(fp.c, fp.c, self.scoreboard.card[pnum], 0, -kui:px(184))
        -- class icon:
        self.scoreboard.card[pnum].class = kui.frame:newbytype("BACKDROP", self.scoreboard.card[pnum])
        self.scoreboard.card[pnum].class:addbgtex("ReplaceableTextures\\CommandButtons\\BTNSelectHeroOn.blp")
        self.scoreboard.card[pnum].class:setsize(kui:px(34), kui:px(34))
        self.scoreboard.card[pnum].class:setfp(fp.c, fp.c, self.scoreboard.card[pnum], 0, kui:px(223+23))
        -- player name:
        self.scoreboard.card[pnum].pname = self.scoreboard.card[pnum]:createbtntext("PlayerName")
        self.scoreboard.card[pnum].pname:setfp(fp.c, fp.c, self.scoreboard.card[pnum], 0, kui:px(205))
    end
    labels = nil
    self.scoreboard:hide()
end


function map.manager:scoreboardstart()
    DestroyTrigger(map.grid.boundstrig)
    scoreboard_is_active = true
    map.grid.boundstrig  = nil
    DisableTrigger(kk.boundstrig)
    utils.disableuicontrol(true)
    utils.setcambounds(gg_rct_scorebounds)
    if self.success then
        badge:earn(kobold.player[Player(0)], 1)
        map.manager.scoreboard.objstate:settext(color:wrap(color.tooltip.good,"Dig Site Complete"))
        if map.mission.cache.id ~= m_type_boss_fight then
            -- prevent back to back victory sounds.
            utils.playsoundall(kui.sound.completebig)
        end
    else
        map.manager.scoreboard.objstate:settext(color:wrap(color.tooltip.bad,"Dig Site Failed"))
        utils.playsoundall(kui.sound.failure)
    end
    self.candlebar:hide()
    self.scoreboard.skipbtn:hide() -- show after delay finishes.
    self.scoreboard.tmrtxt:hide()  -- ``
    self.sbskip   = false
    self.sbactive = true
    sb_tmr        = {}
    sb_dur        = 60 -- screen countdown timer.
    local x,y     = map.mission.score.x,map.mission.score.y
    local tpnum   = 1  -- move kobolds timer pnum.
    -- run the scoreboard screen:
    map.manager.scoreboard.tmrtxt:settext(tostring(sb_dur))
    utils.playerloop(function(p) kui:hidegameui(p) end)
    for pnum = 1,kk.maxplayers do
        local p = Player(pnum-1)
        sb_tmr[p] = NewTimer()
        map.manager.scoreboard.card[pnum]:hide() -- initialize hidden cards
        if kobold.player[p] then
            utils.debugfunc( function()
                utils.face(kobold.player[p].unit, 270.0)
                PauseUnit(kobold.player[p].unit, true)
                PauseTimer(kobold.player[p].permtimer)
                TimerStart(sb_tmr[p], 0.03, true, function() CameraSetupApplyForPlayer(true, gg_cam_scorecam, p, 0.23) end)
            end, "1")
        end
    end
    local dur = 2.5 -- timer duration
    if self.devmode then dur = 0.03 end
    utils.timed(dur, function()
        -- move kobolds into frame:
        local dur = 1.0 -- timer duration
        if self.devmode then dur = 0.03 end
        utils.timedrepeat(dur, kk.maxplayers, function()
            utils.debugfunc( function()
                local p     = Player(tpnum-1)
                local dur   = 0.66 -- timer duration
                if self.devmode then dur = 0.03 end
                if kobold.player[p] then
                    self:scoreupdate(kobold.player[p])
                    map.manager.scoreboard:show()
                    map.manager.scoreboard.card[tpnum]:show()
                    if is_single_player then
                        utils.setxy(kobold.player[p].unit, 10750, -18450)
                        -- utils.issmovexy(kobold.player[p].unit, 10750, -18600)
                    else
                        utils.setxy(kobold.player[p].unit, x + (tpnum-1)*map.mission.score.d, y)
                        -- utils.issmovexy(kobold.player[p].unit, x + (tpnum-1)*map.mission.score.d, y - map.mission.score.walkd)
                    end
                    utils.playsoundall(kui.sound.scorebcard)
                    kui.effects.char[kobold.player[p].charid]:playu(kobold.player[p].unit)
                    if self.runlvleff == true then -- show level up eye candy
                        self.runlvleff = false
                        TimerStart(NewTimer(), dur, false, function()
                            kobold.player[p].lvleff:playu(kobold.player[p].unit)
                            self.scoreboard.card[tpnum].pname:settext(kobold.player[p].name.." ("
                                ..color:wrap(color.tooltip.alert, kobold.player[p].level)..")")
                        end)
                    end
                end
                tpnum = tpnum + 1
            end, "2")
        end)
        if self.devmode then dur = 0.15 end
        -- show skip option after cards show:
        utils.timed(dur, function()
            self.scoreboard.skipbtn:show()
            self.scoreboard.tmrtxt:show()
            utils.disableuicontrol(false)
            -- start global timer:
            utils.timedrepeat(1.0, sb_dur + 1, function()
                sb_dur = sb_dur - 1
                map.manager.scoreboard.tmrtxt:settext(tostring(sb_dur))
                if sb_dur == 0 or not self.sbactive then
                    map.manager:scoreboardend()
                    sb_dur = nil
                    ReleaseTimer()
                end
            end)
        end)
    end)
    map.grid:purge()
end


function map.manager:scoreboardskip()
    -- a player clicks "continue" button.
    if not self.sbskip then -- prevent dup click events.
        self.sbskip = true
        if sb_dur > 5 and not self.devmode then
            sb_dur = 3
            self.scoreboard.tmrtxt:settext(tostring(sb_dur))
            self.scoreboard.skipbtn:hide()
        else
            self:scoreboardend()
        end
    end
end


function map.manager:scoreboardend()
    utils.debugfunc(function()
        map.manager.selectedid = nil
        scoreboard_is_active = false
        self.scoreboard:hide()
        self.sbactive = false
        map.manager:exit()
        utils.playerloop(function(p)
            ReleaseTimer(sb_tmr[p])
            PauseUnit(kobold.player[p].unit, false)
            -- resume sticky camera:
            CameraSetupApplyForPlayer(false, gg_cam_gameCameraTemplate, p, 0)
            TimerStart(kobold.player[p].permtimer, 0.03, true, GetTimerData(kobold.player[p].permtimer))
            kui:showgameui(p)
            self:scorepurge(kobold.player[p])
            if kobold.player[p].downed then kobold.player[p]:down(false) end
            utils.restorestate(kobold.player[p].unit)
            SetUnitInvulnerable(kobold.player[p].unit, false)
        end)

        -- store previous mission details if needed after:
        map.manager.prevdiffid = map.manager.diffid
        map.manager.prevbiomeid = map.manager.biome.id

        -- **************
        -- BOSS UPDATES/LOOT:
        -- **************

        -- general boss defeat:
        if map.mission.cache and map.mission.cache.id == m_type_boss_fight and map.manager.success then
            boss:awardbosschest(map.manager.diffid)
            -- consume dig key after use:
            kui.canvas.game.dig.pane:hide()
            utils.playerloop(function(p)
                if kobold.player[p].items[slot_digkey] then
                    kobold.player[p].items[slot_digkey] = nil
                    if utils.islocalp(p) then
                        kui.canvas.game.dig.space[slot_digkey].icon:setbgtex(kui.tex.invis)
                        kui.canvas.game.dig.digkeyglow:hide()
                        kui.canvas.game.dig.boss:hide()
                    end
                end
            end)
        end
        -- **************
        -- QUEST UPDATES:
        -- **************

        if map.manager.success and quest.current and quest.current.triggered then
            if map.mission.cache.id == quest.current.qst_m_type and quest.current.qst_m_type ~= m_type_boss_fight and map.manager.biome.id == quest.current.biomeid then
                -- complete a normal dig:
                quest.current:markprogress(true)
            elseif quest.current.qst_m_type == m_type_boss_fight and map.manager.biome.id == quest.current.biomeid then
                -- complete boss fight quest:
                if quest.current.bossid and map.mission.cache.boss and quest.current.bossid == map.mission.cache.bossid then
                    quest.current:markprogress(true)
                end
            end
        end
        -- reset quest markers so they don't bug out:
        if quest.current then quest.current:refreshmapmarker() end

        -- **************
        -- **************
        -- **************

        if map.mission.cache then
            map.mission.cache:cleanup()
            map.mission.cache = nil
        end
        shrine:cleanup()

    end, "3")
end


function map.manager:scoreupdate(pobj)
    local pnum = utils.pnum(pobj.p)
    -- update visuals/stats for a player:
    self.scoreboard.card[pnum].class:setbgtex(kui.meta.classicon[pobj.charid])
    self.scoreboard.card[pnum].pname:settext(pobj.name.." ("..color:wrap(color.tooltip.alert, pobj.level)..")")
    if self.success then -- only run on mission success.
        self:calcearnings(pobj)
    else
        pobj.score.g  = 0
        pobj.score.xp = 0
    end
    self.scoreboard.card[pnum].goldtxt:settext( "Gold: "..color:wrap(color.ui.gold, pobj.score.g) )
    if pobj.score.xp == "MAX LEVEL" then -- display alternative text.
        self.scoreboard.card[pnum].xptxt:settext(color:wrap(color.ui.xp, pobj.score.xp))
    else
        self.scoreboard.card[pnum].xptxt:settext( "XP: "..color:wrap(color.ui.xp, pobj.score.xp) )
    end
    for statid = 1,6 do
        self.scoreboard.card[pnum].score[statid].val:settext(math.floor(math.abs(pobj.score[statid])))
    end
end


function map.manager:scorepurge(pobj)
    -- reset a player's score card details.
    for i = 1,6 do pobj.score[i] = 0 end
end


function map.manager:calcearnings(pobj)
    -- determine dig site XP and gold earned from mission.
    local prevlvl, baseg, bonusg, minedg, basexp, bonusxp = pobj.level, 0, 0, 0, 0, 0
    -- award xp:
    if pobj.level < 60 then
        if freeplay_mode then
            basexp  = math.floor( 400 + 25*pobj.level )
        else
            basexp  = math.floor( 125 + 8*pobj.level )
        end
        bonusxp = math.floor( basexp*(map.mission.cache.setting[m_stat_xp] + pobj[p_stat_digxp]/100) - basexp )
        if bonusxp > 0 then
            pobj.score.xp = basexp..color:wrap(color.tooltip.good," (+"..tostring(bonusxp)..")")
        elseif bonusxp == 0 then
            pobj.score.xp = basexp + bonusxp
        else
            bonusxp = 0
        end
        -- for boss fights, double the XP earned:
        if map.mission.cache.id == m_type_boss_fight then
            basexp = basexp*2
        end
        pobj:awardxp(basexp + bonusxp)
    else
        pobj.score.xp = "MAX LEVEL"
    end
    -- award gold:
    baseg  = math.floor( 100 + 8*pobj.level )
    bonusg = math.floor( baseg*(map.mission.cache.setting[m_stat_treasure] + pobj[p_stat_treasure]/100) - baseg )
    -- convert gold mined to currency:
    if pobj.ore[ore_gold] > 0 then
        minedg             = math.floor( 5*pobj.ore[ore_gold]*(1+map.mission.cache.level*map.mission.goldmult) - baseg )
        if minedg < 0 then minedg = 0 end
        pobj.ore[ore_gold] = 0
    end
    if bonusg > 0 then
        pobj.score.g = baseg..color:wrap(color.tooltip.good," (+"..tostring(bonusg + minedg)..")")
    elseif bonusg == 0 then
        pobj.score.g = baseg + bonusg + minedg
    else
        bonusg = 0
    end
    pobj:awardgold(baseg + bonusg + minedg)
    -- queue level eye candy if level earned:
    if prevlvl < pobj.level then self.runlvleff = true end -- queue level up eye candy flag.
end


function map.manager:resetloadbar()
    self.loadstate = 0
    BlzFrameSetValue( self.loadbar.fh, 0 )
end


-- @val = increment toward 100
function map.manager:addprogress(val)
    if self.loading then
        self.loadstate = self.loadstate + val
        if self.loadstate > 100 then self.loadstate = 100 end
        BlzFrameSetValue( self.loadbar.fh, math.ceil(self.loadstate) )
    end
end


-- @id = level id (1-x)
function map.manager:select(id)
    self.selectedid = id
end


function map.manager:run()
    DisableTrigger(kk.boundstrig)
    self.biome          = map.biome.biomet[map.manager.selectedid]
    self.activemap      = true
    self.success        = false
    self.objiscomplete  = false
    if not map.manager.debug then
        map.manager:loadstart()
    else -- if debug, skip loading sequence
        map.manager:loadend()
    end
    -- see if dig key should generate a boss:
    if kobold.player[utils.trigp()].items[slot_digkey] and 
        kobold.player[utils.trigp()].items[slot_digkey].biomeid and kobold.player[utils.trigp()].items[slot_digkey].biomeid == map.manager.selectedid then

        -- **************
        -- ****BOSSES****
        -- **************

        local bossid = kobold.player[utils.trigp()].items[slot_digkey].bossid
        map.mission:build(m_type_boss_fight)
        map_manager_load_boss = function()
            -- init mission and boss unit:
            map.mission.cache.boss   = boss:new(utils.unitatxy(Player(24), 0, 1000, bossid, 270.0), bossid)
            map.mission.cache.bossid = bossid
            map.mission.cache.boss:run_intro_scene()
        end
        alert:new(color:wrap(color.tooltip.alert, "Dig key activated!"), 2.5)

        -- **************
        -- **************
        -- **************

    -- see if a quest will override the mission for this biome:
    elseif quest.current and quest.current.triggered and map.manager.selectedid == quest.current.biomeid and quest.current.qst_m_type and quest.current.qst_m_type ~= 0
    and quest.current.qst_m_type ~= m_type_boss_fight then
        map.mission:build(quest.current.qst_m_type)
    else
        map.mission:build()
    end
    utils.debugfunc(function()
        -- build arena size based on chosen mission:
        if map.mission.cache.id == m_type_monster_hunt then
            map.grid:build(45, 45, true)
        elseif map.mission.cache.id == m_type_gold_rush then
            map.grid:build(24, 24, true)
        elseif map.mission.cache.id == m_type_candle_heist then
            map.grid:build(34, 34, true)
        elseif map.mission.cache.id == m_type_boss_fight then
            map.grid:build(22, 22, true)
        end
    end, "map.grid:build")
end


function map.manager:loadstart()
    -- show loading splash, disable players.
    self.loading = true
    self.totalp  = 0
    self.prevdiffid = nil
    self.prevbiomeid = nil
    candle:init()
    utils.fadeblack(true)
    BlzChangeMinimapTerrainTex('war3mapImported\\minimap-dig.blp')
    for pnum = 1,kk.maxplayers do
        local p = Player(pnum-1)
        if kobold.player[p] then
            kobold.player[p]:resetscore()
            if kobold.player[p].downed then kobold.player[p]:down(false) end
            self.totalp = self.totalp + 1
            PauseUnit(kobold.player[p].unit, true)
            utils.playsound(kui.sound.digstart)
            if p == utils.localp() then
                kui:closeall()
                kui:hidegameui(p)
                self.loadsplash:show()
                kui.canvas.game.bosschest:hide()
                kui.canvas.game.equip.save:hide()
                kui.canvas.game.modal:hide()
            end
        end
    end
    self.downp   = 0 -- keep after down check.
end


function map.manager:loadend()
    -- remove loading splash, initialized player entry.
    self.loading  = false
    utils.fadeblack(false, 1.33)
    utils.moveallpxy(map.grid.start.x, map.grid.start.y)
    candle:load()
    for pnum = 1,kk.maxplayers do
        local p = Player(pnum-1)
        if kobold.player[p] then
            PauseUnit(kobold.player[p].unit, false)
            utils.setinvul(kobold.player[p].unit, false)
            utils.pantounit(p, kobold.player[p].unit, 0.0)
            utils.playsound(kui.sound.loadend, p)
            utils.restorestate(kobold.player[p].unit)
            -- ui elements:
            if p == utils.localp() then
                self.loadsplash:hide()
                BlzFrameSetValue(self.candlebar.fh, 100) -- prevent initial show jankiness.
                if map.mission.cache.id ~= m_type_boss_fight then
                    self.candlebar:show()
                    self.candlebar:setfp(fp.c, fp.t, kui.worldui, 0, -kui:px(76))
                else -- move candle bar down if boss bar is present:
                    self.candlebar:setfp(fp.c, fp.t, kui.worldui, 0, -kui:px(142))
                end
                if not map_manager_load_boss then kui:showgameui(p) end
                utils.looplocalp(ClearTextMessages)
            end
            -- if boss should initialize:
            if map_manager_load_boss then map_manager_load_boss() map_manager_load_boss = nil end
        end
    end
    -- play any music:
    if map.mission.cache.id == m_type_boss_fight then
        utils.playsoundall(kui.sound.bossmusic)
    end
    -- show objective intro text:
    alert:new(map.mission.missionintros[map.mission.cache.id], 6.0)
    -- begin burning candle:
    TimerStart(self.candletmr, candle.cadence*map.mission.cache.setting[m_stat_waxrate], true, function()
        utils.debugfunc(function()
            if not map.manager.activemap or map.manager.sbactive or candle.spawned[3] then
                PauseTimer(self.candletmr)
            else
                candle:burn(1)
            end
        end,"burn")
    end)
end


function map.manager:exit()
    utils.debugfunc(function()
        map.manager.activemap = false
        map.manager:setbasebounds()
        utils.panallp(utils.rectx(gg_rct_betsyenter), utils.recty(gg_rct_betsyenter), 0.0)
        utils.playsoundall(kui.sound.digend)
        utils.moveallp(gg_rct_betsyenter)
        BlzChangeMinimapTerrainTex('war3mapImported\\minimap-hub.blp')
        -- save the character:
        utils.playerloop(function(p)
            port_yellowtp:play(utils.unitxy(kobold.player[p].unit))
            if not freeplay_mode then
                kobold.player[p].char:save_character()
                if p == utils.localp() then
                    kui.canvas.game.equip.save:show()
                end
            end
        end)
    end, "map.manager:exit")
end


function map.manager:setbasebounds()
    utils.setcambounds(gg_rct_expeditionVision)
    EnableTrigger(kk.boundstrig)
end


function map.mission:init()
    self.__index        = self
    self.debug          = false -- troubleshooting prints.
    self.mtypet         = {}
    self.mtable         = {}
    -- globals:
    m_stat_density      = 1
    m_stat_movespeed    = 2
    m_stat_attack       = 3
    m_stat_health       = 4
    m_stat_enemy_res    = 5
    m_stat_waxrate      = 6
    m_stat_player_ms    = 7
    m_stat_player_hp    = 8
    m_stat_treasure     = 9
    m_stat_xp           = 10
    m_stat_ms           = 11
    m_stat_blockhp      = 12
    m_stat_oredensity   = 13
    m_stat_elite_pack   = 14
    m_stat_elite_str    = 15
    -- gold rush:
    self.goldmineid     = 'ngol'
    self.koboldworkerid = 'nkob'
    self.koboldhallid   = 'h00J'
    self.koboldtowerid  = 'o000'
    self.grworkerhp     = 164  -- starting health of kobold workers.
    self.grtowerhp      = 250  -- `` kobold towers.
    -- candle heist:
    self.darkkobpylonid = 'n01V'
    self.chpylonhp      = 124
    -- mission ids:
    m_type_monster_hunt = 1
    m_type_gold_rush    = 2
    m_type_candle_heist = 3
    m_type_boss_fight   = 4
    -- mission data:
    self.missionintros  = {
        [m_type_monster_hunt]   = "|c0047c9ffMonster Hunt|r: Defeat the two treasure guardians!",
        [m_type_gold_rush]      = "|c00fff000Gold Rush|r: Defend your workers while they mine!",
        [m_type_candle_heist]   = "|c00fdff6fCandle Heist|r: Recover wax from the Dark Kobolds!",
        [m_type_boss_fight]     = "|c00ff3e3eBoss Fight|r",
    }
    m_asset      = {}
    m_asset.obj  = {}
    m_asset.map  = {}
    m_asset.name = {}
    -- obj tex:
    m_asset.obj[m_type_monster_hunt] = "war3mapImported\\obj_icon-monster.blp"
    m_asset.obj[m_type_gold_rush]    = "war3mapImported\\obj_icon-rush.blp"
    m_asset.obj[m_type_candle_heist] = "war3mapImported\\obj_icon-heist.blp"
    m_asset.obj[m_type_boss_fight]   = "war3mapImported\\obj_icon-monster.blp"
    -- map icon mdl:
    m_asset.map[m_type_monster_hunt] = "UI\\Minimap\\MiniMap-Boss.mdl"
    m_asset.map[m_type_gold_rush]    = "UI\\Minimap\\Minimap-QuestObjectiveBonus.mdl"
    m_asset.map[m_type_candle_heist] = "UI\\Minimap\\MiniMap-ControlPoint.mdl"
    m_asset.map[m_type_boss_fight]   = "UI\\Minimap\\MiniMap-Boss.mdl"
    --
    m_asset.name[m_type_monster_hunt] = "Monster Hunt"
    m_asset.name[m_type_gold_rush]    = "Gold Rush"
    m_asset.name[m_type_candle_heist] = "Candle Heist"
    m_asset.name[m_type_boss_fight]   = "Boss Fight"
    --
    self.starticon    = "UI\\Minimap\\Minimap-Waypoint.mdl"
    --
    self.diff         = map.manager.diff
    -- screen settings:
    self.score        = {}
    self.score.d      = 128
    self.score.x      = 10560
    self.score.y      = -18300
    self.score.walkd  = 256
     -- instantiate player ore stat table:
    self.goldmult     = 0.07 -- ore multiplier per map level.
    -- enemy modifiers:
    self.setting                        = {}
    self.setting[m_stat_density]        = 1.0
    self.setting[m_stat_attack]         = 1.0
    self.setting[m_stat_health]         = 1.0
    self.setting[m_stat_enemy_res]      = 1.0
    self.setting[m_stat_waxrate]        = 1.0
    self.setting[m_stat_player_ms]      = 1.0
    self.setting[m_stat_player_hp]      = 1.0
    self.setting[m_stat_treasure]       = 1.0
    self.setting[m_stat_xp]             = 1.0
    self.setting[m_stat_ms]             = 1.0
    self.setting[m_stat_blockhp]        = 1.0
    self.setting[m_stat_oredensity]     = 1.0
    self.setting[m_stat_elite_pack]     = 1.0
    self.setting[m_stat_elite_str]      = 1.0
    self.level                          = 1
    self.forceditem                     = nil -- table for fragment modifier.
    self.forcedrarity                   = nil -- ``
    -- instantiated mission settings:
    self.id      = id
    self.label   = label
    self.objicon = "war3mapImported\\obj_icon-monster.blp" -- icon displayed in objective counter.
    self.mapicon = "UI\\Minimap\\Minimap-QuestObjectiveBonus.mdl" -- minimap icon path.
     -- where minimap icons are stored:
    self.icont   = {}
    -- generate base mission templates:
    map.mission:buildtypes()
end


function map.mission:new(missionid, objtotal)
    local o = {}
    setmetatable(o, self)
    o.id      = missionid
    o.objtotal= objtotal or 2
    o.objdone = 0
    o.name    = m_asset.name[missionid]
    o.objicon = m_asset.obj[missionid] -- objective counter
    o.mapicon = m_asset.map[missionid] -- minimap image
    o.setting = utils.shallow_copy(self.setting) -- clone to do custom mods per mission type if needed.
    o.mods    = map.diff:getkeymods()
    o:modmerge()
    return o
end


function map.mission:generate(missionid)
    -- create a copy of the missionid template for total manipulation.
    local o = utils.deep_copy(self.mtypet[missionid])
    if o then
        setmetatable(o, self)
    else
        print("error: map.mission:generate found no missionid in self.mtypet")
        return
    end
    return o
end


function map.mission:modmerge()
    if self.mods then -- if dig site fragment present, add any modifiers
        for m_stat,mult in pairs(self.mods) do
            self.setting[m_stat] = self.setting[m_stat] + mult
        end
    end
end


function map.mission:diffmerge()
    -- update cached mission settings based on selected dig site difficulty.
    for m_stat,diffmult in pairs(map.diff[map.manager.diffid]) do
        if self.setting[m_stat] then
            self.setting[m_stat] = self.setting[m_stat] * diffmult
        end
    end
end


function map.mission:objstep(_scoredelaydur, _sndsuppress)
    -- increment the obj counter.
    self.objdone = self.objdone + 1
    -- run objective complete:
    if self.objdone >= self.objtotal and not map.manager.objiscomplete then
        map.manager.objiscomplete = true
        kui.canvas.game.skill.obj.txt:settext(color:wrap(color.tooltip.good, math.min(self.objdone, self.objtotal).."/"..self.objtotal))
        if map.mission.cache.id ~= m_type_boss_fight then alert:new(color:wrap(color.tooltip.good, "Objective Complete!"), 4.0) end
        utils.playerloop(function(p)
            SetUnitInvulnerable(kobold.player[p].unit, true)
            speff_voidport[1]:attachu(kobold.player[p].unit, _scoredelaydur or 6.0, 'origin', 0.9)
        end)
        utils.playsoundall(kui.sound.complete)
        PauseTimer(map.manager.candletmr)
        utils.timed(_scoredelaydur or 6.0, function() utils.debugfunc(function() self:objcomplete() end, "objcomplete") end)
    elseif self.objdone < self.objtotal then -- add to progress:
        kui.canvas.game.skill.obj.txt:settext(color:wrap(color.txt.txtwhite, self.objdone.."/"..self.objtotal))
        if not _sndsuppress then utils.playsoundall(kui.sound.objstep) end -- play step complete sound
    end
end


function map.mission:objfailed()
    map.manager.success = false
    utils.playerloop(function(p)
        for i = 1,3 do map.manager.scoreboard.card[kobold.player[p].pnum].loot[i]:hide() end
        utils.palert(p, "Your team has been downed.", 6.0)
        end)
    utils.playsoundall(kui.sound.failure)
    utils.timed(6.0, function()
        utils.debugfunc(function() map.manager:scoreboardstart() end, "objfailed")
    end)
end


function map.mission:objcomplete()
    map.manager.success = true
    utils.looplocalp(ClearTextMessages)
    -- generate loot:
    local rarityid, ilvl, slotid
    for p,_ in pairs(kobold.playing) do
        local pobj = kobold.player[p]
        local warningflag = false -- alert spam prevention.
        for i = 1,3 do
            local newitem = nil
            rarityid, ilvl, slotid = self:rolltreasure(pobj)
            newitem = loot:generate(pobj.p, ilvl, slotid, rarityid)
            utils.looplocalp(function() map.manager.scoreboard.card[pobj.pnum].loot[i]:show() end)
            utils.looplocalp(function() map.manager.scoreboard.card[pobj.pnum].loot[i].rarity:setbgtex(loot.raritytable[rarityid].icon) end)
            if newitem then utils.looplocalp(function() map.manager.scoreboard.card[pobj.pnum].loot[i]:setbgtex(newitem.itemtype.icon) end) newitem = nil end
        end
        pobj = nil
    end
    map.manager:scoreboardstart()
end


function map.mission:rolltreasure(pobj)
    local raremin, raremax, ilvlmin, ilvlmax, slotid, ilvl = rarity_common, rarity_common, math.max(1,pobj.level-3), math.min(60,pobj.level+1), loot:getrandomslottype(), 1
    local oddsmod = pobj:getlootodds()
    -- get item level:
    if oddsmod >= 10000 or math.random(0,10000 - oddsmod) < 500 then -- 5 percent of the time, roll a perfect match ilvl. improved by treasure find.
        ilvl = ilvlmax 
    else
        ilvl = math.random(ilvlmin, ilvlmax)
    end
    -- get rarity min:
    if pobj.level >= 30 then -- epics can only roll above level 30.
        -- tyrannical difficulty = guaranteed rare or higher.
        if map.manager.diffid == 5 then
            raremin = rarity_rare
            raremax = rarity_epic
        else
            raremin, raremax = rarity_common, rarity_epic
        end
    elseif pobj.level > 10 then -- rares can only randomly roll above level 10.
        raremin, raremax = rarity_common, rarity_rare
    else -- commons can only roll while below level 10.
        raremin, raremax = rarity_common, rarity_common
    end
    rarityid = loot:getrandomrarity(raremin, raremax, oddsmod)
    return rarityid, ilvl, slotid
end


function map.mission:buildpanel()
    -- objective tracker panel.
    local fr = kui.frame:newbytype("PARENT", kui.canvas.game.skill)
    fr.txt   = fr:createbtntext("0/3", nil)
    fr.txt:setsize(kui:px(104), kui:px(16))
    fr.txt:setfp(fp.c, fp.t, kui.minimap, 0, kui:px(76))
    fr.txt:assigntooltip("obj")
    fr.icon  = kui.frame:newbytype("BACKDROP", fr)
    fr.icon:addbgtex(self.objicon)
    fr.icon:setsize(kui:px(64), kui:px(64))
    fr.icon:setfp(fp.t, fp.b, fr.txt, 0, 0)
    BlzFrameSetTextAlignment(fr.txt.fh, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
    fr:hide()
    return fr
end


function map.mission:seticon()
    kui.canvas.game.obj.icon:setbgtex(self.objicon)
end


function map.mission:placestarticon()
    CreateMinimapIconBJ(map.grid.start.x, map.grid.start.y, 0, 255, 255, self.starticon, FOG_OF_WAR_MASKED)
    self.icont[#self.icont+1] = GetLastCreatedMinimapIcon()
end


function map.mission:placemapicon(x, y, missionid)
    -- for unit in future?: SetMinimapIconOrphanDestroy( GetLastCreatedMinimapIcon(), true )
    CreateMinimapIconBJ(x, y, 255, 255, 255, self.mapicon, FOG_OF_WAR_MASKED)
    self.icont[#self.icont1] = GetLastCreatedMinimapIcon()
end


function map.mission:attachmapicon(unit)
    -- destroy when this unit dies
    CreateMinimapIconOnUnitBJ(unit, 255, 255, 255, self.mapicon, FOG_OF_WAR_MASKED)
    SetMinimapIconOrphanDestroy(GetLastCreatedMinimapIcon(), true)
    self.icont[#self.icont+1] = GetLastCreatedMinimapIcon()
end


function map.mission:clearmapicons()
    for _,icon in pairs(self.icont) do
        DestroyMinimapIcon(icon)
        icon = nil
    end
end


function map.mission:cleanup()
    map.mission:clearmapicons()
    for _,trig in pairs(self.trigstack) do trig:destroy() end
    self.trigstack = nil
    if self ~= map.mission then
        self.setting = nil
    else 
        print("error: ran cleanup() on 'map.mission' class")
    end
    utils.looplocalp(function() kui.canvas.game.skill.obj:hide() end)
end


function map.mission:buildtypes()
    -- monster hunt:
    self.mtypet[m_type_monster_hunt] = map.mission:new(m_type_monster_hunt)
    -- gold rush:
    self.mtypet[m_type_gold_rush]    = map.mission:new(m_type_gold_rush, 200)
    -- candle heist:
    self.mtypet[m_type_candle_heist] = map.mission:new(m_type_candle_heist, 3)
    -- boss fight:
    self.mtypet[m_type_boss_fight]   = map.mission:new(m_type_boss_fight, 1)
end


-- @missiontype = mission type
function map.mission:build(missionid)
    -- RANDOMIZE MISSION TYPE:
    local missionid = missionid or math.random(m_type_monster_hunt, m_type_candle_heist) --[[m_type_candle_heist m_type_gold_rush--]]
    if dev_mission_id then missionid = dev_mission_id end
    self.cache = map.mission:generate(missionid)
    self.cache.level = kobold.player[Player(0)].level
    self.cache:diffmerge()
    self.cache:modmerge()
end


function map.mission:placeobj()
    -- NOTE: this function's objective component only applies to monster hunt now
    self.trigstack = {}
    if map.mission.cache.id == m_type_monster_hunt then
        -- place bounty activators:
        local d = map.grid:getx( math.random(math.floor(map.grid.r*0.5), math.floor(map.grid.r*0.8)) )
        local a = utils.anglexy(map.grid.start.x, map.grid.start.y, map.grid.center.x, map.grid.center.y)
        self.spawn = { [1] = {}, [2] = {} }
        self.spawn[1].x, self.spawn[1].y = utils.projectxy(map.grid.center.x, map.grid.center.y, d, a + 45)
        self.spawn[2].x, self.spawn[2].y = utils.projectxy(map.grid.center.x, map.grid.center.y, d, a - 45)
        for i = 1,2 do
            map.grid:excavate(self.spawn[i].x, self.spawn[i].y, 1024, map.manager.biome.dirt)
            map.grid:clearunits(self.spawn[i].x, self.spawn[i].y, 1536)
            local bossid = math.random(1,#creature.boss[map.manager.biome.id])
            local unit   = creature.boss[map.manager.biome.id][bossid]:create(self.spawn[i].x, self.spawn[i].y)
            local trove  = b_trove:placexy(self.spawn[i].x, self.spawn[i].y)
            self.trigstack[#self.trigstack+1] = trg:newdeathtrig(trove, function() ShowUnit(unit, true) end, speff_explode)
            self.trigstack[#self.trigstack+1] = trg:newdeathtrig(unit,  function() self:objstep() end)
            self:attachmapicon(unit)
            ShowUnit(unit, false)
        end
        -- place shrines:
        for i = 1,2 do
            local a = utils.anglexy(self.spawn[i].x, self.spawn[i].y, 0, 0) + math.randomneg(-17,17)
            local sx,sy = utils.projectxy(self.spawn[i].x, self.spawn[i].y, math.random(1512,3584), a)
            shrine:placerandom(sx, sy)
        end
        self.spawn = nil
    elseif map.mission.debug then
        print("caution: map.mission:placeobj(): mission id",map.mission.cache.id,"not implemented")
    end
    utils.looplocalp(function()
        kui.canvas.game.skill.obj.txt:settext("0/"..self.objtotal)
        kui.canvas.game.skill.obj.icon:addbgtex(self.objicon)
        kui.canvas.game.skill.obj:show()
    end)
end


function map.diff:init()
    self.lvlreq = 0
    -- id map: 1 = greenwhisker | 2 = standard | 3 = heroic | 4 = vicious | 5 = tyrannical
    self[1] = map.diff:new(0.60, 0.60, 1.00, 0.60, 1.50, 1.00, 1.00, 0.75, 1.00, 0.75)
    self[2] = map.diff:new(1.00, 1.00, 1.00, 1.00, 1.00, 1.10, 1.25, 1.00, 1.00, 1.00)
    self[3] = map.diff:new(1.50, 1.50, 1.10, 1.10, 0.90, 1.50, 1.50, 1.00, 1.25, 1.50)
    self[4] = map.diff:new(2.25, 2.25, 1.25, 1.30, 0.80, 3.00, 2.00, 1.00, 1.50, 1.75)
    self[4].lvlreq = 20
    self[5] = map.diff:new(3.75, 3.25, 1.50, 1.40, 0.70, 10.00, 5.00, 1.50, 1.50, 1.75)
    self[5].lvlreq = 30
end


-- retrieve dig site key modifiers:
function map.diff:getkeymods()
    local t = {}
    local key = kobold.player[Player(0)].items[slot_digkey] or nil
    if key and key.kw then
        for kw_type,kwt in pairs(key.kw) do
            -- TODO
        end
    else
        t = nil
    end
    return t
end


function map.diff:new(enemyhp, enemystr, enemyres, enemydensity, waxcap, treasure, xp, ms, elitepacksize, elitestr)
    local o = {}
    o[m_stat_health]     = enemyhp
    o[m_stat_attack]     = enemystr
    o[m_stat_enemy_res]  = enemyres
    o[m_stat_density]    = enemydensity
    o[m_stat_waxrate]    = waxcap
    o[m_stat_treasure]   = treasure
    o[m_stat_xp]         = xp
    o[m_stat_ms]         = ms
    o[m_stat_elite_pack] = elitepacksize
    o[m_stat_elite_str]  = elitestr
    o[m_stat_player_ms]  = 1.0
    o[m_stat_blockhp]    = 1.0
    o[m_stat_player_hp]  = 1.0
    o[m_stat_oredensity] = 1.0
    o.lvlreq             = 0
    setmetatable(o, self)
    return o
end
