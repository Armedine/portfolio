quest = {}
quest.lineage = {}


function quest:init()
    self.__index    = self
    self.log        = {} -- store quest objects here.
    self.id         = 0
    self.xpaward    = 250
    self.lvlaward   = 0
    self.minimized  = false -- flag for knowing if frame is min'd or max'd.
    self.collectable= false -- flag for allowing quest gathering.
    self.triggered  = false -- flag for preventing repeat triggers.
    self.complete   = false -- flag to allow completion.
    self.awardfunc  = nil   -- if present, run this function on completion for bonus effects.
    self.startfunc  = nil   -- if present, run this function on completion for bonus effects.

    -- trigger listening for speech events:
    self.trig       = CreateTrigger()
    self.speakcode  = FourCC('A03B')
    TriggerRegisterAnyUnitEventBJ(self.trig, EVENT_PLAYER_UNIT_SPELL_EFFECT)
    TriggerAddAction(quest.trig, function()
        utils.debugfunc( function()
            if GetSpellAbilityId() == quest.speakcode then
                local target = GetSpellTargetUnit()
                if not quest.current or (not (quest.current.endunit == target and quest.current.complete) and not (quest.current.startunit == target and quest.current.collectable)) then
                    if target == udg_actors[2] and quest_shinykeeper_unlocked then -- shinykeeper
                        shop_vendor_type_open[utils.trigpnum()] = 0
                        shop:toggleshopopen()
                    elseif target == udg_actors[4] and quest_elementalist_unlocked then -- elementalist.
                        shop_vendor_type_open[utils.trigpnum()] = 1
                        shop:toggleshopopen()
                    elseif target == udg_actors[8] and quest_greywhisker_unlocked then -- elementalist.
                        utils.playsound(kui.sound.panel[2].open, utils.unitp())
                        shop.gwfr:show()
                    end
                end
            end
        end, "open shop speak")
    end)
    -- globals:
    quest.inprogress = false -- flag to signal that a quest is activated and in progress.
    quests_total_completed = 0

    -- quest-specific mission types (for descriptions and completion logic):
    m_type_speak            = 0
    -- from map.mission:
    -- m_type_monster_hunt  = 1
    -- m_type_boss_fight    = 2
    -- m_type_gold_rush     = 3
    -- m_type_candle_heist  = 4
    
    quest:dataload() -- from questdata.

    -- activate quest frame:
    self.parentfr = kui.frame:newbytype("PARENT", kui.canvas.gameui)
    -- maximized frame:
    self.parentfr.maxfr = kui.frame:newbytype("BACKDROP", self.parentfr)
    self.parentfr.maxfr:setbgtex('war3mapImported\\panel-quest-backdrop.blp')
    self.parentfr.maxfr:setsize(kui:px(234), kui:px(128))
    self.parentfr.maxfr:setfp(fp.bl, fp.b, kui.worldui, kui:px(394), kui:px(104))
    self.parentfr.maxfr.titlefr = self.parentfr.maxfr:createheadertext("Stop Dilly Dallying!", 0.52) -- text frame
    self.parentfr.maxfr.titlefr:setparent(self.parentfr.maxfr.fh)
    self.parentfr.maxfr.titlefr:setfp(fp.t, fp.t, self.parentfr.maxfr, 0, -kui:px(27))
    self.parentfr.maxfr.textfr = self.parentfr.maxfr:createtext("(No Active Quest)") -- text frame
    self.parentfr.maxfr.textfr:setparent(self.parentfr.maxfr.fh)
    self.parentfr.maxfr.textfr:setsize(kui:px(200), kui:px(98))
    self.parentfr.maxfr.textfr:setfp(fp.c, fp.b, self.parentfr.maxfr, 0, kui:px(49))
    BlzFrameSetTextAlignment(self.parentfr.maxfr.textfr.fh, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_CENTER)
    -- minimized frame:
    self.parentfr.minfr = kui.frame:newbytype("BACKDROP", self.parentfr)
    self.parentfr.minfr:setbgtex('war3mapImported\\panel-quest-standalone-banner.blp')
    self.parentfr.minfr:setsize(kui:px(221), kui:px(50))
    self.parentfr.minfr:setfp(fp.c, fp.b, kui.worldui, kui:px(516), kui:px(122))
    self.parentfr.minfr.titlefr = self.parentfr.minfr:createheadertext("Stop Dilly Dallying!", 0.52) -- text frame
    self.parentfr.minfr.titlefr:setparent(self.parentfr.minfr.fh)
    self.parentfr.minfr.titlefr:setfp(fp.t, fp.t, self.parentfr.minfr, 0, -kui:px(24))
    self.parentfr.maxfr:hide()
    self.parentfr.minfr:hide()
    -- checkmark completion icon:
    self.cmfr = kui.frame:newbytype("BACKDROP", self.parentfr.maxfr) -- parent frame
    self.cmfr:setsize(kui:px(21), kui:px(22))
    self.cmfr:setbgtex('war3mapImported\\panel-quest-checkbox.blp')
    self.cmfr:setfp(fp.c, fp.b, self.parentfr.maxfr, 0, kui:px(3))
    self.cmfr:hide()
    -- init minimize toggle:
    self.parentfr.maxbtnwrap = kui.frame:newbtntemplate(self.parentfr, kui.tex.invis) -- create hidden wrapper buttons
    self.parentfr.maxbtnwrap:setallfp(self.parentfr.maxfr)
    self.parentfr.maxbtnwrap.btn:assigntooltip("questmax")
    self.parentfr.minbtnwrap = kui.frame:newbtntemplate(self.parentfr, kui.tex.invis)
    self.parentfr.minbtnwrap:setallfp(self.parentfr.minfr)
    self.parentfr.minbtnwrap.btn:assigntooltip("questmin")
    local showhidefunc = function()
        if self.parentfr.maxfr:isvisible() then quest.minimized = true self.parentfr.maxfr:hide() self.parentfr.minfr:show() self.parentfr.minbtnwrap:show() self.parentfr.maxbtnwrap:hide()
        else self.parentfr.maxfr:show() quest.minimized = false self.parentfr.minfr:hide() self.parentfr.minbtnwrap:hide() self.parentfr.maxbtnwrap:show() end
        utils.playsound(gg_snd_audio_map_open_close, utils.trigp())
    end
    self.parentfr.maxbtnwrap.btn:addevents(nil, nil, showhidefunc)
    self.parentfr.minbtnwrap.btn:addevents(nil, nil, showhidefunc)
    self.parentfr.maxbtnwrap:hide()
    self.parentfr.minbtnwrap:hide()
    -- dialogue buttons:
    self.socialfr = kui.frame:newbytype("PARENT", kui.canvas.gameui)
    self.socialfr.shinshop = kui.frame:newbtntemplate(self.socialfr, 'war3mapImported\\menu-button-shop-icon-shinykeeper.blp')
    self.socialfr.shinshop:setsize(kui:px(84), kui:px(87))
    self.socialfr.shinshop:setfp(fp.c, fp.b, kui.worldui, kui:px(42), kui:px(200))
    self.socialfr.shinshop.btn:assigntooltip("shopshiny")
    self.socialfr.shinshop.btn:clearallfp()
    self.socialfr.shinshop.btn:setfp(fp.c, fp.c, self.socialfr.shinshop)
    self.socialfr.shinshop.btn:setsize(kui:px(50), kui:px(50))
    self.socialfr.shinshop:hide()
    self.socialfr.eleshop = kui.frame:newbtntemplate(self.socialfr, 'war3mapImported\\menu-button-shop-icon-elementalist.blp')
    self.socialfr.eleshop:setsize(kui:px(84), kui:px(87))
    self.socialfr.eleshop:setfp(fp.c, fp.b, kui.worldui, kui:px(-42), kui:px(200))
    self.socialfr.eleshop.btn:assigntooltip("shopele")
    self.socialfr.eleshop.btn:clearallfp()
    self.socialfr.eleshop.btn:setfp(fp.c, fp.c, self.socialfr.eleshop)
    self.socialfr.eleshop.btn:setsize(kui:px(50), kui:px(50))
    self.socialfr.eleshop:hide()
    self.socialfr.fragshop = kui.frame:newbtntemplate(self.socialfr, 'war3mapImported\\menu-button-shop-icon-greywhisker.blp')
    self.socialfr.fragshop:setsize(kui:px(84), kui:px(87))
    self.socialfr.fragshop:setfp(fp.c, fp.b, kui.worldui, 0, kui:px(236))
    self.socialfr.fragshop.btn:assigntooltip("shopfrag")
    self.socialfr.fragshop.btn:clearallfp()
    self.socialfr.fragshop.btn:setfp(fp.c, fp.c, self.socialfr.fragshop)
    self.socialfr.fragshop.btn:setsize(kui:px(50), kui:px(50))
    self.socialfr.fragshop:hide()
    self.socialfr.speakto = kui.frame:newbtntemplate(self.socialfr, 'war3mapImported\\menu-button-speak-to-npc-icon.blp')
    self.socialfr.speakto:setsize(kui:px(84), kui:px(87))
    self.socialfr.speakto:setfp(fp.c, fp.b, kui.worldui, 0, kui:px(164))
    self.socialfr.speakto.btn:assigntooltip("speakto")
    self.socialfr.speakto.btn:clearallfp()
    self.socialfr.speakto.btn:setfp(fp.c, fp.c, self.socialfr.speakto)
    self.socialfr.speakto.btn:setsize(kui:px(50), kui:px(50))
    -- dialogue functions:
    self.socialfr.shinshop.btn:addevents(nil, nil, function() shop_vendor_type_open[utils.trigpnum()] = 0 shop:toggleshopopen() end)
    self.socialfr.eleshop.btn:addevents(nil, nil, function() shop_vendor_type_open[utils.trigpnum()] = 1 shop:toggleshopopen() end)
    self.socialfr.fragshop.btn:addevents(nil, nil, function()
        if utils.islocaltrigp() then
            if shop.gwfr:isvisible() then
                shop.gwfr:hide()
                utils.playsound(kui.sound.panel[2].close, utils.trigp())
            else
                shop.gwfr:show()
                utils.playsound(kui.sound.panel[2].open, utils.trigp())
            end
        end
    end)
    self.socialfr:hide()
    self.socialfr.showfunc = function() 
        if quest_shinykeeper_unlocked then self.socialfr.shinshop:show() end
        if quest_elementalist_unlocked then self.socialfr.eleshop:show() end
    end
