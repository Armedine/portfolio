terrain = {}


-- Ldrt Lordaeron Summer Dirt (cliff)
-- Ldro Lordaeron Summer Rough Dirt
-- Ldrg Lordaeron Summer Grassy Dirt
-- Lrok Lordaeron Summer Rock
-- Lgrs Lordaeron Summer Grass (cliff)
-- Lgrd Lordaeron Summer Dark Grass
-- Fdrt Lordaeron Fall Dirt (cliff)
-- Fdro Lordaeron Fall Rough Dirt
-- Fdrg Lordaeron Fall Grassy Dirt
-- Frok Lordaeron Fall Rock
-- Fgrs Lordaeron Fall Grass (cliff)
-- Fgrd Lordaeron Fall Dark Grass
-- Wdrt Lordaeron Winter Dirt
-- Wdro Lordaeron Winter Rough Dirt
-- Wsng Lordaeron Winter Grassy Snow
-- Wrok Lordaeron Winter Rock
-- Wgrs Lordaeron Winter Grass (cliff)
-- Wsnw Lordaeron Winter Snow (cliff)
-- Bdrt Barrens Dirt
-- Bdrh Barrens Rough Dirt
-- Bdrr Barrens Pebbles
-- Bdrg Barrens Grassy Dirt
-- Bdsr Barrens Desert (cliff)
-- Bdsd Barrens Dark Desert
-- Bflr Barrens Rock
-- Bgrr Barrens Grass (cliff)
-- Adrt Ashenvale Dirt (cliff)
-- Adrd Ashenvale Rough Dirt
-- Agrs Ashenvale Grass (cliff)
-- Arck Ashenvale Rock
-- Agrd Ashenvale Lumpy Grass
-- Avin Ashenvale Vines
-- Adrg Ashenvale Grassy Dirt
-- Alvd Ashenvale Leaves
-- Cdrt Felwood Dirt (cliff)
-- Cdrd Felwood Rough Dirt
-- Cpos Felwood Poison
-- Crck Felwood Rock
-- Cvin Felwood Vines
-- Cgrs Felwood Grass (cliff)
-- Clvg Felwood Leaves
-- Ndrt Northrend Dirt (cliff)
-- Ndrd Northrend Dark Dirt
-- Nrck Northrend Rock
-- Ngrs Northrend Grass
-- Nice Northrend Ice
-- Nsnw Northrend Snow (cliff)
-- Nsnr Northrend Rocky Snow
-- Ydrt Cityscape Dirt (cliff)
-- Ydtr Cityscape Rough Dirt
-- Yblm Cityscape Black Marble
-- Ybtl Cityscape Brick
-- Ysqd Cityscape Square Tiles (cliff)
-- Yrtl Cityscape Round Tiles
-- Ygsb Cityscape Grass
-- Yhdg Cityscape Grass Trim
-- Ywmb Cityscape White Marble
-- Vdrt Village Dirt (cliff)
-- Vdrr Village Rough Dirt
-- Vcrp Village Crops
-- Vcbp Village Cobble Path
-- Vstp Village Stone Path
-- Vgrs Village Short Grass
-- Vrck Village Rocks
-- Vgrt Village Thick Grass (cliff)
-- Qdrt Village Fall Dirt (cliff)
-- Qdrr Village Fall Rough Dirt
-- Qcrp Village Fall Crops
-- Qcbp Village Fall Cobble Path
-- Qstp Village Fall Stone Path
-- Qgrs Village Fall Short Grass
-- Qrck Village Fall Rocks
-- Qgrt Village Fall Thick Grass (cliff)
-- Xdrt Dalaran Dirt (cliff)
-- Xdtr Dalaran Rough Dirt
-- Xblm Dalaran Black Marble
-- Xbtl Dalaran Brick
-- Xsqd Dalaran Square Tiles (cliff)
-- Xrtl Dalaran Round Tiles
-- Xgsb Dalaran Grass
-- Xhdg Dalaran Grass Trim
-- Xwmb Dalaran White Marble
-- Ddrt Dungeon Dirt (cliff)
-- Dbrk Dungeon Brick
-- Drds Dungeon Red Stone
-- Dlvc Dungeon Lava Cracks
-- Dlav Dungeon Lava
-- Ddkr Dungeon Dark Rock
-- Dgrs Dungeon Grey Stones
-- Dsqd Dungeon Square Tiles (cliff)
-- Gdrt Underground Dirt (cliff)
-- Gbrk Underground Brick
-- Grds Underground Red Stone
-- Glvc Underground Lava Cracks
-- Glav Underground Lava
-- Gdkr Underground Dark Rock
-- Ggrs Underground Grey Stones
-- Gsqd Underground Square Tiles (cliff)
-- Zdrt Sunken Ruins Dirt (cliff)
-- Zdtr Sunken Ruins Rough Dirt
-- Zdrg Sunken Ruins Grassy Dirt
-- Zbks Sunken Ruins Small Bricks
-- Zsan Sunken Ruins Sand
-- Zbkl Sunken Ruins Large Bricks (cliff)
-- Ztil Sunken Ruins RoundTiles
-- Zgrs Sunken Ruins Grass
-- Zvin Sunken Ruins Dark Grass
-- Idrt Icecrown Dirt
-- Idtr Icecrown Rough Dirt
-- Idki Icecrown Dark Ice
-- Ibkb Icecrown Black Bricks
-- Irbk Icecrown Runed Bricks (cliff)
-- Itbk Icecrown Tiled Bricks
-- Iice Icecrown Ice
-- Ibsq Icecrown Black Squares
-- Isnw Icecrown Snow (cliff)
-- Odrt Outland Dirt
-- Odtr Outland Light Dirt
-- Osmb Outland Rough Dirt (cliff)
-- Ofst Outland Cracked Dirt
-- Olgb Outland Flat Stones
-- Orok Outland Rock
-- Ofsl Outland Light Flat Stone
-- Oaby Outland Abyss (cliff)
-- Kdrt Black Citadel Dirt (cliff)
-- Kfsl Black Citadel Light Dirt
-- Kdtr Black Citadel Rough Dirt
-- Kfst Black Citadel Flat Stones
-- Ksmb Black Citadel Small Bricks
-- Klgb Black Citadel Large Bricks
-- Ksqt Black Citadel Square Tiles
-- Kdkt Black Citadel Dark Tiles (cliff)
-- Jdrt Dalaran Ruins Dirt (cliff)
-- Jdtr Dalaran Ruins Rough Dirt
-- Jblm Dalaran Ruins Black Marble
-- Jbtl Dalaran Ruins Brick
-- Jsqd Dalaran Ruins Square Tiles (cliff)
-- Jrtl Dalaran Ruins Round Tiles
-- Jgsb Dalaran Ruins Grass
-- Jhdg Dalaran Ruins Grass Trim
-- Jwmb Dalaran Ruins White Marble
-- cAc2 Ashenvale Dirt (non-cliff)
-- cAc1 Ashenvale Grass (non-cliff)
-- cBc2 Barrens Desert (non-cliff)
-- cBc1 Barrens Grass (non-cliff)
-- cKc1 Black Citadel Dirt (non-cliff)
-- cKc2 Black Citadel Dark Tiles (non-cliff)
-- cYc2 Cityscape Dirt (non-cliff)
-- cYc1 Cityscape Square Tiles (non-cliff)
-- cXc2 Dalaran Dirt (non-cliff)
-- cXc1 Dalaran Square Tiles (non-cliff)
-- cJc2 Dalaran Ruins Dirt (non-cliff)
-- cJc1 Dalaran Ruins Square Tiles (non-cliff)
-- cDc2 Dungeon Dirt (non-cliff)
-- cDc1 Dungeon Square Tiles (non-cliff)
-- cCc2 Felwood Dirt (non-cliff)
-- cCc1 Felwood Grass (non-cliff)
-- cIc2 Icecrown Runed Bricks (non-cliff)
-- cIc1 Icecrown Snow (non-cliff)
-- cFc2 Lordaeron Fall Dirt (non-cliff)
-- cFc1 Lordaeron Fall Grass (non-cliff)
-- cLc2 Lordaeron Summer Dirt (non-cliff)
-- cLc1 Lordaeron Summer Grass (non-cliff)
-- cWc2 Lordaeron Winter Grass (non-cliff)
-- cWc1 Lordaeron Winter Snow (non-cliff)
-- cNc2 Northrend Dirt (non-cliff)
-- cNc1 Northrend Snow (non-cliff)
-- cOc1 Outland Abyss (non-cliff)
-- cOc2 Outland Rough Dirt (non-cliff)
-- cZc2 Sunken Ruins Dirt (non-cliff)
-- cZc1 Sunken Ruins Large Bricks (non-cliff)
-- cGc2 Underground Dirt (non-cliff)
-- cGc1 Underground Square Tiles (non-cliff)
-- cVc2 Village Dirt (non-cliff)
-- cVc1 Village Thick Grass (non-cliff)
-- cQc2 Village Fall Dirt (non-cliff)
-- cQc1 Village Fall Thick Grass (non-cliff)


