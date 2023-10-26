extends Area2D


signal player_enter_house


func _on_body_entered(_body):
	player_enter_house.emit()
