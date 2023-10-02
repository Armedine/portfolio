function kui:dataload()
    --------------------------------------
    -- ui vars
    --------------------------------------
    self.canvas             = {}
    self.worldui            = BlzGetOriginFrame(ORIGIN_FRAME_WORLD_FRAME, 0)
    self.ubertip            = BlzGetOriginFrame(ORIGIN_FRAME_UBERTOOLTIP, 0)
    self.otip               = BlzGetOriginFrame(ORIGIN_FRAME_TOOLTIP, 0)
    self.unitmsg            = BlzGetOriginFrame(ORIGIN_FRAME_UNIT_MSG,0)
    self.chatmsg            = BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG,0)
    self.consolebd          = BlzGetFrameByName("ConsoleUIBackdrop",0)
    self.consuleui          = BlzGetFrameByName("ConsoleUI", 0)
    self.minimap            = BlzGetFrameByName("MiniMapFrame",0)
    self.minimapbar         = BlzGetFrameByName("MinimapButtonBar",0)
    self.effects            = {
        char = {
            [1] = speffect:new('Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl', 1.0),
            [2] = speffect:new('Abilities\\Spells\\Undead\\DarkRitual\\DarkRitualTarget.mdl', 1.0),
            [3] = speffect:new('Abilities\\Spells\\Orc\\FeralSpirit\\feralspiritdone.mdl', 1.0),
            [4] = speffect:new('Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl', 1.0),
        }
    }
    kui.framestack          = {}
    --------------------------------------
    -- ui assets
    --------------------------------------
    self.tex  = {
        -- for hiding parent containers:
        invis           = "war3mapImported\\misc-invisible-texture.blp",
        -- general btns:
        closebtn        = "war3mapImported\\btn-close_x.blp",
        backbtn         = "war3mapImported\\menu-backbtn.blp",
        -- main splash menu:
        splash          = "war3mapImported\\menu-intro_splash.blp",
        opnew           = "war3mapImported\\menu-scroll-option_new.blp",
        opload          = "war3mapImported\\menu-scroll-option_load.blp",
        -- main panels:
        panelinv        = "war3mapImported\\panel-inventory.blp",
        panelchar       = "war3mapImported\\panel-character-page.blp",
        -- character components:
        addatr          = "war3mapImported\\btn-add_attr-dis.blp",
        addatrgrn       = "war3mapImported\\btn-add_attr.blp",
        -- inventory components:
        invslot         = "war3mapImported\\inventory-slot_bd.blp",
        -- skill bar ui:
        skillbd         = "war3mapImported\\skillbar-card_bd.blp", -- skill bar backdrop
        cdfill          = "war3mapImported\\skillbar-cooldown_overlay.blp",
        -- dig site panel:
        paneldig        = "war3mapImported\\panel-dig_site_map.blp",
        digkeybd        = "war3mapImported\\digsite-key_insert_btn_dis.blp",
        digkeybdact     = "war3mapImported\\digsite-key_insert_btn_act.blp",
        -- minimap bd:
        minimap         = "war3mapImported\\minimap-frame.blp",
        -- character specific graphics by charid:
        char = { -- charid lookup
            [1] = { -- tunneler
                selectchar = "war3mapImported\\menu-scroll-char_01.blp",
                panelequip = "war3mapImported\\panel-equipment-char01.blp",
            },
            [2] = { -- geomancer
                selectchar = "war3mapImported\\menu-scroll-char_02.blp",
                panelequip = "war3mapImported\\panel-equipment-char02.blp",
            },
            [3] = { -- rascal
                selectchar = "war3mapImported\\menu-scroll-char_03.blp",
                panelequip = "war3mapImported\\panel-equipment-char03.blp",
            },
            [4] = { -- wickfighter
                selectchar = "war3mapImported\\menu-scroll-char_04.blp",
                panelequip = "war3mapImported\\panel-equipment-char04.blp",
            },
        }
    }
    --------------------------------------
    -- positioning and group meta.
    --------------------------------------
    self.meta = {
        tipcharselect = {
            [1] = {
                [1] = "war3mapImported\\icon-class_01.blp",
                [2] = color:wrap(color.tooltip.alert, "Tunneler").."|n".."The Kinetic Sapper",
                [3] = "Lord over the tunnels with an array of volatile explosives and experimental Kobold technology."
                    .."|n|n"..color:wrap(color.tooltip.good, "Select this scroll to begin your adventure as the Tunneler.")
            },
            [2] = {
                [1] = "war3mapImported\\icon-class_02.blp",
                [2] = color:wrap(color.tooltip.alert, "Geomancer").."|n".."The Menacing Mage",
                [3] = "Conjure powerful spells and golems from the physical, nature, and arcane schools of magic."
                    .."|n|n"..color:wrap(color.tooltip.good, "Select this scroll to begin your adventure as the Geomancer.")
            },
            [3] = {
                [1] = "war3mapImported\\icon-class_03.blp",
                [2] = color:wrap(color.tooltip.alert, "Rascal").."|n".."The Speedy Varmint",
                [3] = "Eviscerate your foes with nimble comboes and punishing disable effects."
                    .."|n|n"..color:wrap(color.tooltip.good, "Select this scroll to begin your adventure as the Rascal.")
            },
            [4] = {
                [1] = "war3mapImported\\icon-class_04.blp",
                [2] = color:wrap(color.tooltip.alert, "Wickfighter").."|n".."The Tough Rat",
                [3] = "Spew scorching flames and molten wax as you get up close and personal with creatures of the darkness."
                    .."|n|n"..color:wrap(color.tooltip.good, "Select this scroll to begin your adventure as the Wickfighter.")
            },
        },
        partyframe = {
            [1] = "war3mapImported\\party_pane-player_pill_01.blp",
            [2] = "war3mapImported\\party_pane-player_pill_02.blp",
            [3] = "war3mapImported\\party_pane-player_pill_03.blp",
            [4] = "war3mapImported\\party_pane-player_pill_04.blp", 
        },
        oretooltip = { -- for kui UI loops.
            [1] = "orearcane",
            [2] = "orefrost",
            [3] = "orenature",
            [4] = "orefire",
            [5] = "oreshadow",
            [6] = "orephysical",
        },
        oreicon = { -- for kui UI loops.
            [1] = "war3mapImported\\ore-type-icons_01.blp",
            [2] = "war3mapImported\\ore-type-icons_02.blp",
            [3] = "war3mapImported\\ore-type-icons_03.blp",
            [4] = "war3mapImported\\ore-type-icons_04.blp",
            [5] = "war3mapImported\\ore-type-icons_05.blp",
            [6] = "war3mapImported\\ore-type-icons_06.blp",
        },
        -- pixel dimensions (width, height, border)
        mfw         = 475, -- was: 447
        mfh         = 598, -- was: 564
        mfp         = 10,
        headerw     = 620,
        headerh     = 90,
        splashbtnw  = 365*0.6,
        splashbtnh  = 445*0.6,
        splashbtny  = 0.185,
        splashbtnx  = 0.71,
        menubtnw    = 179,
        menubtnh    = 44,
        menubtnp    = 30,
        backbtnw    = 126,
        backbtnh    = 55,
        closebtnw   = 53,
        closebtnh   = 49,
        invp        = 10,
        invg        = 50,
        invoffy     = 40, -- pushes inventory buttons down from top.
        digsx       = 1062, -- 72.7% of origin size.
        digsy       = 759,  -- 72.7% of origin size.
        skillw      = 82, -- skill card backdrop dimensions.
        skillh      = 80, -- skill card backdrop dimensions.
        skillp      = 6,
        skillhotkey = {
            [1] = "Q", [2] = "W", [3] = "E", [4] = "R", [5] = "Z", [6] = "X", [7] = "T", [8] = "Y", 
        },
        digcard = { -- cardid lookup
            ["btnsel"] = { -- selected pointer icon
                tex = "war3mapImported\\panel-map_card-selected.blp",
                w       = 60,
                h       = 68,
            },
            ["btn"] = { -- begin dig site btn
                tex     = "war3mapImported\\panel-map_go_btn.blp",
                texact  = "war3mapImported\\panel-map_go_btn_active.blp",
                texhvr  = "war3mapImported\\panel-map_go_btn_active_hover.blp",
                w       = 200,
                h       = 210,
                x       = 976,
                y       = 576,
            },
            [1] = { -- fossile
                tex     = "war3mapImported\\panel-map_card_fossile_std.blp",
                texhvr  = "war3mapImported\\panel-map_card_fossile_hover.blp",
                texact  = "war3mapImported\\panel-map_card_fossile_hover.blp",
                w       = 97,
                h       = 144,
                x       = 340,
                y       = 212,
            },
            [2] = { -- slag
                tex     = "war3mapImported\\panel-map_card_slag_std.blp",
                texhvr  = "war3mapImported\\panel-map_card_slag_hover.blp",
                texact  = "war3mapImported\\panel-map_card_slag_hover.blp",
                w       = 101,
                h       = 144,
                x       = 600,
                y       = 380,
            },
            [3] = { -- mire
                tex     = "war3mapImported\\panel-map_card_mire_std.blp",
                texhvr  = "war3mapImported\\panel-map_card_mire_hover.blp",
                texact  = "war3mapImported\\panel-map_card_mire_hover.blp",
                w       = 90,
                h       = 144,
                x       = 690,
                y       = 158,
            },
            [4] = { -- glacier
                tex     = "war3mapImported\\panel-map_card_ice_std.blp",
                texhvr  = "war3mapImported\\panel-map_card_ice_hover.blp",
                texact  = "war3mapImported\\panel-map_card_ice_hover.blp",
                w       = 96,
                h       = 144,
                x       = 358,
                y       = 509,
            },
            [5] = { -- vault
                tex     = "war3mapImported\\panel-map_card_vault_std.blp",
                texhvr  = "war3mapImported\\panel-map_card_vault_hover.blp",
                texact  = "war3mapImported\\panel-map_card_vault_hover.blp",
                w       = 103,
                h       = 152,
                x       = 108,
                y       = 170,
            },
        },
        digdiff = { -- dig difficulty bar
            -- these need to be layer-ordered (first = in back).
            tex = "war3mapImported\\panel-dig_site_map_difficulty_backdrop.blp",
            texx = 530,
            texy = 130,
            texw = 186,
            texh = 417,
            btnwh = 62, -- btn size
            [1] = {
                tex      = "war3mapImported\\panel-dig_site_difficulty_01.blp",
                y        = 120,
                advtip   = "",
                name     = "Difficulty:|n|cffebce5aGreenwhisker|r",
                descript = "You grab your pickaxe with enthusiasm and then trip on a pebble. We'll go easy on you.|n|n"
                    ..color:wrap(color.tooltip.good, "-25%%").." Enemy Toughness|n"
                    ..color:wrap(color.tooltip.good, "-25%%").." Enemy Lethality|n"
                    ..color:wrap(color.tooltip.good, "-25%%").." Enemy Density|n"
                    ..color:wrap(color.tooltip.good, "-25%%").." Enemy Movespeed|n"
                    ..color:wrap(color.tooltip.good, "+50%%").." Wax Efficiency|n"
                    ..color:wrap(color.tooltip.alert, "+0%%").." Treasure Find|n"
                    ..color:wrap(color.tooltip.alert, "+0%%").." Dig Site XP|n|n"
                    ..color:wrap(color.tooltip.good, "Bosses drop common to rare loot"),
            },
            [2] = {
                tex      = "war3mapImported\\panel-dig_site_difficulty_02.blp",
                y        = 56,
                name     = "Difficulty:|n|cffd1d8ebStandard|r",
                descript = "Just another day on the job. You curl your whiskers confidently and secure your candle in place.|n|n"
                    ..color:wrap(color.tooltip.alert, "+0%%").." Enemy Toughness|n"
                    ..color:wrap(color.tooltip.alert, "+0%%").." Enemy Lethality|n"
                    ..color:wrap(color.tooltip.alert, "+0%%").." Enemy Density|n"
                    ..color:wrap(color.tooltip.alert, "+0%%").." Wax Efficiency|n"
                    ..color:wrap(color.tooltip.good,  "+10%%").." Treasure Find|n"
                    ..color:wrap(color.tooltip.good,  "+25%%").." Dig Site XP|n|n"
                    ..color:wrap(color.tooltip.good, "Bosses drop rare to epic loot").."|n"
                    ..color:wrap(color.tooltip.alert, "Recommended difficulty"),
            },
            [3] = {
                tex      = "war3mapImported\\panel-dig_site_difficulty_03.blp",
                y        = -10,
                name     = "Difficulty:|n|cff2fceebHeroic|r",
                descript = "You have the vision of a Greywhisker basked in the light of a fire, sharing your past heroic deeds.|n|n"
                    ..color:wrap(color.tooltip.bad,   "+50%%").." Enemy Toughness|n"
                    ..color:wrap(color.tooltip.bad,   "+50%%").." Enemy Lethality|n"
                    ..color:wrap(color.tooltip.bad,   "+10%%").." Enemy Density|n"
                    ..color:wrap(color.tooltip.bad,   "+50%%").." Elite Lethality & Pack Size|n"
                    ..color:wrap(color.tooltip.bad,   "-10%%").." Wax Efficiency|n"
                    ..color:wrap(color.tooltip.good,  "+50%%").." Treasure Find|n"
                    ..color:wrap(color.tooltip.good,  "+50%%").." Dig Site XP|n|n"
                    ..color:wrap(color.tooltip.good, "Bosses drop rare to ancient loot"),
            },
            [4] = {
                tex      = "war3mapImported\\panel-dig_site_difficulty_04.blp",
                y        = -76,
                name     = "Difficulty:|n|cffb250d8Vicious|r",
                descript = "You are an aspiring underlord with a treasure addiction, but the Darkness is fierce and encroaching. Will you prevail?|n|n"
                    ..color:wrap(color.tooltip.bad,  "+125%%").." Enemy Toughness|n"
                    ..color:wrap(color.tooltip.bad,  "+125%%").." Enemy Lethality|n"
                    ..color:wrap(color.tooltip.bad,  "+30%%").." Enemy Density|n"
                    ..color:wrap(color.tooltip.bad,  "+50%%").." Elite Lethality & Pack Size|n"
                    ..color:wrap(color.tooltip.bad,  "-20%%").." Wax Efficiency|n"
                    ..color:wrap(color.tooltip.good, "+200%%").." Treasure Find|n"
                    ..color:wrap(color.tooltip.good, "+100%%").." Dig Site XP|n|n"
                    ..color:wrap(color.tooltip.good, "Bosses drop epic to ancient loot").."|n"
                    ..color:wrap(color.tooltip.alert, "Required Level: ")..color:wrap(color.tooltip.good, "20+"),
            },
            [5] = {
                tex      = "war3mapImported\\panel-dig_site_difficulty_05.blp",
                y        = -140,
                name     = "Difficulty:|n|cffed6d00Tyrannical|r",
                descript = "You are Rajah Rat: face the apocalypse and bask your whiskers in its unyielding flames.|n|n"
                    ..color:wrap(color.tooltip.bad,  "+???%%").." Enemy Toughness|n"
                    ..color:wrap(color.tooltip.bad,  "+???%%").." Enemy Lethality|n"
                    ..color:wrap(color.tooltip.bad,  "+???%%").." Enemy Density|n"
                    ..color:wrap(color.tooltip.bad,  "+???%%").." Elite Lethality & Pack Size|n"
                    ..color:wrap(color.tooltip.bad,  "-???%%").." Wax Efficiency|n"
                    ..color:wrap(color.tooltip.good, "+???%%").." Treasure Find|n"
                    ..color:wrap(color.tooltip.good, "+???%%").." Dig Site XP|n|n"
                    ..color:wrap(color.tooltip.good, "Bosses drop epic to ancient loot").."|n"
                    ..color:wrap(color.tooltip.alert, "Required Level: ")..color:wrap(color.tooltip.good, "30+"),
            },
        },
        inv = {
            btnh   = 32, -- sizing for item selected icons.
            btnw   = 32, -- ``
            [1] = {
                tex     = "war3mapImported\\inventory-icon_equip.blp",
                tipstr  = "invbtnequip",
            },
            [2] = {
                tex     = "war3mapImported\\inventory-icon_sell.blp",
                tipstr  = "invbtnsell",
            },
        },
        panelbtn = {
            [1] = {
                tex     = "war3mapImported\\skillbar-tome-btn.blp",
                tipstr  = "charbtn",
                keystr  = "C",
            },
            [2] = {
                tex     = "war3mapImported\\skillbar-tools-icon.blp",
                tipstr  = "equipbtn",
                keystr  = "V",
            },
            [3] = {
                tex     = "war3mapImported\\skillbar-backpack-btn.blp",
                tipstr  = "invbtn",
                keystr  = "B",
            },
            [4] = {
                tex     = "war3mapImported\\skillbar-mastery-btn.blp",
                tipstr  = "masterybtn",
                keystr  = "N",
            },
            [5] = {
                tex     = "war3mapImported\\skillbar-tome_yellow-btn.blp",
                tipstr  = "abilbtn",
                keystr  = "K",
            },
            [6] = {
                tex     = "war3mapImported\\skillbar-map-btn.blp",
                tipstr  = "digbtn",
                keystr  = "Tab",
            },
            [7] = {
                tex     = "war3mapImported\\skillbar-scroll-btn.blp",
                tipstr  = "questbtn",
                keystr  = "F9",
            },
            [8] = {
                tex     = "war3mapImported\\skillbar-x-btn.blp",
                tipstr  = "mainbtn",
                keystr  = "F10",
            },
            [9] = {
                tex     = "war3mapImported\\skillbar-kobold-btn.blp",
                tipstr  = "badgebtn",
                keystr  = "J",
            },
            [10] = {
                tex     = "war3mapImported\\skillbar-env-btn.blp",
                tipstr  = "logbtn",
                keystr  = "F12",
            },
        },
        equipslotw  = 55, -- equipment slot invis button width.
        abiliconw   = 65, -- skill icon size.
        abilnudgey  = 42, -- push down from top of skill bd.
        -- massive scroll panel backdrop:
        massivescroll = {
            tex     = "war3mapImported\\panel-background-huge-scroll.blp",
            headerx = -3,
            headery = 335,
            w       = 1436,
            h       = 651,
        },
        -- ability panel:
        abilpanel = {
            btnwh   = 86, -- abil circle icon size
            btnoffy = -10,
            [1] = { -- abil card
                tex     = "war3mapImported\\panel-ability-ability_backdrop.blp",
                x       = 147, -- start xy offset from top left
                y       = -112,
                offx    = 300, -- move next abil over this much
                offy    = 160, -- move next row down this much
                w       = 265,
                h       = 152,
            },
            [2] = { -- icon backdrop
                tex    = "war3mapImported\\panel-ability-abil_circle_icon.blp",
                texsel = "war3mapImported\\panel-ability-abil_circle_icon_selected.blp",
            },
            headers = {
                [1] = "Q", [2] = "W", [3] = "E", [4] = "R",
            },
        },
        masterypanel = {
            nodex    = -599, -- start xy offset from center
            nodey    = 240,
            tex      = "war3mapImported\\panel-mastery-huge-scroll.blp",
            texstart = "war3mapImported\\panel-mastery-starting_backdrop.blp",
            [1] = { -- standard node
                tex     = "war3mapImported\\panel-mastery-node.blp",
                texsel  = "war3mapImported\\panel-mastery-node_sel.blp",
            },
            [2] = { -- ability/power node
                tex     = "war3mapImported\\panel-mastery-node_abil.blp",
                texsel  = "war3mapImported\\panel-mastery-node_abil_sel.blp",
            },
            [3] = { -- runeword variant
                tex     = "war3mapImported\\mastery_panel-runeword_dis_01.blp",
                texact  = "war3mapImported\\mastery_panel-runeword_act_01.blp",
            },
            [4] = { -- runeword variant
                tex     = "war3mapImported\\mastery_panel-runeword_dis_02.blp",
                texact  = "war3mapImported\\mastery_panel-runeword_act_02.blp",
            },
            [5] = { -- runeword variant
                tex     = "war3mapImported\\mastery_panel-runeword_dis_03.blp",
                texact  = "war3mapImported\\mastery_panel-runeword_act_03.blp",
            },
            [6] = { -- runeword variant
                tex     = "war3mapImported\\mastery_panel-runeword_dis_04.blp",
                texact  = "war3mapImported\\mastery_panel-runeword_act_04.blp",
            },
            [7] = { -- runeword variant
                tex     = "war3mapImported\\mastery_panel-runeword_dis_05.blp",
                texact  = "war3mapImported\\mastery_panel-runeword_act_05.blp",
            },
            [8] = { -- runeword variant
                tex     = "war3mapImported\\mastery_panel-runeword_dis_06.blp",
                texact  = "war3mapImported\\mastery_panel-runeword_act_06.blp",
            },
        },
        classicon = { -- kobold class icons.
            [1] = "war3mapImported\\icon-class_01.blp",
            [2] = "war3mapImported\\icon-class_02.blp",
            [3] = "war3mapImported\\icon-class_03.blp",
            [4] = "war3mapImported\\icon-class_04.blp",
        },
        -- frame metadata
        invmaxx     = 6,        -- max x slots.
        invmaxy     = 7,        -- max y slots.
        -- misc.
        stickyscale = 1.25,     -- sticky nav height growth.
        hoverscale  = 1.09,     -- button hover eye candy scale.
        splashscale = 1.03,     -- splash button scale amount.
        char01raw   = 'H000',   -- tunneler.
        char02raw   = 'H00E',   -- geomancer.
        char03raw   = 'H00G',   -- rascal.
        char04raw   = 'H00F',   -- wickfighter.
        charname    = {
            [1] = "Tunneler",
            [2] = "Geomancer",
            [3] = "Rascal",
            [4] = "Wickfighter",
        },
        rectspawn   = gg_rct_charspawn,
    }
    self.font = {
        header          = "war3mapImported\\fonts-tarzan.ttf",
        tooltip         = "war3mapImported\\fonts-consolas.ttf"
    }
    self.position = {
        -- global ui refs
        centerx         = 0.40,
        centery         = 0.30,
        maxx            = 0.80,
        maxy            = 0.60,
        -- panel position values
        padding         = 0.0083,
    }
    self.color = {
        black           = "war3mapImported\\colors_black.blp",
        bgbrown         = "war3mapImported\\colors_bgbrown.blp",
        bgtan           = "war3mapImported\\colors_bgtan.blp",
        accentgrey      = "war3mapImported\\colors_accentgrey.blp",
    }
    --------------------------------------
    -- debug
    --------------------------------------
    self.debugstr = {}
    self.debugstr[FRAMEEVENT_MOUSE_ENTER]   = "MOUSE_ENTER"
    self.debugstr[FRAMEEVENT_MOUSE_LEAVE]   = "MOUSE_LEAVE"
    self.debugstr[FRAMEEVENT_MOUSE_UP]      = "MOUSE_UP"
    self.debugstr[FRAMEEVENT_CONTROL_CLICK] = "MOUSE_UP_CONTROL"
    --------------------------------------
    -- misc. ui 
    --------------------------------------
    self.cmdmap = { [0] = "CommandButton_0", [1] = "CommandButton_1", [2] = "CommandButton_2",
        [3] = "CommandButton_3", [4] = "CommandButton_4", [5] = "CommandButton_5",
        [6] = "CommandButton_6", [7] = "CommandButton_7", [8] = "CommandButton_8",
        [9] = "CommandButton_9", [10] = "CommandButton_10", [11] = "CommandButton_11",
    }
end
