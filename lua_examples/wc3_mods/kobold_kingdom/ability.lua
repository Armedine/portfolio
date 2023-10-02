ability          = {}
ability.template = {}

function ability:init()
    self.__index = self
    ability.template:init()
    utils.debugfunc(function() ability.template:buildall() end, "ability.template:buildall")
end


function ability:new(id, iconpath)
    local o = {}
    setmetatable(o, self)
    o.code     = FourCC(id)
    o.icon     = iconpath
    return o
end


function ability:initfields(fields)
    if fields then
        for i,v in pairs(fields) do
            self[i] = v
        end
    else
        print("error: ability initfields requires a 'fields' table")
    end
end


function ability:initdescript(name, descript)
    -- print(name)
    self.name     = name
    self.dorigin  = descript
    self.descript = self:parsedescript()
end


function ability:parsedescript()
    local str = self.dorigin
    --print("old descript = "..self.dorigin)
    for field,value in pairs(self) do
        if type(field) == "string" then
            if type(value) == "table" then
                str = string.gsub(str,   "(#"..field..")",     color:wrap(value.color, tostring(value.name)))
            else
                if string.find(field, "range") or string.find(field, "radius") then
                    str = string.gsub(str,   "(#"..field..")",     color:wrap(color.tooltip.good, tostring(value).."m"))
                elseif string.find(field, "dur") then
                    str = string.gsub(str,   "(#"..field..")",     color:wrap(color.tooltip.good, tostring(value).." sec"))
                elseif string.find(field, "perc") then
                    str = string.gsub(str,   "(#"..field..")",     color:wrap(color.tooltip.good, tostring(value).."%%%%"))
                    str = string.gsub(str,   "(%)", "" )
                else
                    str = string.gsub(str,   "(#"..field..")",     color:wrap(color.tooltip.good, tostring(value)))
                end
            end
        end
    end
    self.dorigin = nil
    return str
end


function ability:buildpanel()
    fr = kui:createmassivepanel("ABILITIES")
    local startx,starty  = kui:px(kui.meta.abilpanel[1].x),kui:px(kui.meta.abilpanel[1].y)
    local x,y  = startx,starty
    local offx = kui:px(kui.meta.abilpanel[1].offx)
    local offy = kui:px(kui.meta.abilpanel[1].offy)
    local abilslot = 0
    fr.slot   = {} -- ability cards.
    fr.header = {} -- QWER headers.
    for row = 1,3 do
        fr.slot[row] = {}
        for col = 1,4 do
            abilslot = abilslot + 1
            fr.slot[row][col] = kui.frame:newbytype("BACKDROP", fr)
            fr.slot[row][col]:addbgtex(kui.meta.abilpanel[1].tex)
            fr.slot[row][col]:setsize(kui:px(kui.meta.abilpanel[1].w), kui:px(kui.meta.abilpanel[1].h))
            fr.slot[row][col]:setfp(fp.tl, fp.tl, fr, x, y)
            fr.slot[row][col]:addtext("btn", "Ability Name", fp.t)
            fr.slot[row][col].txt:setfp(fp.c, fp.t, fr.slot[row][col], 0.0, kui:px(-16))
            -- ability backdrop dec:
            fr.slot[row][col].iconbd = kui.frame:newbytype("BACKDROP", fr.slot[row][col])
            fr.slot[row][col].iconbd:addbgtex(kui.meta.abilpanel[2].tex)
            fr.slot[row][col].iconbd:setsize(kui:px(kui.meta.abilpanel.btnwh), kui:px(kui.meta.abilpanel.btnwh))
            fr.slot[row][col].iconbd:setfp(fp.c, fp.l, fr.slot[row][col], 0.0, kui:px(kui.meta.abilpanel.btnoffy) + kui:px(8))
            -- ability icon:
            fr.slot[row][col].icon = kui.frame:newbytype("BACKDROP", fr.slot[row][col])
            fr.slot[row][col].icon:setsize(kui:px(kui.meta.abilpanel.btnwh*0.54), kui:px(kui.meta.abilpanel.btnwh*0.54))
            fr.slot[row][col].icon:setfp(fp.c, fp.c, fr.slot[row][col].iconbd, 0.0, kui:px(2))
            -- ability description:
            fr.slot[row][col].descript = fr.slot[row][col]:createtext("")
            fr.slot[row][col].descript:setsize(kui:px(208), kui:px(95))
            fr.slot[row][col].descript:setfp(fp.tl, fp.tl, fr.slot[row][col], kui:px(43), -kui:px(44))
            BlzFrameSetTextAlignment(fr.slot[row][col].descript.fh, TEXT_JUSTIFY_MIDDLE, TEXT_JUSTIFY_LEFT)
            -- btn fill:
            fr.slot[row][col].btn = kui.frame:newbytype("BUTTON", fr.slot[row][col])
            fr.slot[row][col].btn:assigntooltip("learnabil")
            fr.slot[row][col].btn:setallfp(fr.slot[row][col].iconbd)
            fr.slot[row][col].btn:addhoverscale(fr.slot[row][col].icon, 1.1)
            -- abil costs:
            local costwh = 24
            fr.slot[row][col].mana = kui.frame:newbytype("BACKDROP", fr.slot[row][col])
            fr.slot[row][col].mana:addbgtex('war3mapImported\\icon-abil_costs_02.blp')
            fr.slot[row][col].mana:setsize(kui:px(costwh), kui:px(costwh))
            fr.slot[row][col].mana:addtext("btn", "0", fp.c)
            fr.slot[row][col].mana.txt:assigntooltip("manacost")
            fr.slot[row][col].mana.txt:setscale(0.85)
            fr.slot[row][col].mana.txt:setsize(kui:px(costwh), kui:px(costwh))
            fr.slot[row][col].mana:setfp(fp.tr, fp.b, fr.slot[row][col].iconbd, 0.0, kui:px(3))
            fr.slot[row][col].cd = kui.frame:newbytype("BACKDROP", fr.slot[row][col])
            fr.slot[row][col].cd:setsize(kui:px(costwh), kui:px(costwh))
            fr.slot[row][col].cd:addbgtex('war3mapImported\\icon-abil_costs_01.blp')
            fr.slot[row][col].cd:addtext("btn", "0", fp.c)
            fr.slot[row][col].cd.txt:assigntooltip("cooldown")
            fr.slot[row][col].cd.txt:setscale(0.9)
            fr.slot[row][col].cd.txt:setsize(kui:px(costwh), kui:px(costwh))
            fr.slot[row][col].cd:setfp(fp.tl, fp.b, fr.slot[row][col].iconbd, 0.0, kui:px(3))
            -- progression lock icon after 1st abil:
            if row == 1 and col == 1 then
                -- do nothing, these abilities are unlocked by default.
            else
                fr.slot[row][col].lock = kui.frame:newbtntemplate(fr, "war3mapImported\\panel-ability-lock_icon.blp")
                fr.slot[row][col].lock:setfp(fp.c, fp.c, fr.slot[row][col])
                fr.slot[row][col].lock:setsize(kui:px(62), kui:px(79))
                fr.slot[row][col].lock:addtext("btn", "LVL. "..((abilslot - 1)*3 + 1), fp.c) -- level req. text.
                fr.slot[row][col].lock.btn:addhoverhl(fr.slot[row][col].lock)
                fr.slot[row][col].lock.btn:clearallfp()
                fr.slot[row][col].lock.btn:setfp(fp.c, fp.c, fr.slot[row][col].lock)
                fr.slot[row][col].lock.btn:setsize(kui:px(kui.meta.abilpanel[1].w), kui:px(kui.meta.abilpanel[1].h))
                fr.slot[row][col].lock.btn:addevents(nil, nil, function() end, nil) -- add baked-in focus fix.
                fr.slot[row][col].lock.alpha = 255
                fr.slot[row][col].lock.alphahl = 0
                fr.slot[row][col].lock:resetalpha()
                fr.slot[row][col].lock.txt:setfp(fp.c, fp.c, fr.slot[row][col].lock, 0.0, -kui:px(6))
                fr.slot[row][col].lock.txt:setlvl(2)
                fr.slot[row][col].lock.btn:assigntooltip("abilitylvl")
                fr.slot[row][col].lock.btn:setlvl(3)
                fr.slot[row][col].lock.btn.hoverarg = abilslot - 1
                fr.slot[row][col].btn:hide()        -- hide the ability learn button to prevent clicks.
                fr.slot[row][col].btn.disabled = true
                fr.slot[row][col]:setnewalpha(150)  -- initialize default alpha for locked abils.
            end
            -- QWER header:
            if row == 1 then
                fr.header[col] = fr:createheadertext(kui.meta.abilpanel.headers[col])
                fr.header[col]:setfp(fp.c, fp.t, fr.slot[row][col], 0.0, kui:px(22))
                fr.header[col]:setsize(kui:px(60), kui:px(60))
            end
            fr.slot[row][col].click = function()
                -- FIXME: DESYNCS
                local p = utils.trigp()
                if not map.manager.loading and not map.manager.activemap then
                    kobold.player[p].ability:learn(row, col)
                else
                    utils.palert(p, "You cannot change abilities during a dig!")
                end
            end
            fr.slot[row][col].btn:addevents(nil,nil,fr.slot[row][col].click)
            x = x + offx
        end
        x = startx
        y = y - offy
    end
    fr.panelid  = 6
    fr.statesnd = true
    fr:hide()
    return fr
end


function ability.template:createbase()
    local o  = {}
    o.spells = {}
    for i = 1,4 do
        o.spells[i] = {}
    end
    o.spells[9] = {}
    o.spells[10] = {}
    for i = 1,10 do o[i] = {} end
    setmetatable(o, self)
    return o
end