function terrain:init()
    self.__index  = self
    self.biomet   = {} -- store biome terrain settings.
    t_desert_dirt = FourCC('Bdrh')
    t_desert_sand = FourCC('Bdsr')
    t_desert_crag = FourCC('Bdsd')
    t_desert_rock = FourCC('Bflr')
    t_udgrd_dirt  = FourCC('Gdrt')
    t_udgrd_rock  = FourCC('Ggrs')
    t_udgrd_tile  = FourCC('Gsqd')
    t_marsh_dirt  = FourCC('Cdrd')
    t_marsh_vine  = FourCC('Cvin')
    t_marsh_pois  = FourCC('Cpos')
    t_marsh_rock  = FourCC('Crck')
    t_slag_dirt   = FourCC('cDc2')
    t_slag_rock   = FourCC('Dgrs')
    t_slag_lava   = FourCC('Dlvc')
    t_slag_brck   = FourCC('Dbrk')
    t_ice_ice     = FourCC('Iice')
    t_ice_icedark = FourCC('Idki')
    -- assign biome tiles:
    t_desert_g    = {
        [1] = t_desert_sand,
        [2] = t_desert_crag,
        [3] = t_desert_rock,
    }
    t_marsh_g     = {
        [1] = t_marsh_rock,
        [2] = t_marsh_vine,
        [3] = t_marsh_pois,
    }
    t_slag_g      = {
        [1] = t_slag_rock,
        [2] = t_slag_brck,
        [3] = t_slag_lava,
    }
    t_ice_g       = {
        [1] = t_udgrd_rock,
        [2] = t_ice_ice,
        [3] = t_ice_icedark,
    }
    t_vault_g       = {
        [1] = t_udgrd_tile,
        [2] = t_desert_sand,
        [3] = t_desert_sand,
    }
end


function terrain:paint(x, y, terrainid, brushsize)
    -- 0 = circle, 1 = sqare, brushsize = tile size
    for pnum = 1,kk.maxplayers do
        if utils.localp() == Player(pnum-1) then
            SetTerrainType(x, y, terrainid, -1, brushsize, 0)
        end
    end
end