end


-- @name            = quest title to display to users.
-- @qst_m_type         = quest type used to build description and objective logic.
-- @startchain      = [optional] play this speak chain before the quest alert.
-- @_biomeid        = [optional] complete a mission of this biome type to finish the quest.
-- @_xpaward        = [optional] award this xp to players.
-- @_lvlaward       = [optional] award raw levels to players (overrides _xpaward).
-- @_treasureclass  = [optional] controls which rarity, slotids, and itemtypes are available. (TODO: make this class)
function quest:new(name, qst_m_type, _startchain, _endchain, _biomeid, _xpaward, _lvlaward, _treasureclass)
    local o = setmetatable({}, self)
    o.name = name
    if qst_m_type == m_type_boss_fight then
        o.bossname = _bossname
        o.bossunitid = _bossunitid
    end
    o.qst_m_type = qst_m_type
    o.startchain = _startchain or nil
    o.endchain   = _endchain or nil
    o.biomeid    = _biomeid or nil
    o.xpaward    = _xpaward or self._xpaward
    o.lvlaward   = _lvlaward or self._lvlaward
    o.treasure   = _treasureclass or nil
    o.id         = #self.lineage + 1
    self.lineage[o.id] = o
    return o
end


-- a generic quest for directing the user to talk to another NPC.
function quest:createspeakquest(name, startchain, endchain, startunit, endunit, _xpaward, _lvlaward)
    local qst = quest:new(name, m_type_speak, startchain, endchain, nil, _xpaward or self.xpaward, _lvlaward or nil)
    qst:build(startunit, endunit)
    qst:getdescription()
    return qst