function ability.template:buildall()
    -- locals for readability:
    local Q_id,W_id,E_id,R_id = 1,2,3,4
    -- init template base object:
    for charid = 1,4 do
        ability.template[charid] = ability.template:createbase()
    end

    --------------------------------------------------------------------------------------------------
    ------------------ TUNNELER ----------------------------------------------------------------------
    --------------------------------------------------------------------------------------------------
    --[[
        row 1:
    --]]
    -- Q
    ability.template[1][Q_id][1] = ability:new("A010", "war3mapImported\\class_ability_icons_01.blp")
    ability.template[1][Q_id][1]:initfields({type1=dmg.type[dmg_phys], dmg1=52, radius1=3, cost=5, cd=nil, perc1=75})
    ability.template[1][Q_id][1]:initdescript(
        "Tunnel Bomb",
        "Throw dynamite at a target area, dealing #dmg1 #type1 damage in a #radius1 radius. Deals #perc1 damage to blocks.")
    -- W
    ability.template[1][W_id][1] = ability:new("A013", "war3mapImported\\class_ability_icons_02.blp")
    ability.template[1][W_id][1]:initfields({type1=dmg.type[dmg_phys], dmg1=21, count1=3, range1=3, cost=25, cd=16, dur1=8, perc1=75})
    ability.template[1][W_id][1]:initdescript(
        "Rocksaw",
        "Mount #count1 spinning blades to the ground for #dur1, each dealing #dmg1 #type1 damage per sec in a #range1 radius."
        .." Deals #perc1 damage to blocks.")
    -- E
    ability.template[1][E_id][1] = ability:new("A014", "war3mapImported\\class_ability_icons_03.blp")
    ability.template[1][E_id][1]:initfields({type1=dmg.type[dmg_phys], dmg1=76, range1=3, cost=25, cd=14, dur1=3})
    ability.template[1][E_id][1]:initdescript(
        "Mole Hole",
        "Dig into the ground and move around freely, becoming immune to all effects. Emerge after #dur1 to deal #dmg1 #type1"
        .." damage in a #range1 radius.")
    -- R
    ability.template[1][R_id][1] = ability:new("A015", "war3mapImported\\class_ability_icons_04.blp")
    ability.template[1][R_id][1]:initfields({type1=dmg.type[dmg_phys], dmg1=64, cost=60, cd=45, dur1=8, range1=2, range2=3, perc1=75, perc2=75})
    ability.template[1][R_id][1]:initdescript(
        "Wrecking Ball",
        "Turn into a wrecking ball for #dur1, dealing #dmg1 #type1 damage to targets in a #range1 radius and knocking them back."
        .." While active, take #perc2 less damage.")
    --[[
        row 2:
    --]]
    -- Q
    ability.template[1][Q_id][2] = ability:new("A011", "war3mapImported\\class_ability_icons_05.blp")
    ability.template[1][Q_id][2]:initfields({type1=dmg.type[dmg_phys], dmg1=32, range1=8, radius1=2, cost=25, cd=nil, perc1=25, dur1=6})
    ability.template[1][Q_id][2]:initdescript(
        "Pickerang",
        "Throw two spinning pickaxes that arc for #dur1, each dealing #dmg1 #type1 damage. Deals #perc1 bonus damage to slowed targets."
        .." Can strike targets multiple times.")
    -- W
    ability.template[1][W_id][2] = ability:new("A012", "war3mapImported\\class_ability_icons_06.blp")
    ability.template[1][W_id][2]:initfields({type1=dmg.type[dmg_phys], dmg1=48, range1=8, radius1=2, cost=15, cd=nil, dur1=1, dur2=2.5})
    ability.template[1][W_id][2]:initdescript(
        "Hammerang",
        "Throw two precise hammers that travel for #dur1, each dealing #dmg1 #type1 damage and slowing targets for #dur2."
        .." Can strike targets once.")
    -- E
    ability.template[1][E_id][2] = ability:new("A016", "war3mapImported\\class_ability_icons_07.blp")
    ability.template[1][E_id][2]:initfields({type1=dmg.type[dmg_phys], dmg1=42, range1=15, radius1=2, cost=40, cd=12, perc1=100, dur1=2.5})
    ability.template[1][E_id][2]:initdescript(
        "'Kobolt' Auto-Miner",
        "Deploy a robotic assistant which travels in a line for #range1, dealing #dmg1 #type1 damage to targets its path and slowing them for #dur1."
        .." Deals #perc1 damage to blocks.")
    -- R
    ability.template[1][R_id][2] = ability:new("A017", "war3mapImported\\class_ability_icons_08.blp")
    ability.template[1][R_id][2]:initfields({type1=dmg.type[dmg_phys], dmg1=348, dur1=4, dur2=3, radius1=8, cost=40, cd=60, perc1=75})
    ability.template[1][R_id][2]:initdescript(
        "The Big One",
        "Deploy a bomb which detonates after #dur1, dealing #dmg1 #type1 damage in a #radius1 radius."
        .." Deals #perc1 damage to blocks.")
    --[[
        row 3:
    --]]
    -- Q
    ability.template[1][Q_id][3] = ability:new("A018", "war3mapImported\\class_ability_icons_09.blp")
    ability.template[1][Q_id][3]:initfields({type1=dmg.type[dmg_fire], type2=dmg.type[dmg_frost], type3=dmg.type[dmg_nature],
        dmg1=32, range1=6, radius1=2, cost=10, cd=nil, count1=3})
    ability.template[1][Q_id][3]:initdescript(
        "Primal Candle",
        "Unleash #count1 random bursts of candle magic in a #range1 line, each dealing #dmg1 #type1, #type2, or #type3 damage twice in quick succession.")
    -- W
    ability.template[1][W_id][3] = ability:new("A019", "war3mapImported\\class_ability_icons_10.blp")
    ability.template[1][W_id][3]:initfields({type1=dmg.type[dmg_fire], type2=dmg.type[dmg_frost], type3=dmg.type[dmg_nature],
        dmg1=84, range1=10, cost=20, cd=10, dur1=3})
    ability.template[1][W_id][3]:initdescript(
        "Rift Rocket",
        "Launch a pair of tethered missiles which travel for #range1, rooting targets for #dur1"
        .." and dealing #dmg1 #type1, #type2, and #type3 damage.")
    -- E
    ability.template[1][E_id][3] = ability:new("A01A", "war3mapImported\\class_ability_icons_11.blp")
    ability.template[1][E_id][3]:initfields({type1=dmg.type[dmg_fire], type2=dmg.type[dmg_frost], type3=dmg.type[dmg_nature],
        dmg1=24, cost=25, cd=1, dur1=30, range1=8, radius1=8})
    ability.template[1][E_id][3]:initdescript(
        "'Kobolt' Auto-Turret",
        "Deploy a robotic turret for #dur1 that lobs random elementium missiles at nearby targets, dealing"
        .." #dmg1 #type1, #type2, or #type3 damage with each shot.")
    -- R
    ability.template[1][R_id][3] = ability:new("A01B", "war3mapImported\\class_ability_icons_12.blp")
    ability.template[1][R_id][3]:initfields({type1=dmg.type[dmg_fire], type2=dmg.type[dmg_frost], type3=dmg.type[dmg_nature],
        count1=3, dmg1=34, dur1=12, cost=45, cd=30, range1=10})
    ability.template[1][R_id][3]:initdescript(
        "Triumvirate",
        "Spawn #count1 wax orbs which orbit you for #dur1, launching random elemental missiles in a continuous spiral which deal"
        .." #dmg1 #type1, #type2, or #type3 damage.")

    --------------------------------------------------------------------------------------------------
    ------------------ GEOMANCER ---------------------------------------------------------------------
    --------------------------------------------------------------------------------------------------
    --[[
        row 1:
    --]]
    -- Q
    ability.template[2][Q_id][1] = ability:new("A00O", "war3mapImported\\class_ability_icons_13.blp")
    ability.template[2][Q_id][1]:initfields({type1=dmg.type[dmg_phys], dmg1=72, range1=8, radius1=3, cost=10, cd=nil, dur1=2.5})
    ability.template[2][Q_id][1]:initdescript(
        "Geo-Bolt",
        "Launch a missile that explodes on contact, dealing #dmg1 #type1 damage in a #radius1 radius and slowing targets for #dur1.")
    -- W
    ability.template[2][W_id][1] = ability:new("A00R", "war3mapImported\\class_ability_icons_14.blp")
    ability.template[2][W_id][1]:initfields({type1=dmg.type[dmg_phys], count1=3, dmg1=32, range1=6, radius1=1.5, cost=15, cd=nil, dur1=3.5})
    ability.template[2][W_id][1]:initdescript(
        "Tremor",
        "Launch #count1 tremoring paths toward a target area, dealing #dmg1 #type1 damage in each quake's #radius1 radius and slowing targets for #dur1.")
    -- E
    ability.template[2][E_id][1] = ability:new("A00T", "war3mapImported\\class_ability_icons_15.blp")
    ability.template[2][E_id][1]:initfields({range1=12, cost=15, cd=30, dur1=10, radius1=1})
    ability.template[2][E_id][1]:initdescript(
        "Geo-Portal",
        "Create a magical portal in front of you and at a target location up to #range1 away, allowing Kobolds to travel between either for #dur1.")
    -- R
    ability.template[2][R_id][1] = ability:new("A00U", "war3mapImported\\class_ability_icons_16.blp")
    ability.template[2][R_id][1]:initfields({type1=dmg.type[dmg_nature], dmg1=176, radius1=10, cost=75, cd=30, dur1=3, dur2=2})
    ability.template[2][R_id][1]:initdescript(
        "Fulmination",
        "Charge yourself with energy for #dur1. When complete, strike each target within #radius1 for #dmg1 #type1 damage and stun them for #dur2.")
    --[[
        row 2:
    --]]
    -- Q
    ability.template[2][Q_id][2] = ability:new("A00P", "war3mapImported\\class_ability_icons_17.blp")
    ability.template[2][Q_id][2]:initfields({type1=dmg.type[dmg_nature], dmg1=16, heal1=12, range1=8, radius1=3, cost=10, cd=nil, dur1=6,
        shroom="Shroom"})
    ability.template[2][Q_id][2]:initdescript(
        "Shroom Bolt",
        "Launch a missile that explodes to summon a #shroom for #dur1. The shroom deals #dmg1 #type1 damage to targets every sec while "
        .." healing Kobolds for #heal1.")
    -- W
    ability.template[2][W_id][2] = ability:new("A00S", "war3mapImported\\class_ability_icons_18.blp")
    ability.template[2][W_id][2]:initfields({type1=dmg.type[dmg_nature], dmg1=160, range1=10, cost=20, cd=12, dur1=6, dur2=3, perc1=20})
    ability.template[2][W_id][2]:initdescript(
        "Fungal Infusion",
        "Become infused with shroom magic, absorbing #dmg1 damage for #dur1. Additionally, restore #perc1 of your health over #dur2.")
    -- E
    ability.template[2][E_id][2] = ability:new("A00V", "war3mapImported\\class_ability_icons_19.blp")
    ability.template[2][E_id][2]:initfields({type1=dmg.type[dmg_nature], dmg1=16, dmg2=48, cost=75, cd=30, dur1=3, golem="Bog Golem", bolt="Bolt", leaps="leaps"})
    ability.template[2][E_id][2]:initdescript(
        "Bog Golem",
        "Summon a #golem to attack your foes for #dmg1 #type1 damage. The Golem #leaps to #bolt cast locations for #dmg2 #type1 damage (#dur1 cooldown).")
    -- R
    ability.template[2][R_id][2] = ability:new("A00W", "war3mapImported\\class_ability_icons_20.blp")
    ability.template[2][R_id][2]:initfields({type1=dmg.type[dmg_nature], dmg1=16, range1=5, cost=nil, cd=45, dur1=12, dur2=6, perc1=100, heal1=12,
        shroom="Shroom", radius1=3})
    ability.template[2][R_id][2]:initdescript(
        "Shroompocalypse",
        "Imbibe the ultimate concoction, restoring #perc1 of your health and mana over #dur1. While active, using a spell causes you to"
        .." leave behind a #shroom.")
    --[[
        row 3:
    --]]
    -- Q
    ability.template[2][Q_id][3] = ability:new("A00Q", "war3mapImported\\class_ability_icons_21.blp")
    ability.template[2][Q_id][3]:initfields({type1=dmg.type[dmg_arcane], dmg1=64, dmg2=34, range1=8, radius1=2, cost=10, cd=nil, perc1=3})
    ability.template[2][Q_id][3]:initdescript(
        "Arcane Bolt",
        "Launch a missile that pierces targets in a #radius1 radius, dealing #dmg1 #type1 damage. Each target hit increases the missile's damage by #perc1.")
    -- W
    ability.template[2][W_id][3] = ability:new("A00X", "war3mapImported\\class_ability_icons_22.blp")
    ability.template[2][W_id][3]:initfields({type1=dmg.type[dmg_arcane], dmg1=12, range1=10, cost=40, cd=30, dur1=3, dup="duplicate", bolt="Bolt", golem="Arcane Golem"})
    ability.template[2][W_id][3]:initdescript(
        "Arcane Golem",
        "Summon a passive #golem to follow you. The Golem will #dup any #bolt ability you use (#dur1 cooldown).")
    -- E
    ability.template[2][E_id][3] = ability:new("A00Y", "war3mapImported\\class_ability_icons_23.blp")
    ability.template[2][E_id][3]:initfields({type1=dmg.type[dmg_arcane], dmg1=176, cost=60, cd=3, radius1=3, dur1=2, dur2=3})
    ability.template[2][E_id][3]:initdescript(
        "Gravity Burst",
        "Target an area which detonates after #dur1, dealing #dmg1 #type1 damage in a #radius1 radius and slowing targets for #dur2.")
    -- R
    ability.template[2][R_id][3] = ability:new("A00Z", "war3mapImported\\class_ability_icons_24.blp")
    ability.template[2][R_id][3]:initfields({type1=dmg.type[dmg_arcane], dmg1=32, cost=60, cd=45, radius1=6, dur1=12, perc1=25})
    ability.template[2][R_id][3]:initdescript(
        "Curse of Doom",
        "Curse targets in a #radius1 radius for #dur1, dealing #dmg1 #type1 damage per sec, slowing them, and reducing their primary damage"
        .." resistance by #perc1.")
    --------------------------------------------------------------------------------------------------
    ------------------ RASCAL-------------------------------------------------------------------------
    --------------------------------------------------------------------------------------------------
    --[[
        row 1:
    --]]
    -- Q
    ability.template[3][Q_id][1] = ability:new("A01C", "war3mapImported\\class_ability_icons_25.blp")
    ability.template[3][Q_id][1]:initfields({type1=dmg.type[dmg_phys], range1=3, dmg1=48, cost=5, cd=nil, dur1=3, perc1=15, count1=3})
    ability.template[3][Q_id][1]:initdescript(
        "Gambit",
        "Strike targets within #range1 for #dmg1 #type1 damage."
        .." Each use of this ability increases its damage by #perc1 for #dur1.")
    -- W
    ability.template[3][W_id][1] = ability:new("A01D", "war3mapImported\\class_ability_icons_26.blp")
    ability.template[3][W_id][1]:initfields({type1=dmg.type[dmg_fire], cost=15, cd=8, dur1=3, dmg1=32, radius1=5, radius2=3})
    ability.template[3][W_id][1]:initdescript(
        "Candleblight",
        "Curse targets within #radius1, causing them to explode in fiery wax for #dmg1 #type1 damage in a #radius2 radius after #dur1.")
    -- E
    ability.template[3][E_id][1] = ability:new("A01E", "war3mapImported\\class_ability_icons_27.blp")
    ability.template[3][E_id][1]:initfields({type1=dmg.type[dmg_fire], dmg1=64, range1=10, range2=3, cost=25, cd=10, dur1=3, perc1=25})
    ability.template[3][E_id][1]:initdescript(
        "Rocket Jump",
        "Blast off to a location up to #range1 away, dealing #dmg1 #type1 damage in a #range2 radius from the launch point and gaining"
        .." #perc1 movespeed for #dur1.")
    -- R
    ability.template[3][R_id][1] = ability:new("A01F", "war3mapImported\\class_ability_icons_28.blp")
    ability.template[3][R_id][1]:initfields({type1=dmg.type[dmg_phys], cost=0, cd=10, perc1=60, perc2=20, perc3=10, count1=2, radius1=3})
    ability.template[3][R_id][1]:initdescript(
        "Devitalize",
        "Strike targets within #radius1 for #perc1 of their missing health as #type1 damage and restore #perc2 mana. If a target dies, restore #perc3 bonus mana."
        .." Less effective versus bosses.")
    --[[
        row 2:
    --]]
    -- Q
    ability.template[3][Q_id][2] = ability:new("A01G", "war3mapImported\\class_ability_icons_29.blp")
    ability.template[3][Q_id][2]:initfields({type1=dmg.type[dmg_shadow], type2=dmg.type[dmg_shadow], dmg1=38, dmg2=76, cost=5, cd=nil, perc1=200, radius1=3})
    ability.template[3][Q_id][2]:initdescript(
        "Backstab",
        "Strike targets within #radius1 for #dmg1 #type1 damage. If you are behind a target, deal #perc1 bonus #type2 damage to them.")
    -- W
    ability.template[3][W_id][2] = ability:new("A01H", "war3mapImported\\class_ability_icons_30.blp")
    ability.template[3][W_id][2]:initfields({dmg1=38, count1=6, range1=8, cost=20, cd=nil, perc1="50", count2=3})
    ability.template[3][W_id][2]:initdescript(
        "Gamble",
        "Throw #count2 magical blades which deal #dmg1 damage of a random type to the first target they strike. #perc1 chance to throw #count1 blades.")
    -- E
    ability.template[3][E_id][2] = ability:new("A01I", "war3mapImported\\class_ability_icons_31.blp")
    ability.template[3][E_id][2]:initfields({type1=dmg.type[dmg_shadow], dmg1=36, radius1=3, cost=30, cd=14, dur1=6})
    ability.template[3][E_id][2]:initdescript(
        "Nether Bomb",
        "Toss a grenade which creates a #radius1 void puddle, pulling targets towards its impact center for #dur1 and dealing #dmg1 #type1 damage per sec.")
    -- R
    ability.template[3][R_id][2] = ability:new("A01V", "war3mapImported\\class_ability_icons_32.blp")
    ability.template[3][R_id][2]:initfields({type1=dmg.type[dmg_shadow], dmg1=48, cost=40, cd=40, dur1=6, perc1=50})
    ability.template[3][R_id][2]:initdescript(
        "Deadly Shadows",
        "Become invisible and invulnerable for #dur1. While stealthed, your abilities deal #perc1 bonus #type1 damage and you move at max movespeed.")
    --[[
        row 3:
    --]]
    -- Q
    ability.template[3][Q_id][3] = ability:new("A01K", "war3mapImported\\class_ability_icons_33.blp")
    ability.template[3][Q_id][3]:initfields({type1=dmg.type[dmg_frost], type2=dmg.type[dmg_frost], dmg1=32, dmg2=64, range1=1, range2=3, cost=5,
        cd=nil, perc1=200, frozen="frozen", radius1=3})
    ability.template[3][Q_id][3]:initdescript(
        "Frost Strike",
        "Strike targets within #radius1 for #dmg1 #type1 damage. If a target is #frozen, deal #perc1 bonus #type2 damage in a #range2 radius.")
    -- W
    ability.template[3][W_id][3] = ability:new("A01L", "war3mapImported\\class_ability_icons_34.blp")
    ability.template[3][W_id][3]:initfields({type1=dmg.type[dmg_frost], dmg1=72, range1=3, radius1=2.33, cost=15, cd=nil,
        dur1=2.25, freezes="freezes"})
    ability.template[3][W_id][3]:initdescript(
        "Frigid Dagger",
        "Throw a dagger that deals #dmg1 #type1 damage in a #range1 line. The dagger detonates at the end of its path for #dmg1 #type1"
        .." damage and #freezes targets for #dur1.")
    -- E
    ability.template[3][E_id][3] = ability:new("A01M", "war3mapImported\\class_ability_icons_35.blp")
    ability.template[3][E_id][3]:initfields({type1=dmg.type[dmg_frost], dmg1=132, range1=3, cost=30, cd=12, dur1=4, dur2=6, freezing="freezing"})
    ability.template[3][E_id][3]:initdescript(
        "Glacial Grenade",
        "Toss a grenade which deals #dmg1 #type1 damage in a #range1 radius, #freezing targets for #dur1.")
    -- R
    ability.template[3][R_id][3] = ability:new("A01N", "war3mapImported\\class_ability_icons_36.blp")
    ability.template[3][R_id][3]:initfields({type1=dmg.type[dmg_frost], dmg1=82, dur1=12, dur2=3, range1=6, cost=60, cd=45, freezing="freezing"})
    ability.template[3][R_id][3]:initdescript(
        "Abominable",
        "Turn into an abominable snobold for #dur1. While active, abilities create rolling snowballs which deal #dmg1 #type1 damage"
        .." to targets, #freezing them for #dur2.")
    --------------------------------------------------------------------------------------------------
    ------------------ WICKFIGHTER -------------------------------------------------------------------
    --------------------------------------------------------------------------------------------------
    --[[
        row 1:
    --]]
    -- Q
    ability.template[4][Q_id][1] = ability:new("A002", "war3mapImported\\class_ability_icons_37.blp")
    ability.template[4][Q_id][1]:initfields({type1=dmg.type[dmg_fire], dmg1=42, radius1=3, cost=5, cd=nil, perc1=1, dur1=4})
    ability.template[4][Q_id][1]:initdescript(
        "Wickfire",
        "Deal #dmg1 #type1 damage in a #radius1 radius and taunt targets for #dur1. Restore #perc1 of your max health for each target hit.")
    -- W
    ability.template[4][W_id][1] = ability:new("A003", "war3mapImported\\class_ability_icons_38.blp")
    ability.template[4][W_id][1]:initfields({type1=dmg.type[dmg_fire], dmg1=196, dmg2=14, radius1=3, cost=25, cd=12, dur1=6})
    ability.template[4][W_id][1]:initdescript(
        "Molten Shield",
        "Absorb the next #dmg1 damage taken for #dur1. While active, deal #dmg2 #type1 damage per sec in a #radius1 radius.")
    -- E
    ability.template[4][E_id][1] = ability:new("A004", "war3mapImported\\class_ability_icons_39.blp")
    ability.template[4][E_id][1]:initfields({type1=dmg.type[dmg_fire], dmg1=64, range1=10, radius1=3, cost=25, cd=8, dur1=6})
    ability.template[4][E_id][1]:initdescript(
        "Ember Charge",
        "Charge a target area within #range1 and combust, dealing #dmg1 #type1 damage in a #radius1 radius and slowing targets for #dur1.")
    -- R
    ability.template[4][R_id][1] = ability:new("A005", "war3mapImported\\class_ability_icons_40.blp")
    ability.template[4][R_id][1]:initfields({type1=dmg.type[dmg_fire], radius1=6, cost=40, cd=45, dur1=10, dmg1=24})
    ability.template[4][R_id][1]:initdescript(
        "Candlepyre",
        "Become a living candle for #dur1. While active, abilities lob wax globules in a #radius1 radius which deal #dmg1 #type1 damage.")
    --[[
        row 2:
    --]]
    -- Q
    ability.template[4][Q_id][2] = ability:new("A00G", "war3mapImported\\class_ability_icons_41.blp")
    ability.template[4][Q_id][2]:initfields({type1=dmg.type[dmg_phys], type2=dmg.type[dmg_fire], dmg1=44, dmg2=32, dmg3=32, cost=5, cd=nil, radius1=3})
    ability.template[4][Q_id][2]:initdescript(
        "Slag Slam",
        "Bash targets within #radius1 for #dmg1 #type1 damage plus #dmg2 #type2 damage. If a target dies, they combust to"
        .." deal #dmg3 #type2 damage in a #radius1 radius.")
    -- W
    ability.template[4][W_id][2] = ability:new("A00H", "war3mapImported\\class_ability_icons_42.blp")
    ability.template[4][W_id][2]:initfields({type1=dmg.type[dmg_phys], dmg1=64, radius1=10, cost=20, cd=20, dur1=12, perc1=15, perc2=20})
    ability.template[4][W_id][2]:initdescript(
        "Waxshell",
        "Become encased in defensive wax, gaining #perc1 elemental resistance for #dur1 and restoring #perc2 life.")
    -- E
    ability.template[4][E_id][2] = ability:new("A00I", "war3mapImported\\class_ability_icons_43.blp")
    ability.template[4][E_id][2]:initfields({type1=dmg.type[dmg_phys], dmg1=104, radius1=3, range1=3, cost=20, cd=10, dur1=0.50})
    ability.template[4][E_id][2]:initdescript(
        "Wickfire Leap",
        "Leap to a target point over #dur1, dealing #dmg1 #type1 damage to targets in a #radius1 radius upon landing"
        .." and knocking them back #range1.")
    -- R
    ability.template[4][R_id][2] = ability:new("A00J", "war3mapImported\\class_ability_icons_44.blp")
    ability.template[4][R_id][2]:initfields({type1=dmg.type[dmg_fire], dmg1=94, dur1=4, radius1=3, range1=10, cost=40, cd=45, count1=8})
    ability.template[4][R_id][2]:initdescript(
        "Basalt Mortar",
        "Hurl a volley of #count1 fireballs at a target area over #dur1, each dealing #dmg1 #type1 damage in a #radius1 radius.")
    --[[
        row 3:
    --]]
    -- Q
    ability.template[4][Q_id][3] = ability:new("A00K", "war3mapImported\\class_ability_icons_45.blp")
    ability.template[4][Q_id][3]:initfields({type1=dmg.type[dmg_phys], dmg1=64, radius1=10, cost=5, cd=nil, perc1=25, count1=3, radius2=3})
    ability.template[4][Q_id][3]:initdescript(
        "Rallying Clobber",
        "Pummel targets within #radius1, dealing #dmg1 #type1 damage and increasing the movespeed and physical resistance of Kobolds within"
        .." #radius1 by #perc1 for 3 sec.")
    -- W
    ability.template[4][W_id][3] = ability:new("A00L", "war3mapImported\\class_ability_icons_46.blp")
    ability.template[4][W_id][3]:initfields({type1=dmg.type[dmg_fire], dmg1=36, radius1=4, cost=20, cd=nil, dur1=4, perc1=25})
    ability.template[4][W_id][3]:initdescript(
        "Molten Roar",
        "Roar with molten waxfury, dealing #dmg1 #type1 damage to targets in a #radius1 radius and reducing their"
        .." attack damage by #perc1 for #dur1.")
    -- E
    ability.template[4][E_id][3] = ability:new("A00M", "war3mapImported\\class_ability_icons_47.blp")
    ability.template[4][E_id][3]:initfields({type1=dmg.type[dmg_phys], dmg1=148, cost=20, cd=6, dur1=3, perc1=50, range1=4.25, count1=2, radius1=3, range1=3})
    ability.template[4][E_id][3]:initdescript(
        "Seismic Toss",
        "Toss targets within #radius1 away from you, dealing #dmg1 #type1 damage and stunning them for #dur1. Deals #perc1 bonus damage to toss-immune targets.")
    -- R
    ability.template[4][R_id][3] = ability:new("A00N", "war3mapImported\\class_ability_icons_48.blp")
    ability.template[4][R_id][3]:initfields({type1=dmg.type[dmg_fire], dmg1=28, dur1=15, cost=40, cd=20, radius1=2.5, perc1=25})
    ability.template[4][R_id][3]:initdescript(
        "Dreadfire",
        "Become engulfed in fiery wax armor for #dur1, reducing all damage taken by #perc1 and dealing #dmg1 #type1 damage to nearby targets each sec.")

    ability.template:buildmasteryabils()
end


