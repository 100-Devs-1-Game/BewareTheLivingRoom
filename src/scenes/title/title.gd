extends Node3D

@export var play_button: BaseButton
@export var quit_button: BaseButton
@export var settings_button: BaseButton

@export var cameras: Array[Camera3D] = []
@export var UIAudio: AudioStreamPlayer

@export var settings_menu: PackedScene

var can_next: bool = false
var in_menu: bool = false

var hover_sounds = [UI_HOVER_01, UI_HOVER_02]
var click_sounds = [UI_CLICK_01, UI_CLICK_02]

const UI_CLICK_01 = preload("res://assets/audio/ui/UI_click_01.ogg")
const UI_CLICK_02 = preload("res://assets/audio/ui/UI_click_02.ogg")
const UI_HOVER_01 = preload("res://assets/audio/ui/UI_hover_01.ogg")
const UI_HOVER_02 = preload("res://assets/audio/ui/UI_hover_02.ogg")

const DOOR_OPENS_02 = preload("res://assets/audio/other/door_opens_02.ogg")

func _ready() -> void:
	if play_button:
		play_button.pressed.connect(play_pressed)
		play_button.mouse_entered.connect(play_sound.bind(hover_sounds))
	if quit_button:
		quit_button.pressed.connect(quit_pressed)
		quit_button.mouse_entered.connect(play_sound.bind(hover_sounds))
	if settings_button:
		settings_button.pressed.connect(settings_pressed)
		settings_button.mouse_entered.connect(play_sound.bind(hover_sounds))

	$TitleAnim.animation_finished.connect(func(_anim_name):
		can_next = true
	)
	set_camera()

func set_camera() -> void:
	var c = cameras.pick_random()
	if c:
		c.current = true

func _input(event: InputEvent) -> void:
	if can_next and event.is_pressed() and event is InputEventKey and !in_menu:
		$TitleAnim.play("display")
		can_next = false
		in_menu = true
		play_sound(DOOR_OPENS_02)
		$TitleUI/UIButtons/play.visible = true
		$TitleUI/UIButtons/settings.visible = true
		$TitleUI/UIButtons/quit.visible = true

func play_sound(sound) -> void:
	if not UIAudio:
		return

	if sound is Array:
		UIAudio.stream = sound.pick_random()
	else:
		UIAudio.stream = sound
	UIAudio.play()

func play_pressed() -> void:
	$TitleAnim.play("play")
	play_sound(click_sounds)
	await $TitleAnim.animation_finished
	Sceneloader.load_scene("res://scenes/game/game.tscn")

func settings_pressed() -> void:
	$TitleUI.visible = false
	if settings_menu:
		var c = settings_menu.instantiate()
		c.settings_exited.connect(func(): $TitleUI.visible = true)
		add_child(c)

func quit_pressed() -> void:
	play_sound(click_sounds)
	$TitleUI/UIButtons.visible = false
	$TitleUI/PATC2.visible = false
	$TitleUI/Top.visible = false
	$TitleUI/Panel.visible = false
	$TitleUI/creds.visible = false
	$ExCam.play("ExitGame")
	await $ExCam.animation_finished
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()
