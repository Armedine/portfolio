-- system data (do not change)
local mvp                       = {}
local mvp_data                  = {}
mvp_data.playerName             = {} -- optional var; store original player names to prevent color code overload.
mvp_data.x                      = GetRectCenterX(gg_rct_mapCenter)
mvp_data.y                      = GetRectCenterY(gg_rct_mapCenter)
mvp_data.pDmg                   = {} -- score: track damage.
mvp_data.pHealing               = {} -- score: track healing.
mvp_data.pAbsorbed              = {} -- score: track damage absorbed.
mvp_data.pElim                  = {} -- score: track eliminations.
mvp_data.pDeath                 = {} -- score: track deaths.
mvp_data.pExp                   = {} -- score: track experience earned.
mvp_data.pObjCap                = {} -- score: track objective participation.
mvp_data.pClutch                = {} -- score: track clutch events (e.g. a life-saving heal).
mvp_data.weight                 = {} -- initiate score weights.
mvp_data.pScore                 = {} -- a player's score.
-- score config:
mvp_data.weight.damage          = 0.50   -- how much value a damage point is worth.
mvp_data.weight.absorb          = 1.15   -- how much value a damage point is worth.
mvp_data.weight.healing         = 0.90   -- how much value a healing point is worth.
mvp_data.weight.experience      = 5.00   -- how much value earned experience is worth.
mvp_data.weight.deathFactor     = 0.98   -- multiply the final score for a penalty per death.
mvp_data.weight.elimFactor      = 1.02   -- multiply the final score for a bonus per elimination.
mvp_data.weight.clutchFactor    = 1.01   -- multiply the final score for a bonus per clutch event (e.g. healing a very low health ally).
mvp_data.weight.objFactor       = 1.10   -- multiply the final score for a bonus per completed event (e.g. near an objective capture).
-- system config:
mvp_data.maxPlayers             = 10     -- how many players exist.
mvp_data.sepDist                = 120.0  -- how far aparts heroes are.
mvp_data.camDist                = 1233.0 -- how far the camera angle is.
mvp_data.camRot                 = 315.0  -- how the camera is angled.
mvp_data.teamDist               = 575.0  -- starting distance of each team row from x,y center.
mvp_data.mvpNudge               = 125.0  -- how far the MVP hero is pushed forward.
mvp_data.queuedDelay            = 1.5    -- the delay before the MVP system initiates.
mvp_data.enterDelay             = 0.25   -- how fast each hero enters the MVP formation.
mvp_data.selectDelay            = 2.55   -- the delay before an MVP is chosen.
mvp_data.lbDelay                = 2.55   -- the delay before the scoreboard shows.
mvp_data.teamColor              = true   -- enable to set heroes to matching colors for team clarity.
mvp_data.mvpColor               = true   -- reverts the selected MVP back to their original color for individual player identification.
mvp_data.teamIntSplit           = 6      -- the first player number (1-based) of team B (e.g. in a 5v5, typically is player 6).
mvp_data.backdropAlpha          = 190    -- transparency of leaderboard background.
mvp_data.teamColorA             = PLAYER_COLOR_MAROON -- team A color if teamColor is enabled.
mvp_data.teamColorB             = PLAYER_COLOR_NAVY   -- team B color if teamColor is enabled.
mvp_data.mvpAnim                = 'stand victory'     -- played animation for selected MVP.
mvp_data.effectMVP1             = 'Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl'
mvp_data.effectMVP2             = 'Abilities\\Spells\\Human\\Thunderclap\\ThunderClapCaster.mdl'
mvp_data.enterEffect            = 'Abilities\\Spells\\Undead\\DarkRitual\\DarkRitualTarget.mdl'
mvp_data.textureMain            = 'war3mapImported\\ui_black_colorizer.tga'
mvp_data.teamTxtColorA          = '|cffff2c2c'
mvp_data.teamTxtColorB          = '|cff007dff'
mvp_data.titleColor             = '|cff00ffff'
mvp_data.mvpTxtC                = '|cffffff00'
mvp_data.showHideBtn            = {}
mvp_data.titles = { -- column headers
    [1] = 'Hero',
    [2] = 'Player',
    [3] = 'EXP Gained',
    [4] = 'Obj. Caps',
    [5] = 'Kills',
    [6] = 'Deaths',
    [7] = 'Damage',
    [8] = 'Healing',
    [9] = 'Absorbs',
    [10] = 'Clutch Spells',
    [11] = 'Score'
}
mvp_data.textColors = { -- color of the text in each column
    [1] = '|cffffffff',
    [2] = '|cffffffff',
    [3] = '|cffff00ff',
    [4] = '|cffffffff',
    [5] = '|cffffffff',
    [6] = '|cffffffff',
    [7] = '|cffff8505',
    [8] = '|cff5aff5a',
    [9] = '|cff00b1ff',
    [10] = '|cff8080ff',
    [11] = '|cffffaf00'
}
-- col:
-- :: hero icon | player name | exp earned | objcap | elims | deaths | dmg | healing | absorbs | clutch events | final score
-- rows: 
-- :: Hero | Player | EXP | Obj Completed | Eliminations | Deaths | Damage Done | Healing Done | Damage Absorbed | Clutch Spells | Score
-- :: [player 1]
-- ::   . . .
-- :: [player 10]


