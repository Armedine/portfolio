loot          = {} -- item management class.
loot.itemtype = {} -- item base type sub class.
loot.item     = {} -- item object sub class.
loot.slottype = {} -- slot type sub class.
loot.kw       = {} -- item attribute sub class.
loot.rarity   = {} -- item rarity sub class.
loot.statmod  = {} -- player modification sub class.
loot.box      = {} -- treasure group sub class (decides which items are possible on roll).
loot.ancient  = {} -- wrapper for dealing with ancient effects and metadata.
loot.ancient.allancients = {} -- global ancient rolls from any biome.

function loot:init()
    global_statmod_multiplier = 2.25 -- makes all statmods more potent as player level increase.
    self.debug        = false -- print debug messages.
    self.invmax       = 42    -- total inv slots.
    -- class init:
    loot.itemtype:init()
    loot.item:init()
    loot.kw:init()
    loot.statmod:init()
    loot.rarity:init()
    -- lootdata functions:
    loot:globals()
    loot:buildtables()
    loot.missile = {
        [rarity_common]  = 'I00B',
        [rarity_rare]    = 'I00C',
        [rarity_epic]    = 'I00D',
        [rarity_ancient] = 'I00E',
    }
    loot.pickup = {
        [FourCC("I00B")] = rarity_common,
        [FourCC("I00C")] = rarity_rare,
        [FourCC("I00D")] = rarity_epic,
        [FourCC("I00E")] = rarity_ancient,
    }
end


function loot:isbagfull(p)
    -- if player's bag is full, return true.
    for slotid = 1,loot.invmax do
        if kobold.player[p].items[slotid] == nil then
            return false
        end
    end
    return true
end


function loot:getfirstempty(p)
    for slotid = 1,loot.invmax do
        if kobold.player[p].items[slotid] == nil then
            return slotid
        end
    end
    return false
end


function loot:inventorysellall(p)
    local founditem = false
    if kobold.player[p].sellallclk then
        for slotid = 1,42 do
            if kobold.player[p].items[slotid] and kobold.player[p].items[slotid].itemtype.slottype.slotid ~= slot_digkey and not kobold.player[p].items[slotid].ancientid then
                kobold.player[p].items[slotid]:sell(p, true, slotid)
                founditem = true
            end
        end
        loot:cleanupempty(p)
    else
        kobold.player[p].sellallclk = true
        utils.timed(0.42, function() kobold.player[p].sellallclk = nil end)
    end
    if founditem then
        utils.playsound(kui.sound.sell, p)
        kui.canvas.game.equip.pane:hide()
        kui.canvas.game.inv.pane:hide()
        kobold.player[p].selslotid = nil
    end
end


function loot:unequipall(p)
    if kobold.player[p].unequipallclk then
        for slotid = 1001,1010 do
            if kobold.player[p].items[slotid] then
                loot.item:unequip(p, slotid)
            end
        end
        utils.playsound(kui.sound.itemsel, p)
        kui.canvas.game.equip.pane:hide()
        kui.canvas.game.inv.pane:hide()
        kobold.player[p].selslotid = nil
    else
        kobold.player[p].unequipallclk = true
        utils.timed(0.42, function() kobold.player[p].unequipallclk = nil end)
    end
end


