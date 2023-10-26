extends Area2D


@export var projectile_speed = 800.
@export var projectile_damage = 5
@export var projectile_lifetime = 2.5


func _ready():
	$AudioStreamPlayer2D.pitch_scale = randf_range(.72, .76)
	$AudioStreamPlayer2D.play()
	body_entered.connect(
		Callable(_hit_target).bind(projectile_damage)
	)
	await get_tree().create_timer(projectile_lifetime).timeout
	queue_free()


func _process(delta):
	global_position += Vector2.from_angle(global_rotation)*projectile_speed*delta


func _hit_target(hit_node, dmg):
	if is_instance_valid(hit_node):
		if "projectile_hit" in hit_node and "is_player" in hit_node:
			hit_node.projectile_hit(dmg)
	queue_free()
