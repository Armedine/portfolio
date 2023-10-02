function loot:globals()
    self.slottable      = {}
    self.raritytable    = {}
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- base keyword assignment:
    -- [Prefix] [TypeMod] [ItemType] [Suffix]
    -- [1]      [2]       [n]        [3]
    kw_type_prefix      = 1
    kw_type_typemod     = 2
    kw_type_suffix      = 3
    kw_type_secondary   = 4
    kw_type_epic        = 5
    kw_type_ancient     = 6
    kw_type_digsite     = 7
    kw_type_potion      = 8
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- statmod types:
    modtype_relative    = 1
    modtype_absolute    = 2
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- rarity data:
    rarity_common       = 1
    rarity_rare         = 2
    rarity_epic         = 3
    rarity_ancient      = 4
    rarity_ids   = {
        [1] = rarity_common,
        [2] = rarity_rare,
        [3] = rarity_epic,
        [4] = rarity_ancient,
    }
    rarity_color = {
        [rarity_common]  = "5bff45",
        [rarity_rare]    = "4568ff",
        [rarity_epic]    = "c445ff",
        [rarity_ancient] = "ff9c00",
    }
    rarity_odds     = {
        [rarity_common]  = 10000,
        [rarity_rare]    = 1500,
        [rarity_epic]    = 300,
        [rarity_ancient] = 50,
    }
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- equipment slot ids:
    slot_helmet         = 1001
    slot_outfit         = 1002
    slot_leggings       = 1003
    slot_tool           = 1004
    slot_potion         = 1005
    slot_boots          = 1006
    slot_gloves         = 1007
    slot_backpack       = 1008
    slot_artifact       = 1009
    slot_candle         = 1010
    -- misc:
    slot_digkey         = 1011
    slot_all_t          = { -- used in fetch random slot id.
        slot_helmet,slot_outfit,slot_leggings,
        slot_tool,slot_potion,slot_boots,
        slot_gloves,slot_backpack,slot_artifact,
        slot_candle }
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- keyword groups:
    kw_group_elemental  = { slot_artifact, slot_candle, slot_tool }
    kw_group_attack     = { slot_artifact, slot_tool, slot_gloves }
    kw_group_resist     = { slot_artifact, slot_helmet, slot_outfit, slot_leggings, slot_boots, slot_gloves }
    kw_group_resist_two = { slot_artifact, slot_helmet, slot_outfit, slot_leggings, slot_boots, slot_gloves, slot_backpack }
    kw_group_wax        = { slot_candle, slot_backpack, slot_artifact }
    kw_group_utility    = { slot_potion, slot_artifact, slot_candle, slot_backpack }
    kw_group_movement   = { slot_boots, slot_backpack }
    kw_group_char       = { slot_outfit, slot_helmet, slot_leggings, slot_potion, slot_gloves }
    kw_group_defense    = { slot_artifact, slot_outfit }
    kw_group_castspeed  = { slot_artifact, slot_candle, slot_gloves, slot_tool }
    kw_group_equipment  = { slot_helmet, slot_gloves, slot_leggings, slot_outfit, slot_boots }
    kw_group_tool       = { slot_tool }
    kw_group_digsite    = { slot_digkey }
    kw_group_onpotion   = { slot_artifact, slot_potion }
    kw_group_potion     = { slot_potion }
    kw_group_artifact   = { slot_artifact }
    kw_group_all        = { slot_helmet,slot_outfit,slot_leggings,slot_tool,slot_potion,slot_boots,slot_gloves,slot_backpack,slot_artifact,slot_candle }
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- initialize slot ids:
    self.slottable[slot_helmet]          = loot.slottype:new(slot_helmet,    "Helmet")
    self.slottable[slot_outfit]          = loot.slottype:new(slot_outfit,    "Outfit")
    self.slottable[slot_leggings]        = loot.slottype:new(slot_leggings,  "Leggings")
    self.slottable[slot_tool]            = loot.slottype:new(slot_tool,      "Tool")
    self.slottable[slot_potion]          = loot.slottype:new(slot_potion,    "Potion")
    self.slottable[slot_boots]           = loot.slottype:new(slot_boots,     "Boots")
    self.slottable[slot_gloves]          = loot.slottype:new(slot_gloves,    "Gloves")
    self.slottable[slot_backpack]        = loot.slottype:new(slot_backpack,  "Backpack")
    self.slottable[slot_artifact]        = loot.slottype:new(slot_artifact,  "Artifact")
    self.slottable[slot_candle]          = loot.slottype:new(slot_candle,    "Candle")
    -- non-equipment types:
    self.slottable[slot_digkey]          = loot.slottype:new(slot_digkey,    "Dig Site Key")
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- initialize rarities:
    self.raritytable[rarity_common]             = loot.rarity:new(rarity_common,    "war3mapImported\\rarity-gem-icons_01.blp", "Common")
    self.raritytable[rarity_common].tooltipbg   = "war3mapImported\\tooltip-bg_scroll_common.blp"
    self.raritytable[rarity_common].rareind     = "war3mapImported\\item-rarity_indicator_01.blp"
    self.raritytable[rarity_rare]               = loot.rarity:new(rarity_rare,      "war3mapImported\\rarity-gem-icons_02.blp", "Rare")
    self.raritytable[rarity_rare].tooltipbg     = "war3mapImported\\tooltip-bg_scroll_rare.blp"
    self.raritytable[rarity_rare].rareind       = "war3mapImported\\item-rarity_indicator_02.blp"
    self.raritytable[rarity_rare].sellfactor    = 1.1
    self.raritytable[rarity_rare].maxfactor     = 0.65
    self.raritytable[rarity_rare].rollfactor    = 1.1
    self.raritytable[rarity_epic]               = loot.rarity:new(rarity_epic,      "war3mapImported\\rarity-gem-icons_03.blp", "Epic")
    self.raritytable[rarity_epic].tooltipbg     = "war3mapImported\\tooltip-bg_scroll_epic.blp"
    self.raritytable[rarity_epic].rareind       = "war3mapImported\\item-rarity_indicator_03.blp"
    self.raritytable[rarity_epic].sellfactor    = 1.2
    self.raritytable[rarity_epic].maxfactor     = 0.8
    self.raritytable[rarity_epic].rollfactor    = 1.3
    self.raritytable[rarity_ancient]            = loot.rarity:new(rarity_ancient,   "war3mapImported\\rarity-gem-icons_04.blp", "Ancient")
    self.raritytable[rarity_ancient].tooltipbg  = "war3mapImported\\tooltip-bg_scroll_ancient.blp"
    self.raritytable[rarity_ancient].rareind    = "war3mapImported\\item-rarity_indicator_04.blp"
    self.raritytable[rarity_ancient].sellfactor = 1.3
    self.raritytable[rarity_ancient].maxfactor  = 0.9
    self.raritytable[rarity_ancient].rollfactor = 1.5
end


function loot:buildtables()
    loot:buildtypetable()
    loot:buildstatmodtable()
    loot:buildkwtable()
    loot:builtancienttable()
    loot:builtancienttable_v1_5()
end


function loot:getslotname(slotid)
    return self.slottable[slotid].name
end


