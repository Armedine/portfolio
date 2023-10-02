file = {}


-- globals:
file.abil = {
    --[[
        These are a grouping of abilities already present in the object editor.
        If desired, they could be changed to any other ability code that is not going
        to be used in your map's gameplay. Their tooltips are set/reset by this system.
    --]]
    [1] = "Agyv",
    [2] = "Ahsb",
    [3] = "Asth",
    [4] = "Asps",
    [5] = "Aslo",
    [6] = "AHta",
    [7] = "Ahrp",
    [8] = "Aply",
    [9] = "Adts",
    [10] = "Amdf",
    [11] = "Ahri",
    [12] = "Aivs",
    [13] = "Ainf",
    [14] = "Ahlh",
    [15] = "Ahea",
    [16] = "Afsh",
    [17] = "Agyb",
    [18] = "Afla",
    [19] = "Aflk",
    [20] = "Afbk",
}
file.stored_tip     = {}
file.in_progress    = false
file.player         = nil
file.data           = ""
file.meta_delimiter = ":"


function file:init()
    file.__index = file
    file.trigger = CreateTrigger()

    -- load trigger:
    for i = 0,23 do
        if GetPlayerSlotState(Player(i)) == PLAYER_SLOT_STATE_PLAYING then
            BlzTriggerRegisterPlayerSyncEvent(file.trigger, Player(i), "LuaSaveLoad", false)
        end
    end
    file:add_sync_action()
    file:get_original_tip()
end


function file:add_sync_action()
    if file.action then
        TriggerRemoveAction(file.trigger, file.action)
        file.action = nil
    end
    file.action = TriggerAddAction(file.trigger, function()
        if BlzGetTriggerSyncPrefix() == "LuaSaveLoad" then
            debug(function()
                file.data = BlzGetTriggerSyncData()
                if file.data ~= "" and file:get_data_table() then
                    if file:validate_current() then
                        local pid = pnum(file.player)
                        if char.save_unit and udg_save_load_hero[pid] then
                            RemoveUnit(udg_save_load_hero[pid])
                            udg_save_load_hero[pid] = nil
                        end
                        local load_char = char:new(file.player)
                        load_char:get_load_data(file.data_table)
                        load_char:load_data()
                        load_char = nil
                    elseif is_local(file.player) then
                        print(msg.no_data_found)
                    end
                elseif is_local(file.player) then
                    print(msg.decrypt_fail)
                end
                file:reset_abils(file.player)
                file.data   = ""
                file.player = nil
            end)
        end
    end)
end


function file:load(player, _file_slot, _timeout)
    local file_slot  = _file_slot or 0
    if file_slot <= file.capacity then
        if not file.in_progress then
            file.player      = player
            local timeout    = _timeout or 0.03
            local pid        = pnum(player)
            file.in_progress = true
            file:reset_abils(player)
            debug(function()
                -- reset file progress if a fatal error occurs using a timeout check:
                timed(timeout, function()
                    if file.in_progress then
                        file.in_progress = false
                        if is_local(player) then
                            print("Load Timeout: Failed to load from file slot "..tostring(file_slot)..". File is corrupt.")
                        end
                    end
                end)
                -- commence load:
                if is_local(player) then
                    Preloader(file.folder.."\\"..file.name..tostring(file_slot)..".pld")
                    if file:read(player) then
                        file:sync()
                    else
                        file.data = ""
                    end
                end
                file.in_progress = false
            end)
        elseif is_local(player) then
            print(msg.on_conflict)
        end
    elseif is_local(player) then
        print(msg.over_capacity)
    end
end


function file:read(player)
    file.data = ""
    local d = ""
    for i,abilid in ipairs(file.abil) do
        d = BlzGetAbilityTooltip(FourCC(abilid), 0)
        if d ~= file.stored_tip[i] then
            file.data = file.data..d
        end
    end
    if file.data and file.data ~= "" then
        return true
    end
    return false
end


