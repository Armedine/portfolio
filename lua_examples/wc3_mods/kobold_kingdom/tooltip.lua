tooltip = {}


function tooltip:init()
    self.__index = self
    tooltip_callout_c = "|cff"..color.tooltip.good
    self.temp         = nil --
    self.setting = {
        simpleh = 0.016, -- base height.
        simplew = 0.020, -- base width.
        simplec = 0.00425, -- char sizing.
        flevel  = 6, -- frame level (layer).
    }
    self.string   = {
        -- generate wrapped text for performance:
        -- *note: leave blue as color.tooltip.alert to 
        --  prevent duplicate |cff concats.
        resist    = color:wrap(color.tooltip.alert,"Resistances"),
        second1   = color:wrap(color.tooltip.alert,"Secondary Utility"),
        second2   = color:wrap(color.tooltip.alert,"Secondary Other"),
        defensive = color:wrap(color.tooltip.alert,"Defensive"),
        offensive = color:wrap(color.tooltip.alert,"Offensive"),
        character = color:wrap(color.tooltip.alert,"Character"),
        digsite   = color:wrap(color.tooltip.alert,"Dig Site"),
        utility   = color:wrap(color.tooltip.alert,"Utility"),
        clstr     = color:wrap(color.ui.candlelight, "Candle Light"),
        waxstr    = color:wrap(color.ui.wax, "Wax"),
    }
    self.orecolor = {
        [1] = color.dmg.arcane,
        [2] = color.dmg.frost,
        [3] = color.dmg.nature,
        [4] = color.dmg.fire,
        [5] = color.dmg.shadow,
        [6] = color.dmg.physical,
        [7] = color.ui.gold,
    }
    self.orename = {
        [1] = color:wrap(self.orecolor[1],"Arcanium"),
        [2] = color:wrap(self.orecolor[2],"Polarium"),
        [3] = color:wrap(self.orecolor[3],"Fungolium"),
        [4] = color:wrap(self.orecolor[4],"Scorium"),
        [5] = color:wrap(self.orecolor[5],"Obsidium"),
        [6] = color:wrap(self.orecolor[6],"Torporium"),
        [7] = color:wrap(self.orecolor[7],"Gold"),
    }
    self.box = {
        ["abilitylvl"] = {
            simple = true,
            tipanchor = fp.t,
            attachanchor = fp.b,
            txt = "Unlocked at Level ??",
            hoverset = function(abilslot) return "Unlocked at "..color:wrap(color.tooltip.alert, "Level "..(abilslot*3 + 1)) end
        },
        ["charpage"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Change statistics page"
        },
        ["tcache"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Recover overflow rewards (requires free bag space)"
        },
        ["gold"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Your current stash of "..color:wrap(color.ui.gold,"Gold")..". It's shiny."
        },
        ["fragments"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Your current stash of "..color:wrap(color.rarity.ancient, "Ancient Fragments").."."
        },
        ["obj"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.tr,
            txt = "Complete the "..color:wrap(color.tooltip.alert,"objective").." to finish the dig"
        },
        ["closebtn"] = {
            simple = true,
            tipanchor = fp.t,
            attachanchor = fp.b,
            txt = "Close ("..color:wrap(color.tooltip.alert,"Esc").."|r)"
        },
        ["digbtn"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Dig Sites ("..color:wrap(color.tooltip.alert,"Tab").."|r)"
        },
        ["invbtn"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Inventory ("..color:wrap(color.tooltip.alert,"B").."|r)"
        },
        ["equipbtn"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Equipment ("..color:wrap(color.tooltip.alert,"V").."|r)"
        },
        ["charbtn"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Character ("..color:wrap(color.tooltip.alert,"C").."|r)"
        },
        ["masterybtn"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Mastery ("..color:wrap(color.tooltip.alert,"N").."|r)"
        },
        ["abilbtn"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Abilities ("..color:wrap(color.tooltip.alert,"K").."|r)"
        },
        ["questbtn"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Info ("..color:wrap(color.tooltip.alert,"F9").."|r)"
        },
        ["badgebtn"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Badges ("..color:wrap(color.tooltip.alert,"J").."|r)"
        },
        ["logbtn"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Chat Log ("..color:wrap(color.tooltip.alert,"F12").."|r)"
        },
        ["mainbtn"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Main Menu ("..color:wrap(color.tooltip.alert,"F10").."|r)"
        },
        -- attributes tips:
        ["level"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.tr,
            txt = "Earn experience by completing " .. color:wrap(color.tooltip.alert, "Dig Sites")
        },
        ["attrzero"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.tr,
            txt = "Level up to earn attribute points",
            hoverset = function() if kobold.player[utils.trigp()].attrpoints > 0 then return "Click to apply an attribute point" else return "Level up to earn attribute points" end end
        },
        ["attrauto"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.tr,
            txt = "Automatically apply "..color:wrap(color.tooltip.alert,"all").." attribute points"
        },
        ["strength"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.tr,
            txt = "Increases " ..
                color:wrap(color.tooltip.alert, "armor") ..
                    " and " .. color:wrap(color.tooltip.alert, "absorb power")
        },
        ["vitality"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.tr,
            txt = "Increases " ..
                color:wrap(color.tooltip.alert, "maximum health") ..
                    " and " .. color:wrap(color.tooltip.alert, "health regeneration")
        },
        ["wisdom"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.tr,
            txt = "Increases " ..
                color:wrap(color.tooltip.alert, "maximum mana") ..
                    " and " .. color:wrap(color.tooltip.alert, "mana regeneration")
        },
        ["alacrity"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.tr,
            txt = "Increases " ..
                color:wrap(color.tooltip.alert, "mining power") ..
                    " and " .. color:wrap(color.tooltip.alert, "dodge chance")
        },
        ["fear"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.tr,
            txt = "Reduces movement speed and cooldown rate as " .. tooltip.string.clstr .. " fades"
        },
        ["cowardice"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.tr,
            txt = "Reduces mana efficiency as " .. tooltip.string.clstr .. " fades."
        },
        ["paranoia"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.b,
            txt = "Reduces " .. tooltip.string.waxstr .. " capacity and efficiency as".." fades."
        },
        -- quest pane:
        ["questmax"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Click to minimize details"
        },
        ["questmin"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Click to view details"
        },
        ["speakto"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Press 'D' to speak to a target character"
        },
        -- shop:
        ["shopfrag"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Conjure dig site keys at "..color:wrap(color.tooltip.alert, "The Greywhisker")
        },
        ["shopele"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Imbue new items at "..color:wrap(color.tooltip.alert, "The Elementalist")
        },
        ["shopshiny"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Craft new items at "..color:wrap(color.tooltip.alert, "The Shinykeeper")
        },
        ["craftitem"] = {
            simple = true,
            tipanchor = fp.t,
            attachanchor = fp.b,
            txt = "Craft item!"
        },
        ["sellore"] = {
            simple = true,
            tipanchor = fp.t,
            attachanchor = fp.b,
            txt = "Sell "..color:wrap(color.tooltip.alert, "1").." ore for "..color:wrap(color.ui.gold, "20").." gold"
        },
        ["buyore"] = {
            simple = true,
            tipanchor = fp.t,
            attachanchor = fp.b,
            txt = "Buy "..color:wrap(color.tooltip.alert, "1").." ore for "..color:wrap(color.ui.gold, "40").." gold"
        },
        ["buyfragment"] = {
            simple = true,
            tipanchor = fp.t,
            attachanchor = fp.b,
            txt = "Buy "..color:wrap(color.tooltip.alert, "1").." "..color:wrap(color.rarity.ancient, "Ancient Fragment").." for "..color:wrap(color.ui.gold, "300").." gold"
        },
        -- inventory tips:
        ["invbtnsell"] = {
            simple = true,
            tipanchor = fp.tr,
            attachanchor = fp.bl,
            txt = "Sell this item"
        },
        ["invbtnequip"] = {
            simple = true,
            tipanchor = fp.tr,
            attachanchor = fp.bl,
            txt = "Equip this item"
        },
        ["itemtip"] = {
            simple = false,
            tipanchor = fp.r,
            attachanchor = fp.l,
            fn = "FrameItemTooltip"
        },
        -- equipment tips:
        ["equipempty"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "This slot is empty"
        },
        ["invbtnunequip"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Place this item in your bag"
        },
        -- dig site map tips:
        ["digsitecard"] = {
            simple = true,
            tipanchor = fp.t,
            attachanchor = fp.b,
            txt = "Select this "..self.string.digsite
        },
        ["digstart"] = {
            simple = true,
            tipanchor = fp.t,
            attachanchor = fp.b,
            txt = "Start the dig!"
        },
        ["digkey"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "(Optional) Insert a "..color:wrap(color.tooltip.alert, "Dig Key").." to activate a boss"
        },
        -- skill bar:
        ["healthpot"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Restore "..color:wrap(color.tooltip.good, "30%%").." of your "
                ..color:wrap(color.tooltip.bad, "Health.").." 15 sec cooldown."
        },
        ["manapot"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Restore "..color:wrap(color.tooltip.good, "30%%").." of your "
                ..color:wrap(color.tooltip.alert, "Mana.").." 15 sec cooldown."
        },
        ["health"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Your "..color:wrap(color.tooltip.bad, "Health")..". You are "..color:wrap(color.tooltip.bad, "downed").." if it reaches 0."
        },
        ["mana"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Your "..color:wrap(color.tooltip.alert, "Mana")..". Used to fuel your "..color:wrap(color.tooltip.alert, "abilities.")
        },
        ["experience"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Experience: 0/100",
            hoverset = function() return "Experience: "..math.floor(kobold.player[utils.trigp()].experience)
                .."/"..math.floor(kobold.player[utils.trigp()].nextlvlxp) end,
        },
        -- advanced tooltip:
        ["advtip"] = {
            simple = false,
            tipanchor = fp.r,
            attachanchor = fp.l,
            fn = "FrameLongformTooltip"
        },
        -- mastery tooltips:
        ["masterycenter"] = {
            simple = true,
            tipanchor = fp.t,
            attachanchor = fp.b,
            txt = "Unlock your "..color:wrap(color.tooltip.alert, "Mastery Tree").." (1 Point) "..color:wrap(color.tooltip.good,"+5%% Maximum Health")
        },
        -- ability tooltips:
        ["learnabil"] = {
            simple = true,
            tipanchor = fp.t,
            attachanchor = fp.b,
            txt = "Learn this "..color:wrap(color.tooltip.alert, "Ability")
        },
        ["cooldown"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = color:wrap(color.tooltip.alert, "Cooldown").." (Seconds)"
        },
        ["manacost"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = color:wrap(color.tooltip.alert, "Mana").." Cost"
        },
        -- ore name callout:
        ["orearcane"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Arcanium"
        },
        ["orefrost"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Polarium"
        },
        ["orenature"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Fungolium"
        },
        ["orefire"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Scorium"
        },
        ["oreshadow"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Obsidium"
        },
        ["orephysical"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Torporium"
        },
        ["bosschest"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = color:wrap(color.tooltip.alert, "Spoils of the deep").." (Click to claim)"
        },
        ["unlearnmastery"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Clear all learned mastery abilities"
        },
        ["respecmastery"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Reset all spent mastery points for "..color:wrap(color.ui.gold, "5,000 gold")
        },
        ["invsortall"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Sort all items to the top by equipment type"
        },
        ["invsellall"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Double click quickly to sell all "..color:wrap(color.rarity.ancient, "Non-Ancient").." items "..color:wrap(color.tooltip.bad, "(Cannot be undone)")..""
        },
        ["savechar"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = color:wrap(color.tooltip.good, "Save").." your character"
        },
        ["unequipall"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Double click quickly to remove all equipment"
        },
        -- main menu:
        ["freeplaymode"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.t,
            txt = "Accelerated leveling, no story, and "..color:wrap(color.tooltip.bad,"no saving").." (start at "..color:wrap(color.tooltip.good, "level 15")..")"
        },
        ["storymode"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.t,
            txt = "Help build back the kingdom through a short story (start at "..color:wrap(color.tooltip.good, "level 1")..")"
        },
        ["loadchar"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.t,
            txt = color:wrap(color.tooltip.good, "Load").." an existing save file"
        },
        ["deletesave"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = color:wrap(color.tooltip.alert, "Double click").." quickly to delete this file "..color:wrap(color.tooltip.bad, "(Warning: cannot be undone)")
        },
        ["cancel"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.tl,
            txt = "Cancel"
        },
        ["buff"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "<empty>",
            hoverset = function(buffid)
                if buffy.fr.stack[buffid].data and buffy.fr.stack[buffid].data.name and buffy.fr.stack[buffid].data.descript then
                    return color:wrap(color.tooltip.alert, buffy.fr.stack[buffid].data.name)..": "..buffy.fr.stack[buffid].data.descript
                end
            end
        },
        -- greywhisker vendor:
        ["greywhiskerfrag"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Your current stash of "..color:wrap(color.rarity.ancient, "Ancient Fragments")
        },
        ["greywhiskercraft"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Spend "..color:wrap(color.rarity.ancient, "Ancient Fragments").." to craft the selected "..color:wrap(color.tooltip.alert, "Dig Site Key")
        },
        ["relic1"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Summons a powerful foe in "..color:wrap(color.dmg.physical,"Fossil Gorge")
        },
        ["relic2"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Summons a powerful foe in "..color:wrap(color.dmg.fire,"The Slag Pit")
        },
        ["relic3"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Summons a powerful foe in "..color:wrap(color.dmg.nature,"The Mire")
        },
        ["relic4"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Summons a powerful foe in "..color:wrap(color.dmg.frost,"Glacier Cavern")
        },
        ["relic5"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "Summons a powerful foe in "..color:wrap(color.ui.gold,"The Vault")
        },
        ["badgetip1"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Greenwhisker").." - Complete your first dig site."
        },
        ["badgetip2"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Checked Up").." - Fill every item slot with a piece of equipment."
        },
        ["badgetip3"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Hammer Time").." - Unlock the Shinykeeper vendor."
        },
        ["badgetip4"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Magic Rocks").." - Unlock the Elementalist vendor."
        },
        ["badgetip5"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Rat Wisdom").." - Unlock the Greywhisker vendor."
        },
        ["badgetip6"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Raw Power").." - Equip an Ancient-quality item."
        },
        ["badgetip7"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Relic of Fire").." - Defeat the Slag King."
        },
        ["badgetip8"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Relic of Nature").." - Defeat the Marsh Mutant."
        },
        ["badgetip9"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Relic of Earth").." - Defeat Megachomp."
        },
        ["badgetip10"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Relic of Ice").." - Defeat the Thawed Experiment."
        },
        ["badgetip11"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Gold Thunder").." - Defeat the Amalgam of Greed."
        },
        ["badgetip12"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Kobold Kingdom").." - Complete the main storyline."
        },
        ["badgetip13"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Burn, Baby, Burn").." - Defeat the Slag King on |cffed6d00Tyrannical|r difficulty at level 60."
        },
        ["badgetip14"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Marsh Madness").." - Defeat the Marsh Mutant on |cffed6d00Tyrannical|r difficulty at level 60."
        },
        ["badgetip15"] = {
            simple = true,
            tipanchor = fp.bl,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Dino-Sore").." - Defeat Megachomp on |cffed6d00Tyrannical|r difficulty at level 60."
        },
        ["badgetip16"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Ice Loot").." - Defeat the Thawed Experiment on |cffed6d00Tyrannical|r difficulty at level 60."
        },
        ["badgetip17"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Pocket Change").." - Defeat the Amalgam of Greed on |cffed6d00Tyrannical|r difficulty at level 60."
        },
        ["badgetip18"] = {
            simple = true,
            tipanchor = fp.br,
            attachanchor = fp.t,
            txt = color:wrap(color.ui.gold,"Rajah Rat").." - Defeat all bosses on |cffed6d00Tyrannical|r difficulty at level 60."
        },
        ["badgetipclass1"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "As Tunneler"
        },
        ["badgetipclass2"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "As Geomancer"
        },
        ["badgetipclass3"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "As Rascal"
        },
        ["badgetipclass4"] = {
            simple = true,
            tipanchor = fp.b,
            attachanchor = fp.t,
            txt = "As Wickfighter"
        },
    }
