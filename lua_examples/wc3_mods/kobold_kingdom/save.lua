char = {}
char.__index = char
--
char.newseed = "1252222224111111253412555555451234512341235444444234" -- code won't load properly if tinkered with. our encrypt is very dumb, can't have a value over 5.
--
char.abil     = {
    [1] = "AHhb",
    [2] = "AHds",
    [3] = "AHre",
    [4] = "AHad",
    [5] = "AHtc",
    [6] = "AHtb",
    [7] = "AHbh",
    [8] = "AHav",
    [9] = "AHfs",
    [10] = "AHbn",
    [11] = "AHdr",
    [12] = "AHpx",
    [13] = "AHbz",
    [14] = "AHab",
    [15] = "AHwe",
    [16] = "AHmt",
    [17] = "AOsh",
    [18] = "AOae",
    [19] = "AOre",
    [20] = "AOws",
}
char.charcode = {
    [1] = 'H000',   -- tunneler.
    [2] = 'H00E',   -- geomancer.
    [3] = 'H00G',   -- rascal.
    [4] = 'H00F',   -- wickfighter.
}


-- creates a new object representing a character (for all saving/loading; initialized on init for all players).
function char:new(p)
    local o = {}
    setmetatable(o, self)
    o.data = {}
    o.pobj = kobold.player[p]
    return o
end


-- updates a char object to save an existing character.
function char:new_save()
    self.data      = {}
    -- data strings:
    self:build_save_data()
    self:build_meta_string()
    self:build_equip_string()
    self:build_inv_string()
    self:build_mast_string()
    self:build_full_string()
    return self
end


--[[
    
    ----------------------------------------------------------------
    ------------------------ SAVE FUNCTIONS ------------------------ 
    ----------------------------------------------------------------
    
--]]


function char:save_character()
    -- existing slot already loaded, automate the overwrite:
    if self.fileslot then
        local fileslot = self.fileslot
        self:new_save()
        self.fileslot = fileslot
        self:build_char_file(self.pobj.p)
    -- see if a slot is already free:
    else
        local emptyslotfound = false
        for fileslot = 1,4 do
            if not self.pobj.hasfile[fileslot] then
                -- found a file, initiate save:
                self:new_save()
                self.fileslot = fileslot
                self:build_char_file(self.pobj.p)
                emptyslotfound = true
                break
            end
        end
        if not emptyslotfound then
            utils.palert(self.pobj.p, "No slots available!|nSelect one to delete", 3.0)
            if self.pobj:islocal() then
                kui:closeall()
                kui.canvas.game.overwrite:show()
            end
        end
    end
end


function char:build_meta_string()
    self.data.meta = self.pobj.charid.."|"..self.pobj.level.."|"..self.pobj.experience.."|"
        ..self.pobj[p_stat_strength].."|"..self.pobj[p_stat_wisdom].."|"..self.pobj[p_stat_alacrity].."|"..self.pobj[p_stat_vitality].."|"
        ..self.pobj.gold.."|"
    for oreid = 1,6 do
        self.data.meta = self.data.meta..self.pobj.ore[oreid].."|"
    end
    self.data.meta = self.data.meta..self.pobj.attrpoints.."|"..self.pobj.mastery.points.."|"..quests_total_completed.."|"..self.pobj.ancientfrag
    -- store abilities:
    self.data.abil = ""
    -- store main skills:
    for row = 1,3 do
        for col = 1,4 do
            if self.pobj.ability.map[row][col] then
                self.data.abil = self.data.abil..row.."/"..col..","
            end
        end
    end
    self.data.abil = utils.purgetrailing(self.data.abil, ",").."|"
    -- store mastery skills:
    if self.pobj.ability.savedmastery then
        for slot = 1,4 do
            if self.pobj.ability.savedmastery[slot] then
                self.data.abil = self.data.abil..self.pobj.ability.savedmastery[slot]..","
            else
                self.data.abil = self.data.abil.."empty,"
            end
        end
    end
    self.data.abil = utils.purgetrailing(self.data.abil, ",")
    self.data.abil = utils.purgetrailing(self.data.abil, "|") -- if empty mastery, purge empty field.
    self.data.meta = self.data.meta.."|"..self.data.abil
    return self.data.meta
end


function char:build_mast_string()
    self.data.mast = ""
    for row = 1,self.pobj.mastery.nodemaxy do
        for col = 1,self.pobj.mastery.nodemaxx do
            self.data.mast = self.data.mast..utils.booltobit(self.pobj.mastery[row][col])
        end
        self.data.mast = self.data.mast..","
    end
    self.data.mast = utils.purgetrailing(self.data.mast, ",")
    return self.data.mast
