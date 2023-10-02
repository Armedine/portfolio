shop = {}


function shop:init()
    -- globals
    shop_selected_card_id = {} -- array for each player
    shop_selected_ore_id  = {} -- ``
    shop_vendor_type_open = {} -- `` 0 = shinykeeper, 1 = elementalist
    greywhisker_selected_card = {}
     -- map shop card order to actual slot ids:
    shop_slotid_map = {slot_outfit,slot_leggings,slot_gloves,slot_potion,slot_backpack,slot_artifact,slot_candle,slot_boots,slot_helmet,slot_tool}
    self.__index = self
    self.fr      = kui.frame:newbytype("BACKDROP", kui.canvas.game)
    self.fr:setbgtex('war3mapImported\\panel-shop-backdrop.blp')
    self.fr:setsize(kui:px(1200), kui:px(675))
    self.fr:setfp(fp.b, fp.b, kui.worldui, 0, kui:px(325))
    self.fr:setlvl(1)
    self.fr.showfunc = function()
        self:updateframes()
        self:resetselection()
    end
    self.fr.hidefunc = function()
        self:resetselection()
    end
    -- shinykeeper currency pane:
    self.fr.shinypane = kui.frame:newbytype("BACKDROP", self.fr)
    self.fr.shinypane:setbgtex('war3mapImported\\panel-shop-currency-bg-shinykeeper.blp')
    self.fr.shinypane:setsize(kui:px(339), kui:px(208))
    self.fr.shinypane:setfp(fp.bl, fp.bl, self.fr, kui:px(64), kui:px(124))
    self.fr.shinypane.title = self.fr.shinypane:createbtntext('SPEND GOLD|nTO CRAFT ITEMS')
    self.fr.shinypane.title:setfp(fp.c, fp.b, self.fr.shinypane, 0, kui:px(130))
    self.fr.shinypane.title:setsize(kui:px(350), kui:px(80))
    self.fr.shinypane.goldtxt = self.fr.shinypane:createbtntext('0')
    self.fr.shinypane.goldtxt:setfp(fp.bl, fp.bl, self.fr.shinypane, kui:px(156), kui:px(46))
    self.fr.shinypane.goldtxt:setsize(kui:px(130), kui:px(40))
    BlzFrameSetTextAlignment(self.fr.shinypane.goldtxt.fh, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
    self.fr.shinypane.shopname = self.fr.shinypane:createheadertext('The Shinykeeper')
    self.fr.shinypane.shopname:setsize(kui:px(350), kui:px(40))
    self.fr.shinypane.shopname:setfp(fp.c, fp.bl, self.fr, kui:px(246), kui:px(622))
    self.fr.shinypane.portrait = kui.frame:newbytype("BACKDROP", self.fr.shinypane)
    self.fr.shinypane.portrait:setbgtex('war3mapImported\\panel-shop-vendor-splash-shinykeeper.blp')
    self.fr.shinypane.portrait:setsize(kui:px(444), kui:px(348))
    self.fr.shinypane.portrait:setfp(fp.c, fp.bl, self.fr, kui:px(242), kui:px(482))
    -- elementalist currency pane:
    self.fr.elepane = kui.frame:newbytype("BACKDROP", self.fr)
    self.fr.elepane.showfunc = function() self:updateframes() self.fr.sellore:hide() end
    self.fr.elepane:setlvl(1)
    self.fr.elepane:setbgtex('war3mapImported\\panel-shop-currency-bg-elementalist.blp')
    self.fr.elepane:setsize(kui:px(339), kui:px(208))
    self.fr.elepane:setfp(fp.bl, fp.bl, self.fr, kui:px(64), kui:px(124))
    self.fr.elepane.title = self.fr.elepane:createbtntext('SELECT AN ORE TO USE')
    self.fr.elepane.title:setfp(fp.c, fp.b, self.fr.elepane, 0, kui:px(166))
    self.fr.elepane.title:setsize(kui:px(350), kui:px(28))
    self.fr.elepane.select = kui.frame:newbytype("BACKDROP", self.fr.elepane)
    self.fr.elepane.select:setbgtex('war3mapImported\\panel-shop-selection-circle.blp')
    self.fr.elepane.select:setsize(kui:px(94), kui:px(97))
    self.fr.elepane.select:setfp(fp.c, fp.c, self.fr.elepane, 0, 0)
    self.fr.elepane.select:setlvl(7)
    self.fr.elepane.select:hide()
    self.fr.elepane.portrait = kui.frame:newbytype("BACKDROP", self.fr.elepane)
    self.fr.elepane.portrait:setbgtex('war3mapImported\\panel-shop-vendor-splash-elementalist.blp')
    self.fr.elepane.portrait:setsize(kui:px(444), kui:px(348))
    self.fr.elepane.portrait:setfp(fp.c, fp.bl, self.fr, kui:px(242), kui:px(482))
    -- hover glow effect:
    self.fr.hoverglow = kui.frame:newbytype("BACKDROP", self.fr)
    self.fr.hoverglow:setbgtex('war3mapImported\\panel-shop_ore_selection.blp')
    self.fr.hoverglow:setsize(kui:px(80), kui:px(70))
    self.fr.hoverglow:setlvl(6)
    self.fr.hoverglow:hide()
    -- hover glow functions:
    local hoverenter = function(targetfr) self.fr.hoverglow:setfp(fp.c, fp.c, targetfr, kui:px(2.5), 0) self.fr.hoverglow:show() end
    local hoverleave = function(targetfr) self.fr.hoverglow:hide() end
    -- crafting functions:
    local checkcrafteligible = function()
        if shop_vendor_type_open[utils.trigpnum()] == 0 and shop_selected_card_id[utils.trigpnum()] > 0 then -- shinykeeper
            self.fr.craftinactive:hide()
            self.fr.craftactive:show()
        elseif shop_vendor_type_open[utils.trigpnum()] == 1 and shop_selected_ore_id[utils.trigpnum()] > 0 and shop_selected_card_id[utils.trigpnum()] > 0 then -- elementalist
            self.fr.craftinactive:hide()
            self.fr.craftactive:show()
        end
    end
    local clicksellore  = function()
        local p    = utils.trigp()
        local pobj = kobold.player[p]
        if pobj.ore[shop_selected_ore_id[utils.trigpnum()]] >= 1 then
            utils.playsound(kui.sound.goldcoins, p)
            pobj:awardgold(20)
            pobj.ore[shop_selected_ore_id[utils.trigpnum()]] = pobj.ore[shop_selected_ore_id[utils.trigpnum()]] - 1
            self:updateframes()
        else
            alert:new(color:wrap(color.tooltip.bad, "You have no ore to sell!"))
        end
        pobj = nil
    end
    local clickbuyore  = function()
        local p    = utils.trigp()
        local pobj = kobold.player[p]
        if pobj.gold >= 40 then
            utils.playsound(kui.sound.goldcoins, p)
            pobj:awardgold(-40)
            pobj:awardoretype(shop_selected_ore_id[utils.trigpnum()], 1)
            self:updateframes()
        else
            alert:new(color:wrap(color.tooltip.bad, "You don't have enough gold!"))
        end
        pobj = nil
    end
    local clickcraftbtn = function()
        -- this function uses waterfall logic, returning 'true' denotes item crafted,
        -- returning 'false' is a failed condition shared between both shops or that specific shop.
        local p, pnum    = utils.trigp(), utils.trigpnum()
        local gcost = self.fr.card[shop_selected_card_id[pnum]].costval
        local pobj = kobold.player[p]
        -- check default conditions to craft:
        if shop_vendor_type_open[pnum] == 0 and pobj.gold < gcost then
            utils.palert(p, color:wrap(color.tooltip.bad, "You don't have enough gold!"))
            return false
        end
        if loot:isbagfull(p) then
            utils.palert(p, color:wrap(color.tooltip.bad, "Your bags are full!"))
            return false
        end
        -- shop-specific craft actions:
        if shop_vendor_type_open[pnum] == 0 then -- shinykeeper
            local maxrarity = rarity_rare
            if quest_shinykeeper_upgrade_2 then maxrarity = rarity_epic end
            loot:generate(p, pobj.level, shop_slotid_map[shop_selected_card_id[pnum]],
                loot:getrandomrarity(rarity_common, maxrarity, pobj:getlootodds()), true).sellsfor = math.floor(gcost*0.1)
            utils.playsound(kui.sound.eleforge, p)
        elseif shop_vendor_type_open[pnum] == 1 then -- elementalist
            if pobj.ore[shop_selected_ore_id[pnum]] < self.fr.card[shop_selected_card_id[pnum]].costval then
                utils.palert(p, color:wrap(color.tooltip.bad, "You don't have enough ore!"))
                return false
            end
            local maxrarity = rarity_rare
            if quest_elementalist_upgrade_2 then maxrarity = rarity_epic end
            local goldworth = math.floor(25 + math.random(pobj.level^1.05,pobj.level^1.1) + self.fr.card[shop_selected_card_id[pnum]].costval*5)
            loot:generateforcedelement(p, pobj.level, shop_slotid_map[shop_selected_card_id[pnum]],
                loot:getrandomrarity(rarity_common, maxrarity, pobj:getlootodds()), shop_selected_ore_id[pnum]).sellsfor = goldworth
            pobj:awardoretype(shop_selected_ore_id[pnum], -self.fr.card[shop_selected_card_id[pnum]].costval)
            utils.playsound(kui.sound.eleforge, p)
        end
        -- wrap-up:
        pobj:awardgold(-self.fr.card[shop_selected_card_id[pnum]].costval)
        alert:new(color:wrap(color.tooltip.good, "Item crafted!"))
        pobj = nil
        return true
    end
    -- sell ore button:
    self.fr.sellore = kui.frame:newbtntemplate(self.fr, 'war3mapImported\\inventory-icon_sell.blp')
    self.fr.sellore:setsize(kui:px(32),kui:px(32))
    self.fr.sellore.btn:assigntooltip("sellore")
    self.fr.sellore.btn:addevents(nil, nil, clicksellore)
    self.fr.sellore:setlvl(6)
    self.fr.sellore:hide()
    -- buy ore button:
    self.fr.buyore = kui.frame:newbtntemplate(self.fr, 'war3mapImported\\btn-purchase.blp')
    self.fr.buyore:setsize(kui:px(32),kui:px(32))
    self.fr.buyore.btn:assigntooltip("buyore")
    self.fr.buyore.btn:addevents(nil, nil, clickbuyore)
    self.fr.buyore:setlvl(6)
    self.fr.buyore:hide()
    self.fr.elepane.ore = {}
    local x,y = 68,121
    for i = 1,6 do
        if i == 4 then
            x = 68
            y = 52
        elseif i > 1 then
            x = x + 107
        end
        self.fr.elepane.ore[i] = kui.frame:newbtntemplate(self.fr.elepane, kui.tex.invis)
        self.fr.elepane.ore[i].costval = 10 -- use for pricing logic.
        self.fr.elepane.ore[i].btn:assigntooltip(kui.meta.oretooltip[i])
        self.fr.elepane.ore[i]:setsize(kui:px(60), kui:px(60))
        self.fr.elepane.ore[i]:setfp(fp.c, fp.bl, self.fr.elepane, kui:px(x), kui:px(y))
        self.fr.elepane.ore[i].costtxt = self.fr.elepane.ore[i]:createbtntext(self.fr.elepane.ore[i].costval)
        self.fr.elepane.ore[i].costtxt:setfp(fp.b, fp.b, self.fr.elepane.ore[i], 0, kui:px(-5))
        self.fr.elepane.ore[i].costtxt:setsize(kui:px(40), kui:px(18))
        -- select ore:
        local selectfunc = function()
            -- set picked ore:
            if shop_selected_ore_id[utils.trigpnum()] ~= i then
                shop_selected_ore_id[utils.trigpnum()] = i
                if utils.islocaltrigp() then
                    self.fr.elepane.select:show()
                    self.fr.elepane.select:setfp(fp.c, fp.c, self.fr.elepane.ore[i], kui:px(-2), 0)
                    utils.playsound(kui.sound.itemsel, utils.trigp())
                    -- move sell btn to this ore:
                    self.fr.sellore:setfp(fp.tl, fp.br, self.fr.elepane.ore[i], kui:px(-15), kui:px(15))
                    self.fr.sellore:show()
                    self.fr.buyore:setfp(fp.tr, fp.bl, self.fr.elepane.ore[i], kui:px(10), kui:px(15))
                    self.fr.buyore:show()
                end
            end
        end
        self.fr.elepane.ore[i].btn:addevents(
            function() hoverenter(self.fr.elepane.ore[i]) end,
            function() hoverleave(self.fr.elepane.ore[i]) end,
            selectfunc)
        self.fr.elepane.ore[i].btn:addevents(nil, nil, checkcrafteligible)
    end
    self.fr.elepane.shopname = self.fr.elepane:createheadertext('The Elementalist')
    self.fr.elepane.shopname:setsize(kui:px(350), kui:px(40))
    self.fr.elepane.shopname:setfp(fp.c, fp.bl, self.fr, kui:px(246), kui:px(622))
    self.fr.elepane:hide()
    -- select item center tooltip:
    self.fr.tiptxt = self.fr:createbtntext('SELECT AN ITEM TO BUILD')
    self.fr.tiptxt:setsize(kui:px(350), kui:px(40))
    self.fr.tiptxt:setfp(fp.c, fp.bl, self.fr, kui:px(834), kui:px(384))
    -- item selection circle:
    self.fr.select = kui.frame:newbytype("BACKDROP", self.fr)
    self.fr.select:setbgtex('war3mapImported\\panel-shop-selection-circle.blp')
    self.fr.select:setsize(kui:px(134), kui:px(139))
    self.fr.select:setfp(fp.c, fp.c, self.fr, 0, 0)
    self.fr.select:setlvl(5)
    self.fr.select:hide()
    -- invisible close button:
    self.fr.closebtn = kui.frame:newbtntemplate(self.fr, kui.tex.invis)
    self.fr.closebtn.btn:assigntooltip("closebtn")
    self.fr.closebtn.btn:linkcloseevent(self.fr)
    self.fr.closebtn:setsize(kui:px(182), kui:px(72))
    self.fr.closebtn:setfp(fp.c, fp.bl, self.fr, kui:px(158), kui:px(60))
    -- create shop cards and attach icon buttons:
    self.fr.card = {}
    local x,y = 462,386
    for i = 1, 10 do
        if i == 6 then
            x = 462
            y = 109
        elseif i > 1 then
            x = x + 145
        end
        self.fr.card[i] = kui.frame:newbytype("BACKDROP", self.fr)
        self.fr.card[i]:setbgtex('war3mapImported\\panel-shop-card.blp')
        self.fr.card[i]:setsize(kui:px(145), kui:px(275))
        self.fr.card[i]:setfp(fp.bl, fp.bl, self.fr, kui:px(x), kui:px(y))
        if i < 10 then -- hacky fix for path string.
            self.fr.card[i].icon = kui.frame:newbtntemplate(self.fr.card[i], 'war3mapImported\\item_loot_icons_crafting_generic_0'..i..'.blp')
        else
            self.fr.card[i].icon = kui.frame:newbtntemplate(self.fr.card[i], 'war3mapImported\\item_loot_icons_crafting_generic_'..i..'.blp')
        end
        self.fr.card[i].icon:setsize(kui:px(64), kui:px(64))
        self.fr.card[i].icon:setfp(fp.b, fp.b, self.fr.card[i], kui:px(-1), kui:px(108))
        self.fr.card[i].icon:setlvl(7)
        -- card text:
        if i == 4 or i == 5 or i == 6 or i == 7 or i == 10 then
            self.fr.card[i].costval = 200
        else
            self.fr.card[i].costval = 100 -- use this for price logic.
        end
        self.fr.card[i].costtxt = self.fr.card[i]:createbtntext('Cost: '..color:wrap(color.ui.gold, self.fr.card[i].costval))
        self.fr.card[i].costtxt:setfp(fp.c, fp.b, self.fr.card[i], 0, kui:px(67))
        self.fr.card[i].cardname = self.fr.card[i]:createbtntext(loot:getslotname(shop_slotid_map[i]))
        self.fr.card[i].cardname:setfp(fp.c, fp.b, self.fr.card[i], 0, kui:px(205))
        -- select card:
        local selectfunc = function()
            if shop_selected_card_id[utils.trigpnum()] ~= i then
                shop_selected_card_id[utils.trigpnum()] = i
                if utils.islocaltrigp() then
                    self.fr.select:show()
                    self.fr.select:setfp(fp.c, fp.c, self.fr.card[i].icon, 0, 0)
                    utils.playsound(kui.sound.itemsel, utils.trigp())
                end
            end
        end
        self.fr.card[i].icon.btn:addevents(
            function() hoverenter(self.fr.card[i]) end,
            function() hoverleave(self.fr.card[i]) end,
            selectfunc)
        self.fr.card[i].icon.btn:addevents(nil, nil, checkcrafteligible)
    end
    -- craft button:
    self.fr.craftinactive = kui.frame:newbtntemplate(self.fr, 'war3mapImported\\panel-shop-craft-inactive.blp')
    self.fr.craftinactive:setsize(kui:px(106), kui:px(109))
    self.fr.craftinactive:setfp(fp.c, fp.bl, self.fr, kui:px(1116), kui:px(60))
    self.fr.craftactive = kui.frame:newbtntemplate(self.fr, 'war3mapImported\\panel-shop-craft-active.blp')
    self.fr.craftactive.btn:assigntooltip("craftitem")
    self.fr.craftactive:setallfp(self.fr.craftinactive)
    self.fr.craftactive:hide()
    self.fr.craftactive.btn:addevents(nil, nil, clickcraftbtn)
    self.fr:hide() -- hidden by default
    self:buildgreywhisker()
end


function shop:buildgreywhisker()
    self.gwfr = kui.frame:newbytype("BACKDROP", kui.canvas.game)
    self.gwfr:setbgtex('war3mapImported\\panel-shop-backdrop_small.blp')
    self.gwfr:setsize(kui:px(648), kui:px(664))
    self.gwfr:setfp(fp.b, fp.b, kui.worldui, 0, kui:px(325))
    self.gwfr:setlvl(1)
    self.gwfr.showfunc = function()
        self:updateframes()
        self:resetselection()
        self.gwfr.craftinactive:show()
        self.gwfr.craftactive:hide()
        self.gwfr.select:hide()
        self.gwfr.hoverglow:hide()
        self.fr:hide() -- hide other shops.
    end
    self.gwfr.hidefunc = function()
        self:resetselection()
    end
    self.gwfr.hoverglow = kui.frame:newbytype("BACKDROP", self.gwfr)
    self.gwfr.hoverglow:setbgtex('war3mapImported\\panel-shop_ore_selection.blp')
    self.gwfr.hoverglow:setsize(kui:px(80), kui:px(70))
    self.gwfr.hoverglow:setlvl(6)
    self.gwfr.hoverglow:hide()
    self.gwfr.portrait = kui.frame:newbytype("BACKDROP", self.gwfr)
    self.gwfr.portrait:setbgtex('war3mapImported\\panel-greywhisker_portrait.blp')
    self.gwfr.portrait:setsize(kui:px(385), kui:px(298))
    self.gwfr.portrait:setfp(fp.c, fp.b, self.gwfr, 0, kui:px(464))
    self.gwfr.shopname = self.gwfr:createheadertext('The Greywhisker')
    self.gwfr.shopname:setsize(kui:px(350), kui:px(40))
    self.gwfr.shopname:setfp(fp.c, fp.b, self.gwfr, 0, kui:px(615))
    self.gwfr.select = kui.frame:newbytype("BACKDROP", self.gwfr)
    self.gwfr.select:setbgtex('war3mapImported\\panel-shop-selection-circle.blp')
    self.gwfr.select:setsize(kui:px(94), kui:px(97))
    self.gwfr.select:setfp(fp.c, fp.c, self.gwfr, 0, 0)
    self.gwfr.select:setlvl(7)
    self.gwfr.select:hide()
    local hoverenter = function(targetfr) self.gwfr.hoverglow:setfp(fp.c, fp.c, targetfr, kui:px(2.5), 0) self.gwfr.hoverglow:show() end
    local hoverleave = function(targetfr) self.gwfr.hoverglow:hide() end
    local x,y = 40, 101
    self.gwfr.card = {}
    for i = 1,5 do
        self.gwfr.card[i] = kui.frame:newbytype("BACKDROP", self.gwfr)
        if i == 5 then
            self.gwfr.card[i].costval = 15
        else
            self.gwfr.card[i].costval = 5
        end
        self.gwfr.card[i]:setbgtex('war3mapImported\\panel-shop-card.blp')
        self.gwfr.card[i]:setsize(kui:px(113), kui:px(215))
        self.gwfr.card[i]:setfp(fp.bl, fp.bl, self.gwfr, kui:px(x), kui:px(y))
        self.gwfr.card[i].icon = kui.frame:newbtntemplate(self.gwfr.card[i], loot.itemtable[slot_digkey][i].icon)
        self.gwfr.card[i].icon:setsize(kui:px(64), kui:px(64))
        self.gwfr.card[i].icon:setfp(fp.b, fp.b, self.gwfr.card[i], kui:px(-1), kui:px(78))
        self.gwfr.card[i].icon:setlvl(7)
        self.gwfr.card[i].icon.btn:assigntooltip("relic"..tostring(i))
        self.gwfr.card[i].costtxt = self.gwfr.card[i].icon:createbtntext('Cost: '..color:wrap(color.rarity.ancient, self.gwfr.card[i].costval))
        self.gwfr.card[i].costtxt:setfp(fp.c, fp.b, self.gwfr.card[i], 0, kui:px(53))
        self.gwfr.card[i].icon.btn:addevents(
            function() hoverenter(self.gwfr.card[i]) end,
            function() hoverleave(self.gwfr.card[i]) end,
            function()
                if greywhisker_selected_card[utils.trigpnum()] ~= i then
                    greywhisker_selected_card[utils.trigpnum()] = i
                    if utils.islocaltrigp() then
                        self.gwfr.select:show()
                        self.gwfr.select:setfp(fp.c, fp.c, self.gwfr.card[i].icon, 0, 0)
                        utils.playsound(kui.sound.itemsel, utils.trigp())
                    end
                end
                self.gwfr.craftinactive:hide()
                self.gwfr.craftactive:show()
            end)
        x = x + 114
        self.gwfr.card[i].icon:hide()
    end
    -- close:
    self.gwfr.closebtn = kui.frame:newbtntemplate(self.gwfr, kui.tex.invis)
    self.gwfr.closebtn.btn:assigntooltip("closebtn")
    self.gwfr.closebtn.btn:linkcloseevent(self.gwfr)
    self.gwfr.closebtn:setsize(kui:px(182), kui:px(72))
    self.gwfr.closebtn:setfp(fp.c, fp.bl, self.gwfr, kui:px(154), kui:px(51))
    -- currency:
    self.gwfr.currency = kui.frame:newbtntemplate(self.gwfr, "war3mapImported\\panel-greywhisker_currency.blp")
    self.gwfr.currency:setsize(kui:px(156), kui:px(70))
    self.gwfr.currency:setfp(fp.c, fp.bl, self.gwfr, kui:px(395), kui:px(53))
    self.gwfr.currency.btn:assigntooltip("fragments")
    self.gwfr.currency.txt = self.gwfr.currency:createbtntext("0")
    self.gwfr.currency.txt:setfp(fp.r, fp.bl, self.gwfr.currency, kui:px(108), kui:px(33))
    self.gwfr.currency.txt:assigntooltip("fragments")
    BlzFrameSetTextAlignment(self.gwfr.currency.txt.fh, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_RIGHT)
    -- craft:
    local clickcraftbtn = function()
        -- this function uses waterfall logic, returning 'true' denotes item crafted,
        -- returning 'false' is a failed condition shared between both shops or that specific shop.
        local p, pnum    = utils.trigp(), utils.trigpnum()
        local cost = self.gwfr.card[greywhisker_selected_card[pnum]].costval
        local pobj = kobold.player[p]
        -- check default conditions to craft:
        if pobj.ancientfrag < cost then
            utils.palert(p, color:wrap(color.tooltip.bad, "You don't have enough fragments!"))
            return false
        end
        if loot:isbagfull(p) then
            utils.palert(p, color:wrap(color.tooltip.bad, "Your bags are full!"))
            return false
        end
        loot:generatedigkey(p, 1, greywhisker_selected_card[pnum])
        utils.playsound(kui.sound.reliccraft, p)
        pobj:awardfragment(-self.gwfr.card[greywhisker_selected_card[pnum]].costval)
        -- wrap-up:
        alert:new(color:wrap(color.tooltip.good, "Key crafted!"))
        pobj = nil
        return true
    end
    -- buy frag:
    local clickbuyfrag = function()
        local p    = utils.trigp()
        local pobj = kobold.player[p]
        if pobj.gold >= 300 then
            utils.playsound(kui.sound.goldcoins, p)
            pobj:awardgold(-300)
            pobj:awardfragment(1)
            self:updateframes()
        else
            alert:new(color:wrap(color.tooltip.bad, "You don't have enough gold!"))
        end
        pobj = nil
    end
    self.gwfr.craftinactive = kui.frame:newbtntemplate(self.gwfr, 'war3mapImported\\panel-shop-craft-inactive.blp')
    self.gwfr.craftinactive:setsize(kui:px(106), kui:px(109))
    self.gwfr.craftinactive:setfp(fp.c, fp.br, self.gwfr, kui:px(-75), kui:px(50))
    self.gwfr.craftactive = kui.frame:newbtntemplate(self.gwfr, 'war3mapImported\\panel-shop-craft-active.blp')
    self.gwfr.craftactive.btn:assigntooltip("greywhiskercraft")
    self.gwfr.craftactive:setallfp(self.gwfr.craftinactive)
    self.gwfr.craftactive:hide()
    self.gwfr.craftactive.btn:addevents(nil, nil, clickcraftbtn)
    -- buy ore:
    self.gwfr.buyfrag = kui.frame:newbtntemplate(self.gwfr, 'war3mapImported\\btn-purchase.blp')
    self.gwfr.buyfrag:setsize(kui:px(32),kui:px(32))
    self.gwfr.buyfrag:setfp(fp.c, fp.br, self.gwfr, kui:px(-189),kui:px(54))
    self.gwfr.buyfrag.btn:assigntooltip("buyfragment")
    self.gwfr.buyfrag.btn:addevents(nil, nil, clickbuyfrag)
    self.gwfr.buyfrag:setlvl(6)
    -- select item center tooltip:
    self.gwfr.tiptxt = self.gwfr:createbtntext('SELECT A KEY TO CONJURE')
    self.gwfr.tiptxt:setsize(kui:px(350), kui:px(40))
    self.gwfr.tiptxt:setfp(fp.c, fp.b, self.gwfr, 0, kui:px(325))
    self.gwfr:hide()
end


-- update displayed values for various frames.
function shop:updateframes()
    for pnum = 1,kk.maxplayers do
        if kobold.player[utils.getp(pnum)] and kobold.player[utils.getp(pnum)]:islocal() then
            -- update player ore:
            for i = 1,6 do
                if kobold.player[utils.getp(pnum)].ore[i] > 0 then
                    BlzFrameSetText(self.fr.elepane.ore[i].costtxt.fh, color:wrap(color.tooltip.good, kobold.player[utils.getp(pnum)].ore[i]))
                else
                    BlzFrameSetText(self.fr.elepane.ore[i].costtxt.fh, color:wrap(color.txt.txtdisable, 0))
                end
            end
            -- update gold:
            BlzFrameSetText(self.fr.shinypane.goldtxt.fh, kobold.player[utils.getp(pnum)].gold or 0)
            BlzFrameSetText(self.gwfr.currency.txt.fh, kobold.player[utils.getp(pnum)].ancientfrag or 0)
        end
    end
end


function shop:toggleshopopen()
    -- uses waterfall logic to recycle shop assets; 'true' return = vendor is displayed.
    if utils.islocaltrigp() then
        -- always update to target shop:
        if shop_vendor_type_open[utils.trigpnum()] == 0 then -- shinykeeper
            if self.fr.shinypane:isvisible() then
                self:close()
                return false
            else
                self.fr.shinypane:show()
                self.gwfr:hide()
                self.fr.elepane:hide()
                for i = 1,10 do
                    if i == 4 or i == 5 or i == 6 or i == 7 or i == 10 then
                        self.fr.card[i].costval = 225
                    else
                        self.fr.card[i].costval = 125
                    end
                    self.fr.card[i].costtxt:settext('Cost: '..color:wrap(color.ui.gold, self.fr.card[i].costval))
                end
                self:resetselection()
            end
        elseif shop_vendor_type_open[utils.trigpnum()] == 1 then -- elementalist
            if self.fr.elepane:isvisible() then
                self:close()
                return false
            else
                self.fr.shinypane:hide()
                self.gwfr:hide()
                self.fr.elepane:show()
                for i = 1,10 do
                    if i == 4 or i == 5 or i == 6 or i == 7 or i == 10 then
                        self.fr.card[i].costval = 20
                    else
                        self.fr.card[i].costval = 10
                    end
                    self.fr.card[i].costtxt:settext('Cost: '..color:wrap(color.tooltip.alert, self.fr.card[i].costval))
                end
                self:resetselection()
            end
        end
        -- check whether to close/open or do nothing and leave the swap update from above:
        if not self.fr:isvisible() then
            utils.playsound(kui.sound.panel[2].open, utils.trigp())
            self.fr:show()
            return true
        else
            utils.playsound(kui.sound.closebtn, utils.trigp())
            return true
        end
        self:close()
        return false
    end
end


function shop:resetselection()
    shop_selected_card_id[utils.trigpnum()] = 0
    shop_selected_ore_id[utils.trigpnum()] = 0
    greywhisker_selected_card[utils.trigpnum()] = 0
    self.fr.craftinactive:show()
    self.fr.craftactive:hide()
    self.fr.sellore:hide()
    self.fr.buyore:hide()
    self.fr.select:hide()
    self.fr.hoverglow:hide()
    self.fr.elepane.select:hide()
end


function shop:close()
    utils.playsound(kui.sound.panel[2].close, utils.trigp())
    self.fr:hide()
end
