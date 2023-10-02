---@class UnitIndexer
UnitIndexer = { unit_lookup = {} } -- UnitIndexer class.


function UnitIndexer:get_preplaced()
   for i = bj_MAX_PLAYER_SLOTS - 1, 0, -1 do
      GroupEnumUnitsOfPlayer(bj_lastCreatedGroup, Player(i), Filter(function()
         if self.enabled then UnitIndexer:add_index(GetFilterUnit(), true) end
         return false
      end))
   end
   GroupClear(bj_lastCreatedGroup)
end


-- @unit = index this unit and set its custom value
-- @bool = was it a prelaced unit?
function UnitIndexer:add_index(unit, bool)
   self.index              = self.index + 1
   self.placed[self.index] = bool or false
   self.unit_lookup[self.index] = unit
   SetUnitUserData(unit, self.index)
   return self.index
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
   TriggerRegisterEnterRegion(self.trig, self.region, Condition(function() if self.enabled then UnitIndexer:add_index(GetFilterUnit(), false) end return false end))
end


function GetUnitIndex(u)
   return GetUnitUserData(u)
end


function GetUnitByIndex(index)
   return UnitIndexer.unit_lookup[index]
end


do
   OnMapInit(function()
      UnitIndexer:init()
      UnitIndexer:get_preplaced()
   end)
end
