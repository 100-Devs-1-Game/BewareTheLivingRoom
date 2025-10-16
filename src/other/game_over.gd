extends Control

const STATIC = preload("res://assets/audio/spooky/static.ogg")

func _on_title_pressed() -> void:
	Sceneloader.load_scene("res://scenes/title/title.tscn")
