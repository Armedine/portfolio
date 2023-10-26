extends Node2D


@export var launch_points: Array[Marker2D]
@export var weapon_owner: Node2D
@export var projectile: PackedScene
@export var alternate_shots = true  # If multiple launch points exist, alternate.
var calc_a = 0.
var calc_marker: Marker2D
var calc_index = 0
var calc_points: Array[Marker2D] = []


func launch():
	if alternate_shots and launch_points.size() > 1:
		calc_index += 1
		if calc_index > launch_points.size()-1:
			calc_index = 0
		calc_points.append(launch_points[calc_index])
	else:
		calc_points = launch_points.duplicate()
	for marker in calc_points:
		var p = projectile.instantiate() as Area2D
		calc_a = (weapon_owner.active_target.global_position - global_position).normalized()
		Globals.projectile_bucket.add_child(p)
		p.global_position = marker.global_position
		p.global_rotation = calc_a.angle()
	calc_points.clear()
