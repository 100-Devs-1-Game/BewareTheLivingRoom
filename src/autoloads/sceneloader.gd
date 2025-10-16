extends Node

var active_scene: Node = null

func load_scene(path: String) -> void:
	var err = get_tree().change_scene_to_file(path)
	if err != OK:
		push_error("Failed to change scene to: " + path)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("force_jump"):
		load_scene("res://other/jumpscare.tscn")
