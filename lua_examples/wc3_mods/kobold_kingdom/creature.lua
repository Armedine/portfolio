creature                = {} -- creature metadata class.
creature.cluster        = {} -- sub class for generating groupings of similar creatures + an elite.
creature.boss           = {} -- store possible bosses by biomeid.
creature.cluster.biome  = {} -- store possible clusters by biomeid.


function creature:init()
    EnableCreepSleepBJ(false)
    -- globals:
    self.__index    = self
    self.basehp     = 42   -- base hp value.
    self.multhp     = 1.0  -- hp multiplier based on creature strength.
    self.baseatk    = 5    -- `` atk value.
    self.multatk    = 1.0  -- `` 
    self.spelldmg   = 36   -- ``
    self.multspell  = 1.0  -- ``
    self.lvlmulthp  = 0.04 -- multiplier based on map level.
    self.lvlmultatk = 0.04 -- ``
    self.pmulthp    = 0.15 -- multiplier based on party size.
    self.pmultatk   = 0.12 -- ``
    self.eliteratio = 0.08 -- how often elites spawn.
    self.darkt      = {}   -- store darkness commanders.
    creature.boss:init()
    creature.cluster:init()
    creature.cluster.biome:init()
    -- enchantment ids:
    -- TODO: use dmg and check for unit ability 
    self.enchant = { -- eye-candy effects to attach.
        [1] = FourCC('A00F'), -- arcane
        [2] = FourCC('A00D'), -- frost
        [3] = FourCC('A00A'), -- nature
        [4] = FourCC('A00B'), -- fire
        [5] = FourCC('A00C'), -- shadow
        [6] = FourCC('A00E'), -- physical
    }
    -- weak creatures:
    cr_skele_orc    = creature:new( 'n007', {multhp = 0.80, multatk = 0.85} )
    cr_elefirelesr  = creature:new( 'n00C', {multhp = 0.60, multatk = 0.60} )
    cr_firerev      = creature:new( 'n009', {multhp = 0.85, multatk = 0.70} )
    cr_arachnathid  = creature:new( 'n00K', {multhp = 0.60, multatk = 0.60} )
    cr_gnoll        = creature:new( 'n00O', {multhp = 0.85, multatk = 0.60} )
    cr_spider       = creature:new( 'n00S', {multhp = 0.70, multatk = 0.50} )
    cr_shroomlocmag = creature:new( 'n011', {multhp = 0.85, multatk = 0.65} )
    cr_ogreminion   = creature:new( 'n01A', {multhp = 0.80, multatk = 0.60} )
    cr_conslooter   = creature:new( 'u001', {multhp = 0.85, multatk = 0.55} )
    cr_dkoboldmel   = creature:new( 'n01T', {multhp = 0.80, multatk = 0.80} )
    -- normal creatures:
    cr_rarachnathid = creature:new( 'n00X', {multhp = 0.80, multatk = 0.65} )
    cr_gnollwarden  = creature:new( 'n00Q', {multhp = 1.25, multatk = 0.60} )
    cr_gnollnature  = creature:new( 'n00P', {multhp = 1.00, multatk = 0.80} )
    cr_skele_arch   = creature:new( 'n003', {multhp = 0.90, multatk = 0.60} )
    cr_lava_spawn   = creature:new( 'n006', {multhp = 1.20, multatk = 0.40} )
    cr_sludgefling  = creature:new( 'n00A', {multhp = 1.10, multatk = 0.60} )
    cr_marshfiend   = creature:new( 'n000', {multhp = 1.00, multatk = 0.80} )
    cr_geodegolem   = creature:new( 'n00N', {multhp = 1.70, multatk = 0.80} )
    cr_hydra        = creature:new( 'n00U', {multhp = 1.60, multatk = 0.80} )
    cr_lightnliz    = creature:new( 'n00W', {multhp = 1.30, multatk = 0.60} )
    cr_magmaliz     = creature:new( 'n00Z', {multhp = 1.40, multatk = 0.70} )
    cr_shroomloc    = creature:new( 'n010', {multhp = 1.10, multatk = 0.70} )
    cr_magnataur    = creature:new( 'n017', {multhp = 1.60, multatk = 0.90} )
    cr_wendigo      = creature:new( 'n015', {multhp = 1.70, multatk = 0.80} )
    cr_rollingt     = creature:new( 'n01S', {multhp = 1.50, multatk = 0.90} )
    cr_dkoboldrng   = creature:new( 'n01U', {multhp = 1.20, multatk = 0.90} )
    -- tough creatures:
    cr_mirehydra    = creature:new( 'n00T', {multhp = 2.80, multatk = 2.10} )
    cr_gnollseer    = creature:new( 'n00R', {multhp = 2.70, multatk = 2.10} )
    cr_rockgolem    = creature:new( 'n00M', {multhp = 2.80, multatk = 1.70} )
    cr_elefiregrtr  = creature:new( 'n00D', {multhp = 3.00, multatk = 2.25} )
    cr_sludgemonst  = creature:new( 'n00B', {multhp = 3.00, multatk = 2.25} )
    cr_war_cons     = creature:new( 'n008', {multhp = 3.30, multatk = 1.70} )
    cr_magmalizbig  = creature:new( 'n00L', {multhp = 3.10, multatk = 1.90} )
    cr_stormliz     = creature:new( 'n00V', {multhp = 2.70, multatk = 1.70} )
    cr_broodmother  = creature:new( 'n00Y', {multhp = 2.60, multatk = 2.30} )
    cr_shroomlocbig = creature:new( 'n012', {multhp = 2.50, multatk = 2.10} )
    cr_caveogre     = creature:new( 'n019', {multhp = 2.80, multatk = 1.60} )
    cr_magnataurbig = creature:new( 'n018', {multhp = 3.20, multatk = 1.60} )
    cr_wendigobig   = creature:new( 'n016', {multhp = 3.00, multatk = 2.00} )
    cr_greedsymb    = creature:new( 'u002', {multhp = 2.70, multatk = 2.20} )
    -- shrine minions:
    sh_dragbrood    = creature:new( 'n028', {multhp = 1.50, multatk = 0.90} )
    sh_dragfire     = creature:new( 'n027', {multhp = 1.50, multatk = 0.90} )
    sh_dragfrost    = creature:new( 'n026', {multhp = 1.50, multatk = 0.90} )
    sh_arcshard     = creature:new( 'n029', {multhp = 1.85, multatk = 0.60} )
    sh_fossloot     = creature:new( 'n02B', {multhp = 1.85, multatk = 0.60} )
    sh_arcana       = creature:new( 'n02C', {multhp = 1.75, multatk = 0.75} )
    -- boss minions:
    bm_swampling    = creature:new( 'n01G', {multhp = 1.70, multatk = 1.15} )
    bm_livfossil    = creature:new( 'n01I', {multhp = 1.70, multatk = 3.50} )
    bm_discexperim  = creature:new( 'n01K', {multhp = 1.60, multatk = 2.10} )
    bm_darknessdrop = creature:new( 'n01P', {multhp = 1.15, multatk = 1.65} )
    --[[
        slag:
    --]]
    cl_slag_fire    = creature.cluster:new(
        {cr_elefirelesr},
        {cr_lava_spawn},
        {cr_elefiregrtr, cr_sludgemonst},
        {biome_id_slag} )
    cl_slag_shadow  = creature.cluster:new(
        {cr_firerev},
        {cr_sludgefling},
        {cr_sludgemonst},
        {biome_id_slag} )
    cl_slag_liz     = creature.cluster:new(
        nil,
        {cr_magmaliz},
        {cr_magmalizbig},
        {biome_id_slag} )
    cl_slag_liz.thresh = { weak = 0.0, normal = 0.4, tough = 0.2 }
    --[[
        fossile:
    --]]
    cl_skele        = creature.cluster:new(
        {cr_skele_orc},
        {cr_skele_arch},
        {cr_war_cons},
        {biome_id_foss} )
    cl_foss_gnoll   = creature.cluster:new(
        {cr_gnoll},
        {cr_gnollwarden, cr_gnollnature},
        {cr_gnollseer},
        {biome_id_foss} )
    cl_foss_golem   = creature.cluster:new(
        nil,
        {cr_geodegolem},
        {cr_rockgolem},
        {biome_id_foss} )
    cl_foss_golem.thresh  = { weak = 0.0, normal = 0.4, tough = 0.2 }
    cl_foss_liz     = creature.cluster:new(
        nil,
        {cr_lightnliz},
        {cr_stormliz},
        {biome_id_foss} )
    cl_foss_liz.thresh    = { weak = 0.0, normal = 0.6, tough = 0.1 }
    cl_foss_arach   = creature.cluster:new(
        {cr_arachnathid},
        {cr_rarachnathid},
        nil,
        {biome_id_foss} )
    cl_foss_arach.thresh  = { weak = 0.4, normal = 0.4, tough = 0.0 }
    --[[
        mire:
    --]]
    cl_mire_hydra   = creature.cluster:new(
        nil,
        {cr_hydra},
        {cr_mirehydra},
        {biome_id_mire} )
    cl_mire_hydra.thresh  = { weak = 0.0, normal = 0.4, tough = 0.2 }
    cl_mire_spider  = creature.cluster:new(
        {cr_spider},
        nil,
        {cr_broodmother},
        {biome_id_mire} )
    cl_mire_spider.thresh = { weak = 0.9, normal = 0.0, tough = 0.1 }
    cl_mire_loc     = creature.cluster:new(
        {cr_shroomlocmag},
        {cr_shroomloc},
        {cr_shroomlocbig},
        {biome_id_mire} )
    --[[
        glacier:
    --]]
    cl_ice_wendigo  = creature.cluster:new(
        nil,
        {cr_wendigo},
        {cr_wendigobig},
        {biome_id_ice} )
    cl_ice_wendigo.thresh = { weak = 0.0, normal = 0.4, tough = 0.1 }
    cl_ice_magna    = creature.cluster:new(
        nil,
        {cr_magnataur},
        {cr_magnataurbig},
        {biome_id_ice} )
    cl_ice_magna.thresh   = { weak = 0.0, normal = 0.4, tough = 0.1 }
    cl_ice_ogre    = creature.cluster:new(
        {cr_ogreminion},
        nil,
        {cr_caveogre},
        {biome_id_ice} )
    cl_ice_ogre.thresh   = { weak = 0.9, normal = 0.0, tough = 0.1 }
    --[[
        vault:
    --]]
    cl_vault_treasure    = creature.cluster:new(
        {cr_conslooter},
        {cr_rollingt},
        {cr_greedsymb},
        {biome_id_vault} )
    cl_vault_treasure.thresh = { weak = 0.6, normal = 0.3, tough = 0.1 }
    cl_vault_dkobold    = creature.cluster:new(
        {cr_dkoboldmel},
        {cr_dkoboldrng},
        nil,
        {biome_id_vault} )
    cl_vault_dkobold.thresh = { weak = 0.5, normal = 0.4, tough = 0.0 }
    cl_shrine_arcana    = creature.cluster:new(
        nil,
        {sh_arcana},
        nil,
        {biome_id_vault} )
    cl_vault_dkobold.thresh = { weak = 0.0, normal = 0.7, tough = 0.0 }
    --[[
        boss objectives:
    --]]
    bs_hoard_drag    = creature:new('n00E', {multhp = 6.15, multatk = 3.15})
    bs_hoard_amalgam = creature:new('n013', {multhp = 5.75, multatk = 3.25})
    bs_hoard_qngreed = creature:new('n014', {multhp = 5.75, multatk = 3.33})
    bs_hoard_drag:addbosstype({biome_id_foss, biome_id_slag})
    bs_hoard_amalgam:addbosstype({biome_id_mire, biome_id_slag, biome_id_ice, biome_id_vault})
    bs_hoard_qngreed:addbosstype({biome_id_slag, biome_id_mire, biome_id_ice, biome_id_vault})
    --[[
        darkness wave elites:
    --]]
    drk_widow  = creature:new( 'n00F', {multhp = 3.33, multatk = 3.00}, true )
    drk_terror = creature:new( 'n00G', {multhp = 3.00, multatk = 3.50}, true )
    drk_dragon = creature:new( 'n00H', {multhp = 3.15, multatk = 2.33}, true )
