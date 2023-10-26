extends RigidBody2D


@export var speed: int = 900
@export var damage_light: int = 25
@export var damage_full: int = 125
var calc_grp: Array[Node] = []
var calc_member: Node2D

func _ready():
	Globals.utl.play_sound("res://audio/solid_impact.ogg", 0.75, -17)
	

func explode():
	freeze = true
	$CollisionShape2D.disabled = true


func damage_targets_in_radius(dmg, radius):
	calc_grp = (
		get_tree().get_nodes_in_group("Enemy")
		+ get_tree().get_nodes_in_group("Container")
	)
	for member in calc_grp:
		member = member as Node2D
		if member.global_position.distance_to(self.global_position) < radius:
			if "projectile_hit" in member:
				member.projectile_hit(dmg)


func deal_light_damage():
	damage_targets_in_radius(damage_light, 256)


func deal_full_damage():
	damage_targets_in_radius(damage_full, 512)


func sound_light():
	Globals.utl.play_sound("res://audio/explosion.wav", 0.5, -13)

func sound_full():
	Globals.utl.play_sound("res://audio/explosion.wav", 0.75, -11)