function ability.template:buildmasteryabils()
    ability.template.mastery = setmetatable({}, self)

    -- Forcewave
    ability.template.mastery[1] = ability:new("A02N", "war3mapImported\\mastery_ability-icons_01.blp")
    ability.template.mastery[1]:initfields({type1=dmg.type[dmg_arcane], cd=3, cost=15, dmg1=124, radius1=3, range1=4, dur1=6})
    ability.template.mastery[1]:initdescript(
        "Forcewave",
        "Create a shockwave at your feet, dealing #dmg1 #type1 damage to targets in a #radius1 radius, knocking them back #range1,"
        .." and slowing them for #dur1.")

    ability.template.mastery[2] = ability:new("A02X", "war3mapImported\\mastery_ability-icons_02.blp")
    ability.template.mastery[2]:initfields({type1=dmg.type[dmg_arcane], dmg1=24, cd=70, cost=60, dur1=15, perc1=5, radius1=3, third="3rd", every="every element"})
    ability.template.mastery[2]:initdescript(
        "Unstable Arcana",
        "Become power hungry, gaining #perc1 added damage of #every for #dur1. Additionally, every #third ability unleashes a #radius1 nova of missiles for"
        .." #dmg1 #type1 damage.")

    ability.template.mastery[3] = ability:new("A02P", "war3mapImported\\mastery_ability-icons_03.blp")
    ability.template.mastery[3]:initfields({type1=dmg.type[dmg_frost], cd=8, cost=50, dmg1=196, radius1=3, range1=8, freezing="freezing", dur1=3, targetimgsize=200})
    ability.template.mastery[3]:initdescript(
        "Icebound Globe",
        "Launch an orb that explodes on the first target it strikes, dealing #dmg1 #type1 damage in a #radius1 radius and #freezing targets for #dur1.")

    ability.template.mastery[4] = ability:new("A02V", "war3mapImported\\mastery_ability-icons_04.blp")
    ability.template.mastery[4]:initfields({type1=dmg.type[dmg_frost], cd=30, cost=30, dmg1=248, freeze="freeze", dur1=6, perc1=50, radius1=3})
    ability.template.mastery[4]:initdescript(
        "Glaciate",
        "Deal #dmg1 #type1 damage to targets within #radius1 and #freeze them for #dur1. Deals #perc1 bonus damage to freeze-immune targets.")

    ability.template.mastery[5] = ability:new("A02K", "war3mapImported\\mastery_ability-icons_05.blp")
    ability.template.mastery[5]:initfields({type1=dmg.type[dmg_nature], cd=10, cost=30, dmg1=128, radius1=4, dur1=3})
    ability.template.mastery[5]:initdescript(
        "Magnet Rod",
        "Strike all targets within #radius1 for #dmg1 #type1 damage and pull them to you. Pulled targets"
        .." are stunned for #dur1.")

    ability.template.mastery[6] = ability:new("A02Q", "war3mapImported\\mastery_ability-icons_06.blp")
    ability.template.mastery[6]:initfields({type1=dmg.type[dmg_nature], cd=3, cost=75, dmg1=182, dur1=3, perc1=50, perc2=3, radius1=3, targetimgsize=300})
    ability.template.mastery[6]:initdescript(
        "Thunderbolt",
        "Begin charging a target #radius1 area with energy. After #dur1, strike the area with lightning for #dmg1 #type1 damage. "
        .."If an enemy dies, restore #perc2 of your max mana.")

    ability.template.mastery[7] = ability:new("A02O", "war3mapImported\\mastery_ability-icons_07.blp")
    ability.template.mastery[7]:initfields({type1=dmg.type[dmg_fire], cd=10, cost=25, dmg1=264, radius1=3, radius2=3, dur1=8, dur2=3})
    ability.template.mastery[7]:initdescript(
        "Ignite",
        "Burn all targets within #radius1 for #dmg1 #type1 damage over #dur1. If an enemy dies, they combust and stun targets within #radius2 for #dur2.")

    ability.template.mastery[8] = ability:new("A02W", "war3mapImported\\mastery_ability-icons_08.blp")
    ability.template.mastery[8]:initfields({type1=dmg.type[dmg_fire], cd=4, cost=35, dmg1=164, radius1=3, dur1=12, perc1=50, frost="Frost", targetimgsize=300})
    ability.template.mastery[8]:initdescript(
        "Rain of Fire",
        "Deal #dmg1 #type1 damage to targets in a #radius1 radius over #dur1. Deals #perc1 bonus damage to targets with #frost resistance.")

    ability.template.mastery[9] = ability:new("A02J", "war3mapImported\\mastery_ability-icons_09.blp")
    ability.template.mastery[9]:initfields({type1=dmg.type[dmg_shadow], cd=6, cost=30, dmg1=14, range1=8, radius1=3, dur1=12, count1=2, targetimgsize=50})
    ability.template.mastery[9]:initdescript(
        "Demon Bolt",
        "Launch a missile which explodes on the first target it strikes, summoning #count1 demons for #dur1 which attack nearby targets"
        .." for #dmg1 #type1 damage.")

    ability.template.mastery[10] = ability:new("A02R", "war3mapImported\\mastery_ability-icons_10.blp")
    ability.template.mastery[10]:initfields({type1=dmg.type[dmg_shadow], type2=dmg.type[dmg_fire], dmg1=48, dmg2=36, cd=nil, cost=20, radius1=3, range1=8})
    ability.template.mastery[10]:initdescript(
        "Shadowflame",
        "Launch fel magic which travels #range1, dealing #dmg1 #type1 and #dmg2 #type2 damage. When the wave reaches max range, it returns"
        .." to you, damaging targets again.")

    ability.template.mastery[11] = ability:new("A02A", "war3mapImported\\mastery_ability-icons_11.blp")
    ability.template.mastery[11]:initfields({type1=dmg.type[dmg_phys], dmg1=196, cost=50, cd=30, perc1=15, perc2=300, castrange=125, radius1=3})
    ability.template.mastery[11]:initdescript(
        "Eradicate",
        "Deal #dmg1 #type1 damage to targets within #radius1. If they are under #perc1 health, they take #perc2 more damage. "
        .."If an enemy dies, this ability's cooldown is reset.")

    ability.template.mastery[12] = ability:new("A02S", "war3mapImported\\mastery_ability-icons_12.blp")
    ability.template.mastery[12]:initfields({type1=dmg.type[dmg_phys], cost=30, cd=4, perc1=400, perc2=200, armor="armor rating", castrange=125, radius1=3})
    ability.template.mastery[12]:initdescript(
        "Blood Rite",
        "Deal #perc1 of your #armor as #type1 damage to targets within #radius1 and restore health equal to #perc2 of the damage dealt.")

    ability.template.mastery[13] = ability:new("A02M", "war3mapImported\\mastery_ability-icons_13.blp")
    ability.template.mastery[13]:initfields({type1=dmg.type[dmg_phys], cost=25, cd=45, perc1=10, perc2=25, perc3=40, dur1=6, revive="revive", castrange=125, radius1=3})
    ability.template.mastery[13]:initdescript(
        "Bull Rat",
        "Reduce all damage taken by #perc1 for #dur1. If you fall below #perc2 health while active, instantly heal for #perc3 health and consume the effect. "
        .." While active, nearby enemies are knocked back #radius1.")

    ability.template.mastery[14] = ability:new("A02T", "war3mapImported\\mastery_ability-icons_14.blp")
    ability.template.mastery[14]:initfields({type1=dmg.type[dmg_phys], cost=20, cd=6, perc1=10, perc3=100, dur1=3, radius1=10})
    ability.template.mastery[14]:initdescript(
        "Rejuvenate",
        "Restore #perc1 health instantly, plus an additional #perc1 of your max health over #dur1.")

    ability.template.mastery[15] = ability:new("A02L", "war3mapImported\\mastery_ability-icons_15.blp")
    ability.template.mastery[15]:initfields({dmg1=48, cost=30, cd=30, dur1=15, dur2=3})
    ability.template.mastery[15]:initdescript(
        "Energy Shield",
        "Gain a protective shield for #dur1. While active, the shield is powered every #dur2 to absorb #dmg1 damage for #dur2.")

    ability.template.mastery[16] = ability:new("A02U", "war3mapImported\\mastery_ability-icons_16.blp")
    ability.template.mastery[16]:initfields({cost=0, cd=8, radius1=6, dur1=1.0, dmg1=124, castrange=600, targetimgsize=80})
    ability.template.mastery[16]:initdescript(
        "Rat Dash",
        "Quickly dash to a target area up to #radius1 away and absorb the next #dmg1 damage taken for #dur1.")

end


function ability.template:buildmasteryspells(p)
    local p = p
    self.mastery.p = p
    -- "Forcewave"
    ability.template.mastery[1].spell = spell:new(casttype_instant, p, self.mastery:mastabilid(1))
    ability.template.mastery[1].spell.orderstr = 'cloudoffog'
    ability.template.mastery[1].spell.id = 1
    ability.template.mastery[1].spell:addaction(function()
        local s   = ability.template.mastery[1].spell
        s.caster  = kobold.player[p].unit
        local grp = g:newbyunitloc(p, g_type_dmg, s.caster, self.mastery:getmastradius(1, "radius1"))
        speff_fspurp:playu(s.caster)
        spell:gdmg(p, grp, self.mastery:getmastfield(1, "type1"), self.mastery:getmastfield(1, "dmg1"))
        spell:gbuff(grp, bf_slow, self.mastery:getmastfield(1, "dur1"))
        kb:new_group(grp, s.casterx, s.castery, self.mastery:getmastradius(1, "range1"))
        grp:destroy()
    end)
    -- "Unstable Arcana"
    ability.template.mastery[2].spell = spell:new(casttype_instant, p, self.mastery:mastabilid(2))
    ability.template.mastery[2].spell.active = false
    ability.template.mastery[2].spell.casts = 0
    ability.template.mastery[2].spell.trig = trg:newspelltrig(kobold.player[p].unit, function()
        if ability.template.mastery[2].spell.active then
            ability.template.mastery[2].spell.casts = ability.template.mastery[2].spell.casts + 1
            if ability.template.mastery[2].spell.casts >= 3 then -- every 3rd cast
                ability.template.mastery[2].spell.casts = 0
                missile:create_in_radius(utils.unitx(kobold.player[p].unit), utils.unity(kobold.player[p].unit), kobold.player[p].unit,
                    mis_shot_arcane.effect, self.mastery:getmastfield(2, "dmg1"), self.mastery:getmastfield(2, "type1"), 8, 600.0, nil, 125.0, 90, true, false)
            end
        end
    end)
    ability.template.mastery[2].spell.orderstr = 'wispharvest'
    ability.template.mastery[2].spell.id = 2
    ability.template.mastery[2].spell:addaction(function()
        local s    = ability.template.mastery[2].spell
        s.caster   = kobold.player[p].unit
        local dur1 = self.mastery:getmastfield(2, "dur1")
        ability.template.mastery[2].spell.casts  = 0
        ability.template.mastery[2].spell.active = true
        for dmgtypeid = 1,6 do -- enhance all ids except physical.
            if dmgtypeid ~= 6 then
                s:enhancedmgtype(dmgtypeid, self.mastery:getmastfield(2, "perc1"), dur1, p, true)
            end
        end
        speff_bluglow:attachu(s.caster, dur1, 'chest')
        utils.timed(dur1, function() ability.template.mastery[2].spell.active = false end)
        buffy:add_indicator(p, "Unstable Arcana", "ReplaceableTextures\\CommandButtons\\BTNStarfall.blp", dur1,
            "Added elemental damage, abilities unleash arcane missiles")
    end)
    -- "Icebound Globe"
    ability.template.mastery[3].spell = spell:new(casttype_point, p, self.mastery:mastabilid(3))
    ability.template.mastery[3].spell.orderstr = 'controlmagic'
    ability.template.mastery[3].spell.id = 3
    ability.template.mastery[3].spell:addaction(function()
        local s     = ability.template.mastery[3].spell
        s.caster    = kobold.player[p].unit
        speff_frostnova:playu(s.caster)
        local dur   = self.mastery:getmastfield(3, "dur1")
        local r     = self.mastery:getmastradius(3, "radius1")
        local mis   = s:pmissiletargetxy(self.mastery:getmastrange(3, "range1"), orb_eff_frost, self.mastery:getmastfield(3, "dmg1"))
        mis.dmgtype = self.mastery:getmastfield(3, "type1")
        mis.vel     = 17
        mis.expl    = true
        mis.explfunc = function()
            local grp = g:newbyxy(p, g_type_dmg, mis.x, mis.y, r)
            spell:gbuff(grp, bf_freeze, dur)
            speff_frostnova:playradius(r/2, 3, mis.x, mis.y)
            speff_frostnova:playradius(r, 5, mis.x, mis.y)
            grp:destroy()
        end
    end)
    -- "Glaciate"
    ability.template.mastery[4].spell = spell:new(casttype_instant, p, self.mastery:mastabilid(4))
    ability.template.mastery[4].spell.orderstr = 'doom'
    ability.template.mastery[4].spell.id = 4
    ability.template.mastery[4].spell:addaction(function()
        local s     = ability.template.mastery[4].spell
        s.caster    = kobold.player[p].unit
        speff_frostnova:playu(s.caster)
        local dmg1  = self.mastery:getmastfield(4, "dmg1")
        local dur1  = self.mastery:getmastfield(4, "dur1")
        local grp   = g:newbyxy(p, g_type_dmg, s.casterx, s.castery, self.mastery:getmastradius(4, "radius1"))
        grp:action(function()
            if utils.isancient(grp.unit) then
                s:tdmg(p, grp.unit, self.mastery:getmastfield(4, "type1"), dmg1*(1 + self.mastery:getmastfield(4, "perc1")/100))
            else
                bf_freeze:apply(grp.unit, dur1)
                bf_stun:apply(grp.unit, dur1)
                speff_iceblock:attachu(grp.unit, dur1, 'origin')
                s:tdmg(p, grp.unit, self.mastery:getmastfield(4, "type1"), dmg1)
            end
        end)
        grp:destroy()
    end)
    -- "Magnet Rod"
    ability.template.mastery[5].spell = spell:new(casttype_instant, p, self.mastery:mastabilid(5))
    ability.template.mastery[5].spell.orderstr = 'creepdevour'
    ability.template.mastery[5].spell.id = 5
    ability.template.mastery[5].spell:addaction(function()
        local s     = ability.template.mastery[5].spell
        s.caster    = kobold.player[p].unit
        local dur1  = self.mastery:getmastfield(5, "dur1")
        local grp   = g:newbyxy(p, g_type_dmg, s.casterx, s.castery, self.mastery:getmastradius(5, "radius1"))
        mis_hammerred:playu(s.caster)
        spell:gbuff(grp, bf_stun, dur1)
        spell:gdmg(p, grp, self.mastery:getmastfield(5, "type1"), self.mastery:getmastfield(5, "dmg1"))
        -- grp:action(function() buffy:gen_cast_unit(s.caster, FourCC('A03A'), 'chainlightning', grp.unit) end)
        kb:new_pullgroup(grp, s.casterx, s.castery, 0.84)
        grp:destroy()
    end)
    -- "Thunderbolt"
    ability.template.mastery[6].spell = spell:new(casttype_point, p, self.mastery:mastabilid(6))
    ability.template.mastery[6].spell.orderstr = 'cyclone'
    ability.template.mastery[6].spell.id = 6
    ability.template.mastery[6].spell:addaction(function()
        local s    = ability.template.mastery[6].spell
        s.caster   = kobold.player[p].unit
        speff_charging:play(s.targetx, s.targety, self.mastery:getmastfield(6, "dur1"), 1.33)
        utils.timed(self.mastery:getmastfield(6, "dur1"), function()
            utils.debugfunc(function()
                local grp = g:newbyxy(p, g_type_dmg, s.targetx, s.targety, self.mastery:getmastradius(6, "radius1"))
                grp:action(function()
                    if utils.isalive(grp.unit) then
                        s:tdmg(p, grp.unit, self.mastery:getmastfield(6, "type1"), self.mastery:getmastfield(6, "dmg1"))
                        if not utils.isalive(grp.unit) then -- refund partial manacost if death by dmg.
                            utils.addmanap(s.caster, 3.0, true)
                        end
                    end
                end)
                speff_stormlght:play(s.targetx, s.targety)
                grp:destroy()
            end, "Thunderbolt")
        end)
    end)
    -- "Ignite"
    ability.template.mastery[7].spell = spell:new(casttype_instant, p, self.mastery:mastabilid(7))
    ability.template.mastery[7].spell.teffect  = {}
    ability.template.mastery[7].spell.orderstr = 'coupletarget'
    ability.template.mastery[7].spell.id = 7
    ability.template.mastery[7].spell:addaction(function()
        ability.template.mastery[7].spell.caster = kobold.player[p].unit
        local s     = ability.template.mastery[7].spell
        local dur1, dur2 = self.mastery:getmastfield(7, "dur1"), self.mastery:getmastfield(7, "dur2")
        local dmg1  = math.floor(self.mastery:getmastfield(7, "dmg1")/dur1)
        local r     = self.mastery:getmastradius(7, "radius1")
        local grp   = g:newbyunitloc(p, g_type_dmg, s.caster, self.mastery:getmastradius(1, "radius1"))
        grp:action(function()
            if utils.isalive(grp.unit) then
                local e = speff_burning:attachu(s.target, dur1, 'overhead')
                local grpunit = grp.unit
                utils.timedrepeat(1.0, dur1, function()
                    if grpunit and utils.isalive(grpunit) then
                        s:tdmg(p, grpunit, self.mastery:getmastfield(7, "type1"), dmg1)
                    else
                        speff_fireroar:playu(grpunit)
                        local grp2 = g:newbyxy(utils.powner(s.caster), g_type_dmg, utils.unitx(grpunit), utils.unity(grpunit), r)
                        grp2:action(function()
                            s:gbuff(grp2, bf_stun, dur2)
                        end)
                        grp2:destroy()
                        DestroyEffect(e)
                        ReleaseTimer()
                    end
                end, function() if e then DestroyEffect(e) end end)
            end
        end)
        speff_fireroar:playu(s.caster)
        grp:destroy()
    end)
    -- "Rain of Fire"
    ability.template.mastery[8].spell = spell:new(casttype_point, p, self.mastery:mastabilid(8))
    ability.template.mastery[8].spell.orderstr = 'creepheal'
    ability.template.mastery[8].spell.id = 8
    ability.template.mastery[8].spell:addaction(function()
        local s      = ability.template.mastery[8].spell
        s.caster     = kobold.player[p].unit
        local x,y    = s.targetx, s.targety
        local radius = self.mastery:getmastradius(8, "radius1")
        local dur1   = self.mastery:getmastfield(8, "dur1")
        local dmg1   = self.mastery:getmastfield(8, "dmg1")/3/dur1
        local dmgtype= self.mastery:getmastfield(8, "type1")
        local a,r,x2,y2
        utils.timedrepeat(0.33, dur1*3, function()
            a = math.random() * 2 * 3.141
            r = radius * math.sqrt(math.random())
            x2 = x + (r * math.cos(a))
            y2 = y + (r * math.sin(a))
            speff_rainfire:play(x2, y2)
            mis_fireball:play(x2, y2)
            s:gdmgxy(p, dmgtype, dmg1, x, y, radius)
            local grp = g:newbyxy(p, g_type_dmg, x, y, radius)
            grp:action(function()
                if BlzGetUnitIntegerField(grp.unit, UNIT_IF_DEFENSE_TYPE) == GetHandleId(DEFENSE_TYPE_NORMAL) then -- has frost defense type.
                    s:tdmg(p, grp.unit, dmgtype, dmg1*1.5)
                else
                    s:tdmg(p, grp.unit, dmgtype, dmg1)
                end
            end)
            grp:destroy()
        end, function() s = nil dmgtype = nil end)
    end)
    -- "Demon Bolt"
    ability.template.mastery[9].spell = spell:new(casttype_point, p, self.mastery:mastabilid(9))
    ability.template.mastery[9].spell.orderstr = 'blizzard'
    ability.template.mastery[9].spell.id = 9
    ability.template.mastery[9].spell:addaction(function()
        local s     = ability.template.mastery[9].spell
        s.caster    = kobold.player[p].unit
        local dmg1  = self.mastery:getmastfield(9, "dmg1")
        local mis   = ability.template.mastery[9].spell:pmissiletargetxy(self.mastery:getmastrange(9, "range1"), mis_boltpurp, dmg1)
        mis.dmgtype = self.mastery:getmastfield(9, "type1")
        mis.vel     = 16
        mis.expl    = true
        mis.explfunc = function()
            speff_explpurp:play(mis.x, mis.y)
            for i = 1,self.mastery:getmastfield(9, "count1") do
                local x,y = utils.projectxy(mis.x, mis.y, 128, math.random(0,360))
                local unit = utils.unitatxy(p, x, y, 'n00J', math.random(0,360))
                BlzSetUnitBaseDamage(unit, dmg1, 0)
                UnitApplyTimedLife(unit, FourCC('BTLF'), self.mastery:getmastfield(9, "dur1"))
                speff_deathpact:play(x, y)
            end
        end
    end)
    -- "Shadowflame"
    ability.template.mastery[10].spell = spell:new(casttype_point, p, self.mastery:mastabilid(10))
    ability.template.mastery[10].spell.orderstr = 'creepthunderclap'
    ability.template.mastery[10].spell.id = 10
    ability.template.mastery[10].spell:addaction(function()
        local s     = ability.template.mastery[10].spell
        s.caster    = kobold.player[p].unit
        local x,y   = s.casterx, s.castery
        local dmg1  = self.mastery:getmastfield(10, "dmg1")
        local dmg2  = self.mastery:getmastfield(10, "dmg2")
        local smis     = s:pmissiletargetxy(self.mastery:getmastrange(9, "range1"), mis_voidballhge, dmg1)
        smis.vel       = 24
        smis.x, smis.y = utils.projectxy(utils.unitx(s.caster), utils.unity(s.caster), 50.0, s:angletotarget()-90.0)
        smis.dmgtype   = self.mastery:getmastfield(10, "type1")
        smis.reflect   = true
        smis:initpiercing()
        local fmis     = s:pmissiletargetxy(self.mastery:getmastrange(9, "range1"), mis_fireballhge, dmg2)
        fmis.vel       = 24
        fmis.dmgtype   = self.mastery:getmastfield(10, "type2")
        fmis.x, fmis.y = utils.projectxy(utils.unitx(s.caster), utils.unity(s.caster), 50.0, s:angletotarget()+90.0)
        fmis.reflect   = true
        fmis:initpiercing()
    end)
    -- "Eradicate"
    ability.template.mastery[11].spell = spell:new(casttype_instant, p, self.mastery:mastabilid(11))
    ability.template.mastery[11].spell.orderstr = 'devourmagic'
    ability.template.mastery[11].spell.id = 11
    ability.template.mastery[11].spell.dmgfunc = function(unit)
        if utils.getlifep(unit) < 15 then
            speff_beamred:playu(unit)
            spell:tdmg(p, unit, self.mastery:getmastfield(11, "type1"), self.mastery:getmastfield(11, "dmg1")*3.0)
            if not utils.isalive(unit) then
                utils.timed(0.21, function() BlzEndUnitAbilityCooldown(s.caster, s.dummycode) s.cdactive = false end)
            end
        end
    end
    ability.template.mastery[11].spell:addaction(function()
        local s   = ability.template.mastery[11].spell
        s.caster  = kobold.player[p].unit
        local grp = g:newbyunitloc(p, g_type_dmg, s.caster, self.mastery:getmastradius(1, "radius1"))
        speff_redburst:playu(s.caster)
        spell:gdmg(p, grp, self.mastery:getmastfield(11, "type1"), self.mastery:getmastfield(1, "dmg1"), ability.template.mastery[11].spell.dmgfunc)
        kb:new_group(grp, s.casterx, s.castery, self.mastery:getmastradius(1, "range1"))
        grp:destroy()
    end)
    -- "Blood Rite"
    ability.template.mastery[12].spell = spell:new(casttype_instant, p, self.mastery:mastabilid(12))
    ability.template.mastery[12].spell.orderstr = 'deathcoil'
    ability.template.mastery[12].spell.id = 12
    ability.template.mastery[12].spell:addaction(function()
        local s     = ability.template.mastery[12].spell
        s.caster    = kobold.player[p].unit
        local dmg1  = math.floor(((kobold.player[p][p_stat_armor]-(kobold.player[p].level-1)*0.8)))
        if dmg1 > 0 then
            local grp = g:newbyxy(p, g_type_dmg, s.casterx, s.castery , self.mastery:getmastradius(12, "radius1"))
            grp:action(function()
                s:tdmg(p, grp.unit, self.mastery:getmastfield(12, "type1"), dmg1)
                utils.addlifeval(s.caster, dmg1*2, true, s.caster)
                speff_redburst:playu(grp.unit)
            end)
            speff_bloodsplat:playu(s.caster)                
            grp:destroy()
        end
    end)
    -- "Bull Rat"
    ability.template.mastery[13].spell = spell:new(casttype_instant, p, self.mastery:mastabilid(13))
    ability.template.mastery[13].spell.orderstr = 'cannibalize'
    ability.template.mastery[13].spell.id = 13
    ability.template.mastery[13].spell:addaction(function()
        local s     = ability.template.mastery[13].spell
        s.caster    = kobold.player[p].unit
        local dur1  = self.mastery:getmastfield(13, "dur1")
        local e     = sp_enchant_eff[4]:attachu(s.caster, dur1, 'chest', 0.8)
        local perc2,perc3  = self.mastery:getmastfield(13, "perc2"),self.mastery:getmastfield(13, "perc3")
        local c     = 0
        local consumedbool = false
        speff_roar:playu(s.caster)
        kobold.player[p][p_stat_dmg_reduct] = kobold.player[p][p_stat_dmg_reduct] + self.mastery:getmastfield(13, "perc1")
        tooltip:updatecharpage(p)
        utils.timedrepeat(0.03, dur1*33, function()
            c = c + 1
            if c >= 5 then
                c = 0
                local grp = g:newbyxy(p, g_type_dmg, utils.unitx(s.caster), utils.unity(s.caster), 185.0)
                kb:new_group(grp, utils.unitx(s.caster), utils.unity(s.caster), self.mastery:getmastradius(13, "radius1"), 0.66)
                grp:destroy()
            end
            if not kobold.player[p].downed and utils.getlifep(s.caster) <= perc2 and not consumedbool then -- below 10% detected
                consumedbool = true
                kobold.player[p][p_stat_dmg_reduct] = kobold.player[p][p_stat_dmg_reduct] - self.mastery:getmastfield(13, "perc1")
                tooltip:updatecharpage(p)
                utils.addlifep(s.caster, perc3, true, kobold.player[p].unit)
                speff_resurrect:playu(s.caster)
                DestroyEffect(e)
                ReleaseTimer()
            end
        end, function()
            if not consumedbool then
                kobold.player[p][p_stat_dmg_reduct] = kobold.player[p][p_stat_dmg_reduct] - self.mastery:getmastfield(13, "perc1")
                tooltip:updatecharpage(p)
            end
        end)
        buffy:add_indicator(p, "Bull Rat", "ReplaceableTextures\\CommandButtons\\BTNReincarnation.blp", dur1,
            "Reduces damage taken, restores health when low")
    end)

    -- "Rejuvenate"
    ability.template.mastery[14].spell = spell:new(casttype_instant, p, self.mastery:mastabilid(14))
    ability.template.mastery[14].spell.orderstr = 'rejuvination'
    ability.template.mastery[14].spell.id = 14
    ability.template.mastery[14].spell:addaction(function()
        local s         = ability.template.mastery[14].spell
        s.caster        = kobold.player[p].unit
        local dur1      = self.mastery:getmastfield(14, "dur1")
        local amt       = (utils.maxlife(s.caster)*0.10)/dur1
        local caster    = s.caster -- leave this, have to instantiate or timer bugs.
        speff_rejuv:attachu(caster, dur1, 'origin')
        utils.addlifep(caster, 10.0, true, caster)
        utils.timedrepeat(1.0, dur1, function()
            utils.addlifeval(caster, amt, true, caster)
        end, function() s = nil end)
        buffy:add_indicator(p, "Rejuvenate", "ReplaceableTextures\\CommandButtons\\BTNRejuvenation.blp", dur1,
            "Recovering "..tostring(math.floor(amt)).." health per sec")
    end)
    -- "Energy Shield"
    ability.template.mastery[15].spell = spell:new(casttype_instant, p, self.mastery:mastabilid(15))
    ability.template.mastery[15].spell.orderstr = 'breathoffire'
    ability.template.mastery[15].spell.id = 15
    ability.template.mastery[15].spell:addaction(function()
        local s    = ability.template.mastery[15].spell
        s.caster   = kobold.player[p].unit
        local dmg1  = self.mastery:getmastfield(15, "dmg1")
        local dur1  = self.mastery:getmastfield(15, "dur1")
        local dur2  = self.mastery:getmastfield(15, "dur2")
        local e1    = mis_lightnorb:attachu(s.caster, dur1, 'hand,left')
        local e2    = mis_lightnorb:attachu(s.caster, dur1, 'hand,right')
        local e3    = mis_lightnorb:attachu(s.caster, dur1, 'overhead')
        dmg.absorb:new(s.caster, dur2, { all = dmg1 }, speff_uberblu)
        utils.timedrepeat(dur2, math.floor(dur1/dur2), function()
            utils.debugfunc(function()
                if not kobold.player[p].downed then
                    dmg.absorb:new(s.caster, dur2, { all = dmg1 }, speff_uberblu)
                    buffy:add_indicator(p, "Energy Shield Absorb", "ReplaceableTextures\\CommandButtons\\BTNOrbOfLightning.blp", dur2,
                        "Absorbs up to "..tostring(dmg1).." damage")
                else
                    DestroyEffect(e1) DestroyEffect(e2) DestroyEffect(e3)
                    ReleaseTimer()
                end
            end, "energy shield")
        end)
        buffy:add_indicator(p, "Energy Shield", "ReplaceableTextures\\CommandButtons\\BTNLightningShield.blp", dur1,
            "Absorbs damage every "..tostring(dur2).." sec")
    end)
    -- "Rat Dash"
    ability.template.mastery[16].spell = spell:new(casttype_point, p, self.mastery:mastabilid(16))
    ability.template.mastery[16].spell.orderstr = 'blink'
    ability.template.mastery[16].spell.id = 16
    ability.template.mastery[16].spell:addaction(function()
        local s     = ability.template.mastery[16].spell
        s.caster    = kobold.player[p].unit
        local e     = sp_enchant_eff[2]:attachu(s.caster, 0.24, 'chest')
        if not spell:slide(s.caster, s:disttotarget(), 0.24, s.targetx, s.targety, nil, function()
            dmg.absorb:new(s.caster, self.mastery:getmastfield(16, "dur1"), { all = self.mastery:getmastfield(16, "dmg1") }) end) then DestroyEffect(e) end
        buffy:add_indicator(p, "Rat Dash", "ReplaceableTextures\\CommandButtons\\BTNEvasion.blp", self.mastery:getmastfield(16, "dur1"),
            "Absorbs up to "..tostring(self.mastery:getmastfield(16, "dmg1")).." damage")
    end)