function file:get_data_table()
    if file.data_table then
        shallow_destroy(file.data_table)
        file.data_table = nil
    end
    file.data_table     = {}
    local pass, sum     = false, 0
    local t             = split(file.data, file.meta_delimiter)
    local metadata      = split(t[1], ",")
    t[2], pass, sum     = encrypt:basic(t[2], metadata[4], false, tonumber(metadata[5]))
    local chunks        = split(t[2], "|") -- re-insert metadata:
    table.insert(chunks, 1, t[1])
    if pass then
        for i,v in ipairs(chunks) do
            if v ~= "00" then
                file.data_table[i] = split(v, ",")
                -- convert string data to numbers:
                if i > 1 then
                    for i2,v2 in ipairs(file.data_table[i]) do
                        file.data_table[i][i2] = tonumber(v2)
                    end
                end
            else
                file.data_table[i] = {}
            end
        end
    end
    t        = nil
    metadata = nil
    chunks   = nil
    return pass
end


function file:validate_current()
    for grp = 1,file.data_groups do
        if not file.data_table[grp] then
            return false
        end
    end
    return true
end


function file:delete(file_slot)
    PreloadGenClear()
    PreloadGenStart()
    Preload("")
    PreloadGenEnd(file.folder.."\\"..file.name..tostring(file_slot)..".pld")
end


function file:save(player, _file_slot)
    local file_slot = _file_slot or 0
    if file_slot <= file.capacity then
        if not file.in_progress then
            file.in_progress = true
            local seed = ""
            for _ = 1,12 do
                seed = seed..tostring(math.random(1,5)) -- running this locally causes a desync.
            end
            if is_local(player) then
                save_char = char:save(player, udg_save_load_hero[pnum(player)])
                file:reset_abils(player)
                -- because of the 259 character limit in a preload line, we must break each string into groups.
                save_char:save_data()
                local data, _, sum = encrypt:basic(save_char.data, seed, true)
                save_char.metadata = save_char.metadata..seed..","..tostring(sum)..file.meta_delimiter
                local chunk_size, pos, posend  = 200, 0, 0
                local chunk_count = math.ceil(string.len(data)/chunk_size)
                PreloadGenClear()
                PreloadGenStart()
                Preload("\")\ncall BlzSetAbilityTooltip('"..file.abil[1].."',\""..save_char.metadata.."\",".."0"..")\n//")
                if chunk_count > 1 then
                    for chunk = 2,chunk_count do
                        pos = 1 + ((chunk-1)*chunk_size)
                        posend = chunk*chunk_size
                        if chunk < chunk_count then
                            Preload("\")\ncall BlzSetAbilityTooltip('"..file.abil[chunk].."',\""..string.sub(data, pos, posend).."\",".."0"..")\n//")
                        elseif chunk == chunk_count then
                            Preload("\")\ncall BlzSetAbilityTooltip('"..file.abil[chunk].."',\""..string.sub(data, pos, posend).."\",".."0"..")\n//")
                        end
                    end
                else
                    Preload("\")\ncall BlzSetAbilityTooltip('"..file.abil[2].."',\""..data.."\",".."0"..")\n//")
                end
                Preload("\" )\nendfunction\nfunction a takes nothing returns nothing\n //")
                PreloadGenEnd(file.folder.."\\"..file.name..tostring(file_slot)..".pld")
                print(msg.on_save)
                save_char = nil
            end
            seed = nil
            file.in_progress = false
        elseif is_local(player) then
            print(msg.on_conflict)
        end
    elseif is_local(player) then
        print(msg.over_capacity)
    end
end


function file:sync()
    BlzSendSyncData("LuaSaveLoad", file.data)
    file.data = ""
end


function file:reset_abils(player)
    if is_local(player) then
        for i,abilid in ipairs(file.abil) do
            BlzSetAbilityTooltip(FourCC(abilid), file.stored_tip[i], 0)
        end
    end
end


function file:get_original_tip()
    for i,abilid in ipairs(file.abil) do
        file.stored_tip[i] = BlzGetAbilityTooltip(FourCC(abilid), 0)
    end
end


function file:print_abil()
    for i,abilid in ipairs(file.abil) do
        print(BlzGetAbilityTooltip(FourCC(abilid), 0))
    end
end