end


function char:build_equip_string()
    self.data.equip = ""
    for slotid = 1001,1011 do
        if self.pobj.items[slotid] then
            self.data.equip = self.data.equip..self:build_item_string(self.pobj.items[slotid])
        end
    end
    self.data.equip = utils.purgetrailing(self.data.equip, ",")
    return self.data.equip
end


function char:build_inv_string()
    self.data.inv = ""
    for slotid = 1,42 do
        if self.pobj.items[slotid] then
            self.data.inv = self.data.inv..self:build_item_string(self.pobj.items[slotid])
        end
    end
    self.data.inv = utils.purgetrailing(self.data.inv, ",")
    return self.data.inv
end


function char:build_item_string(item)
    -- structure: 'itemtypeid|ilvl|sellsfor|modifierid|kwid=kwroll[/kwid2=kwroll2.../kwid3=kwroll3...]'
    local str = ""
    str = str..item.itemtype.id.."|"
    str = str..item.level.."|"
    str = str..item.sellsfor.."|"
    str = str..item.modifierid.."|"
    str = str..item.rarity.id.."|"
    -- gather kw ids, statmod ids, rolled values:
    if utils.tablesize(item.kw) > 0 then
        for kw_type,kw in pairs(item.kw) do
            str = str..kw.id.."="..item.kw_roll[kw_type].."/"
        end
    else
        str = utils.purgetrailing(str, "|") -- purge kw field delimiter since empty.
    end
    str = utils.purgetrailing(str, "/")
    str = str..","
    return str
end


function char:build_full_string()
    self.data.full = self.data.save.."*"..self.data.meta.."*"..self.data.equip.."*"..self.data.inv.."*"..self.data.mast
    return self.data.full
end


function char:build_save_data()
    self.data.save = kui.meta.charname[self.pobj.charid].."|"..self.newseed
end


--[[
    
    ----------------------------------------------------------------
    ------------------------ FILE FUNCTIONS ------------------------ 
    ----------------------------------------------------------------

--]]


function char:build_char_file(p)
    char:reset_abils()
    -- because of the stupid 259 character limit in a preload line, we must break each string into groups.
    PreloadGenClear()
    PreloadGenStart()
    local chunk_size  = 200
    local pos, posend = 0, 0
    local chunk_count = math.ceil(string.len(self.data.full)/chunk_size)
    self.data.full = char:basic_encrypt(char.newseed, self.data.full, true)
    if chunk_count > 1 then
        for chunk = 1,chunk_count do
            pos = 1 + ((chunk-1)*chunk_size)
            posend = chunk*chunk_size
            if chunk < chunk_count then -- no chunk validation indicator.
                Preload("\")\ncall BlzSetAbilityTooltip('"..char.abil[chunk].."',\""..string.sub(self.data.full, pos, posend).."\",".."0"..")\n//")
            elseif chunk == chunk_count then
                Preload("\")\ncall BlzSetAbilityTooltip('"..char.abil[chunk].."',\""..string.sub(self.data.full, pos, posend).."\",".."0"..")\nreturn//")
            end
        end
    else
        -- we should rarely need this:
        Preload("\")\ncall BlzSetAbilityTooltip('"..char.abil[1].."',\""..self.data.full.."\",".."0"..")\nreturn//")
    end
    PreloadGenEnd("KoboldKingdom\\char"..tostring(self.fileslot)..".txt")
    if p then
        utils.palert(p, "Character Saved!", 2.0, true)
    end
    -- save badges:
    utils.timed(0.06, function()
        badge:save_data(kobold.player[p])
    end)
end


function char:read_file(fileslot)
    -- reads a file into ability tooltips.
    self:reset_abils()
    utils.timed(0.06,function()
        -- sometimes tooltips don't update in time (unknown cause). so we add a delay:
        PreloadStart()
        Preload("")
        Preloader("KoboldKingdom\\char"..tostring(fileslot)..".txt")
        Preload("")
        PreloadEnd(0.0)
    end)
    return true
end


function char:delete_file(fileslot)
    PreloadGenClear()
    PreloadGenStart()
    Preload("")
    PreloadGenEnd("KoboldKingdom\\char"..tostring(fileslot)..".txt")
    utils.palert(self.pobj.p, "Character Deleted!", 3.0, true)
    self.pobj.hasfile[fileslot] = false
end