-- set default values
function mvp.Init()
    Preload(mvp_data.enterEffect)
    Preload(mvp_data.effectMVP1)
    Preload(mvp_data.effectMVP2)
    for pInt = 1,mvp_data.maxPlayers do -- 1-based to match GUI's player index
        mvp_data.pDmg[pInt]           = 0
        mvp_data.pHealing[pInt]       = 0
        mvp_data.pAbsorbed[pInt]      = 0
        mvp_data.pClutch[pInt]        = 0
        mvp_data.pObjCap[pInt]        = 0
        -- if undesired, delete this and handle populated leaderboard names yourself:
        mvp_data.playerName[pInt]     = GetPlayerName(Player(pInt-1))
    end
end


-- queue mvp screen
function mvp.Initiate()
    -- remove units in center of map:
    mvp.ClearArea()
    -- setup camera and heroes:
    for pInt = 1,mvp_data.maxPlayers do -- 1-based
        mvp.ShowHero(pInt, false)
        mvp.SetCameraTimer(pInt)
        -- revive heroes if dead then move them
        if udg_playerHero[pInt] then
            -- if dead, revive:
            if not IsUnitAliveBJ(udg_playerHero[pInt]) then
                ReviveHero(udg_playerHero[pInt],-1000,800,false)
            end
            -- re-initiate freeze just in case
            PauseUnit(udg_playerHero[pInt],true)
            SetUnitInvulnerable(udg_playerHero[pInt],true)
            if mvp_data.teamColor and pInt < mvp_data.teamIntSplit then
                SetUnitColor( udg_playerHero[pInt], mvp_data.teamColorA )
             elseif mvp_data.teamColor then
                SetUnitColor( udg_playerHero[pInt], mvp_data.teamColorB )
            end
            -- get scores:
            mvp_data.pScore[pInt] = mvp.CalculateScore(pInt)
        end
    end
    -- begin timer to place heroes:
    local xOffset, yOffset, distance, offset, angle, pInt = 0.0, 0.0, mvp_data.teamDist, -mvp_data.sepDist, 180.0, 1
    TimerStart(NewTimer(),mvp_data.queuedDelay,false,function() -- do a short wait
        TimerStart(NewTimer(),mvp_data.enterDelay,true,function()
            -- flip projection angle for team B, moving them right of x,y instead of left.
            if pInt == mvp_data.teamIntSplit then
                angle = 360.0
                distance = mvp_data.teamDist
            end
            xOffset, yOffset = PolarProjectionXY(mvp_data.x, mvp_data.y, distance, angle)
            if udg_playerHero[pInt] then
                mvp.ShowHero(pInt, true)
                UnitRemoveBuffs(udg_playerHero[pInt], true, true)
                SetUnitX(udg_playerHero[pInt],xOffset)
                SetUnitY(udg_playerHero[pInt],yOffset)
                SetUnitFacing(udg_playerHero[pInt],270.0)
                SetUnitPathing(udg_playerHero[pInt],false)
                SetUnitLifePercentBJ(udg_playerHero[pInt], 100)
                DestroyEffect(AddSpecialEffect(mvp_data.enterEffect,xOffset,yOffset))
            end
            distance = distance + offset
            pInt = pInt + 1
            if pInt > mvp_data.maxPlayers then
                -- delay before an MVP is chosen:
                TimerStart(NewTimer(),mvp_data.selectDelay,false,function()
                    mvp_data.mvpWinner = mvp.SelectMVP()
                    TimerStart(NewTimer(),mvp_data.lbDelay,false,function()
                        mvp.ScoreboardGenerate()
                        ReleaseTimer()
                    end)
                    ReleaseTimer()
                end)
                ReleaseTimer()
            end
        end)
    end)