end

--[[
    mastery lookup helpers:
--]]

function ability.template:mastabilid(id)
    return self[id].code
end


function ability.template:getmastfield(id, fieldname)
    return self[id][fieldname]
end


function ability.template:getmastradius(id, fieldname)
    -- *note: this converts meters to in-game units (x * 100).
    return math.floor(self[id][fieldname]*(1+kobold.player[self.p][p_stat_abilarea]/100))*100
end


function ability.template:getmastrange(id, fieldname)
    return math.floor(self[id][fieldname]*100) -- *note, we get missile range stat in spell helpers!
end


--[[
    standard lookup helpers:
--]]


function ability.template:abilid(hotkeyid, colid)
    return self[hotkeyid][colid].code -- ability code
end


function ability.template:getfield(hotkeyid, colid, fieldname)
    return self[hotkeyid][colid][fieldname]
end


function ability.template:getradius(hotkeyid, colid, fieldname)
    -- *note: this converts meters to in-game units (x * 100).
    return math.floor(self[hotkeyid][colid][fieldname]*(1+kobold.player[self.p][p_stat_abilarea]/100))*100
end


function ability.template:getrange(hotkeyid, colid, fieldname)
    return math.floor(self[hotkeyid][colid][fieldname]*(1+kobold.player[self.p][p_stat_mislrange]/100))*100 -- *note, we get missile range stat in spell helpers!
end