function char:validate_fileslots()
    -- sees which files have data to enable UI selection in main menu.
    if not self.pobj.hasfile then self.pobj.hasfile = {} end
    for fileslot = 1,4 do
        utils.timed(fileslot*0.21, function()
            self:read_file(fileslot)
            utils.timed(0.16, function()
                utils.debugfunc(function()
                    local tempdata = self:get_file_data()
                    self.pobj.hasfile[fileslot] = true
                    for i = 1,5 do
                        if not tempdata[i] then
                            self.pobj.hasfile[fileslot] = false
                            break
                        end
                    end
                    if self.pobj.hasfile[fileslot] then
                        local savedata      = self:load_savedata(tempdata[1])
                        local metadata      = self:load_metadata(tempdata[2], true)
                        local charname      = savedata[1]
                        local charid        = tonumber(metadata[1])
                        local charlevel     = tonumber(metadata[2])
                        kui.canvas.splash.options.loadbtn.btn.disabled = false
                        kui.canvas.splash.options.loadbtn:setnewalpha(255)
                        kui.canvas.splash.loadmf.char[fileslot]:setbgtex(kui.tex.char[charid].selectchar)
                        kui.canvas.splash.loadmf.char[fileslot]:show()
                        kui.canvas.splash.loadmf.char[fileslot].txt:settext(
                            color:wrap(color.tooltip.alert, charname).."|nLevel "..color:wrap(color.tooltip.good, charlevel)
                        )
                        kui.canvas.game.overwrite.delete[fileslot].txt:settext(
                            "Slot "..fileslot.." | "..color:wrap(color.tooltip.alert, charname).."| Level "..color:wrap(color.tooltip.good, charlevel)
                        )
                        savedata = nil
                    end
                    tempdata = nil
                end, "file validation timer")
            end)
        end)
    end
end


function char:get_file_data()
    -- gets data from loaded file and returns it as a table (also stores as self.dataload)
    local datastr, d = "", ""
    for _,abilid in ipairs(char.abil) do
        d = BlzGetAbilityTooltip(FourCC(abilid), 0)
        if d ~= "_" then
            datastr = datastr..d
        end
    end
    local decrypted = char:basic_encrypt(char.newseed, datastr, false)
    self.dataload = utils.split(decrypted, "*")
    char:reset_abils()
    return self.dataload
end


function char:load_character()
    -- builds a character from the loaded file data.
    self.pobj.isloading = true
    utils.timed(0.06, function()
        self:build_loaded_string()
    end)
end


function char:print_data()
    for i,v in ipairs(self.dataload) do
        print("data",i,"=",v)
    end
end


function char:reset_abils()
    for _,abilid in ipairs(char.abil) do
        BlzSetAbilityTooltip(FourCC(abilid), "_", 0)
    end
end


function char:basic_encrypt(seed, str, isencrypt)
    -- does the dumbest encrypt ever to discourage players from doing weird stuff to files on a whim.
    local bytes, bytesmin, bytesmax = 0, 38, 126
    local spos, opos  = 1, 1
    local smax, omax  = string.len(seed), string.len(str)
    local nstr, ochar  = "", ""
    for i = 1,omax do
      ochar = string.sub(str, opos, opos)
      bytes = string.byte(ochar)
      bytesoff = tonumber(string.sub(seed, spos, spos))
      if isencrypt then
        bytes = bytes - bytesoff
      else
        bytes = bytes + bytesoff
      end
      spos  = spos + 1
      opos  = opos + 1
      if spos > smax then
          spos = 1
      end
      nstr  = nstr..string.char(bytes)
    end
    return nstr
end


--[[
    
    ----------------------------------------------------------------
    ------------------------ LOAD FUNCTIONS ------------------------ 
    ----------------------------------------------------------------

--]]


function char:build_loaded_string()
    -- merge all chunk data together and build categorical table.
    local data = self:get_file_data()
    -- split each data group into workable rows:
    -- validate ordered data:
    for i = 1,5 do
        if not data[i] or data[i] == "" then
            data[i] = nil
        end
    end
    self:load_loaded_string(data)
end