end


-- run an algorithm to calculate player's score; returns score
function mvp.CalculateScore(pInt) -- pass in 1-based value
    -- for a copy paste solution, enable to map existing score variables:
    -- mvp.MapVariableValues()

    local score           = 0
    local h               = mvp_data.pHealing[pInt]  * mvp_data.weight.healing
    local d               = mvp_data.pDmg[pInt]      * mvp_data.weight.damage
    local a               = mvp_data.pAbsorbed[pInt] * mvp_data.weight.absorb
    local e               = mvp_data.pExp[pInt]      * mvp_data.weight.experience

    score = h + d + a + e

    -- bonuses:
    if mvp_data.pElim[pInt] > 0 then
        score = score + (score * (mvp_data.weight.elimFactor-1)   * mvp_data.pElim[pInt])
    end
    if mvp_data.pClutch[pInt] > 0 then
        score = score + (score * (mvp_data.weight.clutchFactor-1) * mvp_data.pClutch[pInt])
    end
    if mvp_data.pObjCap[pInt] > 0 then
        score = score + (score * (mvp_data.weight.objFactor-1)    * mvp_data.pObjCap[pInt])
    end
    -- penalties:
    if mvp_data.pDeath[pInt] > 0 then
        score = score - (score * ((1-mvp_data.weight.deathFactor) * mvp_data.pDeath[pInt]))
    end

    score = math.floor(score)

    return score
end


-- get the highest score of the winning team.
function mvp.SelectMVP()
    local pIntWinner = 1
    local pIntHighScore = 0 -- default a score comparison.
    for pInt = 1,10 do -- loop through every player and compare scores, shuffling winner value based on highest score.
        if mvp_data.pScore[pInt] > pIntHighScore then -- if highest value is beat, set the temporary winner of the sort loop.
            pIntWinner    = pInt
            pIntHighScore = mvp_data.pScore[pInt] -- set the new highest value to beat.
        end
    end
    -- run mvp effects:
    local x,y = PolarProjectionXY(GetUnitX(udg_playerHero[pIntWinner]),GetUnitY(udg_playerHero[pIntWinner]),mvp_data.mvpNudge,270.0)
    if mvp_data.mvpColor then
        SetUnitColor( udg_playerHero[pIntWinner], GetPlayerColor( Player(pIntWinner-1) ) )
    end
    SetUnitX(udg_playerHero[pIntWinner], x)
    SetUnitY(udg_playerHero[pIntWinner], y)
    DestroyEffect(AddSpecialEffect(mvp_data.effectMVP1, x, y))
    DestroyEffect(AddSpecialEffect(mvp_data.effectMVP2, x, y))
    SetUnitAnimation(udg_playerHero[pIntWinner], mvp_data.mvpAnim)
    ClearTextMessages()
    DisplayTextToForce( GetPlayersAll(), "|cff00b1ffMVP:|r " .. GetPlayerName( Player(pIntWinner-1) ) .. '|cff00b1ff!|r')
    return pIntWinner
end