end


function quest:createdigquest(name, mtype, startchain, endchain, startunit, endunit, _xpaward, _lvlaward, _biomeid)
    local mtype = mtype or math.random(1,2)
    if mtype == m_type_boss_fight then
        print("error: use quest:createbossquest to create boss quests, not quest:createdigquest")
        return
    else
        local qst = quest:new(name, mtype, startchain, endchain, _biomeid or math.random(1,4), _xpaward or self.xpaward, _lvlaward or nil)
        qst:build(startunit, endunit)
        qst:getdescription()
        return qst
    end
end


function quest:createbossquest(name, mtype, bossname, bossid, startchain, endchain, startunit, endunit, _xpaward, _lvlaward)
    local qst = quest:new(name, mtype, startchain, endchain, boss.bosst[bossid].biomeid, _xpaward or self.xpaward, _lvlaward or nil)
    qst.bossname = bossname
    qst.bossid   = bossid
    qst:build(startunit, endunit)
    qst:getdescription()
    return qst
end


function quest:activate()
    -- set active so quest can be collected:
    self:updatemapmarker("available")
    self.collectable = true
    self.eyecandystart = speff_quest1:attachu(self.startunit, nil, 'overhead')
    quest.current = self
end


-- @startunit = initializes the quest, enabling completion.
-- @endunit = where player goes to complete the quest.
function quest:build(startunit, endunit)
    self.startunit  = startunit
    self.endunit    = endunit
    self.action     = TriggerAddAction(quest.trig, function()
        utils.debugfunc( function()
            if GetSpellAbilityId() == quest.speakcode then
                if self.collectable then
                    local target = GetSpellTargetUnit()
                    utils.stop(utils.trigu())
                    utils.faceunit(target, utils.trigu())
                    -- if not collected, add quest for player:
                    if not self.triggered and target == self.startunit then
                        self.triggered = true
                        self:begin()
                        return true
                        -- if already collected, see if complete when at turn in point:
                    elseif self.complete and target == self.endunit then
                        self:finish()
                        return true
                    end
                end
            end
        end, "start quest startunit")
    end)
