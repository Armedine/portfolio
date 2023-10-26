extends CanvasLayer


func _ready():
	self.visible = false

func change_scene(target: String) -> void:
	self.visible = true
	$AnimationPlayer.play("FadeOut")
	get_tree().change_scene_to_file(target)