-- set up the camera
function mvp.SetCamera(pInt) -- pass in 1-based value
    PanCameraToTimedForPlayer( Player(pInt-1), mvp_data.x, mvp_data.y, 0.0 )
    SetCameraFieldForPlayer( Player(pInt-1), CAMERA_FIELD_TARGET_DISTANCE, mvp_data.camDist, 0.33 )
    SetCameraFieldForPlayer( Player(pInt-1), CAMERA_FIELD_ANGLE_OF_ATTACK, mvp_data.camRot, 0.33 )
end


-- run a timer to keep camera fixed in place
function mvp.SetCameraTimer(pInt)
    TimerStart(NewTimer(),0.03,true,function()
        if GetLocalPlayer() == Player(pInt-1) then
            mvp.SetCamera(pInt)
        end
    end)
end


-- show the UI component
-- @bool = true for show, false for hide
function mvp.ScoreboardShow(bool)
    BlzFrameSetVisible(mvp_data.leaderboard_bd, bool)
end


-- create the UI component
-- this should only be called after players have chosen their heroes
function mvp.ScoreboardGenerate()
    local lb_x          = 0.84
    local lb_y          = 0.36
    local lb_xpad       = 0.03
    local lb_ypad       = 0.01
    local lb_yoffset    = 0.058
    local count_rows    = 11
    local count_cols    = 11
    local cell_width    = lb_x/count_rows*0.96
    local cell_height   = lb_y/count_cols
    local cellPadding   = cell_width*0.04
    local lb_xnudge     = cell_width*0.24 -- move the lb contents to the left slightly
    local yOffset       = 0.0
    local xOffset       = 0.0
    local isIcon        = false
    local concatLength  = 17 -- limit player name length to prevent overlap/ugliness
    local fh                 -- temp handle for readability
    local teamC              -- team color text
    FloorPlayerScoreValues(pInt) -- flatten values

    mvp_data.lb_table = {}
    mvp_data.leaderboard_bd = mvp.AttachBackdropByHandle(mvp_data.gameUI, 'leaderboard_bd',
        mvp_data.textureMain, mvp_data.backdropAlpha, 0.0, 0.0, lb_x, lb_y)
    BlzFrameClearAllPoints(mvp_data.leaderboard_bd)

    for col = 1,count_cols do -- columns
        mvp_data.lb_table[col] = {}
        xOffset = mvp.ScoreboardOffsetCalcX(col, cell_width, lb_xnudge + cellPadding)

        for row = 1,count_rows do -- rows
            -- player name color text:
            if row < mvp_data.teamIntSplit+1 then -- team A
                teamC = mvp_data.teamTxtColorA
            else -- team B
                teamC = mvp_data.teamTxtColorB
            end

            mvp_data.lb_table[col][row] = {}
            yOffset = mvp.ScoreboardOffsetCalcY(row, cell_height)
            if row > 1 and math.fmod(row,2) == 0 then
                mvp_data.lb_table[col][row].bd = mvp.AttachBackdropByHandle(mvp_data.leaderboard_bd, 'leaderboard_bd_row-'..row,
                    mvp_data.textureMain, 33, 0.0, 0.0, xOffset, yOffset)
            end

            if row == 1 then -- create headers
                fh = mvp.ScoreboardCreateFrame(pInt, col, row, "TEXT")
                BlzFrameSetText(fh, mvp_data.titles[col])
            elseif col == 1 then -- hero icon
                fh = mvp.ScoreboardCreateFrame(pInt, col, row, "BACKDROP")
                BlzFrameSetTexture(fh, udg_mbHeroIcon[row-1], 0, true) -- sub 1 for header row
                isIcon = true -- flag to size differently
            elseif col == 2 then -- player name
                fh = mvp.ScoreboardCreateFrame(pInt, col, row, "TEXT")
                if mvp_data.mvpWinner == row-1 then -- mvp text color
                    BlzFrameSetText(fh, mvp_data.mvpTxtC .. 'MVP:|r ' .. teamC .. string.sub(mvp_data.playerName[row-1],1,concatLength-5) .. '|r')
                else
                    BlzFrameSetText(fh, teamC .. string.sub(mvp_data.playerName[row-1],1,concatLength) .. '|r') -- sub 1 for header row
                end
            elseif col == 3 then -- exp
                fh = mvp.ScoreboardCreateFrame(pInt, col, row, "TEXT")
                BlzFrameSetText(fh, mvp_data.pExp[row-1])
            elseif col == 4 then -- obj
                fh = mvp.ScoreboardCreateFrame(pInt, col, row, "TEXT")
                BlzFrameSetText(fh, mvp_data.pObjCap[row-1])
            elseif col == 5 then -- elims
                fh = mvp.ScoreboardCreateFrame(pInt, col, row, "TEXT")
                BlzFrameSetText(fh, mvp_data.pElim[row-1])
            elseif col == 6 then -- deaths
                fh = mvp.ScoreboardCreateFrame(pInt, col, row, "TEXT")
                BlzFrameSetText(fh, mvp_data.pDeath[row-1])
            elseif col == 7 then -- dmg
                fh = mvp.ScoreboardCreateFrame(pInt, col, row, "TEXT")
                BlzFrameSetText(fh, mvp_data.pDmg[row-1])
            elseif col == 8 then -- healing
                fh = mvp.ScoreboardCreateFrame(pInt, col, row, "TEXT")
                BlzFrameSetText(fh, mvp_data.pHealing[row-1])
            elseif col == 9 then -- absorbs
                fh = mvp.ScoreboardCreateFrame(pInt, col, row, "TEXT")
                BlzFrameSetText(fh, mvp_data.pAbsorbed[row-1])
            elseif col == 10 then -- clutch spells
                fh = mvp.ScoreboardCreateFrame(pInt, col, row, "TEXT")
                BlzFrameSetText(fh, mvp_data.pClutch[row-1])
            elseif col == 11 then -- score
                fh = mvp.ScoreboardCreateFrame(pInt, col, row, "TEXT")
                if mvp_data.mvpWinner == row-1 then -- mvp text color
                    BlzFrameSetText(fh, mvp_data.mvpTxtC .. mvp_data.pScore[row-1] .. '|r')
                else
                    BlzFrameSetText(fh, mvp_data.pScore[row-1])
                end
            end

            if col == 1 and row ~= 1 then -- hero icon move
                BlzFrameSetPoint(fh,FRAMEPOINT_TOPLEFT,mvp_data.leaderboard_bd,FRAMEPOINT_TOPLEFT,
                    xOffset+(cell_width/2)-(cell_height/2)+cellPadding,yOffset)
            else -- standard column
                BlzFrameSetPoint(fh,FRAMEPOINT_TOPLEFT,mvp_data.leaderboard_bd,FRAMEPOINT_TOPLEFT,xOffset,yOffset)
            end
            if isIcon then
                BlzFrameSetSize(fh,cell_height - cellPadding, cell_height - cellPadding)
                isIcon = false
            else
                BlzFrameSetSize(fh,cell_width, cell_height)
            end
            BlzFrameSetVisible(fh, true)
            BlzFrameSetAlpha(fh, 255)
            BlzFrameSetTextSizeLimit(fh, 1)
            if row == 1 then -- title color
                BlzFrameSetText(fh, mvp_data.titleColor .. BlzFrameGetText(fh) .. '|r')
            elseif col ~= 1 then -- row color
                BlzFrameSetText(fh, mvp_data.textColors[col] .. BlzFrameGetText(fh) .. '|r')
            end
            BlzFrameSetTextAlignment(fh, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_CENTER)

        end
    end

    BlzFrameSetSize(mvp_data.leaderboard_bd, lb_x + lb_xpad, lb_y + lb_ypad)
    BlzFrameSetPoint(mvp_data.leaderboard_bd, FRAMEPOINT_CENTER, mvp_data.gameUI, FRAMEPOINT_CENTER, 0.0 - lb_xpad/2, lb_yoffset + lb_ypad/2)
    for pInt = 1,10 do
        CreateShowHideButton(pInt) -- show/hide btn
    end
