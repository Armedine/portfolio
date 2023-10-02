-- project name: {dest code to place, excavation dest to replace, facing angle, scale}
function initprojects()
    constructiont = {}
    placedconst   = {}

    -- shinykeeper shop upgrades:
    constructiont['shiny1'] = {'B00B', udg_projects[1], 270.0, 1.0}     -- hammer -- _0032
    constructiont['shiny2'] = {'B00D', udg_projects[2], 23.0, 1.0}      -- shinies, for dummies -- _0109
    constructiont['shiny3'] = {'B00C', udg_projects[3], 270.0, 0.75}     -- shiny super-forge -- _0110
    constructiont['shiny4'] = {'B00G', udg_projects[4], 270.0, 0.75}    -- scrapomatic -- _0029
    -- elementalist shop upgrades:
    constructiont['ele1']   = {'B00F', udg_projects[5], 166.0, 1.5}     -- enchanted stash -- _0024
    constructiont['ele2']   = {'B00E', udg_projects[6], 270.0, 0.75}    -- infusion crystal 1 -- _0141
    constructiont['ele3']   = {'B00E', udg_projects[7], 270.0, 0.75}    -- `` 2 -- _0140
    constructiont['ele4']   = {'B00E', udg_projects[8], 270.0, 0.75}    -- `` 3 -- _0209
    -- boss trophies:
    constructiont['boss1']  = {'B00H', udg_projects[9], 270.0, 1.75}     -- slag king -- _0214
    constructiont['boss2']  = {'B00I', udg_projects[10], 270.0, 1.75}    -- marsh mutant -- _0137
    constructiont['boss3']  = {'B00J', udg_projects[11], 270.0, 1.75}    -- megachomp -- _0215
    constructiont['boss4']  = {'B00K', udg_projects[12], 270.0, 1.75}    -- thawed experiment -- _0217
    constructiont['boss5']  = {'B00L', udg_projects[13], 270.0, 1.00}    -- ancient portal
    -- greywhisker:
    constructiont['grey1']  = {'B00M', udg_projects[14], 315.0, 0.8}    -- greywhisker crafting station _0394
end


function placeproject(projectname)
    utils.debugfunc(function()
        local x, y = GetDestructableX(constructiont[projectname][2]), GetDestructableY(constructiont[projectname][2])
        KillDestructable(constructiont[projectname][2])
        placedconst[projectname] = CreateDestructable(FourCC(constructiont[projectname][1]), x, y, constructiont[projectname][3], constructiont[projectname][4], 1)
        SetDestructableInvulnerable(placedconst[projectname], true)
    end, 'placeproject')
end


function mergeancientrelics()
    -- KillDestructable(placedconst['boss1'])
    -- KillDestructable(placedconst['boss2'])
    -- KillDestructable(placedconst['boss3'])
    -- KillDestructable(placedconst['boss4'])
    placeproject('boss5')
    utils.playerloop(function(p) utils.shakecam(p, 1.75, 2.5) end)
    utils.playsoundall(kui.sound.portalmerge)
end


function testprojects()
    for name,t in pairs(constructiont) do
        placeproject(name)
    end
end
