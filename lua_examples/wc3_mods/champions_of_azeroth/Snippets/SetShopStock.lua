function SetShopStock(unit)
	local g = CreateGroup()
	GroupEnumUnitsInRect(g, bj_mapInitialPlayableArea, ShopFilter(unit))
	DestroyGroup(g)
end

function ShopFilter(unit)
	local heroId = GetUnitTypeId(unit)
	local u = GetEnumUnit()
	local uId = GetUnitTypeId(u)
	if IsUnitType(uId, UNIT_TYPE_STRUCTURE) then
		RemoveUnitFromStock(u, heroId)
	end
	return false
end

function RemoveStock(unit)
	local id = GetUnitTypeId(unit)
	RemoveUnitFromAllStock(id)
end 