end


-- generate a cell in the leaderboard table:
-- :: returns framehandle
function mvp.ScoreboardCreateFrame(pInt, col, row, frameType)
    mvp_data.lb_table[col][row] = BlzCreateFrameByType(frameType, "lb-"..col.."-"..row, mvp_data.leaderboard_bd, "", 0)
    return mvp_data.lb_table[col][row]
end


-- shift to next col:
function mvp.ScoreboardOffsetCalcX(col, cell_width, nudge)
    if col > 1 then
        return (cell_width * (col-1)) - nudge
    else
        return cell_width/3 * (col-1)
    end
end


-- start a column and iterate down its rows:
function mvp.ScoreboardOffsetCalcY(row, cell_height)
    return -(cell_height * (row-1))
end


-- remove clutter from staging area
function mvp.ClearArea()
    local g = CreateGroup()
    GroupEnumUnitsInRange(g, 0, 0, 1250.0, Condition(function()
        if not IsUnitType(GetFilterUnit(),UNIT_TYPE_HERO) or IsUnitType(GetFilterUnit(),UNIT_TYPE_ANCIENT) then
           RemoveUnit(GetFilterUnit())
           return true
        end
    end))
    DestroyGroup(g)
end


-- hide heroes to prep for mvp sequence
function mvp.ShowHero(pInt, bool)
    ShowUnit(udg_playerHero[pInt], bool)
    if not bool then -- move somewhere out of the way
        SetUnitX(udg_playerHero[pInt], mvp_data.y + 800)
        SetUnitY(udg_playerHero[pInt], mvp_data.x - 800)
    end
