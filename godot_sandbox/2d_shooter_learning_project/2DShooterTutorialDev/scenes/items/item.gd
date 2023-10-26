extends Area2D


var item_types = [
	{
		name = 'primary',
		color = Color(.2, .2, 1),
		value = 10,
		target = "primary_ammo_current",
		max_capacity = 80,
	},
	{
		name = 'secondary',
		color = Color(1, .2, .2),
		value = 1,
		target = "secondary_ammo_current",
		max_capacity = 12,
	},
	{
		name = 'health',
		color = Color(.2, 1, .2),
		value = 25,
		target = "player_health_current",
		max_capacity = 200,
	}
]
@onready var type_roll: int = randi_range(0, item_types.size()-1)
var this_type: Dictionary


func _ready():
	this_type = item_types[type_roll]
	$Sprite2D.modulate = this_type.color


func _process(delta):
	rotation += 3*delta


func _on_body_entered(body):
	if body.is_player:
		Globals[this_type.target] += this_type.value
		if "max_capacity" in this_type:
			if Globals[this_type.target] > this_type.max_capacity:
				Globals[this_type.target] = this_type.max_capacity
		Globals.utl.play_sound("res://audio/item.mp3", 1, -9)
		queue_free()
