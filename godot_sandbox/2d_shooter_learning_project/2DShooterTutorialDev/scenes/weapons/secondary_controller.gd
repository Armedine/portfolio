extends Node2D


func validate_can_fire() -> bool:
	if Globals.secondary_ammo_current > 0:
		Globals.secondary_ammo_current -= 1
		return true
	return false