end


-- show clutch callout eyecandy
-- @unit    = location of arcing text
-- @dBool   = is it damage? (false for healing, true for damage)
function mvp.ArcingClutchText(unit, dBool)
    if dBool then
        ArcingTextTag('|cffff8505Clutch!|r', unit)
    else
        ArcingTextTag('|cff00b1ffClutch!|r', unit)
    end
end


-- increase the damage score of a player
function mvp.IncrementDamage(pInt, val) -- 1-based pInt
    if val < 5000 then -- don't increment if it's hacky damage e.g. instant kill
        mvp_data.pDmg[pInt] = mvp_data.pDmg[pInt] + val
    end
end


-- increase the healing score of a player
function mvp.IncrementHealing(pInt, val) -- 1-based pInt
    if val < 0 then local val = -val end -- control for negatives i.e. healing via negative damage.
    if val < 5000 then -- don't increment if it's hacky healing e.g. full heal
        mvp_data.pHealing[pInt] = mvp_data.pHealing[pInt] + val
    end
end


-- increase the absorbed damage score of a player
function mvp.IncrementAbsorbed(pInt, val) -- 1-based pInt
    if val < 5000 then -- don't increment if it's hacky effect e.g. invul
        mvp_data.pAbsorbed[pInt] = mvp_data.pAbsorbed[pInt] + val
    end
end


-- increase the completed objectives of a player
function mvp.IncrementObjectiveCap(pInt, val) -- 1-based pInt
    mvp_data.pObjCap[pInt] = mvp_data.pObjCap[pInt] + val
end


-- increase the clutch spell use events of a player
function mvp.IncrementClutch(pInt, val) -- 1-based pInt
    mvp_data.pClutch[pInt] = mvp_data.pClutch[pInt] + val
end


-- if needed, map existing variables to mvp data (these GUI vars exist in my personal project as an example):
function mvp.MapVariableValues()
    -- change the set variables to your map values e.g. udg_myHeroDeaths
    for pInt = 1,10 do
        mvp_data.pExp[pInt]   = udg_mbXPEarned[pInt]
        mvp_data.pElim[pInt]  = udg_mbEliminations[pInt]
        mvp_data.pDeath[pInt] = udg_mbDeaths[pInt]
    end
    -- ... add any others as needed (e.g. damage, healing, etc.)
end


