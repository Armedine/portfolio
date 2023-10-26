extends Area2D


@export var projectile_speed: float = 3000.
@export var direction = Vector2.UP  # Updated on fire.
@export var projectile_damage: int = 25
var is_destroyed = false


func _ready():
	$SoundLaser.pitch_scale = randf_range(0.92, 1.07)
	await get_tree().create_timer(.5).timeout
	destroy_projectile()


func _process(delta):
	if not is_destroyed:
		global_position += direction*projectile_speed*delta


func _on_body_entered(body):
#	print("collided with %s" % body)
	play_collision()
	if "projectile_hit" in body:  # Basically mimics interfaces.
		body.projectile_hit(projectile_damage)
	await get_tree().create_timer(.5).timeout
	destroy_projectile()

func play_collision():
	is_destroyed = true
	$LaserSprite2D.visible = false
	$PointLightFeintBlue.queue_free()
	$CollideAnimationPlayer.play("laser_collision")
	$CollisionShape2D.set_deferred("disabled", true)

func destroy_projectile():
	is_destroyed = true
	if not self == null:
		self.queue_free()