function ability.template:loadtunneler(p)
    local Q_id,W_id,E_id,R_id,p = 1,2,3,4,p
    -----------------------------------Q-----------------------------------
    -- TUNNEL BOMB --
    self.spells[Q_id][1] = spell:new(casttype_point, p, self:abilid(Q_id, 1))
    self.spells[Q_id][1].rect = Rect(0,0,0,0)
    self.spells[Q_id][1]:uiregcooldown(self:getfield(Q_id, 1, "cd"), Q_id)
    self.spells[Q_id][1]:addaction(function()
        local s    = self.spells[Q_id][1]
        local r    = self:getradius(Q_id, 1, "radius1")
        local dmg  = self:getfield(Q_id, 1, "dmg1")
        local x,y  = s.targetx, s.targety -- *note: need to instantiate for spammable abils.
        local landfunc = function()
            speff_explode2:play(x, y)
            s:gdmgxy(p, self:getfield(Q_id, 1, "type1"), dmg, x, y, r)
            utils.setrectradius(s.rect, x, y, r)
            utils.dmgdestinrect(s.rect, math.floor(dmg*(self:getfield(Q_id, 1, "perc1")/100)))
        end
        local mis    = s:pmissilearc(mis_grenadeoj, 0)
        mis.explfunc = landfunc
    end)
    -- PICKERANG --
    self.spells[Q_id][2] = spell:new(casttype_point, p, self:abilid(Q_id, 2))
    self.spells[Q_id][2].rect = Rect(0,0,0,0)
    self.spells[Q_id][2]:uiregcooldown(self:getfield(Q_id, 2, "cd"), Q_id)
    self.spells[Q_id][2]:addaction(function()
        local s    = self.spells[Q_id][2]
        local d    = self:getrange(Q_id, 2, "range1")
        local r    = self:getradius(Q_id, 2, "radius1")
        local dmg  = self:getfield(Q_id, 2, "dmg1")/2
        local x,y  = s.targetx, s.targety -- *note: need to instantiate for spammable abils.
        for i = 1,2 do
            local mis  = s:pmissileangle(d, mis_hammergreen, 0)
            local i    = i
            mis.vel    = 28
            mis.x, mis.y = utils.projectxy(mis.x, mis.y, 48.0, mis.angle)
            if i == 1 then mis.angle = mis.angle + 45 else mis.angle = mis.angle - 45 end
            mis.time   = self:getfield(Q_id, 2, "dur1")
            mis:initpiercing()
            mis:initduration()
            speff_defend:playu(s.caster)
            local hitfunc = function(unit)
                utils.debugfunc(function()
                    if utils.isalive(unit) and utils.slowed(unit) then
                        -- NOTE: this will give a false positive of being "broken" on Ymmud because he ignores buffs.
                        self:getfield(Q_id, 2, "type1"):pdeal(p, dmg*0.25, unit)
                    end
                end, "hit")
            end
            mis.func = function(mis)
                utils.debugfunc(function()
                    if math.fmod(mis.elapsed, 8) == 0 then
                        s:gdmgxy(p, self:getfield(Q_id, 2, "type1"), dmg, mis.x, mis.y, r, hitfunc)
                    end
                    if i == 1 then mis.angle = mis.angle - 5.33 else mis.angle = mis.angle + 5.33 end
                end, "mis")
            end
        end
    end)
    -- PRIMAL CANDLE --
    self.spells[Q_id][3] = spell:new(casttype_point, p, self:abilid(Q_id, 3))
    self.spells[Q_id][3].rect = Rect(0,0,0,0)
    self.spells[Q_id][3]:uiregcooldown(self:getfield(Q_id, 3, "cd"), Q_id)
    self.spells[Q_id][3]:addaction(function()
        local s    = self.spells[Q_id][3]
        local r    = self:getradius(Q_id, 3, "radius1")
        local x1,y1= utils.projectxy(s.casterx, s.castery, r,   s:angletotarget())
        local x2,y2= utils.projectxy(s.casterx, s.castery, r*2, s:angletotarget())
        local x3,y3= utils.projectxy(s.casterx, s.castery, r*3, s:angletotarget())
        local t1,t2,t3 = math.random(2,4), math.random(2,4), math.random(2,4)
        speff_expl_stack[t1]:play(x1, y1)
        speff_expl_stack[t2]:play(x2, y2)
        speff_expl_stack[t3]:play(x3, y3)
        s:gdmgxy(p, dmg.type.stack[t1], self:getfield(Q_id, 3, "dmg1"), x1, y1, r)
        s:gdmgxy(p, dmg.type.stack[t2], self:getfield(Q_id, 3, "dmg1"), x2, y2, r)
        s:gdmgxy(p, dmg.type.stack[t3], self:getfield(Q_id, 3, "dmg1"), x3, y3, r)
        utils.timed(0.21, function() -- repeat dmg
            s:gdmgxy(p, dmg.type.stack[t1], self:getfield(Q_id, 3, "dmg1"), x1, y1, r)
            s:gdmgxy(p, dmg.type.stack[t2], self:getfield(Q_id, 3, "dmg1"), x2, y2, r)
            s:gdmgxy(p, dmg.type.stack[t3], self:getfield(Q_id, 3, "dmg1"), x3, y3, r)
        end)
    end)
    -----------------------------------W-----------------------------------
    -- ROCKSAW --
    self.spells[W_id][1] = spell:new(casttype_point, p, self:abilid(W_id, 1))
    self.spells[W_id][1].rect = Rect(0,0,0,0)
    self.spells[W_id][1]:uiregcooldown(self:getfield(W_id, 1, "cd"), W_id)
    self.spells[W_id][1]:addaction(function()
        local s    = self.spells[W_id][1]
        local r    = self:getradius(W_id, 1, "range1")
        local dur  = self:getfield(W_id, 1, "dur1")
        local dmg  = math.floor(self:getfield(W_id, 1, "dmg1")/3)
        local ddmg = math.floor(dmg*(self:getfield(W_id, 1, "perc1")/100))
        local x1,y1,e       = 0,0,{}
        local angleoffset   = 90
        local startangle    = utils.anglexy(utils.unitx(s.caster), utils.unity(s.caster), s.targetx, s.targety) - angleoffset
        for i = 1,tonumber(self:getfield(W_id, 1, "count1")) do
            e[i] = {}
            e[i].x, e[i].y  = utils.projectxy(s.targetx, s.targety, 190.0, startangle + ((i-1)*angleoffset))
            e[i].e          = speff_arcglaive:play(e[i].x, e[i].y, dur)
            speff_dustcloud:play(e[i].x, e[i].y)
        end
        utils.timedrepeat(0.03, dur*33 - 1, function(c)
            utils.debugfunc(function()
                if math.fmod(c, 10) == 0 then
                    for _,t in ipairs(e) do
                        s:gdmgxy(p, self:getfield(W_id, 1, "type1"), dmg, t.x, t.y, r)
                        if math.random(0,1) == 1 then speff_phys:play(t.x, t.y) else mis_rock:play(t.x, t.y) end
                        utils.setrectradius(s.rect, t.x, t.y, r)
                        utils.dmgdestinrect(s.rect, ddmg)
                    end
                end
            end, "rocksaw timer")
        end, function()
            for i,t in ipairs(e) do
                if t.e then DestroyEffect(t.e) end
                e[i] = nil
            end
            e = nil
        end)
    end)
    -- HAMMERANG --
    self.spells[W_id][2] = spell:new(casttype_point, p, self:abilid(W_id, 2))
    self.spells[W_id][2].rect = Rect(0,0,0,0)
    self.spells[W_id][2]:uiregcooldown(self:getfield(W_id, 2, "cd"), W_id)
    self.spells[W_id][2]:addaction(function()
        local s    = self.spells[W_id][2]
        local d    = self:getrange(W_id, 2, "range1")
        local r    = self:getradius(W_id, 2, "radius1")
        -- local dmg  = self:getfield(W_id, 2, "dmg1")/2
        local x,y  = s.targetx, s.targety -- *note: need to instantiate for spammable abils.
        for i = 1,2 do
            local mis    = s:pmissileangle(d, mis_hammerred, self:getfield(W_id, 2, "dmg1"))
            local i      = i
            mis.vel      = 28
            mis.dmgtype  = self:getfield(W_id, 2, "type1")
            mis.x, mis.y = utils.projectxy(mis.x, mis.y, 48.0, mis.angle)
            mis.time     = self:getfield(W_id, 2, "dur1")
            if i == 1 then mis.angle = mis.angle + 6 else mis.angle = mis.angle - 6 end
            -- mis:initpiercing()
            mis:initduration()
            speff_defend:playu(s.caster)
            mis.colfunc = function(mis)
                if utils.isalive(mis.hitu) and not utils.stunned(mis.hitu) then
                    bf_slow:apply(mis.hitu, self:getfield(W_id, 2, "dur2"))
                end
            end
            mis.func = function(mis) if i == 1 then mis.angle = mis.angle - 1.0 else mis.angle = mis.angle + 1.0 end end
        end
    end)
    -- RIFT ROCKET --
    self.spells[W_id][3] = spell:new(casttype_point, p, self:abilid(W_id, 3))
    self.spells[W_id][3].rect = Rect(0,0,0,0)
    self.spells[W_id][3]:uiregcooldown(self:getfield(W_id, 3, "cd"), W_id)
    self.spells[W_id][3]:addaction(function()
        local s    = self.spells[W_id][3]
        local dur  = self:getfield(W_id, 3, "dur1")
        local mis  = s:pmissileangle(self:getrange(W_id, 3, "range1"), speff_gatearcane, 0)
        local mis2 = s:pmissileangle(self:getrange(W_id, 3, "range1"), mis_runic, 0)
        local mis3 = s:pmissileangle(self:getrange(W_id, 3, "range1"), mis_runic, 0)
        local vel  = 12.0
        local dmg1 = self:getfield(W_id, 3, "dmg1")
        local dmgtype1 = self:getfield(W_id, 3, "type1")
        local dmgtype2 = self:getfield(W_id, 3, "type2")
        local dmgtype3 = self:getfield(W_id, 3, "type3")
        speff_explblu:playu(s.caster)
        mis2.collide = false
        mis3.collide = false
        mis.x, mis.y   = utils.projectxy(mis.x, mis.y, 24.0, mis.angle)
        mis2.x, mis2.y = utils.projectxy(mis.x, mis.y, 164.0, mis.angle - 90)
        mis3.x, mis3.y = utils.projectxy(mis.x, mis.y, 164.0, mis.angle + 90)
        mis.dmgtype  = self:getfield(W_id, 3, "type1")
        mis2.vel, mis3.vel, mis.vel = vel, vel, vel
        mis2.height, mis3.height = 145.0, 145.0
        mis.radius   = 328.0
        mis.colfunc  = function(mis)
            utils.debugfunc(function()
                bf_root:apply(mis.hitu, dur)
                speff_lightn:playu(mis.hitu)
                s:tdmg(p, mis.hitu, dmgtype1, dmg1)
                s:tdmg(p, mis.hitu, dmgtype2, dmg1)
                s:tdmg(p, mis.hitu, dmgtype3, dmg1)
            end, "col")
        end
        mis:initpiercing()
    end)
    -----------------------------------E-----------------------------------
    -- MOLE HOLE --
    self.spells[E_id][1] = spell:new(casttype_instant, p, self:abilid(E_id, 1))
    self.spells[E_id][1]:uiregcooldown(self:getfield(E_id, 1, "cd"), E_id)
    self.spells[E_id][1]:addaction(function()
        local s    = self.spells[E_id][1]
        local r    = self:getradius(E_id, 1, "range1")
        local dur  = self:getfield(E_id, 1, "dur1")
        local dmg  = self:getfield(E_id, 1, "dmg1")
        local e    = speff_unitcirc:play(s.casterx, s.castery, dur)
        bf_silence:apply(s.caster, dur)
        utils.setinvul(s.caster, true)
        utils.vertexhide(s.caster, true)
        speff_dustcloud:playu(s.caster)
        speff_nature:playu(s.caster)
        utils.timedrepeat(0.03, dur*33, function()
            if e then
                utils.seteffectxy(e, utils.unitx(s.caster), utils.unity(s.caster))
            else
                ReleaseTimer()
            end
        end)
        utils.timed(dur, function()
            s:gdmgxy(p, self:getfield(W_id, 1, "type1"), dmg, utils.unitx(s.caster), utils.unity(s.caster), r)
            utils.vertexhide(s.caster, false)
            speff_dustcloud:playu(s.caster)
            speff_quake:playu(s.caster)
            if not map.manager.objiscomplete or scoreboard_is_active then
                utils.setinvul(s.caster, false)
            end
        end)
        buffy:add_indicator(p, "Mole Hole", "ReplaceableTextures\\CommandButtons\\BTNCryptFiendBurrow.blp", dur,
            "Untouchable while underground")
    end)
    -- KOBOLT AUTO-MINER --
    self.spells[E_id][2] = spell:new(casttype_point, p, self:abilid(E_id, 2))
    self.spells[E_id][2].rect = Rect(0,0,0,0)
    self.spells[E_id][2]:uiregcooldown(self:getfield(E_id, 2, "cd"), E_id)
    self.spells[E_id][2]:addaction(function()
        local s    = self.spells[E_id][2]
        local r    = self:getradius(E_id, 2, "radius1")
        local dmg  = self:getfield(E_id, 2, "dmg1")/3
        local bdmg = dmg*(self:getfield(E_id, 2, "perc1")/100)*3
        local a    = s:angletotarget()
        local vel  = 8.0
        local c    = math.floor(self:getrange(E_id, 2, "range1")/vel)
        local unit = utils.unitatxy(p, s.casterx, s.castery, 'h009', a)
        local i    = 0
        local x,y  = s.casterx, s.castery
        SetUnitAnimation(unit, "attack")
        utils.timedrepeat(0.03, nil, function()
            utils.debugfunc(function()
                i = i + 1
                if utils.isalive(unit) and i < c then
                    x,y = utils.projectxy(x, y, vel, a)
                    utils.setxy(unit, x, y)
                    if math.fmod(i, 10) == 0 then
                        s:gdmgxy(p, self:getfield(E_id, 2, "type1"), dmg, x, y, r, function(u) bf_slow:apply(u, self:getfield(E_id, 2, "dur1")) end)
                        QueueUnitAnimation(unit, "attack")
                        speff_dustcloud:playu(unit)
                        speff_quake:playu(unit)
                        utils.setrectradius(s.rect, x, y, r)
                        utils.dmgdestinrect(s.rect, bdmg)
                    end
                else
                    ReleaseTimer()
                    RemoveUnit(unit)
                end
            end, "tmr")
        end)
    end)
    -- KOBOLT AUTO TURRET --
    self.spells[E_id][3] = spell:new(casttype_point, p, self:abilid(E_id, 3))
    self.spells[E_id][3]:uiregcooldown(self:getfield(E_id, 3, "cd"), E_id)
    self.spells[E_id][3]:addaction(function()
        local s    = self.spells[E_id][3]
        local r    = self:getradius(E_id, 3, "radius1")
        local d    = self:getrange(E_id, 3, "range1")
        local dmg1 = kobold.player[p]:calcminiondmg(self:getfield(E_id, 3, "dmg1"))
        local dur  = self:getfield(E_id, 3, "dur1")
        local unit = utils.unitatxy(p, s.targetx, s.targety, 'h00A', s:angletotarget())
        speff_feral:play(s.targetx, s.targety)
        utils.timedrepeat(0.5, nil, function()
            if unit then
                local x,y = utils.unitxy(unit)
                local grp = g:newbyxy(p, g_type_dmg, x, y , r)
                if grp:getsize() > 0 then
                    local rgrp = g:newbyrandom(1, grp)
                    rgrp:action(function()
                        local angle = utils.anglexy(x, y, utils.unitxy(rgrp.unit))
                        local r     = math.random(2,4)
                        local mis   = s:pmissile_custom_unitxy(unit, d, utils.unitx(rgrp.unit), utils.unity(rgrp.unit), mis_ele_stack[r], dmg1)
                        mis.dmgtype = dmg.type.stack[r]
                        mis.vel     = 38
                        mis:initpiercing()
                        utils.face(unit, angle)
                        SetUnitAnimation(unit, 'attack')
                        QueueUnitAnimation(unit, 'stand')
                    end)
                    rgrp:destroy()
                end
                grp:destroy()
            else
                ReleaseTimer()
            end
        end)
        utils.timed(dur, function()
            KillUnit(unit)
            unit = nil
        end)
        buffy:add_indicator(p, "'Kobolt' Turret", "ReplaceableTextures\\CommandButtons\\BTNHumanMissileUpTwo.blp", dur,
            "Accompanied by a turret which shoots targets")
    end)
    -----------------------------------R-----------------------------------
    -- WRECKING BALL --
    self.spells[R_id][1] = spell:new(casttype_instant, p, self:abilid(R_id, 1))
    self.spells[R_id][1].rect = Rect(0,0,0,0)
    self.spells[R_id][1]:uiregcooldown(self:getfield(R_id, 1, "cd"), R_id)
    self.spells[R_id][1]:addaction(function()
        local s    = self.spells[R_id][1]
        local r    = self:getradius(R_id, 1, "range1")
        local dur  = self:getfield(R_id, 1, "dur1")
        local dmg  = self:getfield(R_id, 1, "dmg1")/3
        local e    = mis_rock:create(s.casterx, s.castery, 3.33)
        local c, i, x, y = dur*33, 0, s.casterx, s.castery
        speff_quake:playu(s.caster)
        utils.vertexhide(s.caster, true)
        bf_silence:apply(s.caster, dur)
        bf_ms:apply(s.caster, dur)
        spell:enhanceresistpure(75.0, dur, p, false)
        utils.timedrepeat(0.03, nil, function()
            utils.debugfunc(function()
                i   = i + 1
                x,y = utils.unitx(s.caster), utils.unity(s.caster)
                if not kobold.player[s.p].downed and i < c then
                    utils.seteffectxy(e, x, y, utils.getcliffz(x, y, 75.0))
                    BlzSetSpecialEffectYaw(e, utils.getface(s.caster)*bj_DEGTORAD)
                    if math.fmod(i, 10) == 0 then
                        s:gdmgxy(p, self:getfield(R_id, 1, "type1"), dmg, x, y, r)
                        speff_quake:playu(s.caster)
                        kb:new_pgroup(p, x, y, r, dist, 1.0)
                        utils.setrectradius(s.rect, x, y, r)
                        utils.dmgdestinrect(s.rect, math.floor(dmg*(self:getfield(R_id, 1, "perc1")/100)))
                    end
                else
                    s.active = false
                    DestroyEffect(e)
                    utils.vertexhide(s.caster, false)
                    ReleaseTimer()
                end
            end, "wrecking")
        end)
        buffy:add_indicator(p, "Wrecking Ball", "ReplaceableTextures\\CommandButtons\\BTNGolemStormBolt.blp", dur,
            "Knocks back and damages nearby targets")
    end)
    -- THE BIG ONE --
    self.spells[R_id][2] = spell:new(casttype_point, p, self:abilid(R_id, 2))
    self.spells[R_id][2].rect = Rect(0,0,0,0)
    self.spells[R_id][2]:uiregcooldown(self:getfield(R_id, 2, "cd"), R_id)
    self.spells[R_id][2]:addaction(function()
        local s    = self.spells[R_id][2]
        local r    = self:getradius(R_id, 2, "radius1")
        local r2   = r*0.33
        local dur  = self:getfield(R_id, 2, "dur1")
        local dmg  = self:getfield(R_id, 2, "dmg1")
        local sc   = 0.5
        local e    = speff_mine:create(s.targetx, s.targety, sc)
        local i,c  = 0, dur*33
        local x,y  = s.targetx, s.targety
        speff_dustcloud:play(s.targetx, s.targety)
        speff_feral:play(s.targetx, s.targety)
        utils.timedrepeat(0.03, nil, function()
            i = i + 1
            if i < c then
                sc = sc + 0.015
                BlzSetSpecialEffectScale(e, sc)
            else
                s:gdmgxy(p, self:getfield(R_id, 2, "type1"), dmg, x, y, r)
                utils.setrectradius(s.rect, x, y, r)
                utils.dmgdestinrect(s.rect, dmg*(self:getfield(R_id, 2, "perc1")/100))
                speff_explode:playradius(r2, 4, x, y)
                utils.timed(0.12, function()
                    speff_explode2:playradius(r2+r2, 6, x, y)
                    utils.timed(0.12, function()
                        speff_explode2:playradius(r2+r2+r2, 8, x, y)
                        utils.timed(0.12, function()
                            speff_dirtexpl:playradius(r2+r2+r2+r2, 10, x, y)
                        end)
                    end)
                end)
                DestroyEffect(e)
                ReleaseTimer()
            end
        end)
    end)
    -- TRIUMVIRATE --
    self.spells[R_id][3] = spell:new(casttype_instant, p, self:abilid(R_id, 3))
    self.spells[R_id][3]:uiregcooldown(self:getfield(R_id, 3, "cd"), R_id)
    self.spells[R_id][3]:addaction(function()
        local x,y,eff,a,inc,t,rand = {},{},{},{},0,0,0
        local s    = self.spells[R_id][3]
        local d    = self:getrange(R_id, 3, "range1")
        local dur  = self:getfield(R_id, 3, "dur1")
        local dmg1 = self:getfield(R_id, 3, "dmg1")
        local c    = dur*25
        for i = 1,3 do
            a[i]        = utils.getface(s.caster) + inc
            x[i], y[i]  = utils.projectxy(s.casterx, s.castery, 100.0, a[i])
            eff[i]      = speff_orbfire:create(x[i],y[i])
            speff_exploj:play(x[i],y[i])
            inc = inc + 120.0
        end
        local cx, cy = s.casterx, s.castery
        utils.timedrepeat(0.04, nil, function()
            t    = t + 1
            if t < c and utils.isalive(s.caster) then
                cx,cy = utils.unitxy(s.caster)
                for i = 1,3 do
                    a[i] = a[i] + 4
                    x[i], y[i] = utils.projectxy(cx, cy, 100.0, a[i])
                    utils.seteffectxy(eff[i], x[i], y[i])
                    if math.fmod(t,4) == 0 then
                        rand = math.random(2,4)
                        local mis    = s:pmissileangle(d, mis_ele_stack2[rand], dmg1, a[i])
                        mis.x, mis.y = x[i], y[i]
                        mis.dmgtype  = dmg.type.stack[rand]
                        mis.vel      = 32
                        mis:initpiercing()
                    end
                end
            else
                for i = 1,3 do DestroyEffect(eff[i]) end
                x = nil y = nil eff = nil a = nil
                ReleaseTimer()
            end
        end)
        buffy:add_indicator(p, "Triumvirate", "ReplaceableTextures\\CommandButtons\\BTNStormEarth&Fire.blp", dur,
            "Launching elemental missiles in a radius")
    end)
end


