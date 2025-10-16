extends Node3D

const SLAM_SOUNDS = [
	preload("res://assets/audio/other/slam_01.ogg"),
	preload("res://assets/audio/other/slam_02.ogg"),
	preload("res://assets/audio/other/slam_03.ogg"),
	preload("res://assets/audio/other/slam_04.ogg")
]

const CUE_SOUNDS = [
	preload("res://assets/audio/creepy_cue_audio_01.ogg"),
	preload("res://assets/audio/creepy_cue_audio_02.ogg"),
	preload("res://assets/audio/creepy_cue_audio_03.ogg")
]

const SCREAM_SOUNDS = [
	preload("res://assets/audio/spooky/scream_01.ogg"),
	preload("res://assets/audio/spooky/scream_03.ogg")
]

@export var peek_height: float = 2.0
@export var peek_duration: float = 1.0
@export var wait_before_peek: float = 7.0
@export var min_time: float = 40.0
@export var max_time: float = 130.0

@export var look_targets: Array[Node3D] = []
@export var look_duration: float = 1.0
@export var pause_time: float = 1.0
@export var spotlight_node: Node3D
@export var audio_global: AudioStreamPlayer
@export var animation_player: AnimationPlayer

@export var slam_to_peek_duration: float = 0.08
@export var shake_duration: float = 0.7
@export var shake_interval: float = 0.03
@export var shake_amplitude_xz: float = 0.35

@export var game_ref: Node3D

var original_position: Vector3
var spotlight_original_rotation: Vector3 = Vector3(-90.0, 0.0, 0.0)

var kill_player: bool = false
var searching: bool = false

var _bed_task_running: bool = false
var _has_jumped: bool = false

var _peek_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	original_position = global_position
	if spotlight_node:
		spotlight_node.visible = false
	_schedule_next_peek()

func _process(_delta: float) -> void:
	if searching and not _bed_task_running and not _has_jumped:
		_start_bed_check()

func _start_bed_check() -> void:
	_bed_task_running = true
	while searching and not _has_jumped:
		await get_tree().create_timer(0.5).timeout
		if not game_ref.player_in_bed():
			jump_death()
			break
	_bed_task_running = false

func _schedule_next_peek() -> void:
	var wait_time: float = randf_range(min_time, max_time)
	await get_tree().create_timer(wait_time).timeout
	Eventbus.monster_appearing.emit()
	await get_tree().create_timer(wait_before_peek).timeout
	await _peek_down()
	await _look_around()
	await _retreat()

func _peek_down() -> void:
	if game_ref.player_in_kitchen():
		jump_death()
	var target_pos: Vector3 = original_position
	target_pos.y -= peek_height
	_peek_position = target_pos
	var tween = create_tween()
	if is_inside_tree():
		tween.tween_property(self, "global_position", target_pos, peek_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	searching = true
	if game_ref.check_room_changed():
		kill_player = true

func _look_around() -> void:
	if look_targets.is_empty() or not spotlight_node:
		return
	spotlight_node.visible = true
	for target in look_targets:
		await _spotlight_look_at(target.global_position, look_duration * 0.5)
		await _spotlight_inspect(target.global_position, 0.5, 3)
		await get_tree().create_timer(pause_time).timeout

func _spotlight_look_at(target_pos: Vector3, duration: float) -> void:
	var start_rot: Vector3 = spotlight_node.global_rotation
	spotlight_node.look_at(target_pos, Vector3.UP)
	var end_rot: Vector3 = spotlight_node.global_rotation
	spotlight_node.global_rotation = start_rot
	var tween = create_tween()
	tween.tween_property(spotlight_node, "global_rotation", end_rot, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished

func _spotlight_inspect(target_pos: Vector3, duration_per_move: float, steps: int) -> void:
	for i in range(steps):
		var offset: Vector3 = Vector3(randf_range(-0.2, 0.2), randf_range(-0.1, 0.1), randf_range(-0.2, 0.2))
		var inspect_pos: Vector3 = target_pos + offset
		await _spotlight_look_at(inspect_pos, duration_per_move)

func _retreat() -> void:
	_reset_spotlight()
	var tween = create_tween()
	tween.tween_property(self, "global_position", original_position, peek_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	play_sound(CUE_SOUNDS)
	if audio_global:
		await audio_global.finished
	if not kill_player:
		searching = false
		_schedule_next_peek()
		Eventbus.monster_left.emit()
	else:
		searching = false
		slam_down()

func _reset_spotlight() -> void:
	if spotlight_node:
		spotlight_node.visible = false
		spotlight_node.global_rotation = spotlight_original_rotation

func play_sound(sound) -> void:
	if not audio_global:
		return
	if sound is Array:
		audio_global.stream = sound.pick_random()
	else:
		audio_global.stream = sound
	audio_global.play()

func jump_death() -> void:
	if _has_jumped:
		return
	_has_jumped = true
	searching = false
	Sceneloader.load_scene("res://other/jumpscare.tscn")

func slam_down() -> void:

	Eventbus.killing_player.emit()

	var peek_pos = _peek_position
	if peek_pos == Vector3.ZERO:
		peek_pos = original_position - Vector3(0, peek_height, 0)

	var to_peek = create_tween()
	to_peek.tween_property(self, "global_position", peek_pos, slam_to_peek_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	await to_peek.finished
	play_sound(SCREAM_SOUNDS)
	$OmniLight3D.visible = true
	Eventbus.camera_move_to.emit(game_ref.get_active_camera_position(), global_position, null)

	var shake_time: float = 0.0
	var base_pos: Vector3 = global_position
	while shake_time < shake_duration:
		var offset_x = randf_range(-shake_amplitude_xz, shake_amplitude_xz)
		var offset_z = randf_range(-shake_amplitude_xz, shake_amplitude_xz)
		global_position = Vector3(base_pos.x + offset_x, base_pos.y, base_pos.z + offset_z)
		await get_tree().create_timer(shake_interval).timeout
		shake_time += shake_interval

	if animation_player:
		animation_player.play("slam")
	await get_tree().create_timer(0.2).timeout

	play_sound(SLAM_SOUNDS)
	Eventbus.player_killed.emit()