end


function tooltip:getorename(oreid)
    return self.orename[oreid]
end


-- @tipstr = tooltip name.
function tooltip:get(tipstr)
    return self.box[tipstr]
end


function tooltip:bake()
    -- build tooltips on map load to control tip features (we then attach the singleton frames to the tooltip table in .box).
    -- the assign tooltip functions control showing/hiding/updating these singleton frames.
    self.simpletipfr = self:basictemplate()
    self.simpletipfr.alpha = 240
    self.simpletipfr:setsize(w, self.setting.simpleh)
    self.simpletipfr:addtext("tip", "", "all" )
    self.simpletipfr:hide()
    self.simpletipfr:setlvl(self.setting.flevel)
    self.simpletipfr:resetalpha()
    --
    self.advtipfr = kui.frame:newbyname("FrameLongformTooltip", nil)
    self.advtipfr:setlvl(self.setting.flevel)
    self.advtipfr:hide()
    --
    self.itemtipfr = kui.frame:newbyname("FrameItemTooltip", nil)
    self.itemtipfr:setlvl(self.setting.flevel)
    self.itemtipfr:hide()
    --
    self.itemcompfr = kui.frame:newbyname("FrameItemCompTooltip", nil)
    self.itemcompfr:setlvl(self.setting.flevel)
    self.itemcompfr:hide()
    -- assign the new frame to the tooltip table:
    for i,tip in pairs(self.box) do
        if type(tip) == "table" then
            if tip.simple then -- simple frame, 1-line.
                tip.fr = self.simpletipfr
            elseif tip.fn then -- .fdf frame, custom defined.
                if tip.fn == "FrameItemTooltip" then
                    tip.fr = self.itemtipfr
                elseif tip.fn == "FrameLongformTooltip" then
                    tip.fr = self.advtipfr
                end
            end
        end
    end
    self.enhtextleft = 
        self.string.offensive -- header
        .."|n"
        .."Arcane Damage:|n"
        .."Frost Damage:|n"
        .."Nature Damage:|n"
        .."Fire Damage:|n"
        .."Shadow Damage:|n"
        .."Physical Damage:|n"
        .."|n"
        ..self.string.character -- header
        .."|n"
        .."Bonus Health:|n"
        .."Bonus Mana:|n"
        .."Movespeed:|n"
        .."Wax Efficiency:|n"
    self.enhtextright = 
        self.string.resist -- header
        .."|n"
        .."Arcane Resist:|n"
        .."Frost Resist:|n"
        .."Nature Resist:|n"
        .."Fire Resist:|n"
        .."Shadow Resist:|n"
        .."Physical Resist:|n"
        .."|n"
        ..self.string.utility -- header
        .."|n"
        .."Healing Power:|n"
        .."Absorb Power:|n"
        .."Proliferation:|n"
        .."Mining Power:|n"
    self.enhtextleft2 = 
        self.string.second1 -- header
        .."|n"
        .."Treasure Find:|n"
        .."Dig Site XP:|n"
        .."Item Sell Value:|n"
        .."Healing Potion:|n"
        .."Mana Potion:|n"
        .."Minion Damage:|n"
        .."|n"
        ..self.string.defensive -- header
        .."|n"
        .."Damage Reduction:|n"
        .."Dodge Rating:|n"
        .."Armor Rating:|n"
        .."Absorb on Spell:|n"
    self.enhtextright2 = 
        self.string.second2 -- header
        .."|n"
        .."Missile Range:|n"
        .."Ability Radius:|n"
        .."Casting Speed:|n"
        .."Ele. Lifesteal:|n"
        .."Phys. Lifesteal:|n"
        .."Thorns:|n"
        .."Add Arcane Dmg.:|n"
        .."Add Frost Dmg.:|n"
        .."Add Nature Dmg.:|n"
        .."Add Fire Dmg.:|n"
        .."Add Shadow Dmg.:|n"
        .."Add Phys. Dmg.:|n"
    self.itemtipfh = {
        [1] = BlzGetFrameByName("FrameItemTooltipBackdrop",0),
        [2] = BlzGetFrameByName("FrameItemTooltipItemIcon",0),
        [3] = BlzGetFrameByName("FrameItemTooltipItemRarityIcon",0),
        [4] = BlzGetFrameByName("FrameItemTooltipName",0),
        [5] = BlzGetFrameByName("FrameItemTooltipDescription",0),
        [6] = BlzGetFrameByName("FrameItemTooltipLevel",0),
        [7] = BlzGetFrameByName("FrameItemTooltipGoldValue",0),
        [8] = BlzGetFrameByName("FrameItemTooltipGoldIcon",0),
    }
    self.itemcompfh = {
        [1] = BlzGetFrameByName("FrameItemCompTooltipBackdrop",0),
        [2] = BlzGetFrameByName("FrameItemCompTooltipItemIcon",0),
        [3] = BlzGetFrameByName("FrameItemCompTooltipItemRarityIcon",0),
        [4] = BlzGetFrameByName("FrameItemCompTooltipName",0),
        [5] = BlzGetFrameByName("FrameItemCompTooltipDescription",0),
        [6] = BlzGetFrameByName("FrameItemCompTooltipLevel",0),
        [7] = BlzGetFrameByName("FrameItemCompTooltipGoldValue",0),
        [8] = BlzGetFrameByName("FrameItemCompTooltipGoldIcon",0),
        [9] = BlzGetFrameByName("FrameItemCompTooltipTitleBackdrop",0),
    }
    self.advtipfh = {
        [1] = BlzGetFrameByName("FrameLongformTooltipItemIcon",0),
        [2] = BlzGetFrameByName("FrameLongformTooltipName",0),
        [3] = BlzGetFrameByName("FrameLongformTooltipDescription",0),
        [4] = BlzGetFrameByName("FrameLongformTooltipBackdrop",0),
    }