function ability.template:loadgeomancer(p)
    local Q_id,W_id,E_id,R_id,p = 1,2,3,4,p
    -- helpers:
    self.aihelper = function(self, x, y, _unit)
        if self.spells[E_id][2].ai then
            self.spells[E_id][2].ai:engage(x, y, _unit or nil)
        end
    end
    -----------------------------------Q-----------------------------------
    -- GEO-BOLT --
    self.spells[Q_id][1] = spell:new(casttype_point, p, self:abilid(Q_id, 1))
    self.spells[Q_id][1]:addaction(function()
        local s     = self.spells[Q_id][1]
        local dur   = self:getfield(Q_id, 1, "dur1")
        local r     = self:getradius(Q_id, 1, "radius1")
        local mis   = s:pmissiletargetxy(self:getrange(Q_id, 1, "range1"), mis_boltoj, self:getfield(Q_id, 1, "dmg1"))
        mis.dmgtype = self:getfield(Q_id, 1, "type1")
        mis.vel     = 20
        mis.expl    = true
        mis.explfunc = function()
            local grp = g:newbyxy(p, g_type_dmg, mis.x, mis.y, r)
            spell:gbuff(grp, bf_slow, dur, true)
            speff_exploj:play(mis.x, mis.y, nil, 0.75)
            grp:destroy()
            self:aihelper(mis.x, mis.y)
        end
    end)
    -- SHROOM BOLT --
    self.spells[Q_id][2] = spell:new(casttype_point, p, self:abilid(Q_id, 2))
    self.spells[Q_id][2]:addaction(function()
        local s     = self.spells[Q_id][2]
        local dur   = self:getfield(Q_id, 2, "dur1")
        local heal1 = self:getfield(Q_id, 2, "heal1")
        local dmg1  = self:getfield(Q_id, 2, "dmg1")
        local r     = self:getradius(Q_id, 2, "radius1")
        local mis   = s:pmissiletargetxy(self:getrange(Q_id, 2, "range1"), mis_boltgreen, self:getfield(Q_id, 2, "dmg1"))
        local dmgtype = self:getfield(Q_id, 2, "type1")
        mis.dmgtype = dmgtype
        mis.vel     = 20
        mis.expl    = true
        mis.explfunc = function()
            local x,y = mis.x, mis.y
            speff_shroom:play(x, y, dur, 0.3)
            speff_explgrn:play(x, y, nil, 0.75)
            utils.timedrepeat(1.0, dur, function()
                s:ghealxy(p, heal1, x, y, r)
                s:gdmgxy(p, dmgtype, dmg1, x, y, r)
            end, function()
                dmgtype = nil
            end)
            self:aihelper(x, y)
        end
    end)
    -- ARCANE BOLT --
    self.spells[Q_id][3] = spell:new(casttype_point, p, self:abilid(Q_id, 3))
    self.spells[Q_id][3]:addaction(function()
        local s     = self.spells[Q_id][3]
        local mis   = s:pmissiletargetxy(self:getrange(Q_id, 3, "range1"), mis_boltblue, self:getfield(Q_id, 3, "dmg1"))
        mis.radius  = self:getradius(Q_id, 3, "radius1")
        mis.dmgtype = self:getfield(Q_id, 3, "type1")
        mis.vel     = 20
        mis:initpiercing()
        mis.colfunc = function()
            mis.dmg = mis.dmg*1.03
            BlzSetSpecialEffectScale(mis.effect, BlzGetSpecialEffectScale(mis.effect) + 0.04 )
            self:aihelper(mis.x, mis.y)
        end
    end)
    -----------------------------------W-----------------------------------
    -- TREMOR --
    self.spells[W_id][1] = spell:new(casttype_point, p, self:abilid(W_id, 1))
    self.spells[W_id][1]:uiregcooldown(self:getfield(W_id, 1, "cd"), W_id)
    self.spells[W_id][1]:addaction(function()
        local x,y,a = {},{},{}
        local s     = self.spells[W_id][1]
        local r     = self:getradius(W_id, 1, "radius1")
        local d     = self:getrange(W_id, 1, "range1")
        local dmg1  = self:getfield(W_id, 1, "dmg1")
        local vel   = 75.0
        a[1] = s:angletotarget()
        a[2] = a[1] - 35
        a[3] = a[1] + 35
        for i = 1,3 do
            x[i], y[i] = s.casterx, s.castery
        end
        utils.timedrepeat(0.15, math.floor(d/vel), function()
            utils.debugfunc(function()
                for i = 1,3 do
                    local grp = g:newbyxy(p, g_type_dmg, x[i], y[i], r)
                    s:gbuff(grp, bf_slow, self:getfield(W_id, 1, "dur1"), true)
                    s:gdmg(p, grp, self:getfield(W_id, 1, "type1"), dmg1)
                    a[i] = a[i] + math.random(1,30)
                    a[i] = a[i] - math.random(1,30)
                    x[i], y[i] = utils.projectxy(x[i], y[i], vel, a[i])
                    speff_cataexpl:play(x[i], y[i], nil, 0.35)
                    grp:destroy()
                end
            end, "tmr")
        end, function()
            a = nil x = nil y = nil
        end)
    end)
    -- FUNGAL INFUSION --
    self.spells[W_id][2] = spell:new(casttype_instant, p, self:abilid(W_id, 2))
    self.spells[W_id][2]:uiregcooldown(self:getfield(W_id, 2, "cd"), W_id)
    self.spells[W_id][2]:addaction(function()
        local s     = self.spells[W_id][2]
        local caster= s.caster
        speff_radgreen:attachu(s.caster, self:getfield(W_id, 2, "dur2"), 'chest')
        local tmr = utils.timedrepeat(1.0, self:getfield(W_id, 2, "dur2"), function()
            if not kobold.player[p].downed then
                utils.addlifep(caster, self:getfield(W_id, 2, "perc1")/3, true, caster)
            else
                ReleaseTimer(tmr)
            end
        end)
        dmg.absorb:new(caster, self:getfield(W_id, 2, "dur1"), { all = self:getfield(W_id, 2, "dmg1"), }, speff_ubergrn)
        buffy:new_absorb_indicator(p, "Fungal", "ReplaceableTextures\\CommandButtons\\BTNOrbOfVenom.blp", self:getfield(W_id, 2, "dmg1"), self:getfield(W_id, 2, "dur1"))
    end)
    -- ARCANE GOLEM --
    self.spells[W_id][3] = spell:new(casttype_instant, p, self:abilid(W_id, 3))
    self.spells[W_id][3]:uiregcooldown(self:getfield(W_id, 3, "cd"), W_id)
    self.spells[W_id][3]:addaction(function()
    end)
    self.spells[W_id][3].ai = nil -- unit ai container
    self.spells[W_id][3].pauseclone = false
    self.spells[W_id][3].func = function() -- bolt listener
        if self.spells[W_id][3].ai and self.spells[W_id][3].ai.unit and not self.spells[W_id][3].pauseclone then
            local abilid = GetSpellAbilityId()
            if abilid == FourCC('A00O') or abilid == FourCC('A00P') or abilid == FourCC('A00Q') --[[or abilid == FourCC('A02J')--]] then
                self.spells[W_id][3].pauseclone = true
                if abilid == FourCC('A00O') then
                    buffy:gen_cast_point(self.spells[W_id][3].ai.unit, self:abilid(Q_id, 1), 'shockwave', GetSpellTargetX(), GetSpellTargetY())
                elseif abilid == FourCC('A00P') then
                    buffy:gen_cast_point(self.spells[W_id][3].ai.unit, self:abilid(Q_id, 2), 'shockwave', GetSpellTargetX(), GetSpellTargetY())
                elseif abilid == FourCC('A00Q') then
                    buffy:gen_cast_point(self.spells[W_id][3].ai.unit, self:abilid(Q_id, 3), 'shockwave', GetSpellTargetX(), GetSpellTargetY())
                -- elseif abilid == FourCC('A02J') then -- NOTE: bugged 
                --     buffy:gen_cast_point(self.spells[W_id][3].ai.unit, self.mastery:mastabilid(11), 'blizzard', GetSpellTargetX(), GetSpellTargetY())
                end
                PauseUnit(self.spells[W_id][3].ai.unit, true)
                SetUnitAnimation(self.spells[W_id][3].ai.unit,'attack')
                utils.timed(1.0, function()
                    if self.spells[W_id][3].ai.unit then PauseUnit(self.spells[W_id][3].ai.unit, false) ResetUnitAnimation(self.spells[W_id][3].ai.unit) end
                end)
                utils.timed(self:getfield(W_id, 3, "dur1"), function() self.spells[W_id][3].pauseclone = false end)
            end
        end
    end
    self.spells[W_id][3].trig = trg:newspelltrig(kobold.player[p].unit, self.spells[W_id][3].func)
    self.spells[W_id][3]:uiregcooldown(self:getfield(W_id, 2, "cd"), W_id)
    self.spells[W_id][3]:addaction(function()
        local s     = self.spells[W_id][3]
        local dmg1  = self:getfield(W_id, 3, "dmg1")
        local unit  = utils.unitatxy(p, s.casterx, s.castery, 'h00C', math.random(0,360))
        if self.spells[W_id][3].ai then self.spells[W_id][3].ai:releasecompanion() end
        self.spells[W_id][3].ai = ai:new(unit)
        self.spells[W_id][3].ai:initcompanion(1000.0, dmg1, p_stat_nature, self:abilid(W_id, 3))
        BlzSetUnitBaseDamage(unit, dmg1, 0)
        utils.smartmove(unit, s.caster)
        speff_explgrn:play(utils.unitxy(unit))
    end)
    -- ARCANE INFUSION (old) --
    -- self.spells[W_id][3] = spell:new(casttype_instant, p, self:abilid(W_id, 3))
    -- self.spells[W_id][3]:uiregcooldown(self:getfield(W_id, 3, "cd"), W_id)
    -- self.spells[W_id][3]:addaction(function()
    --     local s     = self.spells[W_id][3]
    --     local dmg1  = self:getfield(W_id, 3, "dmg1")
    --     local dur1  = self:getfield(W_id, 3, "dur1")
    --     local perc  = self:getfield(W_id, 3, "perc1")
    --     local grp = g:newbyxy(p, g_type_ally, s.casterx, s.castery , self:getradius(W_id, 3, "radius1"))
    --     grp:action(function()
    --         if utils.ishero(grp.unit) and kobold.player[utils.powner(grp.unit)] then
    --             local grpunit = grp.unit
    --             kobold.player[utils.powner(grpunit)][p_stat_elels] = kobold.player[utils.powner(grpunit)][p_stat_elels] + perc
    --             kobold.player[utils.powner(grpunit)][p_stat_physls] = kobold.player[utils.powner(grpunit)][p_stat_physls] + perc
    --             dmg.absorb:new(grpunit, self:getfield(W_id, 3, "dur1"), { arcane = dmg1 }, speff_radblue, function()
    --                 kobold.player[utils.powner(grpunit)][p_stat_elels] = kobold.player[utils.powner(grpunit)][p_stat_elels] - perc
    --                 kobold.player[utils.powner(grpunit)][p_stat_physls] = kobold.player[utils.powner(grpunit)][p_stat_physls] - perc
    --             end)
    --         end
    --     end)
    --     grp:destroy()
    -- end)
    -----------------------------------E-----------------------------------
    -- GEO-PORTAL --
    self.spells[E_id][1] = spell:new(casttype_point, p, self:abilid(E_id, 1))
    self.spells[E_id][1]:uiregcooldown(self:getfield(E_id, 1, "cd"), E_id)
    self.spells[E_id][1]:addaction(function()
        local x,y,eff,trig,dum,tpt = {},{},{},{},{},{}
        local s     = self.spells[E_id][1]
        local r     = self:getfield(E_id, 1, "radius1")*100 -- fixed value, no stat bonus
        local d     = self:getrange(E_id, 1, "range1")
        local dur   = self:getfield(E_id, 1, "dur1")
        -- starting portal:
        x[1], y[1]  = utils.projectxy(s.casterx, s.castery, 160.0, s:angletotarget())
        -- arrival portal:
        x[2], y[2]  = s.targetx, s.targety
        -- generate triggers:
        local enterfunc = function(unit, dumunit)
            utils.debugfunc(function()
                if utils.pnum(utils.powner(unit)) <= kk.maxplayers and IsUnitType(unit, UNIT_TYPE_HERO) and not tpt[utils.data(unit)] then
                    local dat = utils.data(unit)
                    utils.setxy(unit, utils.unitxy(dumunit))
                    port_yellowtp:playu(unit)
                    tpt[dat] = true
                    utils.stop(unit)
                    utils.timed(1.0, function() if tpt then tpt[dat] = false end end)
                end
            end, "trig")
        end
        for i = 1,2 do
            speff_exploj:play(x[i], y[i])
            dum[i]  = utils.unitatxy(p, x[i], y[i], 'h008', 270.0)
            trig[i] = CreateTrigger()
            eff[i]  = port_yellow:create(x[i], y[i])
        end
        TriggerRegisterUnitInRange(trig[1], dum[1], r, Condition(function() enterfunc(utils.trigu(), dum[2]) return false end))
        TriggerRegisterUnitInRange(trig[2], dum[2], r, Condition(function() enterfunc(utils.trigu(), dum[1]) return false end))
        utils.timed(dur, function()
            for i = 1,2 do
                DestroyEffect(eff[i])
                TriggerClearConditions(trig[i])
                DestroyTrigger(trig[i])
                RemoveUnit(dum[i])
            end
            x = nil y = nil eff = nil trig = nil dum = nil tpt = nil enterfunc = nil
        end)
    end)
    -- BOG GOLEM --
    self.spells[E_id][2] = spell:new(casttype_instant, p, self:abilid(E_id, 2))
    self.spells[E_id][2].ai = nil -- unit ai container
    self.spells[E_id][2].pauseleap = false
    self.spells[E_id][2].func = function() -- bolt listener
        if self.spells[E_id][2].ai and self.spells[E_id][2].ai.unit and not self.spells[E_id][2].pauseleap then
            local abilid = GetSpellAbilityId()
            if abilid == FourCC('A00O') or abilid == FourCC('A00P') or abilid == FourCC('A00Q') or abilid == FourCC('A02J') then
                self.spells[E_id][2].pauseleap = true
                local x,y = utils.unitxy(self.spells[E_id][2].ai.unit)
                local d,a = utils.distanglexy(x,y,GetSpellTargetX(), GetSpellTargetY())
                utils.face(self.spells[E_id][2].ai.unit,a)
                kbeff               = kb:new(self.spells[E_id][2].ai.unit, a, d, 0.72) -- use getradius for throw dist.
                kbeff.effect        = nil
                kbeff.arc           = true
                kbeff.destroydest   = false
                kbeff.terraincol    = false
                kbeff.endfunc       = function()
                    speff_explgrn:playu(self.spells[E_id][2].ai.unit)
                    self.spells[E_id][2]:gdmgxy(p, self:getfield(E_id, 2, "type1"), self:getfield(E_id, 2, "dmg2"),
                        utils.unitx(self.spells[E_id][2].ai.unit), utils.unity(self.spells[E_id][2].ai.unit), 300.0)
                end
                utils.timed(self:getfield(E_id, 2, "dur1"), function() self.spells[E_id][2].pauseleap = false end)
            end
        end
    end
    self.spells[E_id][2].trig = trg:newspelltrig(kobold.player[p].unit, self.spells[E_id][2].func)
    self.spells[E_id][2]:uiregcooldown(self:getfield(E_id, 2, "cd"), E_id)
    self.spells[E_id][2]:addaction(function()
        local s     = self.spells[E_id][2]
        local dmg1  = self:getfield(E_id, 2, "dmg1")
        local unit  = utils.unitatxy(p, s.casterx, s.castery, 'h00B', math.random(0,360))
        if self.spells[E_id][2].ai then self.spells[E_id][2].ai:releasecompanion() end
        self.spells[E_id][2].ai = ai:new(unit)
        self.spells[E_id][2].ai:initcompanion(1000.0, dmg1, p_stat_nature, self:abilid(E_id, 2))
        BlzSetUnitBaseDamage(unit, dmg1, 0)
        utils.smartmove(unit, s.caster)
        speff_explgrn:play(utils.unitxy(unit))
    end)
    -- GRAVITY BURST --
    self.spells[E_id][3] = spell:new(casttype_point, p, self:abilid(E_id, 3))
    self.spells[E_id][3]:uiregcooldown(self:getfield(E_id, 3, "cd"), E_id)
    self.spells[E_id][3]:addaction(function()
        local s     = self.spells[E_id][3]
        local r     = self:getradius(E_id, 3, "radius1")
        local dur1  = self:getfield(E_id, 3, "dur1")
        local dur2  = self:getfield(E_id, 3, "dur2")
        local dmg1  = self:getfield(E_id, 3, "dmg1")
        local x,y   = s.targetx, s.targety
        speff_marker:play(x, y, 1.87)
        utils.timed(dur1, function()
            speff_gravblue:play(x, y)
            speff_explblu:play(x, y)
            s:gdmgxy(p, self:getfield(E_id, 3, "type1"), dmg1, x, y, r, function(unit) bf_slow:apply(unit, dur2) end)
        end)
    end)
    -----------------------------------R-----------------------------------
    -- FULMINATION --
    self.spells[R_id][1] = spell:new(casttype_instant, p, self:abilid(R_id, 1))
    self.spells[R_id][1]:uiregcooldown(self:getfield(R_id, 1, "cd"), R_id)
    self.spells[R_id][1]:addaction(function()
        local s     = self.spells[R_id][1]
        local r     = self:getradius(R_id, 1, "radius1")
        local dur1  = self:getfield(R_id, 1, "dur1")
        local dur2  = self:getfield(R_id, 1, "dur2")
        local dmg1  = self:getfield(R_id, 1, "dmg1")
        local c     = s.caster
        speff_charging:attachu(c, dur1, 'origin', 0.8)
        utils.timed(dur1, function()
            local grp = g:newbyxy(p, g_type_dmg, utils.unitx(c), utils.unity(c), r)
            s:gbuff(grp, bf_stun, 0.75)
            s:gdmg(p, grp, self:getfield(R_id, 1, "type1"), dmg1, function(unit) speff_ltstrike:playu(unit) end)
            grp:destroy()
        end)
    end)
    -- SHROOMPOCALYPSE --
    self.spells[R_id][2] = spell:new(casttype_instant, p, self:abilid(R_id, 2))
    self.spells[R_id][2]:uiregcooldown(self:getfield(R_id, 2, "cd"), R_id)
    self.spells[R_id][2]:addaction(function()
        local s     = self.spells[R_id][2]
        local r     = self:getradius(R_id, 2, "radius1")
        local dur1  = self:getfield(R_id, 2, "dur1")
        local dur2  = self:getfield(R_id, 2, "dur2")
        local heal1 = self:getfield(R_id, 2, "heal1")
        local dmg1  = self:getfield(R_id, 2, "dmg1")
        local trig  = trg:new("spell", p)
        speff_explgrn:play(s.casterx, s.castery)
        speff_shroom:attachu(s.caster, dur1, 'chest', 0.23)
        speff_shroom:attachu(s.caster, dur1, 'hand,left', 0.23)
        speff_shroom:attachu(s.caster, dur1, 'hand,right', 0.23)
        trig:regaction(function()
            local x,y = utils.unitxy(s.caster)
            x,y = utils.projectxy(x, y, math.random(50,200), math.random(0,360))
            if utils.trigu() == s.caster then
                local dmgtype = self:getfield(R_id, 2, "type1")
                speff_shroom:play(x, y, dur2, 0.3)
                speff_explgrn:play(x, y, nil, 0.75)
                utils.timedrepeat(1.0, dur2, function()
                    s:ghealxy(p, heal1, x, y, r)
                    s:gdmgxy(p, dmgtype, dmg1, x, y, r)
                end, function() dmgtype = nil end)
            end
        end)
        utils.timedrepeat(0.25, dur1*4, function()
            utils.addmanap(s.caster, 2.08, true)
            utils.addlifep(s.caster, 2.08, true)
        end, function()
            trig:destroy()
        end)
        buffy:add_indicator(p, "Shroompocalypse", "ReplaceableTextures\\CommandButtons\\BTNHealingSpray.blp", dur1,
            "Recovering mana, abilities spawn Shrooms")
    end)
    -- CURSE OF DOOM --
    self.spells[R_id][3] = spell:new(casttype_point, p, self:abilid(R_id, 3))
    self.spells[R_id][3]:uiregcooldown(self:getfield(R_id, 3, "cd"), R_id)
    self.spells[R_id][3]:addaction(function()
        local s     = self.spells[R_id][3]
        local r     = self:getradius(R_id, 3, "radius1")
        local dur1  = self:getfield(R_id, 3, "dur1")
        local dmg1  = self:getfield(R_id, 3, "dmg1")/3
        local perc1 = self:getfield(R_id, 3, "perc1")
        local grp   = g:newbyxy(p, g_type_dmg, s.targetx, s.targety, r)
        local efft  = {} -- store effects to remove if unit died.
        local dmgtype = self:getfield(R_id, 3, "type1")
        speff_eldritch:play(s.targetx, s.targety, 1.33, nil, 1.1)
        speff_voidaura:playradius(550, 6, s.targetx, s.targety, 0.51)
        grp:action(function()
            spell:armorpenalty(grp.unit, perc1, dur1)
            efft[utils.data(grp.unit)] = speff_weakened:attachu(grp.unit, dur1, 'overhead')
        end)
        s:gbuff(grp, bf_slow, dur1)
        utils.timedrepeat(0.33, dur1*3, function()
            grp:action(function()
                if utils.isalive(grp.unit) then
                    s:tdmg(p, grp.unit, dmgtype, dmg1)
                else
                    DestroyEffect(efft[utils.data(grp.unit)])
                    grp:remove(grp.unit)
                end
            end)
        end, function()
            grp:destroy() efft = nil dmgtype = nil
        end)
    end)
end


