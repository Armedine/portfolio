extends Node


# Engine:
var utl: utils = utils.new()
const target_fps: int = 60
var projectile_bucket: Node2D = null
var node = self

# Player:
@export var player: CharacterBody2D = null
@export var player_position: Vector2 = Vector2()
@export var player_health_capacity = 100
@export var player_health_low_warning = 20
@export var player_health_current = player_health_capacity:
	get:
		return player_health_current
	set(v):
		update_player_health_ui(v)
		player_health_current = v

@export var primary_on_cooldown = false
@export var primary_ammo_capacity = 20
@export var primary_ammo_low_warning = 10
@export var primary_ammo_recharge_cadence = 0.5
@export var primary_ammo_recharge_delay = 2.5
@export var primary_ammo_current = primary_ammo_capacity:
	get:
		return primary_ammo_current
	set(v):
		update_primary_ui(v)
		primary_ammo_current = v

@export var secondary_on_cooldown = false
@export var secondary_ammo_capacity = 3
@export var secondary_ammo_low_warning = 1
@export var secondary_ammo_recharge_cadence = 6.
@export var secondary_ammo_recharge_delay = 12.
@export var secondary_ammo_current = secondary_ammo_capacity:
	get:
		return secondary_ammo_current
	set(v):
		update_secondary_ui(v)
		secondary_ammo_current = v

# User Interface:
var UI: Node
var primary_ammo_label: Label
var primary_ammo_texture: TextureRect
var secondary_ammo_label: Label
var secondary_ammo_texture: TextureRect
var player_health_bar: TextureProgressBar
var player_health_bar_label: Label


func _ready():
	# Other:
	UI = load("res://scenes/ui/ui.tscn").instantiate()
	get_node("/root/Globals").add_child(UI)
	primary_ammo_label = get_node("/root/Globals/UI/MarginContainerWeapon/PrimaryWeaponCounter/VBoxContainer/Label")
	secondary_ammo_label = get_node("/root/Globals/UI/MarginContainerWeapon/SecondaryWeaponCounter/VBoxContainer/Label")
	player_health_bar = get_node("/root/Globals/UI/MarginContainerHealth/TextureProgressBar")
	player_health_bar_label = get_node("/root/Globals/UI/MarginContainerHealth/TextureProgressBar/Label")
	primary_ammo_texture = get_node("/root/Globals/UI/MarginContainerWeapon/PrimaryWeaponCounter/VBoxContainer/TextureRect")
	secondary_ammo_texture = get_node("/root/Globals/UI/MarginContainerWeapon/SecondaryWeaponCounter/VBoxContainer/TextureRect")
	update_ui()


func update_player_health_ui(value):
	player_health_bar.value = int(value)
	player_health_bar_label.text = "%s/%s" % [value, player_health_capacity]
	if value > player_health_capacity:
		player_health_bar_label.modulate = Color(.2, 1, .2)
	elif value <= player_health_low_warning:
		player_health_bar_label.modulate = Color(1, 1, 0)
	elif value <= 0:
		player_health_bar_label.modulate = Color(1, 0, 0)
	else:
		player_health_bar_label.modulate = Color(1, 1, 1)
	return value


func update_primary_ui(value):
	if value == 0:
		primary_ammo_texture.modulate = Color(1, 0, 0)
	elif value == primary_ammo_capacity:
		primary_ammo_texture.modulate = Color(1, 1, 1)
	elif value <= primary_ammo_low_warning:
		primary_ammo_texture.modulate = Color(1, 1, 0)
	elif value > primary_ammo_capacity:
		primary_ammo_texture.modulate = Color(.2, 1, .2)
	else:
		primary_ammo_texture.modulate = Color(.3, .6, 1)
	primary_ammo_label.text = str(value)


func update_secondary_ui(value):
	if value == 0:
		secondary_ammo_texture.modulate = Color(1, 0, 0)
	elif value == secondary_ammo_capacity:
		secondary_ammo_texture.modulate = Color(1, 1, 1)
	elif value <= secondary_ammo_low_warning:
		secondary_ammo_texture.modulate = Color(1, 1, 0)
	elif value > secondary_ammo_capacity:
		secondary_ammo_texture.modulate = Color(.2, 1, .2)
	else:
		secondary_ammo_texture.modulate = Color(1, 1, 1)
	secondary_ammo_label.text = str(value)

func update_ui():
	update_player_health_ui(player_health_current)
	update_primary_ui(primary_ammo_current)
	update_secondary_ui(secondary_ammo_current)