function loot:buildtypetable()
    loot.itemtable = {}
    for slotid = slot_helmet,slot_digkey do
        loot.itemtable[slotid] = {}
    end
    ilvl_map = {1,10,20,30,40,50,60}

    -- builds item types for slotids based on index-ordered .blp icon file names.
    loot:builditemtype(slot_boots,      {"Slippers", "Boots", "Cavewaders", "Greaves", "Stompers", "Ghostcleats", "Slag Stompers"}, 1)
    loot:builditemtype(slot_gloves,     {"Mittons", "Wristwraps", "Gloves", "Gauntlets", "Rockpaws", "Ghostgrasps", "Grottogrips"}, 8)
    loot:builditemtype(slot_artifact,   {"Stone Bead", "Necklace", "Pendant", "Choker", "Jewel", "Carcanet", "Lavalliere"}, 15)
    loot:builditemtype(slot_outfit,     {"Ratwraps", "Vest", "Chainmail", "Chestplate", "Boneplate", "Ghostwraps", "Slag Garb"}, 22)
    loot:builditemtype(slot_leggings,   {"Slacks", "Pants", "Pantaloons", "Chainchaps", "Studjeans", "Ghostwalkers", "Slag Trousers"}, 29)
    loot:builditemtype(slot_helmet,     {"Cap", "Helm", "Chain Helm", "Hard Hat", "Plate Helm", "Bonehat", "Deephelm"}, 36)
    loot:builditemtype(slot_tool,       {"Shovel", "Rock Spade", "Stonecutter", "Ore-Chopper", "Ore-Cleaver", "Autoclaw", "Drillmatic"}, 43)
    -- loot:builditemtype(slot_tool,       {"Gnarlstaff", "Staff", "Moonstaff", "Stone Wand", "Molepole", "Energy Rod", "Terminus"}, 50)
    loot:builditemtype(slot_candle,     {"Candle", "Flambeau", "Waxtorch", "Waxwand", "Bonetorch", "Brazier", "Candlelight Lens"}, 57)
    loot:builditemtype(slot_potion,     {"Tonic", "Potion", "Elixir", "Spirit Beaker", "Spirit Bottle", "Spirit Flask", "Spirit Vessel"}, 64)
    loot:builditemtype(slot_backpack,   {"Rucksack", "Backpack", "Ore Sack", "Satchel", "Duffel", "Ornate Duffel", "Ornate Backpack"}, 71)

    -- dig keys:
    loot.itemtable[slot_digkey][1] = loot.itemtype:new("Ruby Relic",        loot:slot(slot_digkey), 1, "war3mapImported\\icon_bosskey_chomp.blp")
    loot.itemtable[slot_digkey][2] = loot.itemtype:new("Topaz Relic",       loot:slot(slot_digkey), 1, "war3mapImported\\icon_bosskey_slag.blp")
    loot.itemtable[slot_digkey][3] = loot.itemtype:new("Emerald Relic",     loot:slot(slot_digkey), 1, "war3mapImported\\icon_bosskey_mutant.blp")
    loot.itemtable[slot_digkey][4] = loot.itemtype:new("Sapphire Relic",    loot:slot(slot_digkey), 1, "war3mapImported\\icon_bosskey_thawed.blp")
    loot.itemtable[slot_digkey][5] = loot.itemtype:new("Corrupt Relic",     loot:slot(slot_digkey), 1, "war3mapImported\\icon_bosskey_amalgam.blp")

    -- lookup table for dig key itemtypes (used in save/load):
    loot.digkeyt = {
        [loot.itemtable[slot_digkey][1].id] = 1,
        [loot.itemtable[slot_digkey][2].id] = 2,
        [loot.itemtable[slot_digkey][3].id] = 3,
        [loot.itemtable[slot_digkey][4].id] = 4,
        [loot.itemtable[slot_digkey][5].id] = 5,
    }

end


