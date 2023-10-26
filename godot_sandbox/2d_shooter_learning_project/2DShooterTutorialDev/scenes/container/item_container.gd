extends StaticBody2D
class_name ItemContainer


@export var item_to_spawn: PackedScene = preload("res://scenes/items/item.tscn")
@onready var lid_sprite: Sprite2D = $LidSprite
var facing_vector
var container_has_been_opened: bool = false


func projectile_hit(dmg):
	if not container_has_been_opened and dmg > 0:
		Globals.utl.play_sound("res://audio/container_hit.mp3", 1, -10)
		call_deferred("spawn_item", position)


func get_random_dir():
	return rotation + randf_range(-PI/6, PI/6)


func spawn_item(pos):
	var a = get_random_dir()
	var new_item = item_to_spawn.instantiate() as Area2D
	var move_tween = create_tween()
#	var target_pos = Vector2(
#		pos.x + 133*cos(a),
#		pos.y + 133*sin(a)
#	)
	var target_pos = pos + Vector2.from_angle(a)*100
	new_item.global_position = pos
	move_tween.bind_node(new_item)
	move_tween.set_parallel()
	move_tween.tween_property(new_item, "position", target_pos, .3)
	move_tween.tween_property(new_item, "scale", Vector2(.6,.6), .3).from(Vector2())
	container_has_been_opened = true
	lid_sprite.visible = false
	$PointLight2D.visible = false
	get_tree().current_scene.add_child(new_item)
	