end


function tooltip:basictemplate()
    -- single line tip that auto-expands horizontally.
    --  we handle the width calculation based on char count.
    return kui.frame:newbyname("FrameBasicTooltip", kui.gameui)
end


-- @pobj = the player object to read data from.
function tooltip:charcleanse(pobj)
    -- TODO: the performance way to do this would be to
    --  have a frame for each piece of stat text.
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- left block 1
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    local lval = 
        "|n"..tooltip:getstat(pobj[p_stat_arcane]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_frost]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_nature]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_fire]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_shadow]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_phys]).."|r|n"
        .."|n|n"
        ..tooltip:getstat(pobj[p_stat_bhp]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_bmana]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_bms]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_wax]).."|r"
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- right block 1
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    local rval = 
        "|n"..tooltip:getcappedval(pobj[p_stat_arcane_res], 75).."|r|n"
        ..tooltip:getcappedval(pobj[p_stat_frost_res], 75).."|r|n"
        ..tooltip:getcappedval(pobj[p_stat_nature_res], 75).."|r|n"
        ..tooltip:getcappedval(pobj[p_stat_fire_res], 75).."|r|n"
        ..tooltip:getcappedval(pobj[p_stat_shadow_res], 75).."|r|n"
        ..tooltip:getcappedval(pobj[p_stat_phys_res], 75).."|r|n"
        .."|n|n"
        ..tooltip:getstat(pobj[p_stat_healing]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_absorb]).."|r|n"
        ..tooltip:getcappedval(pobj[p_stat_eleproc], 75).."|r|n"
        ..tooltip:getstat(pobj[p_stat_minepwr]).."|r|n"
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- left block 2
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    local lval2 = 
        "|n"..tooltip:getstat(pobj[p_stat_treasure]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_digxp]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_vendor]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_potionpwr]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_artifactpwr]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_miniondmg]).."|r|n"
        .."|n|n"
        ..tooltip:getcappedval(pobj[p_stat_dmg_reduct], 90).."|r|n"
        ..tooltip:getstat(pobj[p_stat_dodge], true).."|r|n"
        ..tooltip:getstat(pobj[p_stat_armor], true).."|r|n"
        ..tooltip:getstat(pobj[p_stat_shielding], true).."|r|n"
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- right block 2
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    local rval2 = 
        "|n"..tooltip:getstat(pobj[p_stat_mislrange]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_abilarea]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_castspeed]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_elels]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_physls]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_thorns], true).."|r|n"
        ..tooltip:getstat(pobj[p_stat_dmg_arcane]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_dmg_frost]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_dmg_nature]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_dmg_fire]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_dmg_shadow]).."|r|n"
        ..tooltip:getstat(pobj[p_stat_dmg_phys]).."|r|n"
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    return self.enhtextleft, self.enhtextleft2, self.enhtextright, self.enhtextright2, lval, lval2, rval, rval2
end