function loot:inventorysortall(p)
    if not kobold.player[p].pausesort then
        orderedt = {}
        kobold.player[p].pausesort = true
        for slotid = 1,42 do
            if kobold.player[p].items[slotid] then
                orderedt[#orderedt+1] = kobold.player[p].items[slotid]
            end
        end
        table.sort(orderedt, function(a, b) return a.itemtype.slottype.slotid < b.itemtype.slottype.slotid end)
        loot:clearitems(p) -- remove existing items
        for slotid = 1,42 do
            -- replace slots with the new ordering:
            if orderedt[slotid] then
                kobold.player[p].items[slotid] = nil
                kobold.player[p].items[slotid] = orderedt[slotid]
            end
        end
        loot:cleanupempty(p) -- refresh new frame icons etc.
        utils.playsound(kui.sound.itemsel, p)
        orderedt = nil
        kui.canvas.game.equip.pane:hide()
        kui.canvas.game.inv.pane:hide()
        kobold.player[p].selslotid = nil
        utils.timed(1.0, function() kobold.player[p].pausesort = false end)
    else
        utils.palert(p, "Sorting too fast!")
    end
    loot:updateallrarityicons(p)
end


function loot:clearitems(p)
    for slotid = 1,42 do
        kobold.player[p].items[slotid] = nil
    end
    loot:cleanupempty(p)
end


function loot:cleanupempty(p)
    -- searches for nil item slots and resets any
    --  lingering icons.
    for slotid = 1,loot.invmax do
        if kobold.player[p].items[slotid] == nil then
            if p == utils.localp() then
                kui.canvas.game.inv.space[slotid].icon:setbgtex(kui.tex.invis)
            end
        else
            kui.canvas.game.inv.space[slotid].icon:setbgtex(kobold.player[p].items[slotid].itemtype.icon)
        end
    end
    loot:updateallrarityicons(p)
end


function loot:updateallrarityicons(p)
    local pobj = kobold.player[p]
    if pobj:islocal() then
        for slotid = 1,42 do
            if pobj.items[slotid] and pobj.items[slotid].slottype.slotid ~= slot_digkey then
                kui.canvas.game.inv.space[slotid].rareind:setbgtex(pobj.items[slotid].rarity.rareind)
            else
                kui.canvas.game.inv.space[slotid].rareind:setbgtex(kui.tex.invis)
            end
        end
        for slotid = 1001,1010 do
            if pobj.items[slotid] then
                kui.canvas.game.equip.space[slotid].rareind:setbgtex(pobj.items[slotid].rarity.rareind)
            else
                kui.canvas.game.equip.space[slotid].rareind:setbgtex(kui.tex.invis)
            end
        end
    end
    pobj = nil
end


-- @p       = for this player.
-- @level   = the item level to determine stats.
-- @slotid  = equipment piece to generate.
-- @rarityid= force this rarity.
-- @_iscrafted = [optional] default false; does custom things for shinykeeper purchases.
function loot:generate(p, level, slotid, rarityid, _iscrafted)
    -- wrapper for generating an item.
    if not loot:isbagfull(p) then
        local level = math.max(1,level) -- level cannot be below 1.
        local newitem    = self.item:new(loot:getitemtypebylvl(slotid, level), p)
        local rarityid   = rarityid or loot:getrandomrarity(rarity_common, rarity_epic, kobold.player[p][p_stat_treasure]*100)
        newitem.rarity   = loot.raritytable[rarityid]
        newitem.level    = level
        newitem.sellsfor = math.ceil(math.random(newitem.level^0.90,newitem.level^1.05)*newitem.rarity.sellfactor)
        if slotid == slot_potion or slotid == slot_artifact or slotid == slot_backpack or slotid == slot_tool or slotid == slot_candle then
            newitem.sellsfor = math.floor(newitem.sellsfor*1.15)
        end
        -- based on rarity, pick affixes to roll:
        if not _iscrafted then
            -- item dropped in world:
            if rarityid == rarity_common then
                if level < 10 then -- under level 10, commons sometimes only have 1 primary.
                    newitem:addrandomaffix(math.random(1,2))
                elseif level < 30 then -- after 10, allow 2 primaries on commons.
                    newitem:addrandomaffix(2)
                elseif level >= 30 and level < 40 then -- after 30, allow 2 primaries and a secondary on commons.
                    newitem:addsecondary()
                    newitem:addrandomaffix(2)
                else -- at level 40, allow full common stats.
                    newitem:addsecondary()
                    newitem:addrandomaffix(3)
                end
            elseif rarityid == rarity_rare then
                newitem:addsecondary()
                if level < 10 then
                    newitem:addrandomaffix(2)
                else
                    newitem:addrandomaffix(3)
                end
                newitem:addrarityaffix(slotid, rarityid)
            elseif rarityid == rarity_epic then
                newitem:addsecondary()
                newitem:addrandomaffix(3)
                newitem:addrarityaffix(slotid, rarityid)
                newitem.sellsfor = math.floor(newitem.sellsfor*1.05)
            elseif rarityid == rarity_ancient then
                newitem:addsecondary()
                newitem:addrandomaffix(3)
                newitem:addrarityaffix(slotid, rarityid)
                newitem.sellsfor = math.floor(newitem.sellsfor*1.1)
            end
        elseif _iscrafted then
            -- item crafted by shinykeeper:
            newitem.modifierid = 1
            local affixcount = 2
            if quest_shinykeeper_upgrade_1 then
                affixcount = affixcount + 1
                if math.random(0,2) == 1 then
                    newitem:addsecondary(true)
                end
            end
            if quest_shinykeeper_upgrade_2 and rarityid == rarity_epic then
                newitem:addrarityaffix(slotid, rarityid)
            end
            newitem:addrandomaffix(affixcount)
            -- if rolled epic, do an effect at the forge construction doodad:
            if rarityid == rarity_epic then
                speff_explpurp:play(18500,-18800, nil, 1.5)
            end
        end
        newitem:buildname()
        newitem:giveto(p)
        return newitem
    else
        loot:cacheloot(level, slotid, rarityid, kobold.player[p])
    end
end


-- generates an item with forced affixes from a specific ore type id.
function loot:generateforcedelement(p, level, slotid, rarityid, oreid)
    if loot.debug then
        for kw_type,kw_table in pairs(loot.eletable[oreid]) do
            for slotid,slottable in pairs(kw_table) do
                if #slottable > 0 then
                    print("found match: ore table",oreid,"kw_type",kw_type,"slotid",slotid,"has table size",#slottable)
                    for slotid,kw in pairs(slottable) do
                        print("p_stat =",kw.statmod.p_stat)
                    end
                end
            end
        end
    end
    local newitem    = self.item:new(loot:getitemtypebylvl(slotid, level), p)
    if loot.debug then print("trying to make elemental item for oreid ", oreid," rarity ", rarityid, " slotid ", slotid, " level ", level) end
    newitem.level    = level
    newitem.rarity   = loot.raritytable[rarityid]
    newitem.modifierid = 2
    newitem:addaffix(kw_type_prefix)
    newitem:addaffix(kw_type_suffix)
    newitem:addelementaffix(oreid, kw_type_typemod)
    if quest_elementalist_upgrade_1 then -- a quest unlocks ability to craft secondary stats.
        newitem:addsecondary(true)
    end
    -- add slotid/rarity specific features:
    if slotid == slot_potion or slotid == slot_artifact then
        newitem:addelementaffix(oreid, kw_type_potion)
    end
    if rarityid > rarity_rare and (slotid ~= slot_potion and slotid ~= slot_artifact) then
        newitem:addelementaffix(oreid, kw_type_epic)
    end
    -- if rolled epic, do eyecandy at upgrade doodad:
    if rarityid == rarity_epic then
        speff_explpurp:play(18190,-16130, nil, 1.5)
    end
    -- as a crafted elemental item, increase all stats by 7 percent:
    for kwt,roll in pairs(newitem.kw_roll) do
        newitem.kw_roll[kwt] = math.floor(newitem.kw_roll[kwt]*1.07)
    end
    -- add the elementalist tag (crafted by):
    newitem:buildname()
    newitem:giveto(p)
    return newitem
end


function loot:generatedigkey(p, level, biomeid)
    if not loot:isbagfull(p) then
        -- local diffid    = diffid or map.manager.prevdiffid or 1
        local newitem       = self.item:new(loot.itemtable[slot_digkey][biomeid], p)
        -- find boss details in boss table:
        for bossid,t in pairs(boss.bosst) do
            if t.biomeid == biomeid then
                newitem.biomeid   = t.biomeid
                newitem.bossname  = t.name
                newitem.biomename = map.biomemap[t.biomeid]
                newitem.bossid    = bossid
                break
            end
        end
        newitem.rarity   = loot.raritytable[4]
        newitem.level    = level
        newitem.sellsfor = 50
        newitem:buildname()
        newitem.descript = "Summons "..color:wrap(color.tooltip.bad, newitem.bossname).." within "..color:wrap(color.tooltip.good, newitem.biomename).."."
            .."|n|n"..color:wrap(color.txt.txtdisable,"Equipping this key will summon a powerful foe on your next adventure into "..newitem.biomename.."."
            .."|n|n"..color:wrap(color.txt.txtdisable,"This item is consumed upon successful completion.") )
        newitem:giveto(p)
        return newitem
    else
        loot:cachedigkey(level, biomeid, kobold.player[p])
    end
end


-- generates loot missiles around x,y and automates rarity selection.
function loot:generatelootpile(x, y, count, _p)
    local oddsmod = 0
    local minrarity, maxrarity = rarity_common, rarity_common
    local level = map.mission.cache and map.mission.cache.level or kobold.player[Player(0)].level -- cheap hack for dev testing NOTE: how to fix for multiplayer?
    if level > 10 then
        maxrarity = rarity_rare
    elseif level > 30 then
        maxrarity = rarity_epic
    elseif level > 50 then
        maxrarity = rarity_ancient
    end
    if _p then oddsmod = kobold.player[_p]:getlootodds() end
    local rarityid = loot:getrandomrarity(minrarity, maxrarity, oddsmod)
    loot:generatelootmissile(x, y, loot.missile[rarityid], count)
end


function loot:generatelootmissile(x, y, itemid, _count, _distance, _effect, _miseffect)
    local count, xorigin, yorigin = _count or 1, x, y
    local dmy = buffy:create_dummy(Player(PLAYER_NEUTRAL_PASSIVE), x, y, 'h008', 3.0)
    for i = 1,count do
        x,y = utils.projectxy(xorigin, yorigin, _distance or math.random(140,240), math.random(0,360))
        missile:create_arc(x, y, dmy, _miseffect or speff_item.effect, 0, function(mis)
            local item = CreateItem(FourCC(itemid), mis.x, mis.y)
            if loot.missile[FourCC(itemid)] and not _effect then
                orb_prolif_stack[loot.pickup[FourCC(itemid)]]:play(mis.x, mis.y)
            elseif _effect then
                _effect:play(mis.x, mis.y)
            end
            if map.manager.activemap then
                utils.timed(30.0, function() RemoveItem(item) end)
            end
        end, 1.0)
    end
end


function loot:collectloot()
    -- highjacked in the candle wax pickup trigger.
    local id = GetItemTypeId(GetManipulatedItem())
    local p  = utils.unitp()
    if loot.pickup[id] then
        if loot.pickup[id] == rarity_ancient then
            loot:generateancient(p, kobold.player[p].level, map.manager.prevbiomeid or map.manager.biome.id, map.manager.prevdiffid or map.manager.diffid)
        else
            loot:generate(p, kobold.player[p].level, loot:getrandomslottype(), loot.pickup[id])
        end
        ArcingTextTag("+"..color:wrap(color.tooltip.good, "Loot"), kobold.player[p].unit)
    end
end


function loot:getancientdmgtype(biomeid)
    -- fetch an appropriate dmgtype id for a biome when rolling ancient affixes.
    return loot.biomedmgtypemap[biomeid][math.random(1,#loot.biomedmgtypemap[biomeid])]
end


function loot:generateancient(p, level, _biomeid, _diffid, _ancientid)
    local biomeid = _biomeid or math.random(1,5)
    if not loot:isbagfull(p) then
        if #loot.ancient.biomes[biomeid] > 0 then
            local ancientid     = _ancientid or loot.ancient.biomes[biomeid][math.random(1, #loot.ancient.biomes[biomeid])]
            local slotid        = loot.ancienttable[ancientid].slotid
            local newitem       = self.item:new(loot.ancienttypes[ancientid], p)
            if _diffid and _diffid > 3 then
                -- modifierids: 4 == vicious item, 5 == tyrannical item.
                newitem.modifierid  = _diffid
            end
            newitem.ancientid   = ancientid
            newitem.rarity      = loot.raritytable[rarity_ancient]
            newitem.level       = level
            if slotid ~= slot_candle and slotid ~= slot_artifact and slotid ~= slot_backpack and math.random(1,100) < 33 then
                newitem:addelementaffix(loot:getancientdmgtype(biomeid), kw_type_prefix)
                newitem:addelementaffix(loot:getancientdmgtype(biomeid), kw_type_suffix)
                newitem:addelementaffix(loot:getancientdmgtype(biomeid), kw_type_typemod)
            else
                newitem:addrandomaffix(3)
            end
            newitem:addsecondary(true)
            -- enhancements - ancients on vicious/ tyrannical are 3.5perc/7perc stronger (matching elementalist quality on diffid 5):
            newitem.sellsfor = math.ceil(math.random(newitem.level^0.90,newitem.level^1.05)*newitem.rarity.sellfactor*1.1)
            if slotid == slot_potion or slotid == slot_artifact or slotid == slot_backpack or slotid == slot_tool or slotid == slot_candle then
                newitem.sellsfor = math.floor(newitem.sellsfor*1.15)
            end
            if _diffid and _diffid > 3 then
                for kwt,roll in pairs(newitem.kw_roll) do
                    newitem.kw_roll[kwt] = math.random(math.floor(newitem.kw_roll[kwt]*(1+((_diffid-3)*0.035))),math.floor(newitem.kw_roll[kwt]*(1+((_diffid-3)*0.035))))
                end
            end
            -- build description:
            newitem:buildancientname(ancientid, _diffid)
            newitem:giveto(p)
            return newitem
        end
    else
        loot:cacheancient(kobold.player[p], level, biomeid, _diffid, _ancientid)
    end
end


function loot.item:buildancientname(ancientid, _diffid)
    self:buildname()
    if _diffid and _diffid > 3 then
        self.fullname = color:wrap(color.tooltip.alert, loot.ancienttable[ancientid].fullname)..self.namedetails.." "..loot.ancient.diffnames[_diffid]
    else
        self.fullname = color:wrap(color.tooltip.alert, loot.ancienttable[ancientid].fullname)..self.namedetails
    end
    self.descript = self.descript..'|n'..color:wrap(color.rarity.ancient, 'Ancient Power:')..'|n'..loot.ancienttable[ancientid].descript
end


function loot:getrandomrarity(min, max, oddsmod)
    -- @oddsmod = treasure find modifier (each point = +0.25 chance of rarer items)
    local rid = min
    for id = max,min,-1 do
        if math.random(0, 10000) <= rarity_odds[id] + oddsmod then
            rid = id
            break
        end
    end
    return rid
end


function loot:getrandomslottype()
    -- this will grab a random slotid
    return slot_all_t[math.random(1,#slot_all_t)]
end


function loot:getitemtypebylvl(slotid, level)
    -- this will pull a random item from the slottype table.
    local r
    for id = #loot.itemtable[slotid],1,-1 do
        if level >= loot.itemtable[slotid][id].ilvl then
            r = loot.itemtable[slotid][id]
            break
        end
    end
    return r
end


function loot:cacheloot(ilvl, slotid, rarityid, pobj)
    -- cache randomly generated loot if bags are full.
    pobj.tcache[#pobj.tcache+1] = function() loot:generate(pobj.p, ilvl, slotid, rarityid) end
    -- utils.palert(pobj.p, "Your bags are full! Free up space to claim from your inventory.", 5.0)
    if pobj.p == utils.localp() then kui.canvas.game.inv.tcache:show() end
end


function loot:cachedigkey(ilvl, biomeid, pobj)
    -- cache randomly generated loot if bags are full.
    pobj.tcache[#pobj.tcache+1] = function() loot:generatedigkey(pobj.p, ilvl, biomeid) end
    -- utils.palert(pobj.p, "Your bags are full! Free up space to claim from your inventory.", 5.0)
    if pobj.p == utils.localp() then kui.canvas.game.inv.tcache:show() end
end


function loot:cacheancient(pobj, level, _biomeid, _diffid, _ancientid)
    -- cache randomly generated loot if bags are full.
    pobj.tcache[#pobj.tcache+1] = function() loot:generateancient(pobj.p, level, _biomeid, _diffid, _ancientid) end
    -- utils.palert(pobj.p, "Your bags are full! Free up space to claim from your inventory.", 5.0)
    if pobj.p == utils.localp() then kui.canvas.game.inv.tcache:show() end
end


function loot:slot(id)
    return loot.slottable[id]
end


function loot:debugprint()
    for i = 1,loot.invmax do
        print(kobold.player[Player(0)].inv[i])
    end
end


function loot.item:init()
    self.sellsfor = 0
    self.__index  = self
end


function loot.item:new(itemtype, p)
    -- the player's actual item object.
    local o    = {}
    o.diffid   = 0                  -- if earned on a difficulty that adds stats, 0 = none.
    o.kw       = {}                 -- array of keyword ids for looking up named strings, etc.
    o.kw_roll  = {}                 -- randomized calcs of keyword attachment values.
    o.owner    = p                  -- 
    o.itemtype = itemtype           -- base item, also controls slottype by default.
    o.slottype = itemtype.slottype  -- lazy inherit for context usage.
    o.name     = itemtype.name      -- *unmodified root itemtype name.
    o.fullname = itemtype.name      -- *modified full name upon generation (apply keywords).
    o.level    = itemtype.level     -- inherited item level.
    o.descript = ""                 -- built based on keyword array.
    o.modifierid = 0                -- modifies name in specific ways (diffid, crafted, etc.).
    loot:updateallrarityicons(p)
    setmetatable(o,self)
    return o
end


function loot.item:buildname()
    self:mergedupstats()
    -- build header if affixes exist:
    if self.kw[kw_type_typemod] or self.kw[kw_type_prefix] or self.kw[kw_type_suffix] then
        self.descript = 
            self.descript
            ..color:wrap(color.txt.txtdisable, "Primary Bonus:|n")
    end
    -- prepend type mod to item name:
    if self.kw[kw_type_typemod] then
        self.fullname = self.kw[kw_type_typemod].name.." "..self.fullname
    end
    -- prepend prefix to item name:
    if self.kw[kw_type_prefix] then
        self.fullname = self.kw[kw_type_prefix].name.." "..self.fullname
        if self.kw_roll[kw_type_prefix] then
            self.descript = 
                self.descript
                ..color:wrap(self.kw[kw_type_prefix].statmod.modcol, self.kw[kw_type_prefix].statmod.moddir
                ..self.kw_roll[kw_type_prefix]..self.kw[kw_type_prefix].statmod.modsym)
                .." "..self.kw[kw_type_prefix].statmod.name.."|n"
        end
    end
    -- append suffix to item name:
    if self.kw[kw_type_suffix] then
        self.fullname = self.fullname.." "..self.kw[kw_type_suffix].name
        if self.kw_roll[kw_type_suffix] then
            self.descript = 
                self.descript
                ..color:wrap(self.kw[kw_type_suffix].statmod.modcol, self.kw[kw_type_suffix].statmod.moddir
                ..self.kw_roll[kw_type_suffix]..self.kw[kw_type_suffix].statmod.modsym)
                .." "..self.kw[kw_type_suffix].statmod.name.."|n"
        end
    end
    -- add typemod description last for perc bonus ordering:
    if self.kw[kw_type_typemod] then
        if self.kw_roll[kw_type_typemod] then
            self.descript = 
                self.descript
                ..color:wrap(self.kw[kw_type_typemod].statmod.modcol, self.kw[kw_type_typemod].statmod.moddir
                ..self.kw_roll[kw_type_typemod]..self.kw[kw_type_typemod].statmod.modsym)
                .." "..self.kw[kw_type_typemod].statmod.name.."|n"
        end
    end
    if self.kw[kw_type_secondary] then
        self.descript = 
            self.descript
            ..color:wrap(color.txt.txtdisable, "|nSecondary Bonus:|n")
        if self.kw_roll[kw_type_secondary] then
            self.descript = 
                self.descript
                ..color:wrap(self.kw[kw_type_secondary].statmod.modcol, self.kw[kw_type_secondary].statmod.moddir
                ..self.kw_roll[kw_type_secondary]..self.kw[kw_type_secondary].statmod.modsym)
                .." "..self.kw[kw_type_secondary].statmod.name.."|n"
        end
    end
    if self.kw[kw_type_epic] then
        self.descript = 
            self.descript
            ..color:wrap(color.txt.txtdisable, "|nEpic Bonus:|n")
        if self.kw_roll[kw_type_epic] then
            self.descript = 
                -- because of a dumb gsub percent escape quirk, concat double percent symbol.
                self.descript
                ..string.gsub(string.gsub(string.gsub(self.kw[kw_type_epic].statmod.descript, "(#v)",
                    color:wrap(self.kw[kw_type_epic].statmod.modcol, 
                        self.kw_roll[kw_type_epic]..(self.kw[kw_type_epic].statmod.modsym..self.kw[kw_type_epic].statmod.modsym))),
                    "(#perc)", "%%%%"), "(%)", "" )
        end
    end
    if self.kw[kw_type_potion] then
        self.descript = 
            self.descript
            ..color:wrap(color.txt.txtdisable, "|nPotion Bonus:|n")
        if self.kw_roll[kw_type_potion] then
            self.descript = 
                self.descript
                ..string.gsub(string.gsub(string.gsub(self.kw[kw_type_potion].statmod.descript, "(#v)",
                    color:wrap(self.kw[kw_type_potion].statmod.modcol, 
                        self.kw_roll[kw_type_potion]..(self.kw[kw_type_potion].statmod.modsym..self.kw[kw_type_potion].statmod.modsym))),
                    "(#perc)", "%%%%"), "(%)", "" )
        end
    end
    self.namedetails = "|n"
            ..color:wrap(self.rarity.color, self.rarity.name).."|n"
            ..color:wrap(color.txt.txtdisable, self.itemtype.slottype.name)
    self.fullname = color:wrap(color.tooltip.alert, self.fullname..self.namedetails)

    -- merge item modifier tags:
    if self.modifierid == 1 then
        self.fullname = self.fullname..color:wrap(color.ui.gold, " (Crafted)")
    elseif self.modifierid == 2 then
        self.fullname = self.fullname..color:wrap(color.ui.xp, " (Crafted)")
    end
end


-- @p         = triggering player.
-- @selslotid = selected inv space.
-- @tarslotid = target inv space.
function loot.item:slotswap(p, selslotid, tarslotid)
    -- if the target slot is empty:
    if kobold.player[p].items[selslotid] and kobold.player[p].items[tarslotid] == nil then
        if selslotid < 1000 and tarslotid < 1000 then
            if p == utils.localp() then
                kui.canvas.game.inv.space[tarslotid].icon:setbgtex(kobold.player[p].items[selslotid].itemtype.icon)
                kui.canvas.game.inv.space[selslotid].icon:setbgtex(kui.tex.invis)
            end
            kobold.player[p].items[tarslotid] = kobold.player[p].items[selslotid] -- move to target slot
            kobold.player[p].items[selslotid] = nil -- clear original slot
        end
    end
    loot:updateallrarityicons(p)
end


function loot.item:unequip(p, _slotid)
    local sid = _slotid or kobold.player[p].selslotid
    if not loot:isbagfull(p) then
        if not map.manager.loading and not map.manager.activemap and kobold.player[p].items[sid] then
            local snd
            utils.debugfunc(function() kobold.player[p].items[sid]:equipstats(p, false) end, "equipstats")
            utils.debugfunc(function() kobold.player[p].items[sid]:giveto(p) end, "giveto")
            kobold.player[p].items[sid] = nil
            if sid == slot_digkey then
                snd = kui.sound.panel[5].open
                kui.canvas.game.dig.space[sid].icon:setbgtex(kui.tex.invis)
                kui.canvas.game.dig.digkeyglow:hide()
                kui.canvas.game.dig.boss:hide()
            else
                snd = kui.sound.panel[3].open
                kui.canvas.game.equip.space[sid].icon:setbgtex(kui.tex.invis)
            end
            if p == utils.localp() then
                if sid == slot_digkey then
                    kui.canvas.game.dig.pane:hide()
                else
                    kui.canvas.game.equip.pane:hide()
                end
                utils.playsound(snd, p)
            end
        else
            if map.manager.loading or map.manager.activemap then
                utils.palert(p, "You cannot change items during a dig!")
            end
        end
    else
        utils.palert(p, "Cannot unequip because your inventory is full!")
    end
    loot:updateallrarityicons(p)
end


function loot.item:equip(p, _slotid)
    local sid = _slotid or kobold.player[p].selslotid -- currently selected item id.
    local eid = kobold.player[p].items[sid].slottype.slotid -- equipment slot id targeted for equipping.
    if kobold.player[p].level >= kobold.player[p].items[sid].level then
        if not map.manager.loading and not map.manager.activemap then
            if kobold.player[p].items[eid] == nil then -- nothing already equipped
                if p == utils.localp() then
                    if eid == slot_digkey then -- dig site key
                        kui.canvas.game.dig.space[eid].icon:setbgtex(kobold.player[p].items[sid].itemtype.icon)
                        -- kui.canvas.game.dig:show()
                        kui.canvas.game.dig.digkeyglow:show()
                        kui.canvas.game.dig.boss:setfp(fp.c, fp.c, kui.canvas.game.dig.card[kobold.player[p].items[sid].biomeid].bd, -kui:px(8), -kui:px(10))
                        kui.canvas.game.dig.boss:show()
                    else
                        kui.canvas.game.equip.space[eid].icon:setbgtex(kobold.player[p].items[sid].itemtype.icon)
                    end
                    kui.canvas.game.inv.space[sid].icon:setbgtex(kui.tex.invis)
                    kui.canvas.game.inv.pane:hide()
                    utils.playsound(kui.sound.panel[3].close)
                end
                kobold.player[p].items[sid]:equipstats(p, true)
                kobold.player[p].items[eid] = kobold.player[p].items[sid] -- move to target slot
                kobold.player[p].items[sid] = nil -- clear original slot
                kobold.player[p].selslotid  = nil
            else -- swap with an equipped item
                local equippeditem = kobold.player[p].items[eid] -- the item already equipped.
                if p == utils.localp() then
                    if eid == slot_digkey then -- dig site key
                        kui.canvas.game.dig.space[eid].icon:setbgtex(kobold.player[p].items[sid].itemtype.icon)
                        -- kui.canvas.game.dig:show()
                        kui.canvas.game.dig.digkeyglow:show()
                        kui.canvas.game.dig.boss:setfp(fp.c, fp.c, kui.canvas.game.dig.card[kobold.player[p].items[sid].biomeid].bd, -kui:px(8), -kui:px(10))
                        kui.canvas.game.dig.boss:show()
                    else
                        kui.canvas.game.equip.space[eid].icon:setbgtex(kobold.player[p].items[sid].itemtype.icon)
                    end
                    kui.canvas.game.inv.space[sid].icon:setbgtex(equippeditem.itemtype.icon)
                    kui.canvas.game.inv.pane:hide()
                    utils.playsound(kui.sound.panel[3].close)
                end
                kobold.player[p].items[eid]:equipstats(p, false) -- remove prev equip stats
                kobold.player[p].items[sid]:equipstats(p, true)  -- add new item stats
                kobold.player[p].items[eid] = kobold.player[p].items[sid] -- equipped becomes selected item
                kobold.player[p].items[sid] = equippeditem -- selected item becomes equipped
                kobold.player[p].selslotid  = nil
            end
            kobold.player[p]:updatecastspeed()
        else
            utils.palert(p, "You cannot change items during a dig!")
        end
    else
        utils.palert(p, "You do not meet that item's level requirement")
    end
    loot:updateallrarityicons(p)
end


-- this will automatically pick up the player's selected item in inventory unless @_selslotid is passed to override (i.e. external logic, sorting, etc.)
function loot.item:sell(p, _sndsuppress, _selslotid)
    local sid = _selslotid or kobold.player[p].selslotid
    if kobold.player[p].items[sid].itemtype.slottype.slotid ~= slot_digkey then
        local p     = p
        local total = kobold.player[p].items[sid].sellsfor*(1+kobold.player[p][p_stat_vendor]/100)
        kobold.player[p]:awardgold(total)
        if not _sndsuppress then utils.playsound(kui.sound.sell, p) end
        if p == utils.localp() then
            kui.canvas.game.inv.space[sid].icon:setbgtex(kui.tex.invis)
            kui.canvas.game.inv.pane:hide()
        end
        kobold.player[p].items[sid] = nil
        kobold.player[p].selslotid  = nil
        shop:updateframes(kobold.player[p])
    else
        utils.palert(p, color:wrap(color.tooltip.bad,"You cannot sell dig keys!"))
    end
    loot:updateallrarityicons(p)
end


-- @p    = give to this player
function loot.item:giveto(p)
    -- place loot into a player's inventory
    for slotid = 1,loot.invmax do
        if kobold.player[p].items[slotid] == nil then
            kobold.player[p].items[slotid] = self
            loot_last_slotid               = slotid -- global for easy referencing.
            if p == utils.localp() then
                kui.canvas.game.skill.alerticon[2]:show() -- show new items alert eyecandy on menu button.
                kui.canvas.game.inv.space[slotid].icon:setbgtex(self.itemtype.icon)
            end
            loot:updateallrarityicons(p)
            return true
        end
    end
    return false
end


-- update function for item tooltip on mouseover (used in kui).
function loot.item:updatetooltip(p)
    -- background texture:
    if self.itemtype.slottype.slotid == slot_digkey then
        BlzFrameSetTexture(tooltip.itemtipfh[1], 'war3mapImported\\tooltip-bg_scroll_items_digkey.blp', 0, true)
    else
        BlzFrameSetTexture(tooltip.itemtipfh[1], self.rarity.tooltipbg, 0, true)
    end
    -- icon:
    BlzFrameSetTexture(tooltip.itemtipfh[2], self.itemtype.icon, 0, true)
    -- rarity gem:
    BlzFrameSetTexture(tooltip.itemtipfh[3], self.rarity.icon, 0, true)
    -- name:
    BlzFrameSetText(tooltip.itemtipfh[4], self.fullname)
    -- description:
    BlzFrameSetText(tooltip.itemtipfh[5], self.descript)
    -- level:
    if kobold.player[p].level >= self.level then
        BlzFrameSetText(tooltip.itemtipfh[6], color:wrap(color.txt.txtdisable, "Level "..self.level))
    else -- doesn't meet req.
        BlzFrameSetText(tooltip.itemtipfh[6], color:wrap(color.tooltip.bad, "Level "..self.level))
    end
    -- gold value:
    BlzFrameSetText(tooltip.itemtipfh[7], self.sellsfor)
end


-- update function for item tooltip on mouseover (used in kui).
function loot.item:updatecomptooltip(p)
    -- background texture:
    if self.itemtype.slottype.slotid == slot_digkey then
        BlzFrameSetTexture(tooltip.itemcompfh[1], 'war3mapImported\\tooltip-bg_scroll_items_digkey.blp', 0, true)
    else
        BlzFrameSetTexture(tooltip.itemcompfh[1], self.rarity.tooltipbg, 0, true)
    end
    BlzFrameSetAlpha(tooltip.itemcompfh[1], 230)
    -- icon:
    BlzFrameSetTexture(tooltip.itemcompfh[2], self.itemtype.icon, 0, true)
    -- rarity gem:
    BlzFrameSetTexture(tooltip.itemcompfh[3], self.rarity.icon, 0, true)
    -- name:
    BlzFrameSetText(tooltip.itemcompfh[4], self.fullname)
    -- description:
    BlzFrameSetText(tooltip.itemcompfh[5], self.descript)
    -- level:
    if kobold.player[p].level >= self.level then
        BlzFrameSetText(tooltip.itemcompfh[6], color:wrap(color.txt.txtdisable, "Level "..self.level))
    else -- doesn't meet req.
        BlzFrameSetText(tooltip.itemcompfh[6], color:wrap(color.tooltip.bad, "Level "..self.level))
    end
    -- gold value:
    BlzFrameSetText(tooltip.itemcompfh[7], self.sellsfor)
    BlzFrameSetAlpha(tooltip.itemcompfh[8], 140)
end


function loot.item:mergedupstats()
    if loot.debug then print("running loot.item:mergedupstats for slot:",self.itemtype.slottype.name) end
    if self.itemtype.slottype.slotid ~= slot_digkey and self.kw and utils.tablesize(self.kw) > 1 then
        for kw_id,kw_t in pairs(self.kw) do
            for kw_id2,kw_t2 in pairs(self.kw) do
                if kw_t ~= kw_t2 and kw_t.statmod.id == kw_t2.statmod.id then
                    self.kw_roll[kw_id]  = self.kw_roll[kw_id] + self.kw_roll[kw_id2] -- merge dup values.
                    self.kw[kw_id2]      = nil -- destroy duplicate.
                    self.kw_roll[kw_id2] = nil
                    return
                end
            end
        end
    end
end


function loot.slottype:new(slotid, name)
    -- matches item objects to equipment slots.
    local o  = {}
    o.count  = 0 -- total items that exist for this slot (design tracking).
    o.slotid = slotid
    o.name   = name
    setmetatable(o,self)
    self.__index = self
    return o
end


function loot.itemtype:init()
    -- the base item or root word (e.g. "dagger", "hatchet", "cludgel", "star pendant")
    -- keywords are then applied to this base item.
    self.stack     = {}
    self.__index   = self
end


-- @name        = the name of the item.
-- @slottype    = slot class to control slot label and UI equip location.
-- @icon        = path to icon .blp.
-- @ilvl        = minimum item level.
function loot.itemtype:new(name, slottype, ilvl, icon)
    -- create a new base item type that item objects inherit.
    local o     = {}
    o.name      = name
    o.slottype  = slottype
    o.icon      = icon
    o.ilvl      = ilvl
    o.id        = #self.stack + 1
    self.stack[o.id] = o
    setmetatable(o,self)
    return o
end


function loot.kw:init()
    -- keywords.
    self.__index    = self
    self.stack      = {}
end


-- @id        = kw id.
-- @name      = kw in-game name.
-- @kw_type   = constant: kw_type_prefix, kw_type_typemod, or kw_type_suffix.
-- @statmod   = the player stat to modify.
-- @kw_group  = applicable slots
function loot.kw:new(name, kw_type, statmod, kw_group)
    local o     = {}
    setmetatable(o,self)
    o.name      = name
    o.kw_type   = kw_type -- prefix, typemod, or suffix
    o.statmod   = statmod
    -- build kw lookups:
    for _,slotid in pairs(kw_group) do
        -- place kw in slotid lookup tables (loot generation performance):
        if loot.affixt[kw_type][slotid] then
            loot.affixt[kw_type][slotid][#loot.affixt[kw_type][slotid]+1] = o
        end
        -- place kw in element lookup tables:
        for oreid = 1,6 do
            if utils.tablehasvalue(loot.oret[oreid], statmod.p_stat) then
                -- print("oreid ",oreid," added kw_type ", kw_type, " p_stat ",statmod.p_stat," slotid ", slotid)
                loot.eletable[oreid][kw_type][slotid][#loot.eletable[oreid][kw_type][slotid]+1] = o
            end
        end
    end
    -- store an id for save/load system:
    o.id = #self.stack + 1
    self.stack[o.id] = o
    return o
end


function loot.rarity:init()
    -- the rarity attachment to an item.
    self.iconw     = 24   -- width and height
    self.iconh     = 24
    self.anchor    = fp.c -- point on rarity icon to attach to item icon.
    self.taranchor = fp.b -- point on item icon to attach rarity gem.
    self.__index   = self
end


function loot.rarity:new(id, icon, name)
    local o      = {}
    o.id         = id
    o.icon       = icon
    o.tooltipbg  = nil
    o.name       = name
    o.sellfactor = 1.0 -- added sell value after generation.
    o.maxfactor  = 0.0 -- the minimum roll is increased by this factor amount based on rarity.
    o.rollfactor = 1.0
    o.color      = rarity_color[id]
    setmetatable(o,self)
    return o
end


function loot.statmod:init()
    self.__index    = self
    self.modtype    = modtype_relative
    self.modsym     = "%%"
    self.moddir     = "+"
    self.modcol     = color.tooltip.good
    self.stack      = {}
    self.pstatstack = {}
end


-- @name     = name of the p_stat.
-- @p_stat   = the player stat to modify.
-- @minval   = minimum stat roll value.
-- @maxmult  = max ``.
-- @lvlmult  = total item level multiplier for this stat.
-- @absbool  = [optional] when true, convert from relative perc-based to absolute value.
-- @negbool  = [optional] when true, this statmod is a negative value.
function loot.statmod:new(name, p_stat, minval, maxval, lvlmult, absbool, negbool)
    if type(p_stat) == "number" then
        local o = {}
        setmetatable(o, self)
        o.name    = name
        o.p_stat  = p_stat
        o.minval  = minval
        o.maxval  = maxval
        o.lvlmult = lvlmult * global_statmod_multiplier
        if absbool then
            o.modsym  = ""
            o.modtype = modtype_absolute
        end
        if negbool then
            o.moddir = "-"
            o.modcol = color.tooltip.bad
        end
        o.id = #self.stack + 1
        self.stack[o.id] = o
        self.pstatstack[p_stat] = o -- store statmod lookup by player stat for external features.
        return o
    else
        print("error: statmod:new() was not passed a valid 'p_stat' id; p_stat = "..p_stat)
    end
end


function loot.statmod:newlong(descript, p_stat, minval, maxval, lvlmult, absbool, negbool)
    local o    = loot.statmod:new(descript, p_stat, minval, maxval, lvlmult, absbool, negbool)
    o.long     = true
    o.descript = descript
    o.id       = #self.stack + 1
    self.stack[o.id] = o
    return o
end


-- @p         = for this player.
-- @isaddbool = true to add stats, false to remove stats.
function loot.item:equipstats(p, isaddbool)
    utils.debugfunc(function()
        local statval
        for kw_type,keyword in pairs(self.kw) do
            if self.kw_roll[kw_type] ~= 0 then
                statval = self.kw_roll[kw_type]
                if isaddbool then
                    kobold.player[p]:modstat(keyword.statmod.p_stat, true, statval)
                else
                    kobold.player[p]:modstat(keyword.statmod.p_stat, false, statval)
                end
            end
        end
        -- add ancient id to array of equipped ancient effects for external logic:
        if self.ancientid then
            if isaddbool then -- add ancient id to table.
                badge:earn(kobold.player[p], 6)
                local size = #kobold.player[p].ancients[loot.ancienttable[self.ancientid].eventtype]
                kobold.player[p].ancients[loot.ancienttable[self.ancientid].eventtype][size + 1] = self.ancientid
                loot.ancient:raiseevent(ancient_event_equip, kobold.player[p], true, nil, self.ancientid)
            else -- remove ``.
                if loot.ancienttable[self.ancientid].unequip then loot.ancienttable[self.ancientid].unequip(kobold.player[p]) end
                loot.ancient:raiseevent(ancient_event_equip, kobold.player[p], false, nil, self.ancientid) -- NOTE: keep ABOVE table removal so func can be found first!
                utils.removefromtable(kobold.player[p].ancients[loot.ancienttable[self.ancientid].eventtype], self.ancientid)
            end
        end
        kobold.player[p]:updateallstats()
    end, "equipstats")
end


function loot.item:addrandomaffix(count)
    -- adds a prefix or suffix to an item.
    self.sellsfor = math.floor(self.sellsfor*(1+(count*0.1)))
    if count == 1 then -- pick a prefix or suffix.
        local r = math.random(0,1)
        if r == 1 then
            self:addaffix(kw_type_prefix)
        else
            self:addaffix(kw_type_suffix)
        end
    elseif count == 2 then -- add prefix and suffix.
        self:addaffix(kw_type_prefix)
        self:addaffix(kw_type_suffix)
    elseif count == 3 then
        self:addaffix(kw_type_prefix)
        self:addaffix(kw_type_typemod)
        self:addaffix(kw_type_suffix)
    else
        print("error: addrandomaffix was passed an invalid 'count' or it was nil")
    end
end


function loot.item:addsecondary(_guaranteed)
    -- only add secondary stats on occasion unless @_guaranteed is passed:
    local r = 0
    if not _guaranteed then
        r = math.random(1,100)
    else
        r = 100
    end
    if r > 20 then
        self:addaffix(kw_type_secondary)
    end
end


function loot.item:addrarityaffix(slotid, rarityid)
    if loot.debug then print("loot.item:addrarityaffix: running for slotid",slotid,"rarityid",rarityid) end
    -- only add secondary stats on occasion:
    if rarityid == rarity_epic and (slotid ~= slot_potion and slotid ~= slot_artifact) then
        self:addaffix(kw_type_epic)
    elseif rarityid == rarity_ancient and (slotid ~= slot_potion and slotid ~= slot_artifact) then
        self:addaffix(kw_type_epic)
    elseif (slotid == slot_potion or slotid == slot_artifact) and (rarityid == rarity_rare or rarityid == rarity_epic) then
        self:addaffix(kw_type_potion)
    end
end


function loot.item:addaffix(kw_type)
    if loot.debug then print("loot.item:addaffix: running for kw_type",kw_type) end
    if not self.kw[kw_type] then -- will not override if already exists.
        if #loot.affixt[kw_type][self.slottype.slotid] > 0 then
            local roll = math.random(1,#loot.affixt[kw_type][self.slottype.slotid])
            if loot.debug then print("kw_type "..kw_type.." rolled tableid "..roll) end
            self.kw[kw_type] = loot.affixt[kw_type][self.slottype.slotid][roll]
            self:rollvalue(kw_type, self.rarity)
        end
    elseif loot.debug then
        print("loot.item:addaffix: 'self.kw[kw_type]' not found, no affix added")
    end
end


function loot.item:addelementaffix(oreid, kw_type)
    if #loot.eletable[oreid][kw_type][self.slottype.slotid] > 0 then
        local roll = math.random(1,#loot.eletable[oreid][kw_type][self.slottype.slotid])
        if loot.debug then print("kw_type "..kw_type.." rolled tableid "..roll) end
        self.kw[kw_type] = loot.eletable[oreid][kw_type][self.slottype.slotid][roll]
        self:rollvalue(kw_type, self.rarity)
    end
end


function loot.item:rollvalue(kw_type, rarity)
    if loot.debug then print("trying to add kw_type: "..kw_type) end
    if rarity.id == rarity_common then
        self.kw_roll[kw_type] = 
            math.random(
                self.kw[kw_type].statmod.minval,
                self.kw[kw_type].statmod.maxval)
    else
        self.kw_roll[kw_type] = 
            math.random(
                -- rare and above items always have a guaranteed
                --  roll value as a perc of the max roll possible.
                math.floor(self.kw[kw_type].statmod.maxval*rarity.maxfactor),
                self.kw[kw_type].statmod.maxval)
        -- alongside the max factor, higher rarities
        --  roll higher values in general.
        self.kw_roll[kw_type] = self.kw_roll[kw_type]*rarity.rollfactor
    end
    -- increment the stat value based on item level:
    self.kw_roll[kw_type] = math.ceil(self.kw_roll[kw_type]*(1.0+(self.level*self.kw[kw_type].statmod.lvlmult)))
end