function ability.template:loadrascal(p)
    local Q_id,W_id,E_id,R_id,p = 1,2,3,4,p
    -----------------------------------Q-----------------------------------
    -- GAMBIT --
    self.spells[Q_id][1] = spell:new(casttype_instant, p, self:abilid(Q_id, 1))
    self.spells[Q_id][1].stackbonus = 0
    self.spells[Q_id][1]:addaction(function()
        local s     = self.spells[Q_id][1]
        local dmg   = self:getfield(Q_id, 1, "dmg1")
        local grp   = g:newbyunitloc(p, g_type_dmg, s.caster, self:getradius(Q_id, 1, "range1"))
        spell:gdmg(p, grp, self:getfield(Q_id, 1, "type1"), dmg + s.stackbonus)
        utils.timed(self:getfield(Q_id, 1, "dur1"), function()
            s.stackbonus = s.stackbonus - dmg*0.15
            if s.stackbonus < 0 then s.stackbonus = 0 end
        end)
        grp:playeffect(speff_cleave)
        s.stackbonus = s.stackbonus + dmg*0.15
        grp:destroy()
    end)
    -- BACKSTAB --
    self.spells[Q_id][2] = spell:new(casttype_instant, p, self:abilid(Q_id, 2))
    self.spells[Q_id][2]:addaction(function()
        local s     = self.spells[Q_id][2]
        local x,y   = utils.unitxy(s.caster)
        local grp   = g:newbyxy(p, g_type_dmg, s.casterx, s.castery, self:getradius(Q_id, 2, "radius1"))
        grp:action(function()
            local x2,y2 = utils.unitxy(grp.unit)
            spell:tdmg(p, grp.unit, self:getfield(Q_id, 2, "type1"), self:getfield(Q_id, 2, "dmg1"))
            if CosBJ(utils.anglexy(x2, y2, x, y) - utils.getface(grp.unit)) <= CosBJ(180.0-90.0) then
                spell:tdmg(p, grp.unit, self:getfield(Q_id, 2, "type2"), self:getfield(Q_id, 2, "dmg2"))
                speff_cleave:attachu(grp.unit, 0.0, 'chest', 1.25)
            end
        end)
        grp:destroy()
    end)
    -- FROST STRIKE --
    self.spells[Q_id][3] = spell:new(casttype_instant, p, self:abilid(Q_id, 3))
    self.spells[Q_id][3]:addaction(function()
        local s = self.spells[Q_id][3]
        local grp  = g:newbyxy(p, g_type_dmg, s.casterx, s.castery, self:getradius(R_id, 1, "radius1"))
        grp:action(function()
            spell:tdmg(p, grp.unit, self:getfield(Q_id, 3, "type1"), self:getfield(Q_id, 3, "dmg1"))
            DestroyEffect(mis_iceball:attachu(grp.unit, nil, 'chest', 0.6))
            if UnitHasBuffBJ(grp.unit, FourCC('B001')) then
                speff_frostnova:playu(grp.unit)
                local grp = g:newbyunitloc(p, g_type_dmg, s.caster, self:getradius(Q_id, 3, "range2"))
                spell:gdmg(p, grp, self:getfield(Q_id, 3, "type2"), self:getfield(Q_id, 3, "dmg2"))
                grp:destroy()
            end
        end)
        grp:destroy()
    end)
    -----------------------------------W-----------------------------------
    -- CANDLEBLIGHT --
    self.spells[W_id][1] = spell:new(casttype_instant, p, self:abilid(W_id, 1))
    self.spells[W_id][1]:uiregcooldown(self:getfield(W_id, 1, "cd"), W_id)
    self.spells[W_id][1]:addaction(function()
        local s = self.spells[W_id][1]
        s.caster = kobold.player[p].unit
        local dur1 = self:getfield(W_id, 1, "dur1")
        local grp  = g:newbyxy(p, g_type_dmg, s.casterx, s.castery, self:getradius(W_id, 1, "radius1"))
        speff_fireroar:playu(s.caster)
        grp:action(function()
            local grpunit = grp.unit
            speff_steamtank:playu(grpunit)
            local e = speff_ember:attachu(grp.unit, dur1, 'overhead')
            utils.timed(dur1, function()
                utils.debugfunc(function()
                    s:gdmgxy(p, self:getfield(W_id, 1, "type1"), self:getfield(W_id, 1, "dmg1"), utils.unitx(grpunit), utils.unity(grpunit), self:getradius(W_id, 1, "radius2"))
                    mis_fireballbig:playu(grpunit)
                    DestroyEffect(e)
                end, "candleblight")
            end)
        end)
        grp:destroy()
    end)
    -- GAMBLE --
    self.spells[W_id][2] = spell:new(casttype_point, p, self:abilid(W_id, 2))
    self.spells[W_id][2]:addaction(function()
        local s = self.spells[W_id][2]
        local c = self:getfield(W_id, 2, "count2")
        if math.random(0,100) < 50 then
            c = self:getfield(W_id, 2, "count1")
        end
        utils.timedrepeat(0.21, c, function()
            local r     = math.random(1,6)
            local mis   = s:pmissiletargetxy(self:getrange(W_id, 2, "range1"), mis_ele_stack[r], self:getfield(W_id, 2, "dmg1"))
            mis.dmgtype = dmg.type.stack[r]
            mis.vel     = 32
        end)
    end)
    -- FRIGID DAGGER --
    self.spells[W_id][3] = spell:new(casttype_point, p, self:abilid(W_id, 3))
    self.spells[W_id][3]:uiregcooldown(self:getfield(W_id, 3, "cd"), W_id)
    self.spells[W_id][3]:addaction(function()
        local s     = self.spells[W_id][3]
        local mis   = s:pmissilepierce(self:getrange(W_id, 3, "range1"), mis_icicle, self:getfield(W_id, 3, "dmg1"))
        mis.dmgtype = dmg.type.stack[dmg_frost]
        mis.vel     = 32
        mis.expl    = true
        mis.explr   = self:getradius(W_id, 3, "radius1")
        mis.explfunc= function()
            utils.debugfunc(function()
                speff_frostnova:play(mis.x, mis.y)
                local grp = g:newbyxy(p, g_type_dmg, mis.x, mis.y, self:getradius(W_id, 3, "radius1"))
                spell:gbuff(grp, bf_freeze, self:getfield(W_id, 3, "dur1"))
                grp:destroy()
            end)
        end
    end)
    -----------------------------------E-----------------------------------
    -- ROCKET JUMP --
    self.spells[E_id][1] = spell:new(casttype_point, p, self:abilid(E_id, 1))
    self.spells[E_id][1]:uiregcooldown(self:getfield(E_id, 1, "cd"), E_id)
    self.spells[E_id][1]:addaction(function()
        local s     = self.spells[E_id][1]
        local x,y   = s.targetx, s.targety
        local d     = self:getradius(E_id, 1, "range2")
        local grp   = g:newbyunitloc(p, g_type_dmg, s.caster, d)
        spell:gdmg(p, grp, self:getfield(E_id, 1, "type1"), self:getfield(E_id, 1, "dmg1"))
        speff_fire:playradius(d/2, 10, s.casterx, s.castery)
        speff_fire:playradius(d, 10, s.casterx, s.castery)
        grp:destroy()
        kbeff               = kb:new(s.caster, s:angletotarget(), s:disttotarget(), 0.75) -- use getradius for throw dist.
        kbeff.effect        = mis_mortar_fir.effect
        kbeff.arc           = true
        kbeff.destroydest   = false
        kbeff.terraincol    = false
        speff_chargeoj:attachu(s.caster, 0.75, 'origin')
        kbeff.endfunc       = function() bf_ms:apply(s.caster, 3.0) end
    end)
    -- NETHER BOMB --
    self.spells[E_id][2] = spell:new(casttype_point, p, self:abilid(E_id, 2))
    self.spells[E_id][2]:uiregcooldown(self:getfield(E_id, 2, "cd"), E_id)
    self.spells[E_id][2]:addaction(function()
        local s    = self.spells[E_id][2]
        local r    = self:getradius(E_id, 2, "radius1")
        local dur  = self:getfield(E_id, 2, "dur1")
        local landfunc = function()
            speff_voidpool:play(s.targetx, s.targety, dur - 0.25)
            utils.timedrepeat(0.25, math.floor(dur/0.25), function()
                local grp = g:newbyxy(p, g_type_dmg, s.targetx, s.targety, r)
                kb:new_pullgroup(grp, s.targetx, s.targety, dur)
                spell:gdmg(p, grp, self:getfield(E_id, 2, "type1"), math.floor(self:getfield(E_id, 2, "dmg1")/4))
                grp:destroy()
                dur = dur - 0.25
            end)
        end
        local mis    = s:pmissilearc(mis_voidball, 0)
        mis.explfunc = landfunc
    end)
    -- GLACIAL GRENADE --
    self.spells[E_id][3] = spell:new(casttype_point, p, self:abilid(E_id, 3))
    self.spells[E_id][3]:uiregcooldown(self:getfield(E_id, 3, "cd"), E_id)
    self.spells[E_id][3]:addaction(function()
        local s    = self.spells[E_id][3]
        local r    = self:getfield(E_id, 3, "range1")*100
        local landfunc = function()
            speff_iceburst2:play(s.targetx, s.targety)
            local grp = g:newbyxy(p, g_type_dmg, s.targetx, s.targety, r)
            spell:gdmg(p, grp, self:getfield(E_id, 3, "type1"), math.floor(self:getfield(E_id, 3, "dmg1")))
            spell:gbuff(grp, bf_freeze, self:getfield(E_id, 3, "dur1"))
            grp:destroy()
        end
        local mis    = s:pmissilearc(mis_grenadeblue, 0)
        mis.explfunc = landfunc
    end)
    -----------------------------------R-----------------------------------
    -- DEVITALIZE --
    self.spells[R_id][1] = spell:new(casttype_instant, p, self:abilid(R_id, 1))
    self.spells[R_id][1]:uiregcooldown(self:getfield(R_id, 1, "cd"), R_id)
    self.spells[R_id][1]:addaction(function()
        local s   = self.spells[R_id][1]
        local grp  = g:newbyxy(p, g_type_dmg, s.casterx, s.castery, self:getradius(R_id, 1, "radius1"))
        grp:action(function()
            if utils.isalive(grp.unit) then
                local dmg = (utils.maxlife(grp.unit) - utils.life(grp.unit))*(self:getfield(R_id, 1, "perc1")/100)
                if utils.isancient(grp.unit) then -- is a boss.
                    dmg = math.floor(dmg*0.01)
                end
                spell:tdmg(p, grp.unit, self:getfield(R_id, 1, "type1"), dmg)
                utils.addmanap(s.caster, 20, true)
                if not utils.isalive(grp.unit) then -- separate for visual indicator
                    utils.addmanap(s.caster, 10, true)
                end
                speff_cleave:attachu(grp.unit, 0.0, 'chest', 1.25)
            end
        end)
        grp:destroy()
    end)
    -- DEADLY SHADOWS --
    self.spells[R_id][2] = spell:new(casttype_instant, p, self:abilid(R_id, 2))
    self.spells[R_id][2]:uiregcooldown(self:getfield(R_id, 2, "cd"), R_id)
    self.spells[R_id][2]:addaction(function()
        local s     = self.spells[R_id][2]
        local dur   = self:getfield(R_id, 2, "dur1")
        local bonus = self:getfield(R_id, 2, "perc1")
        utils.setinvul(s.caster, true)
        utils.setinvis(s.caster, true)
        spell:addenchant(s.caster, dmg_shadow, dur)
        speff_embersha:attachu(s.caster, dur, 'chest', 1.15)
        bf_msmax:apply(s.caster, dur)
        SetUnitVertexColor(s.caster, 175, 0, 175, 135)
        kobold.player[s.p][p_stat_dmg_shadow] = kobold.player[s.p][p_stat_dmg_shadow] + bonus
        utils.timed(dur, function()
            kobold.player[s.p][p_stat_dmg_shadow] = kobold.player[s.p][p_stat_dmg_shadow] - bonus
            utils.setinvis(s.caster, false)
            SetUnitVertexColor(s.caster, 255, 255, 255, 255)
            if not map.manager.objiscomplete or scoreboard_is_active then
                utils.setinvul(s.caster, false)
            end
        end)
        buffy:add_indicator(p, "Deadly Shadows", "ReplaceableTextures\\CommandButtons\\BTNDoom.blp", dur,
            "+"..tostring(self:getfield(R_id, 2, "perc1")).."%% Shadow damage")
    end)
    -- ABOMINABLE --
    self.spells[R_id][3] = spell:new(casttype_instant, p, self:abilid(R_id, 3))
    self.spells[R_id][3]:uiregcooldown(self:getfield(R_id, 3, "cd"), R_id)
    self.spells[R_id][3]:addaction(function()
        local s     = self.spells[R_id][3]
        s.caster    = kobold.player[p].unit
        local snowball = function()
            -- hook the cast xy for the temp trigger:
            local a = math.random(0,360)
            local x,y = 0,0
            for i = 1,6 do
                x,y = utils.projectxy(utils.unitx(utils.trigu()), utils.unity(utils.trigu()), 600, a + i*60)
                local mis   = missile:create_piercexy(x, y, utils.trigu(), mis_iceball.effect, self:getfield(R_id, 3, "dmg1"))
                mis.dist    = self:getrange(R_id, 3, "range1")
                mis.dmgtype = dmg.type.stack[dmg_frost]
                mis.vel     = 20
                mis.colfunc = function()
                    bf_freeze:apply(mis.hitu, self:getfield(R_id, 3, "dur2"))
                    mis_iceball:playu(mis.hitu)
                end
            end
            a,x,y = nil,nil,nil
        end
        local trig = trg:newspelltrig(s.caster, snowball)
        speff_sleet:attachu(s.caster, self:getfield(R_id, 3, "dur1"), 'chest', 0.7)
        speff_conflagbl:playu(s.caster)
        SetUnitVertexColor(s.caster, 100, 100, 255, 255)
        utils.timed(self:getfield(R_id, 3, "dur1"), function()
            trig:destroy()
            SetUnitVertexColor(s.caster, 255, 255, 255, 255)
            s = nil
        end)
        buffy:add_indicator(p, "Abominable", "ReplaceableTextures\\CommandButtons\\BTNIceShard.blp", self:getfield(R_id, 3, "dur1"),
            "Using an ability launches snowballs in a radius")
    end)
end


function ability.template:loadwickfighter(p)
    local Q_id,W_id,E_id,R_id,p = 1,2,3,4,p
    -----------------------------------Q-----------------------------------
    -- WICKFIRE --
    self.spells[Q_id][1] = spell:new(casttype_instant, p, self:abilid(Q_id, 1))
    self.spells[Q_id][1].tnt = {} -- track recently issued orders to prevent sticking order spam.
    self.spells[Q_id][1]:addaction(function()
        local s     = self.spells[Q_id][1]
        local perc  = self:getfield(Q_id, 1, "perc1")
        local grp   = g:newbyunitloc(p, g_type_dmg, s.caster, self:getradius(Q_id, 1, "radius1"))
        spell:gdmg(p, grp, self:getfield(Q_id, 1, "type1"), self:getfield(Q_id, 1, "dmg1"))
        grp:action(function()
            utils.addlifep(s.caster, perc, true, s.caster)
            if GetUnitTypeId(grp.unit) ~= kk.ymmudid and not utils.isancient(grp.unit) then
                utils.issatkunit(grp.unit, s.caster) -- run taunt command.
            end
        end)
        utils.timed(4.0, function()
            grp:action(function()
                if not utils.isancient(grp.unit) then
                    if s.tnt[utils.data(grp.unit)] and GetUnitTypeId(grp.unit) ~= kk.ymmudid then
                        utils.issatkxy(grp.unit, utils.projectxy(s.casterx, s.castery, math.random(100,600), math.random(0,360))) -- reset from taunt.
                        s.tnt[utils.data(grp.unit)] = nil
                    end
                end
            end)
            grp:destroy()
        end)
    end)
    -- SLAG SLAM --
    self.spells[Q_id][2] = spell:new(casttype_instant, p, self:abilid(Q_id, 2))
    self.spells[Q_id][2]:addaction(function()
        local s     = self.spells[Q_id][2]
        local dmg1  = self:getfield(Q_id, 2, "dmg1")
        local dmg2  = self:getfield(Q_id, 2, "dmg2")
        local dmg3  = self:getfield(Q_id, 2, "dmg3")
        local r     = self:getradius(Q_id, 2, "radius1")
        local dur1  = self:getfield(Q_id, 2, "dur1")
        local grp   = g:newbyxy(p, g_type_dmg, s.casterx, s.castery, r)
        grp:action(function()
            if utils.isalive(grp.unit) then
                s:tdmg(p, grp.unit, self:getfield(Q_id, 2, "type1"), dmg1)
                s:tdmg(p, grp.unit, self:getfield(Q_id, 2, "type2"), dmg2)
                speff_demoexpl:play(utils.unitxy(grp.unit))
                if not utils.isalive(grp.unit) then
                    s:gdmgxy(p, self:getfield(Q_id, 2, "type2"), dmg3, utils.unitx(grp.unit), utils.unity(grp.unit), r)
                    speff_exploj:play(utils.unitx(grp.unit), utils.unity(grp.unit), nil, 0.5)
                end
            end
        end)
        grp:destroy()
    end)
    -- RALLYING CLOBBER --
    self.spells[Q_id][3] = spell:new(casttype_instant, p, self:abilid(Q_id, 3))
    self.spells[Q_id][3]:addaction(function()
        local s     = self.spells[Q_id][3]
        local dmg1  = self:getfield(Q_id, 3, "dmg1")
        local dur1  = self:getfield(Q_id, 3, "dur1")
        local grp  = g:newbyxy(p, g_type_dmg, s.casterx, s.castery, self:getradius(Q_id, 3, "radius2"))
        grp:action(function()
            s:tdmg(p, grp.unit, self:getfield(Q_id, 3, "type1"), dmg1)
            speff_demoexpl:play(utils.unitxy(grp.unit))
        end)
        grp:destroy()
        local grp2 = g:newbyxy(p, g_type_ally, s.casterx, s.castery, self:getradius(Q_id, 3, "radius1"))
        grp2:action(function()
            if utils.ishero(grp2.unit) then
                bf_ms:apply(grp2.unit, 3.0)
                bf_armor:apply(grp2.unit, 3.0)
                speff_boosted:attachu(grp2.unit, 0.0, 'origin', 0.85)
            end
        end)
        grp2:destroy()
    end)
    -----------------------------------W-----------------------------------
    -- MOLTEN SHIELD --
    self.spells[W_id][1] = spell:new(casttype_instant, p, self:abilid(W_id, 1))
    self.spells[W_id][1]:uiregcooldown(self:getfield(W_id, 1, "cd"), W_id)
    self.spells[W_id][1]:addaction(function()
        local s      = self.spells[W_id][1]
        local dmg1   = self:getfield(W_id, 1, "dmg1")
        local dmg2   = math.floor(self:getfield(W_id, 1, "dmg2")/3)
        local dex = utils.data(s.caster)
        local r   = self:getradius(W_id, 1, "radius1")
        dmg.absorb:new(s.caster, self:getfield(W_id, 1, "dur1"), { all = dmg1 }, speff_uberorj, endfunc)
        utils.timedrepeat(0.33, self:getfield(W_id, 1, "dur1")*3, function()
            if dmg.absorb.stack[dex] then
                local grp = g:newbyunitloc(p, g_type_dmg, s.caster, r)
                spell:gdmg(p, grp, self:getfield(W_id, 1, "type1"), dmg2)
                grp:destroy()
            else
                ReleaseTimer()
            end
        end)
        buffy:new_absorb_indicator(p, "Molten", "ReplaceableTextures\\CommandButtons\\BTNOrbOfFire.blp", dmg1, self:getfield(W_id, 1, "dur1"))
    end)
    -- WAXSHELL --
    self.spells[W_id][2] = spell:new(casttype_instant, p, self:abilid(W_id, 2))
    self.spells[W_id][2]:uiregcooldown(self:getfield(W_id, 2, "cd"), W_id)
    self.spells[W_id][2]:addaction(function()
        local s     = self.spells[W_id][2]
        s:enhanceresistall(self:getfield(W_id, 2, "perc1"), self:getfield(W_id, 2, "dur1"), p, true)
        speff_radglow:attachu(s.caster, self:getfield(W_id, 2, "dur1"), 'chest', 0.8)
        utils.addlifep(s.caster, self:getfield(W_id, 2, "perc2"), true, s.caster)
        buffy:add_indicator(p, "Waxshell", "ReplaceableTextures\\CommandButtons\\BTNInnerFire.blp", self:getfield(W_id, 2, "dur1"),
            "+"..tostring(self:getfield(W_id, 2, "perc1")).."%% Elemental Resistance")
    end)
    -- MOLTEN ROAR --
    self.spells[W_id][3] = spell:new(casttype_instant, p, self:abilid(W_id, 3))
    self.spells[W_id][3]:uiregcooldown(self:getfield(W_id, 3, "cd"), W_id)
    self.spells[W_id][3]:addaction(function()
        local s     = self.spells[W_id][3]
        local dur1  = self:getfield(W_id, 3, "dur1")
        s:gdmgxy(p, self:getfield(W_id, 3, "type1"), self:getfield(W_id, 3, "dmg1"), s.casterx, s.castery, self:getradius(W_id, 3, "radius1"))
        speff_fireroar:play(s.casterx, s.castery, nil, 1.5)
        bf_a_atk:applyaoe(s.caster, 6.0, self:getradius(W_id, 3, "radius1"))
    end)
    -----------------------------------E-----------------------------------
    -- EMBER CHARGE --
    self.spells[E_id][1] = spell:new(casttype_point, p, self:abilid(E_id, 1))
    self.spells[E_id][1]:uiregcooldown(self:getfield(E_id, 1, "cd"), E_id)
    self.spells[E_id][1]:addaction(function()
        local s     = self.spells[E_id][1]
        local x,y   = utils.projectxy(s.targetx, s.targety, 80.0, s:angletotarget() - 180.0)
        local e     = speff_chargeoj:attachu(s.caster, nil, 'origin')
        local land  = function()
            local r   = self:getradius(E_id, 1, "radius1")
            local grp = g:newbyunitloc(p, g_type_dmg, s.caster, r)
            spell:gdmg(p, grp, self:getfield(E_id, 1, "type1"), self:getfield(E_id, 1, "dmg1"))
            speff_explfire:playradius(r/2, 10, x, y)
            speff_explfire:playradius(r, 10, x, y)
            spell:gbuff(grp, bf_slow, self:getfield(E_id, 1, "dur1"))
            grp:destroy()
            DestroyEffect(e)
        end
        if not spell:slide(s.caster, s:disttotarget(), 0.72, x, y, nil, land) then DestroyEffect(e) end
    end)
    -- WICKFIRE LEAP --
    self.spells[E_id][2] = spell:new(casttype_point, p, self:abilid(E_id, 2))
    self.spells[E_id][2]:uiregcooldown(self:getfield(E_id, 2, "cd"), E_id)
    self.spells[E_id][2]:addaction(function()
        local s     = self.spells[E_id][2]
        local r     = self:getradius(E_id, 2, "radius1")
        local d     = self:getradius(E_id, 2, "range1") -- kb distance
        local dur   = self:getfield(E_id, 2, "dur1")
        local vel   = s:disttotarget()/dur/20
        local a     = s:angletotarget()
        local x,y   = s.casterx, s.castery
        utils.temphide(s.caster, true)
        speff_stormfire:play(utils.unitxy(s.caster))
        utils.timedrepeat(0.05, dur*20, function()
            x,y = utils.projectxy(x, y, vel, a)
            utils.setxy(s.caster, x, y)
        end, function()
            speff_stormfire:play(utils.unitxy(s.caster))
            local grp = g:newbyunitloc(p, g_type_dmg, s.caster, r)
            spell:gdmg(p, grp, self:getfield(E_id, 2, "type1"), self:getfield(E_id, 2, "dmg1"))
            kb:new_group(grp, utils.unitx(s.caster), utils.unity(s.caster), d)
            utils.temphide(s.caster, false)
            grp:destroy()
        end)
    end)
    -- SEISMIC TOSS --
    self.spells[E_id][3] = spell:new(casttype_instant, p, self:abilid(E_id, 3))
    self.spells[E_id][3]:uiregcooldown(self:getfield(E_id, 3, "cd"), E_id)
    self.spells[E_id][3]:addaction(function()
        local s     = self.spells[E_id][3]
        local dur1  = self:getfield(E_id, 3, "dur1")
        local kbeff
        local grp  = g:newbyxy(p, g_type_dmg, s.casterx, s.castery, self:getradius(E_id, 3, "radius1"))
        grp:action(function()
            local grpunit = grp.unit
            if utils.isalive(grpunit) then
                if not utils.isancient(grpunit) then
                     -- use getradius for throw dist.
                    kbeff = kb:new(grpunit, utils.anglexy(utils.unitx(s.caster), utils.unity(s.caster), utils.unitxy(grpunit)), self:getradius(E_id, 3, "range1"), 0.66)
                    kbeff.arc = true
                    kbeff.endfunc = function()
                        utils.debugfunc(function()
                            speff_warstomp:playu(grpunit)
                            bf_stun:apply(grpunit, dur1)
                            s:tdmg(p, grpunit, self:getfield(E_id, 3, "type1"), self:getfield(E_id, 3, "dmg1"))
                            utils.timed(dur1 + 0.21, function()
                                if utils.isalive(grpunit) then
                                    utils.issatkxy(grpunit, utils.unitxy(s.caster)) -- prevent stuck elites exploit, etc.
                                end
                            end)
                        end)
                    end
                else -- if stoic target, deal bonus dmg instead.
                    speff_warstomp:playu(grpunit)
                    s:tdmg(p, grp.unit, self:getfield(E_id, 3, "type1"), self:getfield(E_id, 3, "dmg1")*1.5)
                end
            end
        end)
        grp:destroy()
    end)
    -----------------------------------R-----------------------------------
    -- CANDLEPYRE --
    self.spells[R_id][1] = spell:new(casttype_instant, p, self:abilid(R_id, 1))
    self.spells[R_id][1].active = false
    self.spells[R_id][1].trig   = trg:newspelltrig(kobold.player[p].unit, function()
        if self.spells[R_id][1].active then
            local dist = self:getradius(R_id, 1, "radius1")/2
            local px,py = 0,0
            -- lob missiles:
            utils.timedrepeat(0.44, 2, function()
                px,py = utils.unitxy(kobold.player[p].unit)
                missile:create_arc_in_radius(px, py, kobold.player[p].unit, mis_fireball.effect, self:getfield(R_id, 1, "dmg1"), self:getfield(R_id, 1, "type1"),
                    8, dist, 0.66, 148, 100)
                dist = dist + dist
            end)
        end
    end)
    self.spells[R_id][1]:uiregcooldown(self:getfield(R_id, 1, "cd"), R_id)
    self.spells[R_id][1]:addaction(function()
        local s = self.spells[R_id][1]
        local e = speff_radglow:attachu(s.caster, self:getfield(R_id, 1, "dur1"), 'chest')
        self.spells[R_id][1].active = true
        utils.timedrepeat(1.0, self:getfield(R_id, 1, "dur1"), function()
            if not utils.isalive(s.caster) then
                self.spells[R_id][1].active = false
                DestroyEffect(e)
                ReleaseTimer()
            end
        end, function()
            self.spells[R_id][1].active = false
            DestroyEffect(e)
        end)
        buffy:add_indicator(p, "Candlepyre", "ReplaceableTextures\\CommandButtons\\BTNIncinerate.blp", self:getfield(R_id, 1, "dur1"),
            "Using an ability launches fireballs in a radius")
    end)
    -- BASALT MORTAR --
    self.spells[R_id][2] = spell:new(casttype_point, p, self:abilid(R_id, 2))
    self.spells[R_id][2]:uiregcooldown(self:getfield(R_id, 2, "cd"), R_id)
    self.spells[R_id][2]:addaction(function()
        local s    = self.spells[R_id][2]
        local launchfunc = function(x, y)
            local x,y       = x,y
            local mis       = s:pmissilearc(mis_fireballbig, self:getfield(R_id, 2, "dmg1"), x, y)
            mis.explfunc    = function() speff_explode2:play(mis.x, mis.y, nil, 1.2) end
            mis.dmgtype     = self:getfield(R_id, 2, "type1")
            mis.explr       = self:getradius(R_id, 2, "radius1")
        end
        launchfunc(s.targetx, s.targety)
        local x,y
        utils.timedrepeat(0.51, self:getfield(R_id, 2, "count1")-1, function()
            x,y = utils.projectxy(s.targetx, s.targety, math.random(0,150), math.random(0.360))
            launchfunc(x, y)
        end)
    end)
    -- DREADFIRE --
    self.spells[R_id][3] = spell:new(casttype_instant, p, self:abilid(R_id, 3))
    self.spells[R_id][3]:uiregcooldown(self:getfield(R_id, 3, "cd"), R_id)
    self.spells[R_id][3]:addaction(function()
        local s     = self.spells[R_id][3]
        local dur1  = self:getfield(R_id, 3, "dur1")
        local dmg1  = self:getfield(R_id, 3, "dmg1")
        local r     = self:getradius(R_id, 3, "radius1")
        local e     = speff_blazing:attachu(s.caster, dur1)
        speff_fireroar:play(s.casterx, s.castery, nil, 1.25)
        s:enhanceresistpure(self:getfield(R_id, 3, "perc1"), dur1, p, true)
        utils.timedrepeat(0.33, dur1*3, function()
            if not kobold.player[p].downed then
                s:gdmgxy(p, self:getfield(R_id, 3, "type1"), dmg1/3, utils.unitx(s.caster), utils.unity(s.caster), r)
            else
                s = nil
                DestroyEffect(e)
                ReleaseTimer()
            end
        end)
        buffy:add_indicator(p, "Dreadfire", "ReplaceableTextures\\CommandButtons\\BTNImmolationOn.blp", dur1,
            "Reduces damage taken and damages nearby targets")
    end)