function tooltip:getstat(val, _isint)
    local append
    if _isint then append = "" else append = "%%" end
    self.temp = math.floor(val)
    if self.temp > 0 then
        self.temp = color:wrap(color.tooltip.good, self.temp..append)
    else
        self.temp = color:wrap(color.txt.txtdisable, self.temp..append)
    end
    return self.temp
end


function tooltip:convertval(val, pointval, _shouldfloor)
    -- if each point should equal a different display value, convert it (i.e. 1 pt = 0.25%)
    if _shouldfloor then
        return math.floor(val*pointval)
    else
        return val*pointval
    end
end


function tooltip:getcappedval(val, cap)
    self.temp = val
    if self.temp > cap then
        self.temp = color:wrap(color.tooltip.alert, cap.."%%")
    else
        self.temp = tooltip:getstat(val)
    end
    return self.temp
end


function tooltip:updatecharpage(p)
    if p == utils.localp() then
        local _,_,_,_,newlval1,newlval2,newrval1,newrval2 = tooltip:charcleanse(kobold.player[p])
        kui.canvas.game.char.page[1].rval:settext(newrval1)
        kui.canvas.game.char.page[2].rval:settext(newrval2)
        kui.canvas.game.char.page[1].lval:settext(newlval1)
        kui.canvas.game.char.page[2].lval:settext(newlval2)
        kui.canvas.game.char.attr[1]:settext(math.floor(kobold.player[p][p_stat_strength] + kobold.player[p][p_stat_strength_b]))
        kui.canvas.game.char.attr[2]:settext(math.floor(kobold.player[p][p_stat_wisdom]   + kobold.player[p][p_stat_wisdom_b]))
        kui.canvas.game.char.attr[3]:settext(math.floor(kobold.player[p][p_stat_alacrity] + kobold.player[p][p_stat_alacrity_b]))
        kui.canvas.game.char.attr[4]:settext(math.floor(kobold.player[p][p_stat_vitality] + kobold.player[p][p_stat_vitality_b]))
    end
end
