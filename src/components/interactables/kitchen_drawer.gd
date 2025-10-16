extends Node3D

@export var drawer_id: int = 0
@export var locked: bool = true
@export var slide_distance: float = 1.0
@export var slide_duration: float = 0.3
@export var jiggle_enabled: bool = true
@export var jiggle_distance: float = 0.05
@export var jiggle_duration: float = 0.1
@export var swap_axis: bool = false
@export var drawer_part: Node3D

@export var audio_stream: AudioStreamPlayer3D

const DRAWER_OPENS_01 = preload("res://assets/audio/other/drawer_opens_01.ogg")
const DRAWER_OPENS_02 = preload("res://assets/audio/other/drawer_opens_02.ogg")
const DRAWER_OPENS_03 = preload("res://assets/audio/other/drawer_opens_03.ogg")

const DRAWER_CLOSES_01 = preload("res://assets/audio/other/drawer_closes_01.ogg")
const DRAWER_CLOSES_02 = preload("res://assets/audio/other/drawer_closes_02.ogg")
const DRAWER_CLOSES_03 = preload("res://assets/audio/other/drawer_closes_03.ogg")

const DOOR_RATTLES_01 = preload("res://assets/audio/other/door_rattles_01.ogg")
const DOOR_RATTLES_02 = preload("res://assets/audio/other/door_rattles_02.ogg")
const DOOR_RATTLES_03 = preload("res://assets/audio/other/door_rattles_03.ogg")

var drawer_open = [DRAWER_OPENS_01, DRAWER_OPENS_02, DRAWER_OPENS_03]
var drawer_close = [DRAWER_CLOSES_01, DRAWER_CLOSES_02, DRAWER_CLOSES_03]
var drawer_locked = [DOOR_RATTLES_01, DOOR_RATTLES_02, DOOR_RATTLES_03]

var is_open: bool = false
var closed_position: Vector3

func _ready() -> void:
	if not drawer_part:
		drawer_part = self
	closed_position = drawer_part.global_position
	Eventbus.unlock_called.connect(func(id): if id == drawer_id: locked = false)

func play_audio(audio: Array) ->  void:
	if audio_stream:
		audio_stream.set_stream(audio.pick_random()) ; audio_stream.play()

func interact() -> void:
	if locked:
		play_audio(drawer_locked)
		if jiggle_enabled:
			var dir_vec3 = Vector3(slide_distance * 0.1, 0, 0)
			if swap_axis:
				dir_vec3 = Vector3(0, 0, slide_distance * 0.1)
			var t = get_tree().create_tween()
			t.tween_property(drawer_part, "global_position", closed_position + dir_vec3, jiggle_duration)
			t.tween_property(drawer_part, "global_position", closed_position - dir_vec3, jiggle_duration)
			t.tween_property(drawer_part, "global_position", closed_position, jiggle_duration)
			await t.finished
			t.kill()
		Eventbus.announced_dialogue.emit("This drawer is locked.")
		return

	var target_pos: Vector3
	if is_open:
		target_pos = closed_position
		is_open = false
		play_audio(drawer_open)
	else:
		if !swap_axis:
			target_pos = closed_position + Vector3(slide_distance, 0, 0)
		else:
			target_pos = closed_position + Vector3(0, 0, slide_distance)
		is_open = true
		play_audio(drawer_close)

	var t2 = get_tree().create_tween()
	t2.tween_property(drawer_part, "global_position", target_pos, slide_duration)
	await t2.finished
	t2.kill()

	if is_open:
		print("Drawer opened!")
	else:
		print("Drawer closed!")

func _on_interaction_handler_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		interact()