end


-- update quest frame.
-- @isquestdone = quest completed?
function quest:markprogress(isquestdone)
    local str1, str2 = '', ''
    str1 = self.name
    if isquestdone then
        -- quest is done and completion can be triggered:
        self.complete = true
        if not self.eyecandyfinish then
            self.eyecandyfinish = speff_quest1:attachu(self.endunit, nil, 'overhead')
            BlzSetSpecialEffectColor(self.eyecandyfinish, 0, 255, 0)
        end
        if self.qst_m_type == m_type_speak then
            str2 = 'Speak to '..GetUnitName(self.endunit)
        else
            self.description = string.gsub(string.gsub(self.description, "|c00"..color.tooltip.alert, ""), "|r", "")
            str2 = color:wrap(color.txt.txtgrey, self.description)..color:wrap(color.tooltip.good,'|nReturn to '..GetUnitName(self.endunit)..' for your reward')
        end
        self.cmfr:show()
        self:updatemapmarker("complete")
    else
        -- quest is in progress:
        str2 = self.description
    end
    BlzFrameSetText(self.parentfr.maxfr.titlefr.fh, str1) -- maximized frame title
    BlzFrameSetText(self.parentfr.minfr.titlefr.fh, str1) -- minimized frame title
    BlzFrameSetText(self.parentfr.maxfr.textfr.fh, str2) -- description
    if self.minimized then
        self.parentfr.minbtnwrap:show()
    else
        self.parentfr.maxbtnwrap:show()
    end
end


