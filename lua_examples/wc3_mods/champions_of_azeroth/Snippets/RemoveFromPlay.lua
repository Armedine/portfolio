-- @unit = unit to hide
-- @bool = true to hide, false to show
function RemoveFromPlay(unit, bool)
	ShowUnit(unit, not bool)
	SetUnitPathing(unit, not bool)
	SetUnitInvulnerable(unit, bool)
	if (bool) then
		UnitAddAbility(unit, FourCC('Aloc'))
		UnitAddAbility(unit, FourCC('Amrf'))
	else
		UnitRemoveAbility(unit, FourCC('Aloc'))
		UnitRemoveAbility(unit, FourCC('Amrf'))
	end
end
