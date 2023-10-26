extends Area2D


@export var projectile_speed: float = 100.
@export var direction = Vector2.UP  # Updated on fire.
@export var projectile_damage: int = 15
var is_destroyed = false


func _ready():
	await get_tree().create_timer(.1).timeout
	self.queue_free()


func _process(delta):
	global_position += Vector2.from_angle(global_rotation)*projectile_speed*delta


func _on_body_entered(body):
	if "projectile_hit" in body:  # Basically mimics interfaces.
		body.projectile_hit(projectile_damage)
