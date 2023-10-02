function spell:buildeffects()
    speff_waxcan    = speffect:new('war3mapImported\\mdl-Item_Canister_Yellow_Tier4.mdl')
    -- shrine effects:
    speff_holyglow  = speffect:new('Abilities\\Spells\\Human\\HolyBolt\\HolyBoltSpecialArt.mdl')
    speff_udexpl    = speffect:new('Objects\\Spawnmodels\\Undead\\UCancelDeath\\UCancelDeath.mdl')
    speff_rejuv     = speffect:new('Abilities\\Spells\\NightElf\\Rejuvenation\\RejuvenationTarget.mdl')
    speff_reveal    = speffect:new('Abilities\\Spells\\Other\\Andt\\Andt.mdl')
    speff_lust      = speffect:new('Abilities\\Spells\\Orc\\Bloodlust\\BloodlustTarget.mdl')
    speff_phxfire   = speffect:new('Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl')
    speff_drainlf   = speffect:new('Abilities\\Spells\\Other\\Drain\\DrainCaster.mdl')
    speff_rescast   = speffect:new('Abilities\\Spells\\Human\\Resurrect\\ResurrectCaster.mdl')
    speff_fragment  = speffect:new('Objects\\InventoryItems\\Glyph\\Glyph.mdl')
    speff_tome      = speffect:new('Abilities\\Spells\\Items\\TomeOfRetraining\\TomeOfRetrainingCaster.mdl')
    -- ancient effects:
    speff_liqfire   = speffect:new('Abilities\\Spells\\Orc\\LiquidFire\\Liquidfire.mdl')
    speff_reinc     = speffect:new('Abilities\\Spells\\Orc\\Reincarnation\\ReincarnationTarget.mdl')
    speff_coin      = speffect:new('Objects\\InventoryItems\\PotofGold\\PotofGold.mdl')
    speff_transmute = speffect:new('Abilities\\Spells\\Other\\Transmute\\GoldBottleMissile.mdl')
    speff_animate   = speffect:new('Abilities\\Spells\\Undead\\AnimateDead\\AnimateDeadTarget.mdl')
    speff_icestep   = speffect:new('Doodads\\Icecrown\\Terrain\\ClearIceRock\\ClearIceRock0.mdl')
    speff_goldburst = speffect:new('Abilities\\Spells\\Other\\Transmute\\PileofGold.mdl')
    -- boss effects:
    speff_waterexpl = speffect:new('Objects\\Spawnmodels\\Naga\\NagaDeath\\NagaDeath.mdl')
    speff_followmark= speffect:new('Abilities\\Spells\\Other\\Aneu\\AneuCaster.mdl')
    speff_channel   = speffect:new('war3mapImported\\mdl-ShockWave.mdx')
    speff_darkness  = speffect:new('war3mapImported\\mdl-Malevolence Aura Purple.mdx')
    speff_ragered   = speffect:new('war3mapImported\\mdl-Burning Rage Red.mdx')
    speff_darkorb   = speffect:new('Abilities\\Spells\\NightElf\\shadowstrike\\ShadowStrikeMissile.mdl')
    speff_portal    = speffect:new('doodads\\cinematic\\ShimmeringPortal\\ShimmeringPortal.mdl')
    speff_psiyel    = speffect:new('war3mapImported\\mdl-Psionic Shot Yellow.mdx')
    speff_heavgate  = speffect:new("war3mapImported\\mdl-Heaven's Gate Channel.mdx")
    speff_judge     = speffect:new("war3mapImported\\mdl-Judgement NoHive.mdx")
    speff_bondgold  = speffect:new("war3mapImported\\mdl-Bondage Gold SD.mdx")
    speff_goldpile  = speffect:new("war3mapImported\\mdl-Gold.mdx")
    speff_goldchest = speffect:new("war3mapImported\\mdl-HQ Treasure Chest.mdx")
    -- boss markers:
    speff_bossmark  = speffect:new('Doodads\\Cityscape\\Props\\MagicRunes\\MagicRunes0.mdl')
    speff_bossmark2 = speffect:new('war3mapImported\\mdl-PulseTC.mdx')
    speff_bossmark3 = speffect:new('UI\\Feedback\\Confirmation\\Confirmation.mdx')
    speff_bossmark3.vertex = {0, 175, 255}
    -- items:
    speff_item      = speffect:new('war3mapImported\\mdl-Item_Orb_Purity.mdl')
    -- quest markers:
    speff_quest1    = speffect:new('Abilities\\Spells\\Other\\TalkToMe\\TalkToMe.mdl')
    speff_quest2    = speffect:new('Objects\\RandomObject\\RandomObject.mdl', 0.77)
    -- damage registered hit effects by element:
    speff_fire      = speffect:new('Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl')
    speff_frost     = speffect:new('Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl')
    speff_nature    = speffect:new('Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl')
    speff_shadow    = speffect:new('Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl')
    speff_phys      = speffect:new('Abilities\\Weapons\\BallistaMissile\\BallistaMissile.mdl')
    speff_arcane    = speffect:new('Abilities\\Spells\\Human\\Feedback\\ArcaneTowerAttack.mdl')
    -- elemental orbs:
    speff_orbarcn   = speffect:new('war3mapImported\\mdl-OrbDragonX.mdx')
    speff_orbfrst   = speffect:new('war3mapImported\\mdl-OrbIceX.mdx')
    speff_orbnatr   = speffect:new('war3mapImported\\mdl-OrbLightningX.mdx')
    speff_orbfire   = speffect:new('war3mapImported\\mdl-OrbFireX.mdx')
    speff_orbshad   = speffect:new('war3mapImported\\mdl-OrbDarknessX.mdx')
    speff_orbphys   = speffect:new('war3mapImported\\mdl-OrbBloodX.mdx')
    -- area effects:
    speff_sleet     = speffect:new("war3mapImported\\mdl-Sleet Storm.mdx")
    speff_reaperblu = speffect:new("war3mapImported\\mdl-Reaper's Claws Blue.mdx")
    speff_reaperoj  = speffect:new("war3mapImported\\mdl-Reaper's Claws Orange.mdx")
    speff_reaperpurp= speffect:new("war3mapImported\\mdl-Reaper's Claws Purple.mdx")
    speff_reaperred = speffect:new("war3mapImported\\mdl-Reaper's Claws Red.mdx")

    speff_water     = speffect:new('Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveDamage.mdl')
    speff_sacstorm  = speffect:new('war3mapImported\\mdl-Sacred Storm.mdx')
    speff_manastorm = speffect:new('war3mapImported\\mdl-Mana Storm.mdx')
    speff_eldritch  = speffect:new('war3mapImported\\mdl-Eldritch Scroll.mdl')
    speff_flare     = speffect:new('war3mapImported\\mdl-Shining Flare.mdx')
    speff_steamtank = speffect:new('Abilities\\Weapons\\SteamTank\\SteamTankImpact.mdl')
    speff_doom      = speffect:new('Abilities\\Spells\\Other\\Doom\\DoomDeath.mdl')
    speff_beamred   = speffect:new('war3mapImported\\mdl-Soul Beam Red.mdx')
    speff_warstomp  = speffect:new('Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl')
    speff_fireroar  = speffect:new('war3mapImported\\mdl-Damnation Orange.mdx')
    speff_roar      = speffect:new('Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl')
    speff_edict     = speffect:new('war3mapImported\\mdl-Divine Edict.mdx')
    speff_gravblue  = speffect:new('war3mapImported\\mdl-Soul Discharge Blue.mdx')
    speff_voidaura  = speffect:new('war3mapImported\\mdl-Void Rift Purple.mdx')
    speff_quake     = speffect:new('Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl')
    speff_firebomb  = speffect:new('Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl')
    speff_explfire  = speffect:new('Abilities\\Weapons\\LordofFlameMissile\\LordofFlameMissile.mdl', 1.33)
    speff_voidpool  = speffect:new('war3mapImported\\mdl-Void Disc.mdx')
    speff_frostnova = speffect:new('Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl')
    speff_iceblock  = speffect:new('Abilities\\Spells\\Undead\\FreezingBreath\\FreezingBreathTargetArt.mdl')
    speff_dustcloud = speffect:new('Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl')
    speff_dirtexpl  = speffect:new('war3mapImported\\mdl-NewDirtEXNofire.mdx')
    speff_cataexpl  = speffect:new('abilities\\weapons\\catapult\\catapultmissile.mdl')
    speff_demoexpl  = speffect:new('Abilities\\Weapons\\DemolisherFireMissile\\DemolisherFireMissile.mdl')
    speff_marker    = speffect:new('Abilities\\Spells\\Orc\\WarDrums\\DrumsCasterHeal.mdl', 1.25)
    speff_marker.death = false
    speff_stormlght = speffect:new('war3mapImported\\mdl-Stormfall.mdx')
    speff_stormarc  = speffect:new('war3mapImported\\mdl-Stormfall.mdx')
    speff_stormarc.vertex   = {200, 100, 200}
    speff_stormfrost= speffect:new('war3mapImported\\mdl-Stormfall.mdx')
    speff_stormnat  = speffect:new('war3mapImported\\mdl-Stormfall Fel.mdx')
    speff_stormfire = speffect:new('war3mapImported\\mdl-Stormfall Orange.mdx')
    speff_stormshad = speffect:new('war3mapImported\\mdl-Stormfall Void.mdx')
    speff_stormphys = speffect:new('war3mapImported\\mdl-Stormfall Red.mdx')
    area_storm_stack={
        [1] = speff_stormarc,
        [2] = speff_stormfrost,
        [3] = speff_stormnat,
        [4] = speff_stormfire,
        [5] = speff_stormshad,
        [6] = speff_stormphys,
    }
    speff_exploj    = speffect:new('war3mapImported\\mdl-Singularity I Orange.mdx')
    speff_explblu   = speffect:new('war3mapImported\\mdl-Singularity I Blue.mdx')
    speff_explgrn   = speffect:new('war3mapImported\\mdl-Singularity I Green.mdx')
    speff_explpurp  = speffect:new('war3mapImported\\mdl-Singularity I Purple.mdx')
    speff_explred   = speffect:new('war3mapImported\\mdl-Singularity I Red.mdx')
    speff_explwht   = speffect:new('war3mapImported\\mdl-Singularity I White.mdx')
    speff_expl_stack= { -- table for pulling random elemental damage effects.
        [1] = speff_explblu,
        [2] = speff_explwht,
        [3] = speff_explgrn,
        [4] = speff_exploj,
        [5] = speff_explpurp,
        [6] = speff_explred,
    }
    -- potion effects:
    speff_pothp     = speffect:new('Heal.mdx')
    speff_potmana   = speffect:new('Heal Blue.mdx')
    -- attached effects:
    speff_dispel    = speffect:new('Abilities\\Spells\\Human\\DispelMagic\\DispelMagicTarget.mdl')
    speff_rejuv     = speffect:new('war3mapImported\\mdl-Athelas Green.mdx')
    speff_erejuv    = speffect:new('war3mapImported\\mdl-Athelas Teal.mdx')
    speff_orjrejuv  = speffect:new('war3mapImported\\mdl-Athelas Orange.mdx')
    speff_pinrejuv  = speffect:new('war3mapImported\\mdl-Athelas Pink.mdx')
    speff_redrejuv  = speffect:new('war3mapImported\\mdl-Athelas Red.mdx')
    speff_silrejuv  = speffect:new('war3mapImported\\mdl-Athelas Silver.mdx')
    speff_yelrejuv  = speffect:new('war3mapImported\\mdl-Athelas Yellow.mdx')
    speff_enhance   = speffect:new('Abilities\\Spells\\Human\\Invisibility\\InvisibilityTarget.mdl')
    speff_radglow   = speffect:new('war3mapImported\\mdl-Soul Armor Radiant_opt.mdx')
    speff_bluglow   = speffect:new('war3mapImported\\mdl-Soul Armor Scribe_opt.mdx')
    speff_charging  = speffect:new('war3mapImported\\mdl-MagicLightning Aura.mdx')
    speff_blazing   = speffect:new('war3mapImported\\mdl-RunningFlame Aura.mdx')
    speff_weakened  = speffect:new('Abilities\\Spells\\Other\\HowlOfTerror\\HowlTarget.mdl')
    speff_shield    = speffect:new('Abilities\\Spells\\Human\\ManaFlare\\ManaFlareTarget.mdl', nil, 'overhead')
    speff_fshield   = speffect:new('war3mapImported\\mdl-RighteousGuard.mdx', nil, 'origin')
    speff_eshield   = speffect:new('war3mapImported\\mdl-MagicShield.mdx', nil, 'chest')
    speff_uberblu   = speffect:new('war3mapImported\\mdl-Ubershield Azure.mdx', nil, 'chest')
    speff_uberorj   = speffect:new('war3mapImported\\mdl-Ubershield Ember.mdx', nil, 'chest')
    speff_ubergrn   = speffect:new('war3mapImported\\mdl-Ubershield Spring.mdx', nil, 'chest')
    speff_cleave    = speffect:new('Abilities\\Spells\\Other\\Stampede\\StampedeMissileDeath.mdl', nil, 'chest')
    speff_unitcirc  = speffect:new('UI\\Feedback\\SelectionCircle\\SelectionCircle.mdl', nil, 'origin')
    speff_unitcirc.death = false
    -- elite unit markers:
    speff_libarcane = speffect:new('war3mapImported\\mdl-Liberty Blue.mdx')
    speff_libfrost  = speffect:new('war3mapImported\\mdl-Liberty Silver.mdx')
    speff_libnature = speffect:new('war3mapImported\\mdl-Liberty Green.mdx')
    speff_libfire   = speffect:new('war3mapImported\\mdl-Liberty Orange.mdx')
    speff_libshadow = speffect:new('war3mapImported\\mdl-Liberty Purple.mdx')
    speff_libphys   = speffect:new('war3mapImported\\mdl-Liberty Red.mdx')
    att_lib_glow = {
        [1] = speff_libarcane,
        [2] = speff_libfrost,
        [3] = speff_libnature,
        [4] = speff_libfire,
        [5] = speff_libshadow,
        [6] = speff_libphys,
    }
    -- healing:
    speff_lightheal = speffect:new('Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdl')
    speff_resurrect = speffect:new('Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl')
    -- buff markers:
    speff_debuffed  = speffect:new('war3mapImported\\mdl-DarknessLeechTarget.mdx')
    speff_boosted   = speffect:new('Abilities\\Spells\\Orc\\AncestralSpirit\\AncestralSpiritCaster.mdl')
    speff_burning   = speffect:new('Environment\\LargeBuildingFire\\LargeBuildingFire1.mdl')
    speff_radblue   = speffect:new('war3mapImported\\mdl-Radiance Royal.mdx', nil, 'chest')
    speff_radgreen  = speffect:new('war3mapImported\\mdl-Radiance Nature.mdx', nil, 'chest')
    speff_emberarc  = speffect:new('war3mapImported\\mdl-Ember Blue.mdx')
    speff_emberfro  = speffect:new('war3mapImported\\mdl-Ember Teal.mdx')
    speff_embernat  = speffect:new('war3mapImported\\mdl-Ember Green.mdx')
    speff_ember     = speffect:new('war3mapImported\\mdl-Ember.mdx')
    speff_embersha  = speffect:new('war3mapImported\\mdl-Ember Purple.mdx')
    speff_emberphy  = speffect:new('war3mapImported\\mdl-Ember Red.mdx')
    ember_eff_stack = {
        [1] = speff_emberarc,
        [2] = speff_emberfro,
        [3] = speff_embernat,
        [4] = speff_ember,
        [5] = speff_embersha,
        [6] = speff_emberphy,
    }
    -- target/misc:
    speff_deathpact = speffect:new('Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdl')
    speff_bloodsplat= speffect:new('Objects\\Spawnmodels\\Human\\HumanLargeDeathExplode\\HumanLargeDeathExplode.mdl')
    speff_generate  = speffect:new('Abilities\\Spells\\Demon\\DarkPortalDarkPortalTarget.mdl')
    speff_rainfire  = speffect:new('war3mapImported\\mdl-Rain of Fire III.mdx')
    speff_chargeoj  = speffect:new('war3mapImported\\mdl-Valiant Charge.mdx')
    speff_conflagoj = speffect:new('war3mapImported\\mdl-Conflagrate.mdx')
    speff_conflagbl = speffect:new('war3mapImported\\mdl-Conflagrate Blue.mdx')
    speff_conflaggn = speffect:new('war3mapImported\\mdl-Conflagrate Green.mdx')
    speff_iceblast  = speffect:new('war3mapImported\\mdl-Winter Blast SD.mdx')
    speff_icecrystal= speffect:new('war3mapImported\\mdl-Frostcraft Crystal SD.mdx')
    speff_iceshard  = speffect:new('war3mapImported\\mdl-Ice Shard.mdx')
    speff_ltstrike  = speffect:new('war3mapImported\\mdl-LightningWrath.mdx')
    speff_lightn    = speffect:new('Abilities\\Weapons\\Bolt\\BoltImpact.mdl')
    speff_iceburst2 = speffect:new('war3mapImported\\mdl-Pillar of Flame Blue.mdx')
    speff_redburst  = speffect:new('war3mapImported\\mdl-Pillar of Flame Orange.mdx')
    speff_grnburst  = speffect:new('war3mapImported\\mdl-Pillar of Flame Green.mdx')
    speff_feral     = speffect:new('Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl')
    speff_arcglaive = speffect:new('war3mapImported\\mdl-ArcaneGlaive_2.mdx')
    speff_explode   = speffect:new('Objects\\Spawnmodels\\Other\\NeutralBuildingExplosion\\NeutralBuildingExplosion.mdl')
    speff_explode2  = speffect:new('war3mapImported\\mdl-NewGroundEX.mdl')
    speff_explode2.scale = 0.75
    speff_reveal    = speffect:new('Abilities\\Spells\\Human\\MagicSentry\\MagicSentryCaster.mdl', nil, 'overhead')
    speff_defend    = speffect:new('Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl')
    speff_mine      = speffect:new('units\\creeps\\GoblinLandMine\\GoblinLandMine.mdl')
    speff_shroom    = speffect:new('war3mapImported\\mdl-GreenFungus.mdx')
    speff_goldburst = speffect:new('UI\\Feedback\\GoldCredit\\GoldCredit.mdl')
    -- portals:
    port_yellow     = speffect:new('war3mapImported\\mdl-Void Teleport Yellow To.mdx')
    port_yellowtp   = speffect:new('war3mapImported\\mdl-Void Teleport Yellow Target.mdx')
    -- missiles:
    mis_bat         = speffect:new('war3mapImported\\mdl-Carrion Bat Jade SD.mdx')
    mis_blizzard    = speffect:new('war3mapImported\\mdl-Blizzard II Missile.mdx')
    mis_acid        = speffect:new('Abilities\\Weapons\\ChimaeraAcidMissile\\ChimaeraAcidMissile.mdl')
    mis_waterwave   = speffect:new('Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveMissile.mdl')
    mis_waterele    = speffect:new('Abilities\\Weapons\\WaterElementalMissile\\WaterElementalMissile.mdl')
    mis_runic       = speffect:new('war3mapImported\\mdl-Runic Rocket.mdx')
    mis_lightnorb   = speffect:new('Abilities\\Weapons\\FarseerMissile\\FarseerMissile.mdl')
    mis_rock        = speffect:new('Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl')
    mis_rocket      = speffect:new('Abilities\\Weapons\\Mortar\\MortarMissile.mdl')
    mis_hammerred   = speffect:new('war3mapImported\\mdl-Storm Bolt Red.mdx')
    mis_hammergreen = speffect:new('war3mapImported\\mdl-Storm Bolt Green.mdx')
    mis_grenadeblue = speffect:new('war3mapImported\\mdl-Chain Grenade Blue.mdx')
    mis_grenadeoj   = speffect:new('war3mapImported\\mdl-Chain Grenade Orange.mdx')
    mis_grenadepurp = speffect:new('war3mapImported\\mdl-Chain Grenade Purple.mdx')
    mis_grenadegrn  = speffect:new('war3mapImported\\mdl-Chain Grenade Green.mdx')
    mis_iceball     = speffect:new('Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl')
    mis_icicle      = speffect:new('Abilities\\Weapons\\LichMissile\\LichMissile.mdl')
    mis_voidball    = speffect:new('war3mapImported\\mdl-Voidbolt Rough Minor.mdx')
    mis_voidballhge = speffect:new('war3mapImported\\mdl-Voidbolt Rough Major.mdx')
    mis_fireball    = speffect:new('war3mapImported\\mdl-Firebolt Medium.mdx')
    mis_fireballbig = speffect:new('war3mapImported\\mdl-Fireball Medium.mdx')
    mis_fireballhge = speffect:new('war3mapImported\\mdl-Firebolt Rough Major.mdx')
    mis_boltyell    = speffect:new('war3mapImported\\mdl-Shock Blast Yellow.mdx')
    mis_boltblue    = speffect:new('war3mapImported\\mdl-Shock Blast Blue.mdx')
    mis_boltgreen   = speffect:new('war3mapImported\\mdl-Shock Blast Green.mdx')
    mis_boltoj      = speffect:new('war3mapImported\\mdl-Shock Blast Orange.mdx')
    mis_boltpurp    = speffect:new('war3mapImported\\mdl-Shock Blast Purple.mdx')
    mis_boltred     = speffect:new('war3mapImported\\mdl-Shock Blast Red.mdx')
    mis_bolt_stack  = {
        [1] = mis_boltyell,
        [2] = mis_boltblue,
        [3] = mis_boltgreen,
        [4] = mis_boltoj,
        [5] = mis_boltpurp,
        [6] = mis_boltred,
    }
    mis_mortar_arc  = speffect:new('Abilities\\Weapons\\DragonHawkMissile\\DragonHawkMissile.mdl')
    mis_mortar_arc.scale = 2.0
    mis_mortar_fro  = speffect:new('Abilities\\Weapons\\FrostWyrmMissile\\FrostWyrmMissile.mdl')
    mis_mortar_nat  = speffect:new('Abilities\\Weapons\\GreenDragonMissile\\GreenDragonMissile.mdl')
    mis_mortar_fir  = speffect:new('Abilities\\Weapons\\RedDragonBreath\\RedDragonMissile.mdl')
    mis_mortar_sha  = speffect:new('Abilities\\Spells\\Undead\\DeathCoil\\DeathCoilMissile.mdl')
    mis_mortar_phy  = speffect:new('Abilities\\Weapons\\AncientProtectorMissile\\AncientProtectorMissile.mdl')
    mis_mortar_stack={
        [1] = mis_mortar_arc,
        [2] = mis_mortar_fro,
        [3] = mis_mortar_nat,
        [4] = mis_mortar_fir,
        [5] = mis_mortar_sha,
        [6] = mis_mortar_phy,
    }
    mis_shotarcane  = speffect:new('war3mapImported\\mdl-Shot II Yellow.mdx')
    mis_shotarcane.vertex = {255, 0, 255}
    mis_shotblue    = speffect:new('war3mapImported\\mdl-Shot II Blue.mdx')
    mis_shotgreen   = speffect:new('war3mapImported\\mdl-Shot II Green.mdx')
    mis_shotred     = speffect:new('war3mapImported\\mdl-Shot II Red.mdx')
    mis_shotorange  = speffect:new('war3mapImported\\mdl-Shot II Orange.mdx')
    mis_shotpurple  = speffect:new('war3mapImported\\mdl-Shot II Purple.mdx')
    mis_ele_stack   = { -- matches with kui data element settings to pull random missiles.
        [1] = mis_shotarcane,
        [2] = mis_shotblue,
        [3] = mis_shotgreen,
        [4] = mis_shotorange,
        [5] = mis_shotpurple,
        [6] = mis_shotred,
    }
    mis_shot_arcane = speffect:new('war3mapImported\\mdl-Firebrand Shot Blue.mdx')
    mis_shot_frost  = speffect:new('war3mapImported\\mdl-Firebrand Shot Silver.mdx')
    mis_shot_nature = speffect:new('war3mapImported\\mdl-Firebrand Shot Green.mdx')
    mis_shot_fire   = speffect:new('war3mapImported\\mdl-Firebrand Shot Orange.mdx')
    mis_shot_shadow = speffect:new('war3mapImported\\mdl-Firebrand Shot Purple.mdx')
    mis_shot_phys   = speffect:new('war3mapImported\\mdl-Firebrand Shot Red.mdx')
    mis_ele_stack2  = { -- matches with kui data element settings to pull random missiles.
        [1] = mis_shot_arcane,
        [2] = mis_shot_frost,
        [3] = mis_shot_nature,
        [4] = mis_shot_fire,
        [5] = mis_shot_shadow,
        [6] = mis_shot_phys,
    }
    -- enchantment rawcodes:
    sp_enchant = { -- see below for dmgtypeid (dmg_[name])
        [1] = FourCC('A00F'), -- arcane     dmg_arcane  | 1
        [2] = FourCC('A00D'), -- frost      dmg_frost   | 2
        [3] = FourCC('A00A'), -- nature     dmg_nature  | 3
        [4] = FourCC('A00B'), -- fire       dmg_fire    | 4
        [5] = FourCC('A00C'), -- shadow     dmg_shadow  | 5
        [6] = FourCC('A00E'), -- physical   dmg_phys    | 6
    }
    sp_enchant_elite = { -- see below for dmgtypeid (dmg_[name])
        [1] = FourCC('A02G'), -- arcane     dmg_arcane  | 1
        [2] = FourCC('A02F'), -- frost      dmg_frost   | 2
        [3] = FourCC('A02E'), -- nature     dmg_nature  | 3
        [4] = FourCC('A02C'), -- fire       dmg_fire    | 4
        [5] = FourCC('A02D'), -- shadow     dmg_shadow  | 5
        [6] = FourCC('A02H'), -- physical   dmg_phys    | 6
    }
    -- heavy enchantment effects:
    sp_enchant_eff = {
        [1] = speffect:new('war3mapImported\\mdl-Windwalk Blue Soul.mdx'),
        [2] = speffect:new('war3mapImported\\mdl-Windwalk.mdx'),
        [3] = speffect:new('war3mapImported\\mdl-Windwalk Necro Soul.mdx'),
        [4] = speffect:new('war3mapImported\\mdl-Windwalk Fire.mdx'),
        [5] = speffect:new('war3mapImported\\mdl-Shot II Purple.mdx'),
        [6] = speffect:new('war3mapImported\\mdl-Windwalk Blood.mdx'),
    }
    -- proliferation effects:
    orb_prolif_stack = {
        [1] = speffect:new('war3mapImported\\mdl-Climax Blue.mdx'),
        [2] = speffect:new('war3mapImported\\mdl-Climax Teal.mdx'),
        [3] = speffect:new('war3mapImported\\mdl-Climax Green.mdx'),
        [4] = speffect:new('war3mapImported\\mdl-Climax Orange.mdx'),
        [5] = speffect:new('war3mapImported\\mdl-Climax Purple.mdx'),
        [6] = speffect:new('war3mapImported\\mdl-Climax Red.mdx'),
    }
    -- damage modifiers:
    sp_armor_boost = {
        [1] = speffect:new('war3mapImported\\mdl-Armor Stimulus Pink.mdx'),
        [2] = speffect:new('war3mapImported\\mdl-Armor Stimulus Blue.mdx'),
        [3] = speffect:new('war3mapImported\\mdl-Armor Stimulus Green.mdx'),
        [4] = speffect:new('war3mapImported\\mdl-Armor Stimulus Orange.mdx'),
        [5] = speffect:new('war3mapImported\\mdl-Armor Stimulus Purple.mdx'),
        [6] = speffect:new('war3mapImported\\mdl-Armor Stimulus Red.mdx'),
    }
    sp_armor_penalty = {
        [1] = speffect:new('war3mapImported\\mdl-Armor Penetration Pink.mdx'),
        [2] = speffect:new('war3mapImported\\mdl-Armor Penetration Blue.mdx'),
        [3] = speffect:new('war3mapImported\\mdl-Armor Penetration Green.mdx'),
        [4] = speffect:new('war3mapImported\\mdl-Armor Penetration Orange.mdx'),
        [5] = speffect:new('war3mapImported\\mdl-Armor Penetration Purple.mdx'),
        [6] = speffect:new('war3mapImported\\mdl-Armor Penetration Red.mdx'),
    }
    -- elemental orbs:
    orb_eff_arcane = speffect:new('war3mapImported\\mdl-OrbDragonX.mdx')
    orb_eff_frost  = speffect:new('war3mapImported\\mdl-OrbIceX.mdx')
    orb_eff_nature = speffect:new('war3mapImported\\mdl-OrbLightningX.mdx')
    orb_eff_fire   = speffect:new('war3mapImported\\mdl-OrbFireX.mdx')
    orb_eff_shadow = speffect:new('war3mapImported\\mdl-OrbDarknessX.mdx')
    orb_eff_phys   = speffect:new('war3mapImported\\mdl-OrbBloodX.mdx')
    orb_eff_stack = {
        [1] = orb_eff_arcane,
        [2] = orb_eff_frost,
        [3] = orb_eff_nature,
        [4] = orb_eff_fire,
        [5] = orb_eff_shadow,
        [6] = orb_eff_phys,
    }
    -- area effect markers:
    area_mark_arcane = speffect:new('war3mapImported\\mdl-Longevity Aura Cosmic.mdx')
    area_mark_frost  = speffect:new('war3mapImported\\mdl-Longevity Aura Scribe.mdx')
    area_mark_nature = speffect:new('war3mapImported\\mdl-Longevity Aura Spring.mdx')
    area_mark_fire   = speffect:new('war3mapImported\\mdl-Longevity Aura Divine.mdx')
    area_mark_shadow = speffect:new('war3mapImported\\mdl-Longevity Aura Void.mdx')
    area_mark_phys   = speffect:new('war3mapImported\\mdl-Longevity Aura Crimson.mdx')
    area_marker_stack = {
        [1] = area_mark_arcane,
        [2] = area_mark_frost,
        [3] = area_mark_nature,
        [4] = area_mark_fire,
        [5] = area_mark_shadow,
        [6] = area_mark_phys,
    }
    -- void portals:
    speff_voidport = {
        [1] = speffect:new('war3mapImported\\mdl-Void Teleport Blue To.mdx'),
        [2] = speffect:new('war3mapImported\\mdl-Void Teleport Silver To.mdx'),
        [3] = speffect:new('war3mapImported\\mdl-Void Teleport Green To.mdx'),
        [4] = speffect:new('war3mapImported\\mdl-Void Teleport Orange To.mdx'),
        [5] = speffect:new('war3mapImported\\mdl-Void Teleport To.mdx'),
        [6] = speffect:new('war3mapImported\\mdl-Void Teleport Red To.mdx'),
    }
    -- tethers:
    speff_gatearcane = speffect:new('war3mapImported\\mdl-Accelerator Gate Blue.mdx')
    speff_gatearcane.vertex = {255, 0, 255}
    speff_gatefrost  = speffect:new('war3mapImported\\mdl-Accelerator Gate Blue.mdx')
    speff_gatenature = speffect:new('war3mapImported\\mdl-Accelerator Gate Green.mdx')
    speff_gatefire   = speffect:new('war3mapImported\\mdl-Accelerator Gate Yellow.mdx')
    speff_gateshadow = speffect:new('war3mapImported\\mdl-Accelerator Gate Purple.mdx')
    speff_gatephys   = speffect:new('war3mapImported\\mdl-Accelerator Gate Red.mdx')
    teth_gate_stack  = {
        [1] = speff_gatearcane,
        [2] = speff_gatefrost,
        [3] = speff_gatenature,
        [4] = speff_gatefire,
        [5] = speff_gateshadow,
        [6] = speff_gatephys,
    }
    -- flamestrike:
    speff_fspurp     = speffect:new('war3mapImported\\mdl-Flamestrike Dark Void I.mdx')
end


function spell:createmarker(x, y, _dur, _radius)
    local r = 80.0
    if _radius then
        r = _radius/r
    end
    local e = speff_unitcirc:play(x, y, _dur or nil, r)
    return e
end


function spell:assigndmgtypes()
    -- assign what special effect to run on element damage.
    dmg.type[dmg_arcane].effect = speff_arcane
    dmg.type[dmg_fire].effect   = speff_fire
    dmg.type[dmg_frost].effect  = speff_frost
    dmg.type[dmg_nature].effect = speff_nature
    dmg.type[dmg_shadow].effect = speff_shadow
    dmg.type[dmg_phys].effect   = speff_phys
end


-- @unit        = add to this unit.
-- @dmgtypeid   = this element eye-candy.
-- @_dur        = [optional] make it expire after this many sec.
function spell:addenchant(unit, dmgtypeid, _dur)
    -- eye-candy effect for enhancements.
    local abil = sp_enchant[dmgtypeid]
    UnitAddAbility(unit, abil)
    if _dur then
        utils.timed(_dur, function()
            UnitRemoveAbility(unit, abil)
        end)
    end
end
