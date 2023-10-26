class_name utils
extends Node


static func get_children_recursive(n: Node, add_to_array: Array[Node]) -> Array[Node]:
	if n.get_node_or_null(n.get_path()) and n.get_child_count() > 0:
		for cn in n.get_children():
			add_to_array.append(cn)
			get_children_recursive(cn, add_to_array)
	return add_to_array


static func randi_from_array(array: Array):
	return randi_range(0, array.size()-1)


func timer(node, one_shot: bool = true):
	var t = Timer.new()
	node.add_child(t)
	t.one_shot = one_shot
	return t


func play_sound(sound: String, pitch, volume):
	var player = AudioStreamPlayer.new()
	player.finished.connect(Callable(destroy_audio_player_safe).bind(player))
	player.stream = load(sound)
	player.pitch_scale = pitch
	player.volume_db = volume
	Globals.node.add_child(player)
	player.play()

func destroy_audio_player_safe(sound):
	if is_instance_valid(sound):
		sound.queue_free()
