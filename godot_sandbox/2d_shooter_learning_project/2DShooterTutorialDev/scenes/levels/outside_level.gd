extends LevelParent


func _on_area_2d_body_entered(_body):
	TransitionLayer.change_scene("res://scenes/levels/inside_level.tscn")