function quest:updatemapmarker(stage)
    if self.markerstart then DestroyMinimapIcon(self.markerstart) self.markerstart = nil end
    if self.markerend then DestroyMinimapIcon(self.markerend) self.markerend = nil end
    if stage == "available" then
        CreateMinimapIconBJ(utils.unitx(self.startunit), utils.unity(self.startunit), 255, 225, 0, "UI\\Minimap\\MiniMap-QuestGiver.mdl", FOG_OF_WAR_MASKED)
        self.markerstart = GetLastCreatedMinimapIcon()
    elseif stage == "inprogress" then
        -- DestroyMinimapIcon(quest.markerstart)
        -- quest.markerstart = nil
        -- show and move marker on dig panel:
        if self.qst_m_type ~= my_type_speak and self.biomeid then
            kui.canvas.game.dig.questmark:show()
            kui.canvas.game.dig.questmark:setfp(fp.c, fp.tl, kui.canvas.game.dig.card[self.biomeid].bd, kui:px(14), -kui:px(30))
        end
    elseif stage == "complete" then
        kui.canvas.game.dig.questmark:hide() -- (here twice for dev skipping)
        CreateMinimapIconBJ(utils.unitx(self.endunit), utils.unity(self.endunit), 55, 255, 55, "UI\\Minimap\\MiniMap-QuestGiver.mdl", FOG_OF_WAR_MASKED)
        self.markerend = GetLastCreatedMinimapIcon()
    elseif stage == "turnedin" then
        kui.canvas.game.dig.questmark:hide()
        -- if self.markerstart then DestroyMinimapIcon(self.markerstart) self.markerstart = nil end
        -- if self.markerend then DestroyMinimapIcon(self.markerend) self.markerend = nil end
    end
end


function quest:refreshmapmarker()
    utils.timed(3.0, function()
        -- because changing map bounds bugs out map icons, refresh them after scoreboard.
        if self.markerstart then
            DestroyMinimapIcon(self.markerstart)
            CreateMinimapIconBJ(utils.unitx(self.startunit), utils.unity(self.startunit), 255, 225, 0, "UI\\Minimap\\MiniMap-QuestGiver.mdl", FOG_OF_WAR_MASKED)
        end
        if self.markerend then
            DestroyMinimapIcon(self.markerend)
            CreateMinimapIconBJ(utils.unitx(self.endunit), utils.unity(self.endunit), 55, 255, 55, "UI\\Minimap\\MiniMap-QuestGiver.mdl", FOG_OF_WAR_MASKED)
        end
    end)
end


function quest:clearprogress()
    BlzFrameSetText(self.parentfr.maxfr.textfr.fh, '')
    BlzFrameSetText(self.parentfr.minfr.titlefr.fh, '')
end


function quest:getdescription()
    local biomename = ''
    if self.biomeid then
        biomename = color:wrap(color.tooltip.alert, map.biomemap[self.biomeid])
    end
    if self.qst_m_type == m_type_speak then
        self.description = "Speak with "..GetUnitName(self.endunit)
    elseif self.qst_m_type == m_type_monster_hunt then
        self.description = "Defeat treasure guardians in|n"..biomename
    elseif self.qst_m_type == m_type_candle_heist then
        self.description = "Steal from Dark Kobolds in|n"..biomename
    elseif self.qst_m_type == m_type_boss_fight then
        self.description = "Conjure a dig site key and defeat "..color:wrap(color.tooltip.alert, self.bossname).." in "..biomename
    elseif self.qst_m_type == m_type_gold_rush then
        self.description = "Protect mining efforts in|n"..biomename
    end
end


function quest:begin(_skipspeak)
    alert:new("New Quest: "..color:wrap(color.tooltip.alert, self.name), 5)
    -- on start func if present:
    if self.startfunc then
        self:startfunc()
    end
    utils.playsoundall(kui.sound.queststart)
    if self.startchain and not _skipspeak then
        screenplay:run(self.startchain)
    end
    quest.inprogress = true
    self:updatemapmarker("inprogress")
    self.cmfr:hide()
    -- if speech quest, mark objective complete:
    if self.qst_m_type == m_type_speak then
        self:markprogress(true)
    else
        self:markprogress(false)
    end
    -- clear quest markers:
    if self.eyecandystart then
        BlzSetSpecialEffectAlpha(self.eyecandystart, 0)
        DestroyEffect(self.eyecandystart)
    end
end


