extends Node3D

@export var door_id: int = 0
@export var locked: bool = true
@export var swing_duration: float = 0.5
@export var open_angle: float = 90.0
@export var jiggle_angle: float = 1.0
@export var jiggle_duration: float = 0.1
@export var jiggle_enabled: bool = true
@export var door_part: Node3D

@export var audio_stream: AudioStreamPlayer3D

var is_open: bool = false
var closed_rotation_y: float

#Door open
const DOOR_OPENS_01 = preload("res://assets/audio/other/door_opens_01.ogg")
const DOOR_OPENS_02 = preload("res://assets/audio/other/door_opens_02.ogg")
const DOOR_OPENS_03 = preload("res://assets/audio/other/door_opens_03.ogg")

#Door lock or cabinet lock
const DOOR_RATTLES_01 = preload("res://assets/audio/other/door_rattles_01.ogg")
const DOOR_RATTLES_02 = preload("res://assets/audio/other/door_rattles_02.ogg")
const DOOR_RATTLES_03 = preload("res://assets/audio/other/door_rattles_03.ogg")

#Door close
const DOOR_CLOSES_01 = preload("res://assets/audio/other/door_closes_01.ogg")
const DOOR_CLOSES_02 = preload("res://assets/audio/other/door_closes_02.ogg")
const DOOR_CLOSES_03 = preload("res://assets/audio/other/door_closes_03.ogg")

#Cabinet close
const WOOD_HIT_01 = preload("res://assets/audio/other/wood_hit_01.ogg")
const WOOD_HIT_02 = preload("res://assets/audio/other/wood_hit_02.ogg")
const WOOD_HIT_03 = preload("res://assets/audio/other/wood_hit_03.ogg")

var open_sounds = []
var close_sounds = []
var rattle_sounds = [DOOR_RATTLES_01, DOOR_RATTLES_02, DOOR_RATTLES_03]

@export_enum("Door", "Cabinet", "Drawer") var sound_set = "Door"

func _ready() -> void:
	if not door_part:
		door_part = self
	closed_rotation_y = door_part.rotation_degrees.y
	Eventbus.unlock_called.connect(on_unlock_called)
	Eventbus.lock_called.connect(func(id): if id == door_id: locked = true)
	sync_sounds(sound_set)

func sync_sounds(sounds) -> void:
	match sounds:
		"Door":
			open_sounds = [DOOR_OPENS_01, DOOR_OPENS_02, DOOR_OPENS_03]
			close_sounds = [DOOR_CLOSES_01, DOOR_CLOSES_02, DOOR_CLOSES_03]
		"Cabinet":
			open_sounds = [DOOR_OPENS_01, DOOR_OPENS_02, DOOR_OPENS_03]
			close_sounds = [WOOD_HIT_01, WOOD_HIT_02, WOOD_HIT_03]

func interact() -> void:
	if locked:
		Eventbus.announced_dialogue.emit("This door is locked.")
		play_audio(rattle_sounds)
		if jiggle_enabled:
			var t = get_tree().create_tween()
			t.tween_property(door_part, "rotation_degrees:y", closed_rotation_y + jiggle_angle, jiggle_duration)
			t.tween_property(door_part, "rotation_degrees:y", closed_rotation_y - jiggle_angle, jiggle_duration)
			t.tween_property(door_part, "rotation_degrees:y", closed_rotation_y + jiggle_angle, jiggle_duration)
			t.tween_property(door_part, "rotation_degrees:y", closed_rotation_y, jiggle_duration)
			await t.finished
			t.kill()
		return
	
	var target_angle: float
	if is_open:
		target_angle = closed_rotation_y
		is_open = false
	else:
		target_angle = closed_rotation_y + open_angle
		is_open = true
		play_audio(open_sounds)
	
	var t2 = get_tree().create_tween()
	t2.tween_property(door_part, "rotation_degrees:y", target_angle, swing_duration)
	await t2.finished
	t2.kill()
	
	if is_open:
		print("Door opened!")
	else:
		print("Door closed!")
		play_audio(close_sounds)


func play_audio(audio: Array) ->  void: 
	if audio_stream:
		audio_stream.set_stream(audio.pick_random()) ; audio_stream.play()


func on_unlock_called(id: int) -> void:
	if id == door_id:
		locked = false
		print("Door unlocked!")


func _on_interaction_handler_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		print("clicked: ", self.name)
		interact()
