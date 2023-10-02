badge = {}
badge.__index = badge


function badge:buildpanel()
    fr = kui:createmassivepanel("BADGES")
    fr.panelid  = 7
    fr.statesnd = true
    local x,y = 0,0
    local w,h = 196,164
    local start_xoff,start_yoff = -592,245
    local xoff, yoff = start_xoff, start_yoff
    for id = 1,18 do
        if id < 10 then
            badge[id] =  kui.frame:newbtntemplate(fr, "war3mapImported\\achievement_icon_gallery_0"..tostring(id)..".blp")
        else
            badge[id] =  kui.frame:newbtntemplate(fr, "war3mapImported\\achievement_icon_gallery_"..tostring(id)..".blp")
        end
        badge[id].btn:assigntooltip("badgetip"..tostring(id))
        badge[id].btn:event(nil, nil, nil, nil)
        badge[id]:setsize(kui:px(w), kui:px(h))
        badge[id]:setfp(fp.tl, fp.c, fr, kui:px(xoff), kui:px(yoff))
        badge[id]:setnewalpha(90)
        xoff = xoff + w
        if math.fmod(id, 6) == 0 then
            xoff = start_xoff
            yoff = yoff - h
            xoff = start_xoff
        end
    end
    -- add class indicators
    for id = 1,18 do
        badge[id].classicon = {}
        for classid = 1,4 do
            badge[id].classicon[classid] = kui.frame:newbtntemplate(badge[id], kui.meta.tipcharselect[classid][1])
            badge[id].classicon[classid]:setsize(kui:px(20), kui:px(20))
            badge[id].classicon[classid]:hide()
            badge[id].classicon[classid].btn:assigntooltip("badgetipclass"..tostring(classid))
            badge[id].classicon[classid].btn:event(nil, nil, nil, nil)
            if classid == 1 then
                badge[id].classicon[classid]:setfp(fp.c, fp.c, badge[id], kui:px(-70), kui:px(55))
            elseif classid == 2 then
                badge[id].classicon[classid]:setfp(fp.c, fp.c, badge[id], kui:px(-40), kui:px(68))
            elseif classid == 3 then
                badge[id].classicon[classid]:setfp(fp.c, fp.c, badge[id], kui:px(40), kui:px(68))
            elseif classid == 4 then
                badge[id].classicon[classid]:setfp(fp.c, fp.c, badge[id], kui:px(70), kui:px(55))
            end
            -- glow effect:
            badge[id].classicon[classid].glow = kui.frame:newbytype("BACKDROP", badge[id].classicon[classid])
            badge[id].classicon[classid].glow:addbgtex("war3mapImported\\panel-shop-selection-circle.blp", 200)
            badge[id].classicon[classid].glow:setfp(fp.c, fp.c, badge[id].classicon[classid], 0, 0)
            badge[id].classicon[classid].glow:setsize(kui:px(34), kui:px(34))
            badge[id].classicon[classid].glow:hide()
        end
    end
    fr:hide()
    return fr
end


function badge:earn(pobj, id, _classid)
    local classid = _classid or pobj.charid
    -- earn badge:
    if pobj.badge[id] == 0 then
        pobj.badge[id] = 1
        kui.canvas.game.skill.alerticon[5]:show()
    end
    pobj.badgeclass[badge:get_class_index(id, classid)] = 1 -- 4 per badge, index 1, calc offset.
    badge:validate_all(pobj)
end


function badge:validate_all(pobj)
    if utils.islocalp(pobj.p) then
        for id = 1,18 do
            if pobj.badge[id] == 1 then
                badge[id]:setnewalpha(255)
            end
            for classid = 1,4 do
                if pobj.badgeclass[badge:get_class_index(id, classid)] == 1 then
                    badge[id].classicon[classid]:show()
                    badge[id].classicon[classid].glow:show()
                    badge[id].classicon[classid]:setnewalpha(255)
                else
                    -- only show alpha class icon if that achieve is already unlocked (reduce clutter):
                    if pobj.badge[id] == 1 then
                        badge[id].classicon[classid]:setnewalpha(90)
                        badge[id].classicon[classid]:show()
                    else
                        badge[id].classicon[classid]:hide()
                    end
                end
            end
        end
    end
end


function badge:get_class_index(id, classid)
    -- return the 1-72 position for this combo (player data)
    return (id-1)*4 + classid
end


function badge:save_data(pobj)
    badge.data = ""
    for id = 1,#pobj.badge do
        badge.data = badge.data..tostring(pobj.badge[id])
    end
    for classid = 1,#pobj.badgeclass do
        badge.data = badge.data..tostring(pobj.badgeclass[classid])
    end
    PreloadGenClear()
    PreloadGenStart()
    badge.data = char:basic_encrypt(char.newseed, badge.data, true)
    Preload("\")\ncall BlzSetAbilityTooltip('AOws',\""..badge.data.."\",".."0"..")\n//")
    PreloadGenEnd("KoboldKingdom\\badges.txt")
    badge.data = nil
end


function badge:load_data(pobj)
    PreloadStart()
    Preload("")
    Preloader("KoboldKingdom\\badges.txt")
    Preload("")
    PreloadEnd(0.0)
    utils.debugfunc(function()
        badge.data = BlzGetAbilityTooltip(FourCC("AOws"), 0)
        if badge.data and badge.data ~= "" then
            local badge_length, class_length = #pobj.badge, #pobj.badgeclass
            local decrypted = char:basic_encrypt(char.newseed, badge.data, false)
            for pos = 1,(badge_length + class_length) do
                if string.sub(decrypted, pos, pos) == "1" then
                    if pos <= badge_length then
                        -- load badge data:
                        pobj.badge[pos] = 1
                    else
                        -- load class button data:
                        pobj.badgeclass[pos - badge_length] = 1
                    end
                end
            end
        end
        badge:validate_all(pobj)
        badge.data = nil
    end, "load badges")
end


function badge:sync_past_achievements(pobj)
    -- for retroactive awards (old save codes):
    if quests_total_completed then
        if quests_total_completed >= 2 then
            badge:earn(pobj, 1, pobj.charid)
        end
        if quests_total_completed >= 3 then
            badge:earn(pobj, 3, pobj.charid)
        end
        if quests_total_completed >= 4 then
            badge:earn(pobj, 4, pobj.charid)
        end
        if quests_total_completed >= 5 then
            badge:earn(pobj, 5, pobj.charid)
        end
        if quests_total_completed >= 6 then
            badge:earn(pobj, 7, pobj.charid)
        end
        if quests_total_completed >= 9 then
            badge:earn(pobj, 8, pobj.charid)
        end
        if quests_total_completed >= 12 then
            badge:earn(pobj, 9, pobj.charid)
        end
        if quests_total_completed >= 14 then
            badge:earn(pobj, 10, pobj.charid)
        end
        if quests_total_completed >= 15 then
            badge:earn(pobj, 11, pobj.charid)
            badge:earn(pobj, 12, pobj.charid)
        end
    end
    badge:save_data(pobj)
end
