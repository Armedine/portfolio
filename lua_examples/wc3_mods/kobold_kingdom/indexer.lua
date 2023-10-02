indexer        = {} -- indexer class.


function indexer:preplaced()
   for i = bj_MAX_PLAYER_SLOTS - 1, 0, -1 do
      GroupEnumUnitsOfPlayer(bj_lastCreatedGroup, Player(i), Filter(function()
         if self.enabled then indexer:addindex(GetFilterUnit(), true) end
         return false
      end))
   end
   GroupClear(bj_lastCreatedGroup)
end


-- @unit = index this unit and set its custom value
-- @bool = was it a preplaced unit?
function indexer:addindex(unit, bool)
   self.index              = self.index + 1
   self.placed[self.index] = bool or false
   SetUnitUserData(unit, self.index)
end


function indexer:init()
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
   TriggerRegisterEnterRegion(self.trig, self.region, Condition(function() if self.enabled then indexer:addindex(GetFilterUnit(), false) end return false end))
end


do
   onTriggerInit(function()
      indexer:init()
      indexer:preplaced()
   end)
end