end


function creature.cluster.biome:init()
    self[biome_id_foss]     = {}
    self[biome_id_slag]     = {}
    self[biome_id_mire]     = {}
    self[biome_id_ice]      = {}
    self[biome_id_vault]    = {}
end


function creature.boss:init()
    self[biome_id_foss]     = {}
    self[biome_id_slag]     = {}
    self[biome_id_mire]     = {}
    self[biome_id_ice]      = {}
    self[biome_id_vault]    = {}
end


function creature:new(rawcode, statst, _darkness)
    local o  = {}
    setmetatable(o, self)
    o.code   = FourCC(rawcode)
    for stat,val in pairs(statst) do
        o[stat] = val
    end
    if _darkness then
        self.darkt[#self.darkt + 1] = o
    end
    return o
end


function creature:create(x, y)
    local unit = CreateUnit(Player(PLAYER_NEUTRAL_AGGRESSIVE), self.code, x, y, 0)
    IssuePointOrderById(unit, 851986, x, y) -- move in place to auto-shift the unit outside of blocks.
    utils.stop(unit)   -- stop order to stop pathfinding.
    SetUnitFacing(unit, math.random(0,360))
    BlzSetUnitIntegerField(unit, UNIT_IF_LEVEL, math.floor(map.mission.cache.level))
    -- init from creature template:
    BlzSetUnitMaxHP(unit, math.floor(self.basehp*self.multhp*(1 + (map.mission.cache.level^1.12)*self.lvlmulthp) ) )
    BlzSetUnitBaseDamage(unit, math.floor(self.baseatk*self.multatk*(1 + (map.mission.cache.level^1.12)*self.lvlmultatk) ), 0)
    -- modify based on difficulty:
    if map.mission.cache and map.mission.setting then
        BlzSetUnitMaxHP(unit,       math.ceil( BlzGetUnitMaxHP(unit)*map.mission.cache.setting[m_stat_health]) )
        BlzSetUnitBaseDamage(unit,  math.ceil( BlzGetUnitBaseDamage(unit, 0)*map.mission.cache.setting[m_stat_attack]), 0 )
        SetUnitMoveSpeed(unit,      math.ceil( GetUnitDefaultMoveSpeed(unit)*map.mission.cache.setting[m_stat_ms]) )
        BlzSetUnitArmor(unit,       math.ceil( BlzGetUnitArmor(unit)+((map.mission.cache.setting[m_stat_enemy_res]-1)*100)) )
    end
    -- modify based on players present:
    if map.manager.totalp > 1 then
        BlzSetUnitMaxHP(unit,       math.ceil( BlzGetUnitMaxHP(unit)*(1 + map.manager.totalp*self.pmulthp)) )
        BlzSetUnitBaseDamage(unit,  math.ceil( BlzGetUnitBaseDamage(unit, 0)*(1 + map.manager.totalp*self.pmultatk)), 0 )
    end
    utils.restorestate(unit)
    return unit
end


function creature:addbosstype(biomeid)
    if type(biomeid) == "table" then
        for _,id in pairs(biomeid) do
            creature.boss[id][#creature.boss[id]+1] = self
        end
    else 
        creature.boss[biomeid][#creature.boss[biomeid]+1] = self
    end
    self.boss = true
end


function creature.cluster:init()
    self.__index    = self
    self.size       = { min  = 2,   max    = 4                } -- controls clustering size (min and max * thresh).
    self.dist       = { min  = 128, max    = 896              } -- controls randomized distance between spawns.
    self.thresh     = { weak = 0.7, normal = 0.2, tough = 0.1 } -- thresholds for creatures to spawn based on strength.
    self.creatures  = { weak = {},  normal = {},  tough = {}  } -- store possible creatures to randomly spawn for this squad.
    self.eliteratio = 0.33 -- chance for tough cluster creatures to roll an elite pack.
    self.lvlscale   = 0.01 -- cluster size multiplier per mission level.
end


function creature.cluster:new(weakt, normalt, tought, biomest)
    -- add creatures to a new squad type. assign biomeids with {...}.
    local o      = setmetatable({}, self)
    o.creatures  = utils.deep_copy(self.creatures)
    o.thresh     = utils.deep_copy(self.thresh)
    o.size       = utils.deep_copy(self.size)
    o.dist       = utils.deep_copy(self.dist)
    if weakt then
        for _,cr in pairs(weakt) do
            o.creatures.weak[#o.creatures.weak+1] = cr
        end
    end
    if normalt then
        for _,cr in pairs(normalt) do
            o.creatures.normal[#o.creatures.normal+1] = cr
        end
    end
    if tought then
        for _,cr in pairs(tought) do
            o.creatures.tough[#o.creatures.tough+1] = cr
        end
    end
    for _,biomeid in pairs(biomest) do
        creature.cluster.biome[biomeid][#creature.cluster.biome[biomeid]+1] = o
    end
    return o
end


function creature.cluster:spawn(centerx, centery, min, max, _spawneffect)
    -- spawn a randomized cluster of creatures at this point.
    -- strength randomizers:
    local id, x, y, mn, mx = 1, 1, 1, min or self.size.min, max or self.size.max
    local eliteratio = self.eliteratio
    if map.manager.diffid == 5 then -- far more elites on tyrannical
        eliteratio = eliteratio*2
    end
    local ut = {} -- return the unit table.
    if map.mission.cache then -- merge density modifier.
        mn,mx = mn*map.mission.cache.setting[m_stat_density],mx*map.mission.cache.setting[m_stat_density]
        mn,mx = math.floor(mn*(1+map.mission.cache.level*self.lvlscale)), math.floor(mx*(1+map.mission.cache.level*self.lvlscale))
    end
    if #self.creatures.weak > 0 and self.thresh.weak > 0.0 then
        local threshw   = math.random(math.floor(mn*self.thresh.weak),   math.ceil(mx*self.thresh.weak))
        for i = 1,threshw do
            id  = math.random(1, #self.creatures.weak)
            x,y = utils.projectxy(centerx, centery, math.random(self.dist.min, self.dist.max), math.random(0,360))
            ut[#ut+1] = self.creatures.weak[id]:create(x, y)
            if _spawneffect then _spawneffect:play(x,y) end
        end
    end
    if #self.creatures.normal > 0 and self.thresh.normal > 0.0 then
        local threshn   = math.random(math.floor(mn*self.thresh.normal), math.ceil(mx*self.thresh.normal))
        for i = 1,threshn do
            id  = math.random(1, #self.creatures.normal)
            x,y = utils.projectxy(centerx, centery, math.random(self.dist.min, self.dist.max), math.random(0,360))
            ut[#ut+1] = self.creatures.normal[id]:create(x, y)
            if _spawneffect then _spawneffect:play(x,y) end
        end
    end
    if #self.creatures.tough > 0 and self.thresh.tough > 0.0 then
        local thresht   = math.random(math.floor(mn*self.thresh.tough),  math.ceil(mx*self.thresh.tough))
        for i = 1,thresht do
            id  = math.random(1, #self.creatures.tough)
            x,y = utils.projectxy(centerx, centery, math.random(self.dist.min, self.dist.max), math.random(0,360))
            ut[#ut+1] = self.creatures.tough[id]:create(x, y)
            if _spawneffect then _spawneffect:play(x,y) end
            if map.mission.cache.level > 4 then -- elites only spawn at level 5+
                if math.random(0,100) < eliteratio*100 then
                    elite:new(ut[#ut], math.random(1,6), self)
                end
            end
        end
    end
    return ut
end