function loot:builditemtype(slotid, namet, iconindex, _count)
    local count = _count or 7
    for id = 1,count do
        local idex,iconstr = iconindex-1+id,""
        if idex < 10 then
            iconstr = "war3mapImported\\item_loot_icons_0"..idex..".blp"
        else
            iconstr = "war3mapImported\\item_loot_icons_"..idex..".blp"
        end
        loot.itemtable[slotid][#loot.itemtable[slotid]+1] = loot.itemtype:new(namet[id], loot:slot(slotid), ilvl_map[id], iconstr)
    end
end


function loot:buildstatmodtable()
    loot.smt   = {} -- item stat mods
    loot.digmt = {} -- dig site stat mods
    -- primary:
    loot.smt[p_stat_strength_b]     = loot.statmod:new("Strength",                  p_stat_strength_b,      2,  6, 0.03, true)
    loot.smt[p_stat_strength_b].icon= "ReplaceableTextures\\CommandButtons\\BTNGauntletsOfOgrePower.blp"
    loot.smt[p_stat_wisdom_b]       = loot.statmod:new("Wisdom",                    p_stat_wisdom_b,        2,  6, 0.03, true)
    loot.smt[p_stat_wisdom_b].icon  = "ReplaceableTextures\\CommandButtons\\BTNPendantOfMana.blp"
    loot.smt[p_stat_alacrity_b]     = loot.statmod:new("Alacrity",                  p_stat_alacrity_b,      2,  6, 0.03, true)
    loot.smt[p_stat_alacrity_b].icon= "ReplaceableTextures\\CommandButtons\\BTNDaggerOfEscape.blp"
    loot.smt[p_stat_vitality_b]     = loot.statmod:new("Vitality",                  p_stat_vitality_b,      2,  6, 0.03, true)
    loot.smt[p_stat_vitality_b].icon= "ReplaceableTextures\\CommandButtons\\BTNPeriapt.blp"
    loot.smt[p_stat_wax]            = loot.statmod:new("Wax Efficiency",            p_stat_wax,             2,  6, 0.005)
    loot.smt[p_stat_wax].icon       = "ReplaceableTextures\\CommandButtons\\BTNPotionOfRestoration.blp"
    loot.smt[p_stat_bms]            = loot.statmod:new("Bonus Movespeed",           p_stat_bms,             2, 10, 0.010)
    loot.smt[p_stat_bms].icon       = "ReplaceableTextures\\CommandButtons\\BTNBootsOfSpeed.blp"
    loot.smt[p_stat_bhp]            = loot.statmod:new("Bonus Health",              p_stat_bhp,             2, 10, 0.005)
    loot.smt[p_stat_bhp].icon       = "ReplaceableTextures\\CommandButtons\\BTNPeriapt.blp"
    loot.smt[p_stat_bmana]          = loot.statmod:new("Bonus Mana",                p_stat_bmana,           2, 10, 0.005)
    loot.smt[p_stat_bmana].icon     = "ReplaceableTextures\\CommandButtons\\BTNPendantOfMana.blp"
    loot.smt[p_stat_fear]           = loot.statmod:new("Fear",                      p_stat_fear,            1, 10, 0.025)
    loot.smt[p_stat_cowardice]      = loot.statmod:new("Cowardice",                 p_stat_cowardice,       1, 10, 0.025)
    loot.smt[p_stat_paranoia]       = loot.statmod:new("Paranoia",                  p_stat_paranoia,        1, 10, 0.025)
    loot.smt[p_stat_arcane]         = loot.statmod:new(color:wrap(color.dmg.arcane, "Arcane").." Damage",               p_stat_arcane,          4,  8, 0.015)
    loot.smt[p_stat_arcane].icon    = "ReplaceableTextures\\CommandButtons\\BTNManaBurn.blp"
    loot.smt[p_stat_frost]          = loot.statmod:new(color:wrap(color.dmg.frost, "Frost").." Damage",                 p_stat_frost,           4,  8, 0.015)
    loot.smt[p_stat_frost].icon     = "ReplaceableTextures\\CommandButtons\\BTNDarkRitual.blp"
    loot.smt[p_stat_nature]         = loot.statmod:new(color:wrap(color.dmg.nature, "Nature").." Damage",               p_stat_nature,          4,  8, 0.015)
    loot.smt[p_stat_nature].icon    = "ReplaceableTextures\\CommandButtons\\BTNRegenerate.blp"
    loot.smt[p_stat_fire]           = loot.statmod:new(color:wrap(color.dmg.fire, "Fire").." Damage",                   p_stat_fire,            4,  8, 0.015)
    loot.smt[p_stat_fire].icon      = "ReplaceableTextures\\CommandButtons\\BTNImmolationOn.blp"
    loot.smt[p_stat_shadow]         = loot.statmod:new(color:wrap(color.dmg.shadow, "Shadow").." Damage",               p_stat_shadow,          4,  8, 0.015)
    loot.smt[p_stat_shadow].icon    = "ReplaceableTextures\\CommandButtons\\BTNFaerieFire.blp"
    loot.smt[p_stat_phys]           = loot.statmod:new(color:wrap(color.dmg.physical, "Physical").." Damage",           p_stat_phys,            4,  8, 0.015)
    loot.smt[p_stat_phys].icon      = "ReplaceableTextures\\CommandButtons\\BTNDeathPact.blp"
    loot.smt[p_stat_arcane_res]     = loot.statmod:new(color:wrap(color.dmg.arcane, "Arcane").." Resistance",           p_stat_arcane_res,      3, 7, 0.01)
    loot.smt[p_stat_arcane_res].icon= "ReplaceableTextures\\CommandButtons\\BTNReplenishMana.blp"
    loot.smt[p_stat_frost_res]      = loot.statmod:new(color:wrap(color.dmg.frost, "Frost").." Resistance",             p_stat_frost_res,       3, 7, 0.01)
    loot.smt[p_stat_frost_res].icon = "ReplaceableTextures\\CommandButtons\\BTNBreathOfFrost.blp"
    loot.smt[p_stat_nature_res]     = loot.statmod:new(color:wrap(color.dmg.nature, "Nature").." Resistance",           p_stat_nature_res,      3, 7, 0.01)
    loot.smt[p_stat_nature_res].icon= "ReplaceableTextures\\CommandButtons\\BTNMonsoon.blp"
    loot.smt[p_stat_fire_res]       = loot.statmod:new(color:wrap(color.dmg.fire, "Fire").." Resistance",               p_stat_fire_res,        3, 7, 0.01)
    loot.smt[p_stat_fire_res].icon  = "ReplaceableTextures\\CommandButtons\\BTNFire.blp"
    loot.smt[p_stat_shadow_res]     = loot.statmod:new(color:wrap(color.dmg.shadow, "Shadow").." Resistance",           p_stat_shadow_res,      3, 7, 0.01)
    loot.smt[p_stat_shadow_res].icon= "ReplaceableTextures\\CommandButtons\\BTNPossession.blp"
    loot.smt[p_stat_phys_res]       = loot.statmod:new(color:wrap(color.dmg.physical, "Physical").." Resistance",       p_stat_phys_res,        3, 7, 0.01)
    loot.smt[p_stat_phys_res].icon  = "ReplaceableTextures\\CommandButtons\\BTNImpale.blp"
    loot.smt[p_stat_healing]        = loot.statmod:new("Healing Power",             p_stat_healing,         2,  8, 0.0125)
    loot.smt[p_stat_healing].icon   = "ReplaceableTextures\\CommandButtons\\BTNHealingWard.blp"
    loot.smt[p_stat_absorb]         = loot.statmod:new("Absorb Power",              p_stat_absorb,          2,  8, 0.015)
    loot.smt[p_stat_absorb].icon    = "ReplaceableTextures\\CommandButtons\\BTNPurge.blp"
    loot.smt[p_stat_minepwr]        = loot.statmod:new("Mining Power",              p_stat_minepwr,         3,  5, 0.025)
    loot.smt[p_stat_minepwr].icon   = "ReplaceableTextures\\CommandButtons\\BTNGatherGold.blp"
    loot.smt[p_stat_eleproc]        = loot.statmod:new("Proliferation",             p_stat_eleproc,         1,  5, 0.010)
    loot.smt[p_stat_eleproc].icon   = "ReplaceableTextures\\CommandButtons\\BTNScatterRockets.blp"
    loot.smt[p_stat_thorns]         = loot.statmod:new("Thorns",                    p_stat_thorns,          1,  2, 0.005, true)
    loot.smt[p_stat_thorns].icon    = "ReplaceableTextures\\CommandButtons\\BTNMetamorphosis.blp"
    loot.smt[p_stat_shielding]      = loot.statmod:new("Absorb on Spell Use",       p_stat_shielding,       2,  5, 0.010, true)
    loot.smt[p_stat_shielding].icon = "ReplaceableTextures\\CommandButtons\\BTNAbsorbMagic.blp"
    loot.smt[p_stat_dodge]          = loot.statmod:new("Dodge Rating",              p_stat_dodge,           2,  5, 0.015, true)
    loot.smt[p_stat_dodge].icon     = "ReplaceableTextures\\CommandButtons\\BTNCloudOfFog.blp"
    loot.smt[p_stat_armor]          = loot.statmod:new("Armor Rating",              p_stat_armor,           3,  6, 0.015, true)
    loot.smt[p_stat_armor].icon     = "ReplaceableTextures\\CommandButtons\\BTNThoriumArmor.blp"
    loot.smt[p_stat_miniondmg]      = loot.statmod:new("Minion Damage",             p_stat_miniondmg,       2,  5, 0.010)
    loot.smt[p_stat_miniondmg].icon = "ReplaceableTextures\\CommandButtons\\BTNDarkSummoning.blp"
    -- secondary:
    loot.smt[p_stat_treasure]       = loot.statmod:new("Treasure Find",             p_stat_treasure,        2,  5, 0.010)
    loot.smt[p_stat_treasure].icon  = "ReplaceableTextures\\CommandButtons\\BTNMagicalSentry.blp"
    loot.smt[p_stat_digxp]          = loot.statmod:new("Dig Site XP",               p_stat_digxp,           2,  5, 0.010)
    loot.smt[p_stat_digxp].icon     = "ReplaceableTextures\\CommandButtons\\BTNSorceressAdept.blp"
    loot.smt[p_stat_mislrange]      = loot.statmod:new("Missile Range",             p_stat_mislrange,       3,  6, 0.005)
    loot.smt[p_stat_mislrange].icon = "ReplaceableTextures\\CommandButtons\\BTNDwarvenLongRifle.blp"
    loot.smt[p_stat_abilarea]       = loot.statmod:new("Ability Radius",            p_stat_abilarea,        3,  6, 0.005)
    loot.smt[p_stat_abilarea].icon  = "ReplaceableTextures\\CommandButtons\\BTNUpgradeMoonGlaive.blp"
    loot.smt[p_stat_physls]         = loot.statmod:new("Physical Lifesteal",        p_stat_physls,          1,  3, 0.005)
    loot.smt[p_stat_physls].icon    = "ReplaceableTextures\\CommandButtons\\BTNVampiricAura.blp"
    loot.smt[p_stat_elels]          = loot.statmod:new("Elemental Lifesteal",       p_stat_elels,           1,  3, 0.005)
    loot.smt[p_stat_elels].icon     = "ReplaceableTextures\\CommandButtons\\BTNDevourMagic.blp"
    loot.smt[p_stat_potionpwr]      = loot.statmod:new("Health Potion Power",       p_stat_potionpwr,       1,  5, 0.005)
    loot.smt[p_stat_potionpwr].icon = "ReplaceableTextures\\CommandButtons\\BTNPotionGreenSmall.blp"
    loot.smt[p_stat_artifactpwr]    = loot.statmod:new("Mana Potion Power",         p_stat_artifactpwr,     1,  5, 0.005)
    loot.smt[p_stat_artifactpwr].icon = "ReplaceableTextures\\CommandButtons\\BTNPotionBlueSmall.blp"
    loot.smt[p_stat_vendor]         = loot.statmod:new("Item Sell Value",           p_stat_vendor,          5,  6, 0.005)
    loot.smt[p_stat_vendor].icon    = "ReplaceableTextures\\CommandButtons\\BTNChestOfGold.blp"
    loot.smt[p_stat_castspeed]      = loot.statmod:new("Casting Speed",             p_stat_castspeed,       1,  4, 0.010)
    loot.smt[p_stat_castspeed].icon = "ReplaceableTextures\\CommandButtons\\BTNWandOfCyclone.blp"
    loot.smt[p_stat_dmg_reduct]     = loot.statmod:new("Damage Reduction",            p_stat_dmg_reduct,    1,  1, 0.005)
    loot.smt[p_stat_dmg_reduct].icon= "ReplaceableTextures\\CommandButtons\\BTNDefend.blp"
    -- dig site:
    loot.digmt[m_stat_health]       = loot.statmod:new("Monster Health",          m_stat_health,          5, 12, 0.01)
    loot.digmt[m_stat_health].icon  = ""
    loot.digmt[m_stat_attack]       = loot.statmod:new("Monster Strength",        m_stat_attack,          5, 12, 0.01)
    loot.digmt[m_stat_attack].icon  = ""
    loot.digmt[m_stat_enemy_res]    = loot.statmod:new("Monster Resistances",     m_stat_enemy_res,       5, 12, 0.0025)
    loot.digmt[m_stat_enemy_res].icon = ""
    loot.digmt[m_stat_density]      = loot.statmod:new("Monster Density",         m_stat_density,         5, 12, 0.01)
    loot.digmt[m_stat_density].icon = ""
    loot.digmt[m_stat_treasure]     = loot.statmod:new("Treasure Find",           m_stat_treasure,        5, 12, 0.01)
    loot.digmt[m_stat_treasure].icon= ""
    loot.digmt[m_stat_xp]           = loot.statmod:new("Dig Site XP",             m_stat_xp,              5, 12, 0.005)
    loot.digmt[m_stat_xp].icon      = ""
    -- potion:
    loot.smt[p_potion_life]         = loot.statmod:newlong("On Health Potion use, restore #v bonus life over 10 sec.", p_potion_life, 10, 20, 0.005)
    loot.smt[p_potion_mana]         = loot.statmod:newlong("On Mana Potion use, restore #v bonus mana over 10 sec.", p_potion_mana, 4, 16, 0.005)
    loot.smt[p_potion_arcane_dmg]   = loot.statmod:newlong("On Mana Potion use, gain #v added "..color:wrap(color.dmg.arcane, "Arcane").." damage for 6 sec.", p_potion_arcane_dmg, 5, 10, 0.0125)
    loot.smt[p_potion_frost_dmg]    = loot.statmod:newlong("On Mana Potion use, gain #v added "..color:wrap(color.dmg.frost, "Frost").." damage for 6 sec.", p_potion_frost_dmg, 5, 10, 0.0125)
    loot.smt[p_potion_nature_dmg]   = loot.statmod:newlong("On Mana Potion use, gain #v added "..color:wrap(color.dmg.nature, "Nature").." damage for 6 sec.", p_potion_nature_dmg, 5, 10, 0.0125)
    loot.smt[p_potion_fire_dmg]     = loot.statmod:newlong("On Mana Potion use, gain #v added "..color:wrap(color.dmg.fire, "Fire").." damage for 6 sec.", p_potion_fire_dmg, 5, 10, 0.0125)
    loot.smt[p_potion_shadow_dmg]   = loot.statmod:newlong("On Mana Potion use, gain #v added "..color:wrap(color.dmg.shadow, "Shadow").." damage for 6 sec.", p_potion_shadow_dmg, 5, 10, 0.0125)
    loot.smt[p_potion_phys_dmg]     = loot.statmod:newlong("On Mana Potion use, gain #v added "..color:wrap(color.dmg.physical, "Physical").." damage for 6 sec.", p_potion_phys_dmg, 5, 10, 0.0125)
    loot.smt[p_potion_dmgr]         = loot.statmod:newlong("On any Potion use, reduce all damage taken by #v for 6 sec.", p_potion_dmgr, 5, 10, 0.009)
    loot.smt[p_potion_arcane_res]   = loot.statmod:newlong("On Health Potion use, gain #v "..color:wrap(color.dmg.arcane, "Arcane").." resistance for 6 sec.", p_potion_arcane_res, 10, 20, 0.015)
    loot.smt[p_potion_frost_res]    = loot.statmod:newlong("On Health Potion use, gain #v "..color:wrap(color.dmg.frost, "Frost").." resistance for 6 sec.", p_potion_frost_res, 10, 20, 0.015)
    loot.smt[p_potion_nature_res]   = loot.statmod:newlong("On Health Potion use, gain #v "..color:wrap(color.dmg.nature, "Nature").." resistance for 6 sec.", p_potion_nature_res, 10, 20, 0.015)
    loot.smt[p_potion_fire_res]     = loot.statmod:newlong("On Health Potion use, gain #v "..color:wrap(color.dmg.fire, "Fire").." resistance for 6 sec.", p_potion_fire_res, 10, 20, 0.015)
    loot.smt[p_potion_shadow_res]   = loot.statmod:newlong("On Health Potion use, gain #v "..color:wrap(color.dmg.shadow, "Shadow").." resistance for 6 sec.", p_potion_shadow_res, 10, 20, 0.015)
    loot.smt[p_potion_phys_res]     = loot.statmod:newlong("On Health Potion use, gain #v "..color:wrap(color.dmg.physical, "Physical").." resistance for 6 sec.", p_potion_phys_res, 10, 20, 0.015)
    loot.smt[p_potion_aoe_stun]     = loot.statmod:newlong("On Health Potion use, stun all targets within 3m for #v sec.", p_potion_aoe_stun, 1, 3, 0.0025, true)
    loot.smt[p_potion_aoe_slow]     = loot.statmod:newlong("On Health Potion use, slow all targets within 3m for #v sec.", p_potion_aoe_slow, 2, 3, 0.0075, true)
    loot.smt[p_potion_absorb]       = loot.statmod:newlong("On any Potion use, absorb damage equal to #v of your max health for 6 sec.", p_potion_absorb, 3, 4, 0.015)
    loot.smt[p_potion_armor]        = loot.statmod:newlong("On any Potion use, increase your armor rating by #v for 8 sec.", p_potion_armor, 15, 25, 0.015)
    loot.smt[p_potion_dodge]        = loot.statmod:newlong("On any Potion use, increase your dodge rating by #v for 8 sec.", p_potion_dodge, 15, 25, 0.015)
    loot.smt[p_potion_lifesteal]    = loot.statmod:newlong("On any Potion use, gain #v lifesteal for 8 sec.", p_potion_lifesteal, 1, 10, 0.0015)
    loot.smt[p_potion_thorns]       = loot.statmod:newlong("On any Potion use, gain #v thorns and increase total thorns by 25#perc for 8 sec.", p_potion_thorns, 5, 10, 0.03, true)
    --loot.smt[p_potion_aoe_heal]     = loot.statmod:newlong("On Health Potion use, restore #v life to all other Kobolds within 10m.", p_potion_aoe_heal, 5, 10, 0.015)
    --loot.smt[p_potion_aoe_mana]     = loot.statmod:newlong("On Mana Potion use, restore #v mana to all other Kobolds within 10m.", p_potion_aoe_mana, 3, 7, 0.015)
    -- epic:
    loot.smt[p_epic_dmg_reduct]     = loot.statmod:newlong("On ability use, reduce all damage taken by #v for 3 sec.", p_epic_dmg_reduct, 1, 2, 0.005)
    loot.smt[p_epic_arcane_mis]     = loot.statmod:newlong("Abilities have a 30#perc chance to launch a missile which pierces targets for #v "..color:wrap(color.dmg.arcane, "Arcane").." damage.", p_epic_arcane_mis, 5, 9, 0.015, true)
    loot.smt[p_epic_frost_mis]      = loot.statmod:newlong("Abilities have a 30#perc chance to launch a missile which pierces targets for #v "..color:wrap(color.dmg.frost, "Frost").." damage.", p_epic_frost_mis, 5, 9, 0.015, true)
    loot.smt[p_epic_nature_mis]     = loot.statmod:newlong("Abilities have a 30#perc chance to launch a missile which pierces targets for #v "..color:wrap(color.dmg.nature, "Nature").." damage.", p_epic_nature_mis, 5, 9, 0.015, true)
    loot.smt[p_epic_fire_mis]       = loot.statmod:newlong("Abilities have a 30#perc chance to launch a missile which pierces targets for #v "..color:wrap(color.dmg.fire, "Fire").." damage.", p_epic_fire_mis, 5, 9, 0.015, true)
    loot.smt[p_epic_shadow_mis]     = loot.statmod:newlong("Abilities have a 30#perc chance to launch a missile which pierces targets for #v "..color:wrap(color.dmg.shadow, "Shadow").." damage.", p_epic_shadow_mis, 5, 9, 0.015, true)
    loot.smt[p_epic_phys_mis]       = loot.statmod:newlong("Abilities have a 30#perc chance to launch a missile which pierces targets for #v "..color:wrap(color.dmg.physical, "Physical").." damage.", p_epic_phys_mis, 5, 9, 0.015, true)
    loot.smt[p_epic_heal_aoe]       = loot.statmod:newlong("Abilities have a #v chance to restore 3#perc life to all Kobolds within 10m.", p_epic_heal_aoe, 2, 5, 0.015)
    loot.smt[p_epic_aoe_stun]       = loot.statmod:newlong("Abilities have a #v chance to stun targets in a 3m radius for 2 sec.", p_epic_aoe_stun, 1, 3, 0.01)
    loot.smt[p_epic_hit_crit]       = loot.statmod:newlong("Abilities have a #v chance to critically strike, dealing 50#perc bonus damage.", p_epic_hit_crit, 2, 3, 0.005)
    loot.smt[p_epic_arcane_conv]    = loot.statmod:newlong("Convert #v of damage dealt to "..color:wrap(color.dmg.arcane, "Arcane")..".", p_epic_arcane_conv, 2, 5, 0.01)
    loot.smt[p_epic_frost_conv]     = loot.statmod:newlong("Convert #v of damage dealt to "..color:wrap(color.dmg.frost, "Frost")..".", p_epic_frost_conv, 2, 5, 0.01)
    loot.smt[p_epic_nature_conv]    = loot.statmod:newlong("Convert #v of damage dealt to "..color:wrap(color.dmg.nature, "Nature")..".", p_epic_nature_conv, 2, 5, 0.01)
    loot.smt[p_epic_fire_conv]      = loot.statmod:newlong("Convert #v of damage dealt to "..color:wrap(color.dmg.fire, "Fire")..".", p_epic_fire_conv, 2, 5, 0.01)
    loot.smt[p_epic_shadow_conv]    = loot.statmod:newlong("Convert #v of damage dealt to "..color:wrap(color.dmg.shadow, "Shadow")..".", p_epic_shadow_conv, 2, 5, 0.01)
    loot.smt[p_epic_phys_conv]      = loot.statmod:newlong("Convert #v of damage dealt to "..color:wrap(color.dmg.physical, "Physical")..".", p_epic_phys_conv, 2, 5, 0.01)
    loot.smt[p_epic_arcane_aoe]     = loot.statmod:newlong("Abilities have a 25#perc chance to unleash a nova that deals #v "..color:wrap(color.dmg.arcane, "Arcane").." damage in a 3m radius.", p_epic_arcane_aoe, 4, 8, 0.01, true)
    loot.smt[p_epic_frost_aoe]      = loot.statmod:newlong("Abilities have a 25#perc chance to unleash a nova that deals #v "..color:wrap(color.dmg.frost, "Frost").." damage in a 3m radius.", p_epic_frost_aoe, 4, 8, 0.01, true)
    loot.smt[p_epic_nature_aoe]     = loot.statmod:newlong("Abilities have a 25#perc chance to unleash a nova that deals #v "..color:wrap(color.dmg.nature, "Nature").." damage in a 3m radius.", p_epic_nature_aoe, 4, 8, 0.01, true)
    loot.smt[p_epic_fire_aoe]       = loot.statmod:newlong("Abilities have a 25#perc chance to unleash a nova that deals #v "..color:wrap(color.dmg.fire, "Fire").." damage in a 3m radius.", p_epic_fire_aoe, 4, 8, 0.01, true)
    loot.smt[p_epic_shadow_aoe]     = loot.statmod:newlong("Abilities have a 25#perc chance to unleash a nova that deals #v "..color:wrap(color.dmg.shadow, "Shadow").." damage in a 3m radius.", p_epic_shadow_aoe, 4, 8, 0.01, true)
    loot.smt[p_epic_phys_aoe]       = loot.statmod:newlong("Abilities have a 25#perc chance to unleash a nova that deals #v "..color:wrap(color.dmg.physical, "Physical").." damage in a 3m radius.", p_epic_phys_aoe, 4, 8, 0.01, true)
    loot.smt[p_epic_demon]          = loot.statmod:newlong("Abilities have a 25#perc chance to summon a demon for 12 sec to attack targets for #v "..color:wrap(color.dmg.shadow, "Shadow").." damage.", p_epic_demon, 3, 5, 0.01, true)
    loot.smt[p_stat_dmg_arcane]     = loot.statmod:newlong("Add #v bonus "..color:wrap(color.dmg.arcane, "Arcane").." damage to every attack and ability.", p_stat_dmg_arcane, 1, 3, 0.005)
    loot.smt[p_stat_dmg_arcane].buffname    = "Added "..color:wrap(color.dmg.arcane, "Arcane").." Damage"
    loot.smt[p_stat_dmg_arcane].icon        = "ReplaceableTextures\\CommandButtons\\BTNEtherealFormOn.blp"
    loot.smt[p_stat_dmg_frost]      = loot.statmod:newlong("Add #v bonus "..color:wrap(color.dmg.frost, "Frost").." damage to every attack and ability.", p_stat_dmg_frost, 1, 3, 0.005)
    loot.smt[p_stat_dmg_frost].buffname     = "Added "..color:wrap(color.dmg.frost, "Frost").." Damage"
    loot.smt[p_stat_dmg_frost].icon         = "ReplaceableTextures\\CommandButtons\\BTNFrostArmor.blp"
    loot.smt[p_stat_dmg_nature]     = loot.statmod:newlong("Add #v bonus "..color:wrap(color.dmg.nature, "Nature").." damage to every attack and ability.", p_stat_dmg_nature, 1, 3, 0.005)
    loot.smt[p_stat_dmg_nature].buffname    = "Added "..color:wrap(color.dmg.nature, "Nature").." Damage"
    loot.smt[p_stat_dmg_nature].icon        = "ReplaceableTextures\\CommandButtons\\BTNChainLightning.blp"
    loot.smt[p_stat_dmg_fire]       = loot.statmod:newlong("Add #v bonus "..color:wrap(color.dmg.fire, "Fire").." damage to every attack and ability.", p_stat_dmg_fire, 1, 3, 0.005)
    loot.smt[p_stat_dmg_fire].buffname      = "Added "..color:wrap(color.dmg.fire, "Fire").." Damage"
    loot.smt[p_stat_dmg_fire].icon          = "ReplaceableTextures\\CommandButtons\\BTNArcaniteMelee.blp"
    loot.smt[p_stat_dmg_shadow]     = loot.statmod:newlong("Add #v bonus "..color:wrap(color.dmg.shadow, "Shadow").." damage to every attack and ability.", p_stat_dmg_shadow, 1, 3, 0.005)
    loot.smt[p_stat_dmg_shadow].buffname    = "Added "..color:wrap(color.dmg.shadow, "Shadow").." Damage"
    loot.smt[p_stat_dmg_shadow].icon        = "ReplaceableTextures\\CommandButtons\\BTNUnsummonBuilding.blp"
    loot.smt[p_stat_dmg_phys]       = loot.statmod:newlong("Add #v bonus "..color:wrap(color.dmg.physical, "Physical").." damage to every attack and ability.", p_stat_dmg_phys, 1, 3, 0.005)
    loot.smt[p_stat_dmg_phys].buffname      = "Added "..color:wrap(color.dmg.physical, "Physical").." Damage"
    loot.smt[p_stat_dmg_phys].icon          = "ReplaceableTextures\\CommandButtons\\BTNClawsOfAttack.blp"
end


function loot:buildkwtable()
    -- initial build table.
    loot.kwt                     = {}
    loot.kwt[kw_type_prefix]     = {}
    loot.kwt[kw_type_typemod]    = {}
    loot.kwt[kw_type_suffix]     = {}
    loot.kwt[kw_type_secondary]  = {}
    loot.kwt[kw_type_epic]       = {}
    loot.kwt[kw_type_ancient]    = {}
    loot.kwt[kw_type_digsite]    = {}
    loot.kwt[kw_type_potion]     = {}
    -- indexed lookup for selection/loading based on slotid:
    loot.affixt                     = {}
    loot.affixt[kw_type_prefix]     = {}
    loot.affixt[kw_type_typemod]    = {}
    loot.affixt[kw_type_suffix]     = {}
    loot.affixt[kw_type_secondary]  = {}
    loot.affixt[kw_type_epic]       = {}
    loot.affixt[kw_type_ancient]    = {}
    loot.affixt[kw_type_digsite]    = {}
    loot.affixt[kw_type_potion]     = {}
    for _,slotid in pairs(slot_all_t) do
        loot.affixt[kw_type_prefix][slotid]     = {}
        loot.affixt[kw_type_typemod][slotid]    = {}
        loot.affixt[kw_type_suffix][slotid]     = {}
        loot.affixt[kw_type_secondary][slotid]  = {}
        loot.affixt[kw_type_epic][slotid]       = {}
        loot.affixt[kw_type_ancient][slotid]    = {}
        loot.affixt[kw_type_digsite][slotid]    = {}
        loot.affixt[kw_type_potion][slotid]     = {}
    end
    -- indexed lookup for selection based on oreid crafting:
    loot.oret = {
        [ore_arcane] = {
            p_stat_arcane,
            p_stat_arcane_res,
            p_stat_dmg_arcane,
            p_epic_arcane_mis,
            p_epic_arcane_conv,
            p_epic_arcane_aoe,
            p_potion_arcane_dmg,
            p_potion_arcane_res,
        },
        [ore_frost]  = {
            p_stat_frost,
            p_stat_frost_res,
            p_stat_dmg_frost,
            p_epic_frost_conv,
            p_epic_frost_aoe,
            p_potion_frost_dmg,
            p_potion_frost_res,
        },
        [ore_nature] = {
            p_stat_nature,
            p_stat_nature_res,
            p_stat_dmg_nature,
            p_epic_heal_aoe,
            p_epic_nature_conv,
            p_epic_nature_aoe,
            p_potion_nature_dmg,
            p_potion_nature_res,
            p_potion_thorns,
        },
        [ore_fire]   = {
            p_stat_fire,
            p_stat_fire_res,
            p_stat_dmg_fire,
            p_epic_fire_mis,
            p_epic_fire_conv,
            p_epic_fire_aoe,
            p_potion_fire_dmg,
            p_potion_fire_res,
        },
        [ore_shadow] = {
            p_stat_shadow,
            p_stat_shadow_res,
            p_stat_dmg_shadow,
            p_epic_shadow_mis,
            p_epic_shadow_conv,
            p_epic_demon,
            p_epic_shadow_aoe,
            p_potion_shadow_dmg,
            p_potion_shadow_res,
        },
        [ore_phys]   = {
            p_stat_phys,
            p_stat_phys_res,
            p_stat_dmg_phys,
            p_epic_frost_mis,
            p_epic_nature_mis,
            p_epic_phys_mis,
            p_epic_aoe_stun,
            p_epic_hit_crit,
            p_epic_phys_conv,
            p_epic_phys_aoe,
            p_potion_phys_dmg,
            p_potion_phys_res,
        }
    }
    loot.eletable = {}
    for oreid,_ in pairs(loot.oret) do
        loot.eletable[oreid] = {}
        loot.eletable[oreid][kw_type_prefix]     = {}
        loot.eletable[oreid][kw_type_typemod]    = {}
        loot.eletable[oreid][kw_type_suffix]     = {}
        loot.eletable[oreid][kw_type_secondary]  = {}
        loot.eletable[oreid][kw_type_epic]       = {}
        loot.eletable[oreid][kw_type_ancient]    = {}
        loot.eletable[oreid][kw_type_digsite]    = {}
        loot.eletable[oreid][kw_type_potion]     = {}
        for _,slotid in pairs(slot_all_t) do
            loot.eletable[oreid][kw_type_prefix][slotid]     = {}
            loot.eletable[oreid][kw_type_typemod][slotid]    = {}
            loot.eletable[oreid][kw_type_suffix][slotid]     = {}
            loot.eletable[oreid][kw_type_secondary][slotid]  = {}
            loot.eletable[oreid][kw_type_epic][slotid]       = {}
            loot.eletable[oreid][kw_type_ancient][slotid]    = {}
            loot.eletable[oreid][kw_type_digsite][slotid]    = {}
            loot.eletable[oreid][kw_type_potion][slotid]     = {}
        end
    end
    -----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------PREFIX-----------------------------------------------------
    -----------------------------------------------------------------------------------------------------------------------
    -- prefix main stat:
    loot.kwt[kw_type_prefix][1] = loot.kw:new("Blunt",             kw_type_prefix,         loot.smt[p_stat_strength_b],         kw_group_all)
    loot.kwt[kw_type_prefix][2] = loot.kw:new("Magical",           kw_type_prefix,         loot.smt[p_stat_wisdom_b],           kw_group_all)
    loot.kwt[kw_type_prefix][3] = loot.kw:new("Agile",             kw_type_prefix,         loot.smt[p_stat_alacrity_b],         kw_group_all)
    loot.kwt[kw_type_prefix][4] = loot.kw:new("Tough",             kw_type_prefix,         loot.smt[p_stat_vitality_b],         kw_group_all)
    -- prefix movement:
    loot.kwt[kw_type_prefix][5] = loot.kw:new("Speedy",            kw_type_prefix,         loot.smt[p_stat_bms],                kw_group_movement)
    -- prefix character:
    loot.kwt[kw_type_prefix][6] = loot.kw:new("Vitalized",         kw_type_prefix,         loot.smt[p_stat_bhp],                kw_group_char)
    loot.kwt[kw_type_prefix][7] = loot.kw:new("Energized",         kw_type_prefix,         loot.smt[p_stat_bmana],              kw_group_char)
    loot.kwt[kw_type_prefix][8] = loot.kw:new("Acrobatic",         kw_type_prefix,         loot.smt[p_stat_dodge],              kw_group_equipment)
    loot.kwt[kw_type_prefix][9] = loot.kw:new("Stalwart",          kw_type_prefix,         loot.smt[p_stat_armor],              kw_group_equipment)
    -- prefix utility:
    loot.kwt[kw_type_prefix][10] = loot.kw:new("Restorative",      kw_type_prefix,         loot.smt[p_stat_healing],            kw_group_utility)
    loot.kwt[kw_type_prefix][11] = loot.kw:new("Shielding",        kw_type_prefix,         loot.smt[p_stat_absorb],             kw_group_utility)
    loot.kwt[kw_type_prefix][12] = loot.kw:new("Tunneling",        kw_type_prefix,         loot.smt[p_stat_minepwr],            kw_group_tool)
    -- prefix resistances:
    loot.kwt[kw_type_prefix][13]= loot.kw:new("Aqueous",           kw_type_prefix,         loot.smt[p_stat_fire_res],           kw_group_resist_two)
    loot.kwt[kw_type_prefix][14]= loot.kw:new("Congealing",        kw_type_prefix,         loot.smt[p_stat_frost_res],          kw_group_resist_two)
    loot.kwt[kw_type_prefix][15]= loot.kw:new("Ligneous",          kw_type_prefix,         loot.smt[p_stat_nature_res],         kw_group_resist_two)
    loot.kwt[kw_type_prefix][16]= loot.kw:new("Crepusculous",      kw_type_prefix,         loot.smt[p_stat_shadow_res],         kw_group_resist_two)
    loot.kwt[kw_type_prefix][17]= loot.kw:new("Anti-Mage",         kw_type_prefix,         loot.smt[p_stat_arcane_res],         kw_group_resist_two)
    -- dig site prefix
    loot.kwt[kw_type_prefix][18]= loot.kw:new("Ravenous",          kw_type_prefix,         loot.digmt[m_stat_attack],           kw_group_digsite)
    loot.kwt[kw_type_prefix][19]= loot.kw:new("Adventurous",       kw_type_prefix,         loot.digmt[m_stat_xp],               kw_group_digsite)
    loot.kwt[kw_type_prefix][20]= loot.kw:new("Bountiful",         kw_type_prefix,         loot.digmt[m_stat_treasure],         kw_group_digsite)
    -----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------SUFFIX-----------------------------------------------------
    -----------------------------------------------------------------------------------------------------------------------
    -- suffix resistances:
    loot.kwt[kw_type_suffix][1] = loot.kw:new("of the Infernal",    kw_type_suffix,         loot.smt[p_stat_fire_res],          kw_group_resist)
    loot.kwt[kw_type_suffix][2] = loot.kw:new("of the Lichborn",    kw_type_suffix,         loot.smt[p_stat_frost_res],         kw_group_resist)
    loot.kwt[kw_type_suffix][3] = loot.kw:new("of the Forest",      kw_type_suffix,         loot.smt[p_stat_nature_res],        kw_group_resist)
    loot.kwt[kw_type_suffix][4] = loot.kw:new("of the Damned",      kw_type_suffix,         loot.smt[p_stat_shadow_res],        kw_group_resist)
    loot.kwt[kw_type_suffix][5] = loot.kw:new("of the Magus",       kw_type_suffix,         loot.smt[p_stat_arcane_res],        kw_group_resist)
    loot.kwt[kw_type_suffix][6] = loot.kw:new("of the Brute",       kw_type_suffix,         loot.smt[p_stat_phys_res],          kw_group_resist)
    -- suffix attack:
    loot.kwt[kw_type_suffix][7] = loot.kw:new("of the Warrior",     kw_type_suffix,         loot.smt[p_stat_phys],              kw_group_attack)
    -- suffix wax:
    loot.kwt[kw_type_suffix][8] = loot.kw:new("of Longevity",       kw_type_suffix,         loot.smt[p_stat_wax],               kw_group_wax)
    -- potion/artifact suffix:
    loot.kwt[kw_type_suffix][9] = loot.kw:new("of Vengeance",       kw_type_suffix,         loot.smt[p_stat_thorns],            kw_group_utility)
    loot.kwt[kw_type_suffix][10]= loot.kw:new("of Warding",         kw_type_suffix,         loot.smt[p_stat_shielding],         kw_group_utility)
    -- suffix main stat:
    loot.kwt[kw_type_suffix][11] = loot.kw:new("of the Slayer",     kw_type_suffix,         loot.smt[p_stat_strength_b],        kw_group_equipment)
    loot.kwt[kw_type_suffix][12] = loot.kw:new("of the Oracle",     kw_type_suffix,         loot.smt[p_stat_wisdom_b],          kw_group_equipment)
    loot.kwt[kw_type_suffix][13] = loot.kw:new("of the Trickster",  kw_type_suffix,         loot.smt[p_stat_alacrity_b],        kw_group_equipment)
    loot.kwt[kw_type_suffix][14] = loot.kw:new("of the Veteran",    kw_type_suffix,         loot.smt[p_stat_vitality_b],        kw_group_equipment)
    loot.kwt[kw_type_suffix][15] = loot.kw:new("of the Summoner",   kw_type_suffix,         loot.smt[p_stat_miniondmg],         kw_group_equipment)
    -----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------TYPE MOD---------------------------------------------------
    -----------------------------------------------------------------------------------------------------------------------
    loot.kwt[kw_type_typemod][1] = loot.kw:new("Pyromaniac's",      kw_type_typemod,        loot.smt[p_stat_fire],              kw_group_all)
    loot.kwt[kw_type_typemod][2] = loot.kw:new("Lich's",            kw_type_typemod,        loot.smt[p_stat_frost],             kw_group_all)
    loot.kwt[kw_type_typemod][3] = loot.kw:new("Druid's",           kw_type_typemod,        loot.smt[p_stat_nature],            kw_group_all)
    loot.kwt[kw_type_typemod][4] = loot.kw:new("Warlock's",         kw_type_typemod,        loot.smt[p_stat_shadow],            kw_group_all)
    loot.kwt[kw_type_typemod][5] = loot.kw:new("Wizard's",          kw_type_typemod,        loot.smt[p_stat_arcane],            kw_group_all)
    loot.kwt[kw_type_typemod][6] = loot.kw:new("Bruiser's",         kw_type_typemod,        loot.smt[p_stat_phys],              kw_group_all)
    loot.kwt[kw_type_typemod][7] = loot.kw:new("Elementalist's",    kw_type_typemod,        loot.smt[p_stat_eleproc],           kw_group_all)
    -----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------SECONDARY--------------------------------------------------
    -----------------------------------------------------------------------------------------------------------------------
    loot.kwt[kw_type_secondary][1] = loot.kw:new("Treasure Hunter", kw_type_secondary,      loot.smt[p_stat_treasure],          kw_group_all)
    loot.kwt[kw_type_secondary][2] = loot.kw:new("Veteran",         kw_type_secondary,      loot.smt[p_stat_digxp],             kw_group_all)
    loot.kwt[kw_type_secondary][3] = loot.kw:new("Artillery",       kw_type_secondary,      loot.smt[p_stat_mislrange],         kw_group_attack)
    loot.kwt[kw_type_secondary][4] = loot.kw:new("Cleaver",         kw_type_secondary,      loot.smt[p_stat_abilarea],          kw_group_attack)
    loot.kwt[kw_type_secondary][5] = loot.kw:new("Blood Magic",     kw_type_secondary,      loot.smt[p_stat_elels],             kw_group_elemental)
    loot.kwt[kw_type_secondary][6] = loot.kw:new("Steel Leech",     kw_type_secondary,      loot.smt[p_stat_physls],            kw_group_elemental)
    loot.kwt[kw_type_secondary][7] = loot.kw:new("Potion Mastery",  kw_type_secondary,      loot.smt[p_stat_potionpwr],         kw_group_utility)
    loot.kwt[kw_type_secondary][8] = loot.kw:new("Artifact Mastery",kw_type_secondary,      loot.smt[p_stat_artifactpwr],       kw_group_utility)
    loot.kwt[kw_type_secondary][9] = loot.kw:new("Bartering",       kw_type_secondary,      loot.smt[p_stat_vendor],            kw_group_utility)
    loot.kwt[kw_type_secondary][10]= loot.kw:new("Battle Mage",     kw_type_secondary,      loot.smt[p_stat_castspeed],         kw_group_castspeed)
    -----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------EPIC-------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------------------
    loot.kwt[kw_type_epic][1]   = loot.kw:new("Indestructible",     kw_type_epic,      loot.smt[p_epic_dmg_reduct],             kw_group_all)
    loot.kwt[kw_type_epic][2]   = loot.kw:new("Missile",            kw_type_epic,      loot.smt[p_epic_fire_mis],               kw_group_all)
    loot.kwt[kw_type_epic][3]   = loot.kw:new("Missile",            kw_type_epic,      loot.smt[p_epic_frost_mis],              kw_group_all)
    loot.kwt[kw_type_epic][4]   = loot.kw:new("Missile",            kw_type_epic,      loot.smt[p_epic_nature_mis],             kw_group_all)
    loot.kwt[kw_type_epic][5]   = loot.kw:new("Missile",            kw_type_epic,      loot.smt[p_epic_shadow_mis],             kw_group_all)
    loot.kwt[kw_type_epic][6]   = loot.kw:new("Missile",            kw_type_epic,      loot.smt[p_epic_arcane_mis],             kw_group_all)
    loot.kwt[kw_type_epic][7]   = loot.kw:new("Missile",            kw_type_epic,      loot.smt[p_epic_phys_mis],               kw_group_all)
    loot.kwt[kw_type_epic][8]   = loot.kw:new("Healing Aura",       kw_type_epic,      loot.smt[p_epic_heal_aoe],               kw_group_all)
    loot.kwt[kw_type_epic][9]   = loot.kw:new("Staggering Blow",    kw_type_epic,      loot.smt[p_epic_aoe_stun],               kw_group_all)
    loot.kwt[kw_type_epic][10]  = loot.kw:new("Critical Blow",      kw_type_epic,      loot.smt[p_epic_hit_crit],               kw_group_all)
    loot.kwt[kw_type_epic][11]  = loot.kw:new("Conversion",         kw_type_epic,      loot.smt[p_epic_fire_conv],              kw_group_all)
    loot.kwt[kw_type_epic][12]  = loot.kw:new("Conversion",         kw_type_epic,      loot.smt[p_epic_frost_conv],             kw_group_all)
    loot.kwt[kw_type_epic][13]  = loot.kw:new("Conversion",         kw_type_epic,      loot.smt[p_epic_nature_conv],            kw_group_all)
    loot.kwt[kw_type_epic][14]  = loot.kw:new("Conversion",         kw_type_epic,      loot.smt[p_epic_shadow_conv],            kw_group_all)
    loot.kwt[kw_type_epic][15]  = loot.kw:new("Conversion",         kw_type_epic,      loot.smt[p_epic_arcane_conv],            kw_group_all)
    loot.kwt[kw_type_epic][16]  = loot.kw:new("Conversion",         kw_type_epic,      loot.smt[p_epic_phys_conv],              kw_group_all)
    loot.kwt[kw_type_epic][17]  = loot.kw:new("Demonic",            kw_type_epic,      loot.smt[p_epic_demon],                  kw_group_all)
    loot.kwt[kw_type_epic][18]  = loot.kw:new("Nova",               kw_type_epic,      loot.smt[p_epic_fire_aoe],               kw_group_all)
    loot.kwt[kw_type_epic][19]  = loot.kw:new("Nova",               kw_type_epic,      loot.smt[p_epic_frost_aoe],              kw_group_all)
    loot.kwt[kw_type_epic][20]  = loot.kw:new("Nova",               kw_type_epic,      loot.smt[p_epic_nature_aoe],             kw_group_all)
    loot.kwt[kw_type_epic][21]  = loot.kw:new("Nova",               kw_type_epic,      loot.smt[p_epic_shadow_aoe],             kw_group_all)
    loot.kwt[kw_type_epic][22]  = loot.kw:new("Nova",               kw_type_epic,      loot.smt[p_epic_arcane_aoe],             kw_group_all)
    loot.kwt[kw_type_epic][23]  = loot.kw:new("Nova",               kw_type_epic,      loot.smt[p_epic_phys_aoe],               kw_group_all)
    loot.kwt[kw_type_epic][24]  = loot.kw:new("Proliferation",      kw_type_epic,      loot.smt[p_stat_dmg_arcane],             kw_group_tool)
    loot.kwt[kw_type_epic][25]  = loot.kw:new("Proliferation",      kw_type_epic,      loot.smt[p_stat_dmg_frost],              kw_group_tool)
    loot.kwt[kw_type_epic][26]  = loot.kw:new("Proliferation",      kw_type_epic,      loot.smt[p_stat_dmg_nature],             kw_group_tool)
    loot.kwt[kw_type_epic][27]  = loot.kw:new("Proliferation",      kw_type_epic,      loot.smt[p_stat_dmg_fire],               kw_group_tool)
    loot.kwt[kw_type_epic][28]  = loot.kw:new("Proliferation",      kw_type_epic,      loot.smt[p_stat_dmg_shadow],             kw_group_tool)
    loot.kwt[kw_type_epic][29]  = loot.kw:new("Proliferation",      kw_type_epic,      loot.smt[p_stat_dmg_phys],               kw_group_tool)
    -----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------POTION-----------------------------------------------------
    -----------------------------------------------------------------------------------------------------------------------
    --loot.kwt[kw_type_potion][17]  = loot.kw:new("Shared Healing",   kw_type_potion,    loot.smt[p_potion_aoe_heal],            kw_group_onpotion)
    --loot.kwt[kw_type_potion][18]  = loot.kw:new("Shared Energy",    kw_type_potion,    loot.smt[p_potion_aoe_mana],            kw_group_onpotion)
    loot.kwt[kw_type_potion][1]   = loot.kw:new("Living Essence",   kw_type_potion,    loot.smt[p_potion_life],                kw_group_potion)
    loot.kwt[kw_type_potion][2]   = loot.kw:new("Energy Essence",   kw_type_potion,    loot.smt[p_potion_mana],                kw_group_artifact)
    loot.kwt[kw_type_potion][3]   = loot.kw:new("Tortoise",         kw_type_potion,    loot.smt[p_potion_dmgr],                kw_group_onpotion)
    loot.kwt[kw_type_potion][4]   = loot.kw:new("Elemental Shield", kw_type_potion,    loot.smt[p_potion_fire_res],            kw_group_potion)
    loot.kwt[kw_type_potion][5]   = loot.kw:new("Elemental Shield", kw_type_potion,    loot.smt[p_potion_frost_res],           kw_group_potion)
    loot.kwt[kw_type_potion][6]   = loot.kw:new("Elemental Shield", kw_type_potion,    loot.smt[p_potion_nature_res],          kw_group_potion)
    loot.kwt[kw_type_potion][7]   = loot.kw:new("Elemental Shield", kw_type_potion,    loot.smt[p_potion_shadow_res],          kw_group_potion)
    loot.kwt[kw_type_potion][8]   = loot.kw:new("Elemental Shield", kw_type_potion,    loot.smt[p_potion_arcane_res],          kw_group_potion)
    loot.kwt[kw_type_potion][9]   = loot.kw:new("Elemental Shield", kw_type_potion,    loot.smt[p_potion_phys_res],            kw_group_artifact)
    loot.kwt[kw_type_potion][10]  = loot.kw:new("Elemental Power",  kw_type_potion,    loot.smt[p_potion_fire_dmg],            kw_group_artifact)
    loot.kwt[kw_type_potion][11]  = loot.kw:new("Elemental Power",  kw_type_potion,    loot.smt[p_potion_frost_dmg],           kw_group_artifact)
    loot.kwt[kw_type_potion][12]  = loot.kw:new("Elemental Power",  kw_type_potion,    loot.smt[p_potion_nature_dmg],          kw_group_artifact)
    loot.kwt[kw_type_potion][13]  = loot.kw:new("Elemental Power",  kw_type_potion,    loot.smt[p_potion_shadow_dmg],          kw_group_artifact)
    loot.kwt[kw_type_potion][14]  = loot.kw:new("Elemental Power",  kw_type_potion,    loot.smt[p_potion_arcane_dmg],          kw_group_artifact)
    loot.kwt[kw_type_potion][15]  = loot.kw:new("Elemental Power",  kw_type_potion,    loot.smt[p_potion_phys_dmg],            kw_group_artifact)
    loot.kwt[kw_type_potion][16]  = loot.kw:new("Ground Slam",      kw_type_potion,    loot.smt[p_potion_aoe_stun],            kw_group_potion)
    loot.kwt[kw_type_potion][17]  = loot.kw:new("Ground Tremor",    kw_type_potion,    loot.smt[p_potion_aoe_slow],            kw_group_potion)
    loot.kwt[kw_type_potion][18]  = loot.kw:new("Shielding",        kw_type_potion,    loot.smt[p_potion_absorb],              kw_group_onpotion)
    loot.kwt[kw_type_potion][19]  = loot.kw:new("Thick Hide",       kw_type_potion,    loot.smt[p_potion_armor],               kw_group_onpotion)
    loot.kwt[kw_type_potion][20]  = loot.kw:new("Acrobatic",        kw_type_potion,    loot.smt[p_potion_dodge],               kw_group_onpotion)
    loot.kwt[kw_type_potion][21]  = loot.kw:new("Vampiric",         kw_type_potion,    loot.smt[p_potion_lifesteal],           kw_group_onpotion)
    loot.kwt[kw_type_potion][22]  = loot.kw:new("Vengeful",         kw_type_potion,    loot.smt[p_potion_thorns],              kw_group_onpotion)
    -----------------------------------------------------------------------------------------------------------------------
    ------------------------------------------------------------v1.3-------------------------------------------------------
    -----------------------------------------------------------------------------------------------------------------------
    loot.kwt[kw_type_suffix][16] = loot.kw:new("of Arcane",         kw_type_suffix,        loot.smt[p_stat_arcane],            kw_group_attack)
    loot.kwt[kw_type_suffix][17] = loot.kw:new("of Frost",          kw_type_suffix,        loot.smt[p_stat_frost],             kw_group_attack)
    loot.kwt[kw_type_suffix][18] = loot.kw:new("of Nature",         kw_type_suffix,        loot.smt[p_stat_nature],            kw_group_attack)
    loot.kwt[kw_type_suffix][19] = loot.kw:new("of Fire",           kw_type_suffix,        loot.smt[p_stat_fire],              kw_group_attack)
    loot.kwt[kw_type_suffix][20] = loot.kw:new("of Shadow",         kw_type_suffix,        loot.smt[p_stat_shadow],            kw_group_attack)
    loot.kwt[kw_type_suffix][21] = loot.kw:new("of Rending",        kw_type_suffix,        loot.smt[p_stat_phys],              kw_group_attack)
    loot.kwt[kw_type_suffix][22] = loot.kw:new("of Proliferation",  kw_type_suffix,        loot.smt[p_stat_eleproc],           kw_group_attack)
end
