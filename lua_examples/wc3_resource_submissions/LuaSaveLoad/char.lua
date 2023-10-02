char = {}


--[[
    ------------------
    -------save-------
    ------------------
--]]


function char:init()
    self.__index = self
end


function char:new(player)
    local o         = {}
    setmetatable(o, char)
    o.p             = player
    o.hero_items    = {}
    o.hero_abil     = {}
    o.hero_abil_lvl = {}
    o.hero_attr     = {}
    o.data          = ""
    return o
end


function char:save(player, hero_unit)
    local o             = char:new(player)

    -- save unit metadata:
    if char.save_unit then
        o.hero_id           = get_index_by_value(save_load_hero_ids, GetUnitTypeId(hero_unit))
        if char.save_hero_name then
            o.hero_name     = GetHeroProperName(hero_unit)
        else
            o.hero_name     = "<saved hero>"
        end
        o.hero_unit_name    = GetUnitName(hero_unit)
        o.hero_level        = GetHeroLevel(hero_unit)
        o.hero_xp           = GetHeroXP(hero_unit)
        o.hero_skillups     = GetHeroSkillPoints(hero_unit)
    else
        o.hero_id           = 0
        o.hero_name         = ""
        o.hero_unit_name    = ""
        o.hero_level        = 0
        o.hero_xp           = 0
        o.hero_skillups     = 0
    end

    -- save player data:
    if char.save_gold then
        o.player_gold   = GetPlayerState(o.p, PLAYER_STATE_RESOURCE_GOLD)
    else
        char.save_gold = 0
    end
    if char.save_lumber then
        o.player_lumber = GetPlayerState(o.p, PLAYER_STATE_RESOURCE_LUMBER)
    else
        char.save_lumber = 0
    end
    if char.save_food then
        o.player_food   = GetPlayerState(o.p, char.save_food_state)
    else
        char.save_food = 0
    end

    -- save items:
    if char.save_items then
        for slot = 1,6 do
            local itm = UnitItemInSlot(hero_unit, slot-1)
            if itm then
                o.hero_items[slot] = get_index_by_value(save_load_item_ids, GetItemTypeId(itm))
            end
            if not o.hero_items[slot] then
                o.hero_items[slot] = 0
            end
        end
    else
        for slot = 1,6 do
            o.hero_items[slot] = 0
        end
    end

    -- save abilities and levels:
    if char.save_abils then
        for abil_id,abil_code in ipairs(save_load_abil_ids) do
            if GetUnitAbilityLevel(hero_unit, abil_code) > 0 then
                o.hero_abil[#o.hero_abil+1] = get_index_by_value(save_load_abil_ids, abil_code)
                o.hero_abil_lvl[#o.hero_abil_lvl+1] = GetUnitAbilityLevel(hero_unit, abil_code)
            end
        end
    end

    -- save attributes:
    if char.save_attr then
        o.hero_attr[1]  = GetHeroStr(hero_unit, false)
        o.hero_attr[2]  = GetHeroAgi(hero_unit, false)
        o.hero_attr[3]  = GetHeroInt(hero_unit, false)
    else
        o.hero_attr[1] = 0
        o.hero_attr[2] = 0
        o.hero_attr[3] = 0
    end
    return o
end


function char:save_data()
    -- data clusters to manipulate:

    -- group 1:
    self.metadata = string.sub(self.hero_name, 1, char.name_length_max)..", "..self.hero_unit_name..", Lvl "..tostring(self.hero_level)
    self.metadata = self.metadata.."," -- seed and checksum are added in 'file' class.

    -- group 2:
    self:append_data(self.hero_id, self.hero_level, self.hero_xp, self.hero_skillups, self.player_gold, self.player_lumber, self.player_food)

    -- group 3:
    self.data = self.data.."|"
    self:append_data_table(self.hero_items)

    -- group 4:
    self.data = self.data.."|"
    self:append_data_table(self.hero_abil)

    -- group 5:
    self.data = self.data.."|"
    self:append_data_table(self.hero_abil_lvl)

    -- group 6:
    self.data = self.data.."|"
    self:append_data_table(self.hero_attr)

    return self
end


--[[
    ------------------
    -------load-------
    ------------------
--]]


function char:load_data()
    local pid = pnum(self.p)
    local hero

    -- create unit:
    if char.save_unit then
        udg_save_load_hero[pid] = CreateUnit(self.p, save_load_hero_ids[self.hero_id], char.load_x, char.load_y, char.load_face)
        hero = udg_save_load_hero[pid]
    end

    -- set proper name:
    if char.save_unit and char.save_hero_name and self.hero_name then
        BlzSetHeroProperName(hero, string.sub(self.hero_name, 1, char.name_length_max))
    end

    -- load items:
    if char.save_unit and char.save_items then
        for slot = 1,6 do
            if self.hero_items[slot] and self.hero_items[slot] ~= 0 then
                if save_load_item_ids[self.hero_items[slot]] then
                    UnitAddItem(hero, CreateItem(save_load_item_ids[self.hero_items[slot]], 0, 0))
                elseif is_local(self.p) then
                    print(msg.load_item_error)
                end
            end
        end
    end

    -- set level and hero_attributes:
    if char.save_unit and char.save_attr then
        if char.save_xp then
            AddHeroXP(hero, self.hero_xp, false)
        end
        ModifyHeroSkillPoints(hero, bj_MODIFYMETHOD_SET, 0)
        ModifyHeroSkillPoints(hero, bj_MODIFYMETHOD_ADD, self.hero_skillups)
        SetHeroStr(hero, self.hero_attr[1], true)
        SetHeroAgi(hero, self.hero_attr[2], true)
        SetHeroInt(hero, self.hero_attr[3], true)
    end

    -- add abilities:
    if char.save_unit and char.save_abils then
        for i = 1,#self.hero_abil do
            UnitAddAbility(hero, save_load_abil_ids[self.hero_abil[i]])
            if self.hero_abil_lvl[i] then
                SetUnitAbilityLevel(hero, save_load_abil_ids[self.hero_abil[i]], self.hero_abil_lvl[i])
            end
        end
    end

    -- set player data:
    if char.save_gold and self.player_gold then
        SetPlayerState(self.p, PLAYER_STATE_RESOURCE_GOLD, self.player_gold)
    end
    if char.save_lumber and self.player_lumber then
        SetPlayerState(self.p, PLAYER_STATE_RESOURCE_LUMBER, self.player_lumber)
    end
    if char.save_food and self.player_food then
        SetPlayerState(self.p, char.save_food_state, self.player_food)
    end

    -- wrap-up:
    if char.save_unit then
        SelectUnitForPlayerSingle(hero, self.p)
    end
    if is_local(self.p) then
        print(msg.on_load)
    end
end


function char:get_load_data(data_table)
    -- read the data groups stored on this char object.
    local d = data_table

    -- hero name [1]
    self.hero_name     = d[1][1]

    -- hero meta [2]
    self.hero_id       = d[2][1]
    self.hero_level    = d[2][2]
    self.hero_xp       = d[2][3]
    self.hero_skillups = d[2][4]
    self.player_gold   = d[2][5] or 0
    self.player_lumber = d[2][6] or 0
    self.player_food   = d[2][7] or 0

    -- items [3]
    if d[3] and d[3][1] ~= "00" then
        for slot = 1,6 do
            self.hero_items[slot] = d[3][slot]
        end
    end

    -- abilities [4]
    if d[4] and d[4][1] ~= "00" then
        for slot = 1,#d[4] do
            self.hero_abil[slot] = d[4][slot]
        end
    end

    -- ability levels [5]
    if d[5] and d[5][1] ~= "00" then
        for slot = 1,#d[5] do
            self.hero_abil_lvl[slot] = d[5][slot]
        end
    end

    -- attributes [6]
    self.hero_attr[1]  = d[6][1]
    self.hero_attr[2]  = d[6][2]
    self.hero_attr[3]  = d[6][3]

    d = nil
end


--[[
    ---------------------
    -------helpers-------
    ---------------------
--]]


function char:get_xp(level)
    -- *note: gave up on trying to use this and defaulted to XP value, but it's here
    -- if you want to try and work it in.
    -- credit: TriggerHappy's Codeless Save/Load (SaveHelper)
    local xp = char.xp_level_factor -- level 1
    local i = 1
    while level < i do
        xp = (xp*char.xp_prev_value_factor) + (i+1)*char.xp_level_factor
        i = i + 1
    end
    return xp - char.xp_level_factor
end


function char:append_data(...)
    for i,v in ipairs({...}) do
        self.data = self.data..tostring(v)..","
    end
    self.data = purge_last(self.data, ",")
end


function char:append_data_table(t)
    if t and t[1] then
        for i,v in ipairs(t) do
            self.data = self.data..tostring(v)..","
        end
        self.data = purge_last(self.data, ",")
    else
        self.data = self.data.."00"
    end
end
