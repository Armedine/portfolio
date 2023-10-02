function lua_save_load_init()

    -- set the folder where files will be stored in CustomMapData (this should be your map name as the folder e.g. "MyCoolMap"):
    file.folder = "LuaSaveLoad"

    -- set the name of files within the parent folder:
    file.name = "LuaSaveLoadCharacter"

    -- set the maximum number of save files allowed:
    file.capacity = 10

    -- set the total number of data groups used; this helps validate files (if you are not an advanced user, DO NOT change this):
    -- *note: this should be increased if you add additional data clusters within the "char" class.
    -- * this SHOULD NOT CHANGE unless you are making custom additions to data clusters (even if you disable a feature e.g. char.save_food)
    file.data_groups = 6

    -- character load positioning:
    char.load_x = udg_save_load_x or 0.0
    char.load_y = udg_save_load_y or 0.0
    char.load_face = 270.0
    
    -- save player state settings:
    char.save_unit       = true
    char.save_gold       = true
    char.save_lumber     = true
    char.save_food       = true
    char.save_items      = true -- requires char.save_unit
    char.save_abils      = true -- requires char.save_unit
    char.save_xp         = true -- requires char.save_unit
    char.save_attr       = true -- requires char.save_unit
    char.save_levels     = true -- requires char.save_unit

    -- target the food state to save, if enabled.
    -- *note: depending on chosen state, unit food settings can alter the loaded value (such as the player hero costing food and increasing FOOD_USED).
    char.save_food_state = PLAYER_STATE_RESOURCE_FOOD_USED

    -- hero name settings (preserve the hero's proper name):
    char.save_hero_name  = true
    char.name_length_max = 50

    -- string management:
    msg = {}
    msg.on_save         = "Character saved!"
    msg.on_load         = "Success! Character loaded!"
    msg.on_conflict     = "Error: A save/load sync is already in progress. Try again in a second."
    msg.over_capacity   = "Error: You exceeded the maximum allowed slot value ("..tostring(file.capacity)..")."
    msg.no_data_found   = "Error: No character data was found in that file slot."
    msg.decrypt_fail    = "Error: Decryption checksum failed on file load (did you alter the file contents?)."
    msg.load_item_error = "Warning: An item could not be loaded because it was not found in the map's eligible item table."

    --[[
        ----------
        non-config
        ----------
    --]]

    for i,v in ipairs(save_load_item_ids) do
        save_load_item_ids[i] = FourCC(v)
    end
    for i,v in ipairs(save_load_abil_ids) do
        save_load_abil_ids[i] = FourCC(v)
    end
    for i,v in ipairs(save_load_hero_ids) do
        save_load_hero_ids[i] = FourCC(v)
    end

end