end


function ability.template:loaditemspells(p)
    -- HEALING POTION (F) --
    self.spells[9][1] = spell:new(casttype_instant, p, FourCC('A01O'))
    self.spells[9][1]:uiregcooldown(15.0, 9, 63, 75)
    self.spells[9][1]:addaction(function()
        local unit = self.spells[9][1].caster
        local val  = 30.0 + kobold.player[self.p][p_stat_potionpwr]
        SetUnitLifePercentBJ(unit, GetUnitLifePercent(unit) + val)
        ArcingTextTag(color:wrap(color.tooltip.good, "+"..math.floor(val).."%%"), unit, 2.0)
        StopSound(kui.sound.drinkpot, false, false)
        utils.playsound(kui.sound.drinkpot, self.p)
        loot.ancient:raiseevent(ancient_event_potion, kobold.player[p], true)
    end)
    -- MANA POTION (G) --
    self.spells[10][1] = spell:new(casttype_instant, p, FourCC('A01P'))
    self.spells[10][1]:uiregcooldown(15.0, 10, 63, 75)
    self.spells[10][1]:addaction(function()
        local unit = self.spells[10][1].caster
        local val  = 30.0 + kobold.player[self.p][p_stat_artifactpwr]
        SetUnitManaPercentBJ(unit, GetUnitManaPercent(unit) + val)
        ArcingTextTag(color:wrap(color.tooltip.alert, "+"..math.floor(val).."%%"), unit, 2.0)
        StopSound(kui.sound.drinkpot, false, false)
        utils.playsound(kui.sound.drinkpot, self.p)
        loot.ancient:raiseevent(ancient_event_potion, kobold.player[p], false)
    end)
end


function ability.template:load(charid)
    -- replace icons and descriptions in the ability pane.
    utils.debugfunc(function()
        if self.p == utils.localp() then
            for row = 1,3 do
                for col = 1,4 do
                    -- *note: template tables have col/row reversed from kui skill slots:
                    kui.canvas.game.abil.slot[row][col].icon:setbgtex(self[col][row].icon)
                    kui.canvas.game.abil.slot[row][col].descript:settext(self[col][row].descript)
                    kui.canvas.game.abil.slot[row][col].txt:settext(self[col][row].name)
                    if not self[col][row].cost then self[col][row].cost = 0 end
                    if not self[col][row].cd then self[col][row].cd = 0 end
                    kui.canvas.game.abil.slot[row][col].mana.txt:settext(self[col][row].cost)
                    kui.canvas.game.abil.slot[row][col].cd.txt:settext(self[col][row].cd)
                end
            end
        end
        -- load character spells:
        if charid == 4 then
            kobold.player[self.p].ability:loadwickfighter(self.p)
        elseif charid == 3 then
            kobold.player[self.p].ability:loadrascal(self.p)
        elseif charid == 2 then
            kobold.player[self.p].ability:loadgeomancer(self.p)
        elseif charid == 1 then
            kobold.player[self.p].ability:loadtunneler(self.p)
        end
        -- initialize base items:
        self:loaditemspells(self.p)
        -- instantiate mastery spells:
        self:buildmasteryspells(self.p)
    end, "load")
end


-- learn a standard ability.
function ability.template:learn(row, col)
    -- NOTE: this desyncs in multiplayer
    -- loosely translated: row == ability option, col == skill slot id on skill bar (hotkey id).
    for abilid = 1,3 do
        if self.spells[col][abilid].cdactive then
            -- if column is on cooldown, don't allow a switch:
            utils.palert(self.p, "You cannot change an ability while it's on cooldown!")
            return
        end
    end
    if not self.map[row][col] then -- do nothing if already learned.
        kobold.player[self.p]:updatecastspeed()
        for abilrow = 1,3 do
             -- *NOTE: template has col and row reversed.
            UnitRemoveAbility(kobold.player[self.p].unit, self[col][abilrow].code)
            self.map[abilrow][col] = false -- reset abil learned bool.
        end
        UnitAddAbility(kobold.player[self.p].unit, self[col][row].code)
        self:updateabilstats(BlzGetUnitAbility(kobold.player[self.p].unit, self[col][row].code), col, row)
        -- store abil learned for that slot (for other logic):
        self.map[row][col] = true
        -- update ui components:
        if self.p == utils.localp() then
            for abilrow = 1,3 do
                kui.canvas.game.abil.slot[abilrow][col].iconbd:setbgtex(kui.meta.abilpanel[2].tex)
            end
            kui.canvas.game.abil.slot[row][col].iconbd:setbgtex(kui.meta.abilpanel[2].texsel)
            kui.canvas.game.skill.skill[col].fill:setbgtex(self[col][row].icon) -- skill bar icon
            kui.canvas.game.skill.skill[col].cdtxt.advtip[1] = self[col][row].icon
            kui.canvas.game.skill.skill[col].cdtxt.advtip[2] = 
                color:wrap(color.tooltip.alert, self[col][row].name)
                ..color:wrap(color.txt.txtdisable, "|nMana Cost: "..tostring(self[col][row].cost or 0))
                ..color:wrap(color.txt.txtdisable, "|nCooldown: "..tostring(self[col][row].cd or 0).." sec")
            kui.canvas.game.skill.skill[col].cdtxt.advtip[3] = self[col][row].descript
            utils.playsound(kui.sound.selnode, self.p)
        end
    end
end


-- function specific for talent tree abilities (slots 5-8).
function ability.template:learnmastery(abilid)
    -- *NOTE: abilid == the mastery code we created, not actual ability id (e.g. "na1")
    if not self.savedmastery then self.savedmastery = {} end
    -- loosely translated: row == ability option, col == skill slot id on skill bar (hotkey id).
    if map.manager.activemap then
        utils.palert(self.p, "You cannot change masteries during a dig!", 2.0)
        return
    end
    local foundabil = false
    if self.spells[col] and self.spells[col][abilid] and self.spells[col][abilid].cdactive then
        -- if column is on cooldown, don't allow a switch:
        utils.palert(self.p, "You cannot change an ability while it's on cooldown!")
        return
    end
    -- see if ability is learned already:
    for col = 5,8 do
        if self.spells[col] and self.spells[col][abilid] then -- already learned, remove from bar.
            -- check if slot is on cooldown first:
            for casttype,rawcode in pairs(hotkey.map.codet[hotkey.map.intmap[col]]) do
                if BlzGetUnitAbility(kobold.player[self.p].unit, rawcode) and BlzGetUnitAbilityCooldownRemaining(kobold.player[self.p].unit, rawcode) > 0 then
                    utils.palert(self.p, "You cannot remove a mastery ability while it's on cooldown!")
                    return
                end
            end
            -- update key before clearing:
            kobold.player[self.p].keymap:clearkey(hotkey.map.intmap[col], self.spells[col][abilid].casttype)
            self.spells[col][abilid] = nil
            self.spells[col]         = nil
            self[col][1]             = nil
            kui.canvas.game.skill.skill[col].cdtxt.advtip = nil
            if self.p == utils.localp() then
                kui.canvas.game.skill.skill[col].fill:setbgtex(kui.color.black)
                utils.playsound(kui.sound.closebtn, self.p)
            end
            foundabil = true
            -- save data:
            self.savedmastery[col-4] = nil
            break
        end
    end
    if foundabil then
        return
    else
        for col = 5,8 do
            if not self.spells[col] then
                local row, pobj = 1, kobold.player[self.p]
                -- assign empty slot:
                if not self.spells[col] then self.spells[col] = {} end
                self[col][row] = self.mastery[mastery.abillist[abilid].spell.id]
                self.spells[col][abilid] = nil -- destroy previous table pointer.
                self.spells[col][abilid] = self.mastery[mastery.abillist[abilid].spell.id].spell
                local id = self.spells[col][abilid].id
                -- update hotkey map return dummyabil so we can reference it on the player:
                local dummyabil = pobj.keymap:updatekey(hotkey.map.intmap[col], self.spells[col][abilid].code,
                    self.spells[col][abilid].casttype, self.spells[col][abilid].orderstr)
                self.spells[col][abilid]:uiregcooldown(self.mastery:getmastfield(id, "cd"), col, nil, nil, pobj.unit, dummyabil)
                self.spells[col][abilid].dummycode = dummyabil -- for referencing the dummy abil in spell code.
                self:updatemasterystats(BlzGetUnitAbility(pobj.unit, dummyabil), id)
                pobj:updatecastspeed()
                -- update ui components:
                if self.p == utils.localp() then
                    kui.canvas.game.skill.skill[col].fill:setbgtex(self[col][row].icon) -- skill bar icon
                    kui.canvas.game.skill.skill[col].cdtxt.advtip    = nil -- gc original advtip table.
                    kui.canvas.game.skill.skill[col].cdtxt.advtip    = {}
                    kui.canvas.game.skill.skill[col].cdtxt.advtip[1] = self[col][row].icon
                    kui.canvas.game.skill.skill[col].cdtxt.advtip[2] = 
                        color:wrap(color.tooltip.alert, self[col][row].name)
                        ..color:wrap(color.txt.txtdisable, "|nMana Cost: "..tostring(self[col][row].cost or 0))
                        ..color:wrap(color.txt.txtdisable, "|nCooldown: "..tostring(self[col][row].cd or 0).." sec")
                    kui.canvas.game.skill.skill[col].cdtxt.advtip[3] = self[col][row].descript
                    utils.playsound(kui.sound.selnode, self.p)
                end
                -- save data:
                self.savedmastery[col-4] = abilid
                pobj = nil
                break
            end
        end
    end
end


function ability.template:updatemasterystats(abil, id)
    -- match mana cost and cooldown to ability template field:
    if self.mastery:getmastfield(id, "cost") then
        BlzSetAbilityIntegerLevelField(abil, ABILITY_ILF_MANA_COST, 0, math.floor(self.mastery:getmastfield(id, "cost")))
    else -- field is nil, which is also 0.
        BlzSetAbilityIntegerLevelField(abil, ABILITY_ILF_MANA_COST, 0, 0)
    end
    if self.mastery:getmastfield(id, "cd") then
        BlzSetAbilityRealLevelField(abil, ABILITY_RLF_COOLDOWN, 0, self.mastery:getmastfield(id, "cd"))
    else -- field is nil, which is also 0.
        BlzSetAbilityRealLevelField(abil, ABILITY_RLF_COOLDOWN, 0, 0)
    end
    if self.mastery:getmastfield(id, "castrange") then
        BlzSetAbilityRealLevelField(abil, ABILITY_RLF_CAST_RANGE, 0, self.mastery:getmastfield(id, "castrange"))
    else
        BlzSetAbilityRealLevelField(abil, ABILITY_RLF_CAST_RANGE, 0, 800.0)
    end
    if self.mastery:getmastfield(id, "targetimgsize") then
        BlzSetAbilityRealLevelField(abil, ABILITY_RLF_AREA_OF_EFFECT, 0, self.mastery:getmastfield(id, "targetimgsize"))
    else
        BlzSetAbilityRealLevelField(abil, ABILITY_RLF_AREA_OF_EFFECT, 0, 500.0)
    end
end


function ability.template:updateabilstats(abil, col, row)
    -- match mana cost and cooldown to ability template field:
    if self:getfield(col, row, "cost") then
        BlzSetAbilityIntegerLevelField(abil, ABILITY_ILF_MANA_COST, 0, math.floor(self:getfield(col, row, "cost")))
    else -- field is nil, which is also 0.
        BlzSetAbilityIntegerLevelField(abil, ABILITY_ILF_MANA_COST, 0, 0)
    end
    if self:getfield(col, row, "cd") then
        BlzSetAbilityRealLevelField(abil, ABILITY_RLF_COOLDOWN, 0, self:getfield(col, row, "cd"))
    else -- field is nil, which is also 0.
        BlzSetAbilityRealLevelField(abil, ABILITY_RLF_COOLDOWN, 0, 0)
    end
end


function ability.template:new(p, charid)
    local o
    if ability.template[charid] then
        o = utils.deep_copy(ability.template[charid])
        -- .map stores a bool for learned slots for logical use:
        o.map = {}
        o.mastmap = {}
        for row = 1,3 do
            o.map[row] = {}
            for col = 1,4 do
                o.map[row][col]  = false -- QWER
                o.mastmap[col+4] = false -- 1234
            end
        end
        setmetatable(o, self)
        o.p = p
        return o
    end
end


function ability.template:init()
    -- holds ability metadata.
    self.__index = self
end
