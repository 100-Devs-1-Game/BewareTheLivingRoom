extends Node

func _ready() -> void:
	await get_tree().process_frame
	Sceneloader.load_scene("res://scenes/title/title.tscn")
