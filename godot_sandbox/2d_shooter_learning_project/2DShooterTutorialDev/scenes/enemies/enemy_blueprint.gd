extends CharacterBody2D
class_name EnemyBlueprint


@export var player_detected: bool = false
@export var enemy_health: int = 300
@export var attack_speed: float = .33
@export var weapon: Node2D = null
@export var path_to_follow: PathFollow2D = null
@export var pathing_speed: float = 350.
@export var hit_timer_flash_dur: float = .06
@export var enemy_sprite_override: Node = null
@export var is_flesh: bool = false
@export var attack_range: float = 1650.
@export var has_dynamic_movement: bool = false
@export var movement_speed: float = 300.  # If 'enemy_sprite_override' = AnimatedSprite2D
@export var is_melee: bool = false
@export var melee_attack_speed: float = .33
@export var melee_anim_speed: float = .33  # If 'enemy_sprite_override' = AnimatedSprite2D
@export var melee_anim_delay: float = .15  # Delay before damage is dealt.
@export var melee_anim_pause: float = .33  # Short pause after attack.
@export var active_target: CharacterBody2D = null
@export var stop_movement_speed: bool = false  # after a melee attack
@onready var weapon_timer: Timer = Timer.new()
@onready var util_timer: Timer = Timer.new()
@onready var hit_timer: Timer = Timer.new()
var detection_radius: Area2D = null


func _ready():
	weapon_timer.one_shot = false
	weapon_timer.wait_time = attack_speed
	add_child(weapon_timer)
	hit_timer.one_shot = false
	hit_timer.wait_time = 0.1
	hit_timer.timeout.connect(Callable(hit_flash_end))
	add_child(hit_timer)
	add_child(util_timer)
	detection_radius = $EnemyDetection
	detection_radius.body_entered.connect(Callable(player_enter_radius))
	detection_radius.body_exited.connect(Callable(player_exit_radius))
	weapon_timer.timeout.connect(Callable(_fire_weapon))
	if path_to_follow:
		global_position = path_to_follow.global_position
		global_rotation = path_to_follow.global_rotation
	# User-assigned w/ defaults (optional):
	if not enemy_sprite_override:
		enemy_sprite_override = $EnemySprite
	try_update_animation_player("default")


func _process(delta):
	if player_detected:
		active_target = Globals.player
		look_at(Globals.player_position)
		if has_dynamic_movement:
			if not stop_movement_speed:
				velocity = movement_speed*Vector2.from_angle(global_rotation)
				move_and_slide()
				try_update_animation_player("walk")
	if path_to_follow and pathing_speed > 0:
		path_to_follow.progress += delta*pathing_speed


func _fire_weapon():
	if (
		active_target
		and global_position.distance_to(
				active_target.global_position
			) <= attack_range
	):
		if is_melee:
			_fire_melee()
		else:
			weapon.launch()


func _fire_melee():
	if is_melee and not stop_movement_speed:
		stop_movement_speed = true
		util_timer.stop()
		try_update_animation_player("attack")
		util_timer.start(melee_anim_delay)
		await util_timer.timeout
		if is_instance_valid(self):
			weapon.launch()
			util_timer.start(melee_anim_delay + melee_anim_speed)
			if is_instance_valid(self):
				await util_timer.timeout
				stop_movement_speed = false


func try_update_animation_player(play_anim: String):
	# This is only if an AnimatedSprite2D is overriding $EnemySprite.
	# This sprite requires the following animations: "idle", "walk", "attack".
	if is_instance_valid(enemy_sprite_override) and enemy_sprite_override.get_class() == "AnimatedSprite2D":
		enemy_sprite_override = enemy_sprite_override as AnimatedSprite2D
		if play_anim != "walk" or (play_anim == "walk" and enemy_sprite_override.animation != "walk"):
			if play_anim in enemy_sprite_override.sprite_frames.get_animation_names():
				enemy_sprite_override.play(play_anim)


func projectile_hit(dmg):
	if is_instance_valid(self):
		enemy_health -= dmg
		if is_flesh:
			Globals.utl.play_sound("res://audio/organic_impact.mp3", 1.1, -15)
		else:
			Globals.utl.play_sound("res://audio/solid_impact.ogg", 1.1, -15)
		if enemy_health <= 0:
			if is_flesh:
				Globals.utl.play_sound("res://audio/organic_impact.mp3", 1.3, -12)
			else:
				Globals.utl.play_sound("res://audio/explosion.wav", 0.75, -12)
			queue_free()
		else:
			hit_flash()


func hit_flash():
	if is_instance_valid(enemy_sprite_override) and "material" in self:
		hit_timer.stop()
		enemy_sprite_override.material.set_shader_parameter("progress", 1.)
		hit_timer.start()


func hit_flash_end():
	if is_instance_valid(enemy_sprite_override):
		enemy_sprite_override.material.set_shader_parameter("progress", .0)


func player_enter_radius(body):
	print("enter", body)
	if "is_player" in body and body.is_player:
		if weapon:
			weapon_timer.start()
		player_detected = true
		if path_to_follow and pathing_speed > 0:
			path_to_follow.rotates = false


func player_exit_radius(body):
	print("exit", body)
	if "is_player" in body and body.is_player:
		if weapon:
			weapon_timer.stop()
		player_detected = false
		if path_to_follow and pathing_speed > 0:
			global_rotation = path_to_follow.global_rotation
			path_to_follow.rotates = true