function char:load_loaded_string(data)
    -- iterate through load steps.
    local sequence = {}
    sequence[#sequence + 1] = function() if data[1] then self:load_savedata(data[1]) end end
    sequence[#sequence + 1] = function() if data[2] then self:load_metadata(data[2]) end end
    sequence[#sequence + 1] = function() if data[3] then self:load_equipment(data[3]) end end
    sequence[#sequence + 1] = function() if data[4] then self:load_inventory(data[4]) end end
    sequence[#sequence + 1] = function() if data[5] then self:load_mastery(data[5]) utils.restorestate(self.pobj.unit) end end
    sequence[#sequence + 1] = function() badge:sync_past_achievements(self.pobj) end
    sequence[#sequence + 1] = function() self:load_wrapup() end
    for i = 1,#sequence do
        utils.timed(0.35*i, function() utils.debugfunc(function() sequence[i]() end, "load_loaded_string, function"..tostring(i)) end)
    end
end


function char:load_savedata(str)
    -- field map: charname, code version
    local t = utils.split(str, "|")
    self.seed = t[2]
    return t
end


function char:load_equipment(str)
    local t = utils.split(str, ",")
    for i,itemstr in ipairs(t) do
        self:load_item(itemstr, true)
    end
    utils.timed(10.0, function() t = nil end) -- because we do a delay for sync'd data, do a hacky wait before cleanup.
end


function char:load_inventory(str)
    local t = utils.split(str, ",")
    for i,itemstr in ipairs(t) do
        self:load_item(itemstr, false)
    end
    t = nil
end


function char:load_item(str, _isequip)
    -- field map: itemtype.id, level, sellsfor, rarityid, modifierid
    -- @_isequip = build in slot 1 and then equip the item (equipped item was saved).
    -- e.g. 58|15|26|0|1=11/3=3
    local t       = utils.split(str, "|")
    local kw_type, kw_id = 0, 0
    -- rebuild base item:
    local itemtypeid    = tonumber(t[1])
    -- see if item is a dig key or normal item:
    if utils.tablehasindex(loot.digkeyt, itemtypeid) then
        loot:generatedigkey(self.pobj.p, 1, loot.digkeyt[itemtypeid])
        if _isequip then
            loot.item:equip(self.pobj.p, 1)
        end
    else
        local newitem       = loot.item:new(loot.itemtype.stack[itemtypeid], self.pobj.p)
        newitem.level       = tonumber(t[2])
        newitem.sellsfor    = tonumber(t[3])
        newitem.modifierid  = tonumber(t[4])
        newitem.rarity      = loot.raritytable[tonumber(t[5])]
        -- fetch kw if present:
        if t[6] and t[6] ~= "" then
            -- kw field map:
            local kwt = utils.split(t[6], "/")
            -- fetch all stored keywords:
            for _,kwdata in ipairs(kwt) do
                -- fetch all kw metadata (id and rolled value):
                local kwv = utils.split(kwdata, "=")
                -- kwv[1] == kw_id; kwv[2] == kw_roll
                kw_id = tonumber(kwv[1])
                kw_type = loot.kw.stack[kw_id].kw_type
                newitem.kw[kw_type] = loot.kw.stack[kw_id]
                newitem.kw_roll[kw_type] = tonumber(kwv[2])
                kwv = nil
            end
            kwt = nil
        end
        if loot.itemtype.stack[itemtypeid].ancientid then
            newitem:buildancientname(loot.itemtype.stack[itemtypeid].ancientid, tonumber(t[4]))
            newitem.ancientid = loot.itemtype.stack[itemtypeid].ancientid
        else
            newitem:buildname()
        end
        newitem:giveto(self.pobj.p)
        if _isequip then
            loot.item:equip(self.pobj.p, 1) -- built in slot 1, so we equip from 1.
        end
    end
    t = nil
end


function char:load_metadata(str, _isread)
    -- field map: charid, level, xp, p_stat_strength, p_stat_wisdom, p_stat_alacrity, p_stat_vitality, gold, ore1, ore2, ore3, ore4, ore5, ore6, attrpoints, masterypoints
    local t = utils.split(str, "|")
    if not _isread then
        self.pobj.loadchar = true
        BlzSendSyncData("classpick", tostring(utils.pnum(self.pobj.p))..t[1]..char.charcode[tonumber(t[1])])
        utils.timed(0.33, function()
            utils.debugfunc(function()
                self.pobj:addlevel(tonumber(t[2])-1, true, true)
                self.pobj:awardxp(tonumber(t[3]))
                self.pobj:modstat(p_stat_strength, true, tonumber(t[4]))
                self.pobj:modstat(p_stat_wisdom,   true, tonumber(t[5]))
                self.pobj:modstat(p_stat_alacrity, true, tonumber(t[6]))
                self.pobj:modstat(p_stat_vitality, true, tonumber(t[7]))
                self.pobj:awardgold(tonumber(t[8]))
                for i = 9,14 do
                    self.pobj.ore[i-8] = tonumber(t[i])
                end
                self.pobj:addattrpoint(tonumber(t[15]))
                self.pobj.mastery:addpoint(tonumber(t[16]))
                self:load_quest_progress(tonumber(t[17]))
                self.pobj:awardfragment(tonumber(t[18]), true)
                self.tempabilstr = t[19] -- mastery and ability data must load at the end, so store in temp fields:
                self.tempmaststr = t[20]
                -----------------------------------------------------------------------------------------
                ------------ post-launch data must go below and be wrapped in 'if' checks ---------------
                -----------------------------------------------------------------------------------------
                t = nil
            end, "set metadata to player")
        end)
    end
    if _isread then
        return t
    end
end


function char:load_abilities(str)
    if str then
        local t = utils.split(str, ",")
        for _,abilstr in ipairs(t) do
            if abilstr then
                local rowcol = utils.split(abilstr, "/")
                self.pobj.ability:learn(tonumber(rowcol[1]), tonumber(rowcol[2]))
                rowcol = nil
            end
        end
        t = nil
    end
end


function char:load_masteries(str)
    if str then
        local t = utils.split(str, ",")
        for _,abilcode in ipairs(t) do
            if abilcode and abilcode ~= "empty" then
                self.pobj.ability:learnmastery(abilcode)
            end
        end
        t = nil
    end
end


function char:load_quest_progress(completedcount)
    quests_total_completed = completedcount
    quest:load_current()
    -- quest vars:
    if completedcount >= 3 then quest_shinykeeper_unlocked = true placeproject('shiny1') if self.pobj:islocal() then quest.socialfr.shinshop:show() end end
    if completedcount >= 4 then quest_elementalist_unlocked = true placeproject('ele1') if self.pobj:islocal() then quest.socialfr.eleshop:show() end end
    if completedcount >= 5 then quest_greywhisker_unlocked = true placeproject('grey1') if self.pobj:islocal() then quest.socialfr.fragshop:show() end end
    if completedcount >= 7 then quest_shinykeeper_upgrade_1 = true placeproject('shiny2') end
    if completedcount >= 8 then quest_elementalist_upgrade_1 = true placeproject('ele2') end
    if completedcount >= 10 then quest_shinykeeper_upgrade_2 = true placeproject('shiny3') end
    if completedcount >= 11 then quest_elementalist_upgrade_2 = true placeproject('ele3') end
    -- boss projects:
    if completedcount >= 6 then placeproject('boss1') if self.pobj:islocal() then shop.gwfr.card[2].icon:show() end end
    if completedcount >= 9 then placeproject('boss2') if self.pobj:islocal() then shop.gwfr.card[3].icon:show() end end
    if completedcount >= 12 then placeproject('boss3') if self.pobj:islocal() then shop.gwfr.card[1].icon:show() end end
    if completedcount >= 14 then placeproject('boss4') placeproject('boss5')
        if self.pobj:islocal() then shop.gwfr.card[4].icon:show() kui.canvas.game.dig.mappiece:show() kui.canvas.game.dig.card[5]:show() end end
    if completedcount >= 15 then shop.gwfr.card[5].icon:show() end
end


function char:load_mastery(str)
    -- field map: each table value = row of bits; array of bits = col
    local t = utils.split(str, ",")
    local colmax = 31
    local nodeid = 0
    for row,datastr in ipairs(t) do
        for col = 1,colmax do
            if tonumber(string.sub(datastr, col, col)) == 1 then
                nodeid = mastery.nodemap[row][col]
                if nodeid == -1 then nodeid = 1 end -- center id hack reversion.
                self.pobj.mastery[row][col] = true
                self.pobj.mastery:verifysurround(self.pobj.mastery:findruneword(row,col))
                mastery:addstat(self.pobj, row, col, nodeid == 2)
                if self.pobj:islocal() then
                    kui.canvas.game.mast.node[row][col]:setbgtex(kui.meta.masterypanel[nodeid].texsel)
                    kui.canvas.game.mast.node[row][col]:setnewalpha(255)
                    kui.canvas.game.mast.node[row][col].icon:setnewalpha(255)
                    if not (col == mastery.centerx and row == mastery.centery) then
                        kui.canvas.game.mast.respec:show()
                    end
                end
            end
        end
    end
    self:load_abilities(self.tempabilstr)
    self:load_masteries(self.tempmaststr)
    self.tempabilstr = nil
    self.tempmaststr = nil
    t = nil
end


function char:load_wrapup()
    -- refresh all UI details that might've been left untouched.
    self.pobj:updateorepane()
    self.pobj:updateallstats()
    shop:updateframes()
    tooltip:updatecharpage(self.pobj.p)
    self.pobj.isloading = nil
    if self.pobj:islocal() then
        kui.canvas.game.char.autoattr:hide()
        for i = 1,4 do
            kui.canvas.game.skill.alerticon[i]:hide()
        end
    end
end