function quest:finish(_skipspeak)
    alert:new(color:wrap(color.tooltip.good, "Quest Completed")..': '..color:wrap(color.tooltip.alert, self.name))
    TriggerRemoveAction(self.trig, self.action)
    -- complete current quest and give awards:
    utils.playsoundall(kui.sound.questdone)
    utils.playerloop(function(p)
        if self.lvlaward > 0 then
            kobold.player[p]:addlevel(self.lvlaward)
        else
            kobold.player[p]:awardxp(self.xpaward)
        end
        if not freeplay_mode then
            kobold.player[p].char:save_character()
        end
    end)
    if self.awardfunc then
        self.awardfunc()
    end
    -- play completion dialogue:
    if self.endchain and not _skipspeak then
        screenplay:run(self.endchain)
    end
    self:clearprogress()
    -- queue up next quest start:
    if self.nextquest then
        self.nextquest:activate()
    elseif self.lineage[self.id + 1] then
        self.nextquest = self.lineage[self.id + 1]
        self.nextquest:activate()
    else
        self.current = nil
    end
    -- clear quest markers:
    if self.eyecandyfinish then
        BlzSetSpecialEffectAlpha(self.eyecandyfinish, 0)
        DestroyEffect(self.eyecandyfinish)
    end
    -- reset completion-related frames:
    quests_total_completed = quests_total_completed + 1
    -- story completion badge:
    if quests_total_completed >= 15 and kobold.player[Player(0)].badgeclass[badge:get_class_index(12, kobold.player[Player(0)].charid)] == 0 then
        badge:earn(kobold.player[Player(0)], 12, kobold.player[Player(0)].charid)
    end
    quest.inprogress = false
    self:updatemapmarker("turnedin")
    self.parentfr.maxfr:hide()
end


function quest:addloot(rarityidmin, rarityidmax, _slottype, _count)
    utils.debugfunc(function()
        utils.playerloop(function(p)
            for i = 1,_count or 1 do
                local rarityid =  math.random(rarityidmin, rarityidmax)
                local slotid   = _slottype or loot:getrandomslottype()
                loot:generate(p, kobold.player[p].level, slotid, rarityid)
                ArcingTextTag("+"..color:wrap(color.tooltip.good, "Loot"), kobold.player[p].unit)
            end
        end)
        utils.playsoundall(kui.sound.tutorialpop)
    end, "quest:getloot")
end


-- add @val of a random or specificed @_oreid.
-- pass @_starterflag flag to override and make it physical (for starter quests).
function quest:addoreaward(val, _oreid, _starterflag)
    utils.playerloop(function(p)
        if kobold.player[p] then
            if not _oreid and _starterflag then
                kobold.player[p]:awardoretype(ore_phys, val, false)
            elseif _oreid then
                kobold.player[p]:awardoretype(_oreid, val, false)
            else
                kobold.player[p]:awardoretype(math.random(1,6), val, false)
            end
            ArcingTextTag("+"..color:wrap(color.tooltip.good, "Ore"), kobold.player[p].unit)
        end
    end)
end


function quest:addgoldaward(val)
    utils.playerloop(function(p)
        if kobold.player[p] then
            kobold.player[p]:awardgold(val)
        end
        ArcingTextTag("+"..color:wrap(color.ui.gold, "Gold"), kobold.player[p].unit)
    end)
end


function quest:addfragaward(val)
    utils.playerloop(function(p)
        if kobold.player[p] then
            kobold.player[p]:awardfragment(val)
        end
    end)
end


-- disables the current quest and stops further quest progression.
function quest:disablequests()
    if quest.current then
        quest.current.collectable = false
        DestroyEffect(quest.current.eyecandystart)
        if quest.current.markerstart then DestroyMinimapIcon(quest.current.markerstart) quest.current.markerstart = nil end
        if quest.current.markerend then DestroyMinimapIcon(quest.current.markerend) quest.current.markerend = nil end
        quest.current = nil
    end
end


function quest:load_current()
    -- loads the current quest in the quest chain.
    if self.lineage[quests_total_completed+1] then
        self.lineage[quests_total_completed+1]:activate()
    end
end
