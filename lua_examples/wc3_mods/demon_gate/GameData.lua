OnMapInit(function()
    Try(function()
        -- GameData helpers:
        local rarity_id_common = BoosterController.rarity_type_ids["common"]
        local rarity_id_uncommon = BoosterController.rarity_type_ids["uncommon"]
        local rarity_id_rare = BoosterController.rarity_type_ids["rare"]
        local rarity_id_epic = BoosterController.rarity_type_ids["epic"]
        local rarity_id_legendary = BoosterController.rarity_type_ids["legendary"]

        -- GameEffect Types:
        GameEffect:new("teleport_void", "Void Teleport Caster.mdx")
        GameEffect:new("teleport_void_portal", "Void Teleport To.mdx")
        GameEffect:new("void_rift", "Void Rift Purple.mdl")
        GameEffect:new("fel_flamestrike", "Flamestrike Fel I.mdx")
        GameEffect:new("shining_flare", "Shining Flare.mdx")
        GameEffect:new("spell_marker", "Spell Marker TC.mdx")
        GameEffect:new("spell_marker_gray", "Spell Marker Gray.mdx")
        GameEffect:new("missile_ballista", "Abilities\\Weapons\\BallistaMissile\\BallistaMissileTarget.mdl")
        GameEffect:new("dark_ritual", "Abilities\\Spells\\Undead\\DarkRitual\\DarkRitualTarget.mdl")
        GameEffect:new("resurrect", "Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl")
        GameEffect:new("resurrect_caster", "Abilities\\Spells\\Human\\Resurrect\\ResurrectCaster.mdl")
        GameEffect:new("holy_light", "Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl")
        GameEffect:new("undead_dissipate", "Objects\\Spawnmodels\\Undead\\UndeadDissipate\\UndeadDissipate.mdl")
        NewEffect = GameEffect.catalog ---@type table<string,GameEffect>

        -- ArmyHero Types:
        local hero_templar = ArmyHero:new("H000")

        -- Faction Types:
        FactionController:new(1, "h005", "Clan Garadar",      8,  {})
        FactionController:new(2, "h004", "Darkscale Naga",    7,  {})
        FactionController:new(3, "h006", "Primal Lords",      15, {})
        FactionController:new(4, "h00B", "The Unshackled",    1,  {})
        FactionController:new(5, "h00A", "Rattlebone Legion", 17, {})
        FactionController:new(6, "h002", "Royal Guard",       4,  {hero_templar})
        FactionController:new(7, "h007", "Sun Eaters",        5,  {})
        FactionController:new(8, "h003", "Tuskbreakers",      12, {})

        -- ArmyUnit Types:
        -- ArmyUnit:new(id, army_power, faction_id, name, rarity_id, _squad_size)
        ArmyUnit:new("h00F", 1, 6, "Guardsman", rarity_id_common, 3)
            :set_stats(1.0, nil, 1.0, 1.0):set_icon("ReplaceableTextures\\CommandButtons\\BTNKTFootmanAlternateHelmet.blp")
        ArmyUnit:new("h00I", 1, 6, "Thaumaturge", rarity_id_uncommon, 2)
            :has_mana(25.0)
            :set_stats(0.8, nil, 0.8, 0.8):set_icon("ReplaceableTextures\\CommandButtons\\BTNStorm_Sorcerer_Kul-Tiras_HD.blp")
        ArmyUnit:new("h00G", 1, 6, "Captain of the Guard", rarity_id_epic, 1)
            :set_stats(1.8, nil, 2.0, 1.0):set_icon("ReplaceableTextures\\CommandButtons\\BTNTheCaptain.blp")
        ArmyUnit:new("h00J", 1, 6, "Kingsman", rarity_id_rare, 2)
            :set_stats(1.4, nil, 1.6, 1.0):set_icon("ReplaceableTextures\\CommandButtons\\BTNAdmiralsGuard.blp")
        ArmyUnit:new("h00H", 1, 6, "Dragonfire Tank", rarity_id_legendary, 1)
            :has_mana(100.0)
            :set_stats(4.0, nil, 2.5, 0.6):set_icon("ReplaceableTextures\\CommandButtons\\BTNSeigeEngine.blp")

        -- EnemyGroup Types:
        -- TODO

        -- EnemyUnit Types:
        EnemyUnit:new("Frenzied Ghoul", "u000", 1, "standard")
            :set_as_melee()
            :set_as_type("minion", "undead", "starter")
            :set_stats(1.0, 1.0, 0.75)
            
        EnemyUnit:new("Bloated Parasite", "n000", 2, "aggressive")
            :set_as_melee()
            :set_as_type("minion", "undead", "starter")
            :set_stats(0.5, 1.0, 1.0)

        EnemyUnit:new("Dev Elite", "n001", 3, "aggressive")
            :set_as_melee()
            :set_as_type("elite", "undead", "starter")
            :set_stats(2.0, 1.0, 1.5)

        EnemyUnit:new("Dev Commander", "n002", 1, "aggressive")
            :set_as_melee()
            :set_as_type("commander", "undead", "starter")
            :set_stats(5.0, 1.0, 5.0)

        -- Rounds 1-5
        --[[1]]  RoundController:new("starter", 6,   1, 0, 0, nil)
        --[[2]]  RoundController:new("starter", 8,   1, 0, 0, nil)
        --[[3]]  RoundController:new("starter", 12,  1, 0, 0, nil)
        --[[4]]  RoundController:new("starter", 16,  1, 1, 0, nil)
        --[[5]]  RoundController:new("starter", 20,  1, 1, 1, nil)
        -- Rounds 6-10
        --[[6]]  RoundController:new("starter", 24,  1, 1, 0, 4.0)
        --[[7]]  RoundController:new("starter", 28,  1, 1, 0, 4.0)
        --[[8]]  RoundController:new("starter", 32,  1, 1, 0, 4.0)
        --[[9]]  RoundController:new("starter", 36,  1, 1, 0, 4.0)
        --[[10]] RoundController:new("starter", 40,  1, 1, 1, 4.0)
        -- Rounds 11-15
        --[[11]] RoundController:new("starter", 60,  2, 2, 0, 3.5)
        --[[12]] RoundController:new("starter", 70,  2, 2, 0, 3.5)
        --[[13]] RoundController:new("starter", 80,  2, 2, 0, 3.5)
        --[[14]] RoundController:new("starter", 90,  2, 2, 0, 3.5)
        --[[15]] RoundController:new("starter", 100, 2, 2, 1, 3.5)
        -- Rounds 16-20
        --[[16]] RoundController:new("starter", 100, 3, 2, 0, 3.0)
        --[[17]] RoundController:new("starter", 100, 3, 2, 0, 3.0)
        --[[18]] RoundController:new("starter", 100, 3, 3, 0, 3.0)
        --[[19]] RoundController:new("starter", 110, 3, 3, 0, 3.0)
        --[[20]] RoundController:new("starter", 120, 3, 3, 1, 3.0)
        -- Rounds 21-25
        --[[21]] RoundController:new("starter", 120, 4, 4, 0, 2.5)
        --[[22]] RoundController:new("starter", 130, 4, 4, 0, 2.5)
        --[[23]] RoundController:new("starter", 130, 4, 4, 0, 2.5)
        --[[24]] RoundController:new("starter", 140, 4, 4, 0, 2.5)
        --[[25]] RoundController:new("starter", 140, 4, 4, 1, 2.5)
        -- Rounds 26-30
        --[[26]] RoundController:new("starter", 140, 4, 4, 0, 2.0)
        --[[27]] RoundController:new("starter", 150, 4, 4, 0, 2.0)
        --[[28]] RoundController:new("starter", 160, 4, 4, 0, 2.0)
        --[[29]] RoundController:new("starter", 180, 4, 5, 0, 2.0)
        --[[30]] RoundController:new("starter", 200, 4, 6, 2, 2.0)
    end)
end)
