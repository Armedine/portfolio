extends LevelParent


func _on_exit_region_body_entered(_body):
	TransitionLayer.change_scene("res://scenes/levels/outside_level.tscn")
