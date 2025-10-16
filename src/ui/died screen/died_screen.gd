extends Control

@onready var retry_button = $CanvasLayer/VBoxContainer/Retry
@onready var title_button = $CanvasLayer/VBoxContainer/Return
@onready var quit_button = $CanvasLayer/VBoxContainer/Quit

func _ready() -> void:
	title_button.pressed.connect(to_title)
	quit_button.pressed.connect(quit_game)
	retry_button.pressed.connect(retry_game)


func retry_game() -> void:
	Sceneloader.load_scene("res://scenes/game/game.tscn")


func to_title() -> void:
	Sceneloader.load_title()


func quit_game() -> void:
	get_tree().quit()