-- create a backdrop and set it to be positioned at the desired frame via FRAMEPOINT_CENTER.
-- @fh = target this frame
-- @newFrameNameString = enter a custom value to manipulate backdrop by name if needed e.g. "myInventoryBackdrop"
-- @texturePathString = [optional; usually needed] texture (.blp) as the background
-- @alphaValue = [optional] if the backdrop should be transparent, pass in a value 0-255
-- @offsetx = [optional] nudge the frame left or right (percentage of screen)
-- @offsety = [optional] nudge the frame up or down (percentage of screen)
-- @width, @height = [optional] override the frame size
-- :: returns framehandle
function mvp.AttachBackdropByHandle(fh, newFrameNameString, texturePathString, alphaValue, offsetx, offsety, width, height)
    local nh = BlzCreateFrameByType("BACKDROP", newFrameNameString, mvp_data.gameUI, "", 0)
    local x = offsetx or 0.0
    local y = offsety or 0.0
    local w = width or BlzFrameGetWidth(fh)
    local h = height or BlzFrameGetHeight(fh)
    BlzFrameSetSize(nh, w, h)
    BlzFrameSetPoint(nh, FRAMEPOINT_CENTER, fh, FRAMEPOINT_CENTER, 0.0 + x, 0.0 + y)
    if texturePathString then
        BlzFrameSetTexture(nh, texturePathString, 0, true)
    end
    BlzFrameSetLevel(nh, 0)
    if alphaValue then 
        BlzFrameSetAlpha(nh, math.ceil(alphaValue))
    end
    return nh
end


-- callback when show/hide is clicked:
function ShowHideBtnClick(pInt)
    if GetLocalPlayer() == Player(pInt-1) then
        if not BlzFrameIsVisible(mvp_data.leaderboard_bd) then
            mvp.ScoreboardShow(true)
            BlzFrameSetText(mvp_data.showHideBtn[pInt], "Hide Leaderboard")
        else
            mvp.ScoreboardShow(false)
            BlzFrameSetText(mvp_data.showHideBtn[pInt], "Show Leaderboard")
        end
    end
end


-- create button to show/hide the board:
function CreateShowHideButton(pInt)
    local trig = CreateTrigger()
    mvp_data.showHideBtn[pInt] = BlzCreateFrame("ScriptDialogButton", mvp_data.gameUI, 0.0, 0.0)
    BlzFrameSetSize(mvp_data.showHideBtn[pInt], 0.13, 0.03)
    BlzFrameSetPoint(mvp_data.showHideBtn[pInt], FRAMEPOINT_CENTER, mvp_data.leaderboard_bd, FRAMEPOINT_BOTTOM, 0.0, 0.0)
    BlzFrameSetText(mvp_data.showHideBtn[pInt], "Hide Leaderboard")
    BlzTriggerRegisterFrameEvent(trig, mvp_data.showHideBtn[pInt], FRAMEEVENT_CONTROL_CLICK)
    TriggerAddAction(trig, function() ShowHideBtnClick(GetConvertedPlayerId(GetTriggerPlayer())) end)
    -- hide btn for other players:
    for i = 1,mvp_data.maxPlayers do
        if GetLocalPlayer() == Player(i-1) and GetLocalPlayer() ~= Player(pInt-1) then
            BlzFrameSetVisible(mvp_data.showHideBtn[pInt],false)
        end
    end
end


-- flatten values:
function FloorPlayerScoreValues()
    for pInt = 1,10 do
        mvp_data.pDmg[pInt]           = math.floor(math.abs(mvp_data.pDmg[pInt]))
        mvp_data.pHealing[pInt]       = math.floor(math.abs(mvp_data.pHealing[pInt]))
        mvp_data.pAbsorbed[pInt]      = math.floor(math.abs(mvp_data.pAbsorbed[pInt]))
        mvp_data.pElim[pInt]          = math.floor(math.abs(mvp_data.pElim[pInt]))
        mvp_data.pDeath[pInt]         = math.floor(math.abs(mvp_data.pDeath[pInt]))
        mvp_data.pExp[pInt]           = math.floor(math.abs(mvp_data.pExp[pInt]))
        mvp_data.pObjCap[pInt]        = math.floor(math.abs(mvp_data.pObjCap[pInt]))
        mvp_data.pClutch[pInt]        = math.floor(math.abs(mvp_data.pClutch[pInt]))
        mvp_data.pScore[pInt]         = math.floor(math.abs(mvp_data.pScore[pInt]))
    end
end
