extends Node3D

@export var lighting: OmniLight3D
@export var flash_speed: float = 20.0
@export var flash_strength: float = 10.0
@export var base_energy: float = 0.0

var time: float = 0.0

const SCREAM_01 = preload("res://assets/audio/spooky/scream_01.ogg")
const SCREAM_03 = preload("res://assets/audio/spooky/scream_03.ogg")
const STATIC = preload("res://assets/audio/spooky/static.ogg")

var scream_sounds = [SCREAM_01, SCREAM_03]

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var player = $AudioStreamPlayer
	player.stream = scream_sounds.pick_random()
	player.play()


func _process(delta: float) -> void:
	time += delta * flash_speed
	lighting.light_energy = base_energy + abs(sin(time)) * flash_strength


func show_buttons() -> void:
	$CanvasLayer/Title.visible = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	$CanvasLayer.visible = true
	var player2 = $AudioStreamPlayer2
	player2.stream = STATIC
	player2.play()
	
	_call_show_buttons_delayed()


func _call_show_buttons_delayed() -> void:
	await get_tree().create_timer(2.0).timeout
	show_buttons()


func _on_audio_stream_player_finished() -> void:
	var player2 = $AudioStreamPlayer2
	player2.stream = STATIC
	player2.play()


func _on_title_pressed() -> void:
	Sceneloader.load_scene("res://scenes/title/title.tscn")
