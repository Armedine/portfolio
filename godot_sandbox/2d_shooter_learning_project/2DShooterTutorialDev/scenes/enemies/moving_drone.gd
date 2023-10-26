extends Node2D

var enemy_movespeed: float = 150.


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$EnemyDrone.velocity = Vector2(1, 0)*enemy_movespeed
	$EnemyDrone.move_and_slide()
