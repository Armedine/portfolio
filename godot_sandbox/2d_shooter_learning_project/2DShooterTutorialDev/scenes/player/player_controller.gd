extends CharacterBody2D


signal player_primary_fired(pos: Vector2, dir: Vector2)
signal player_secondary_fired(pos: Vector2, dir: Vector2)


const player_movespeed = 900
var cd_laser: bool = false
var cd_nade: bool = false
var cd_footstep: bool = false
var is_player = true
var player_direction: Vector2 = Vector2.ZERO


func _ready():
	$PlayerCamera.make_current()
	Globals.player = self


func _process(_delta):
	
	# PLAYER DIRECTION:
	look_at(get_global_mouse_position())
	Globals.player_position = global_position
	
	# CAMERA LOCK:
#	$PlayerCamera.global_position = global_position
	
	if Input.is_anything_pressed():
		
		# Rigid body 2d = moved by physics engine
		# Character body 2d = methods attached for use with inputs, etc.
		# Physics body 2d = abstract physics class (base).
		
		# MOVEMENT VECTOR:
		velocity = Input.get_vector("left", "right", "up", "down") * player_movespeed
		move_and_slide()  # The call to apply velocity (pixels/sec).
		if velocity.abs() > Vector2(0, 0):
			# PLAY MOVEMENT ANIMATION:
			$PlayerAnimation.play("player_bobble")
			# PLAY FOOTSTEP, MODULATED:
			if not cd_footstep:
				cd_footstep = true
				$TimerFootstep.start()
				$SoundFootstep.pitch_scale = randf_range(0.5, 0.6)
				$SoundFootstep.play()
		else:
			$PlayerAnimation.stop(true)
#			$PlayerAnimation.pause()
		
		player_direction = (get_global_mouse_position() - position).normalized()
		
		# PRIMARY FIRE:
		if Input.is_action_pressed("primary") and not cd_laser:
			if $PrimaryWeaponController.validate_can_fire():
				cd_laser = true
				var p_markers = $ProjectileLaunchPoint.get_children()
				var p_marker: Marker2D = p_markers[utils.randi_from_array(p_markers)]
				player_primary_fired.emit(
					p_marker.global_position,
					player_direction
				)
				$TimerShoot.start()
				$LaserParticle.restart()
		
		# SECONDARY FIRE:
		if Input.is_action_pressed("secondary") and not cd_nade:
			if $SecondaryWeaponController.validate_can_fire():
				cd_nade = true
				player_secondary_fired.emit(
					$ProjectileLaunchPoint/Marker2D2.global_position,
					player_direction
				)
				$TimerNade.start()


func _on_timer_shoot_timeout():
	cd_laser = false


func _on_timer_nade_timeout():
	cd_nade = false


func _on_timer_footstep_timeout():
	cd_footstep = false

func projectile_hit(dmg):
	Globals.utl.play_sound("res://audio/organic_impact.mp3", 1.1, -12)
	Globals.player_health_current = max(Globals.player_health_current-dmg, 0)
	if Globals.player_health_current <= 0:
		get_tree().reload_current_scene()
		Globals.player_health_current = 50
