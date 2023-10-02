-- UnitIndexer by Planetary @ hiveworkshop.com
-- A basic unit indexer for Lua maps.
UnitIndexer        = {} -- UnitIndexer class.


function UnitIndexer:preplaced()
    for i = bj_MAX_PLAYER_SLOTS - 1, 0, -1 do
        GroupEnumUnitsOfPlayer(bj_lastCreatedGroup, Player(i), Filter(function()
            if self.enabled then UnitIndexer:addindex(GetFilterUnit(), true) end
            return false
        end))
    end
    GroupClear(bj_lastCreatedGroup)
end


-- @unit = index this unit and set its custom value
-- @bool = was it a prelaced unit?
function UnitIndexer:addindex(unit, bool)
    self.index              = self.index + 1
    self.placed[self.index] = bool or false
    SetUnitUserData(unit, self.index)
end


function UnitIndexer:init()
    self.debug   = false -- print data lookups when true.
    self.region  = CreateRegion()
    self.map     = GetWorldBounds()
    self.trig    = CreateTrigger()
    self.index   = 0
    self.enabled = true
    self.placed  = {}
    self.__index = self
    RegionAddRect(self.region, self.map)
    RemoveRect(self.map)
    TriggerRegisterEnterRegion(self.trig, self.region, Condition(function() if self.enabled then UnitIndexer:addindex(GetFilterUnit(), false) end return false end))
end

onTriggerInit(function()
    UnitIndexer:init()
    UnitIndexer:preplaced()
end)
