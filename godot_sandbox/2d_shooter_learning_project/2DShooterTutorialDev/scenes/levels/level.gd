class_name LevelParent


extends Node2D


var laser_scene: PackedScene = preload("res://scenes/projectiles/laser.tscn")
var grenade_scene: PackedScene = preload("res://scenes/projectiles/grenade.tscn")


func _ready():
	Globals.projectile_bucket = $Projectiles


func _on_player_player_primary_fired(pos, dir):
	var laser = laser_scene.instantiate() as Area2D
	laser.position = pos
	laser.direction = dir
	laser.rotation_degrees = rad_to_deg(dir.angle())
	$Projectiles.add_child(laser)
	

func _on_player_player_secondary_fired(pos, dir):
	var grenade = grenade_scene.instantiate() as RigidBody2D
	grenade.position = pos
	grenade.linear_velocity = dir*grenade.speed
	$Projectiles.add_child(grenade)


func _on_house_player_enter_house():
	var tween = get_tree().create_tween()
	tween.tween_property($Player/PlayerCamera, "zoom", Vector2(1., 1.), 0.6).set_trans(tween.TRANS_SINE)


func _on_house_body_exited(_body):
	var tween = get_tree().create_tween()
	tween.tween_property($Player/PlayerCamera, "zoom", Vector2(.8, .8), 0.6).set_trans(tween.TRANS_SINE)
