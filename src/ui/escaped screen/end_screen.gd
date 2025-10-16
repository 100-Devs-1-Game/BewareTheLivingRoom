extends Control

@onready var title_button = $CanvasLayer/VBoxContainer/Return
@onready var quit_button = $CanvasLayer/VBoxContainer/Quit

func _ready() -> void:
	title_button.pressed.connect(to_title)
	quit_button.pressed.connect(quit_game)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func to_title() -> void:
	Sceneloader.load_scene("res://scenes/title/title.tscn")

func quit_game() -> void:
	get_tree().quit()
