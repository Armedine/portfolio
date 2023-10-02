---@class UnitEnum
---A primitive library to better enumerate units in the game world.

-- TODO

UnitEnum = {
    OfType = { 
        GroupEnumUnitsOfType,
        nil,
    },
    OfPlayer = { 
        GroupEnumUnitsOfPlayer,
        nil,
    },
    OfTypeCounted = { 
        GroupEnumUnitsOfTypeCounted,
        nil,
    },
    InRect = { 
        GroupEnumUnitsInRect,
        nil,
    },
    InRectCounted = { 
        GroupEnumUnitsInRectCounted,
        nil,
    },
    InRange = { 
        GroupEnumUnitsInRange,
        nil,
    },
    InRangeOfLoc = { 
        GroupEnumUnitsInRangeOfLoc,
        nil,
    },
    InRangeCounted = { 
        GroupEnumUnitsInRangeCounted,
        nil,
    },
    InRangeOfLocCounted = { 
        GroupEnumUnitsInRangeOfLocCounted,
        nil,
    },
    Selected = { 
        GroupEnumUnitsSelected,
        nil,
    }
}
UnitEnum.__index = UnitEnum


function UnitEnum:fetch_native(...)

end
