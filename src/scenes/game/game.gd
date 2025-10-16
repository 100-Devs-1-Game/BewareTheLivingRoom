extends Node3D

var game_running: bool = true

@export var IntroAnim: AnimationPlayer
@export var IntroCam: Camera3D
@export var important_objects: Array[Node3D]
@export var debug_mode: bool = false
@export var exit_door: Node


@export var pos_threshold: float = 0.02
@export var rot_threshold: float = 0.02
@export var scale_threshold: float = 0.02

var baseline_transforms: Array[Transform3D] = []

@onready var spotlights = $"Camera & Lights/spotlights"
@onready var debug_ui = $"debug_ui"
@onready var debug_label = debug_ui.get_node("debug_text") as Label

var player_in_room: bool = true
var bed_active: bool = false

func _ready() -> void:
	Eventbus.escaped_house.connect(end_game)
	Eventbus.monster_appearing.connect(power.bind(false))
	Eventbus.monster_left.connect(power.bind(true))
	Eventbus.bed_used.connect(func(state): bed_active = state)
	Eventbus.player_killed.connect(func(): 
		$Other/ColorRect.visible = true
		await get_tree().create_timer(1.0).timeout
		Sceneloader.load_scene("res://other/game_over.tscn")
		)
	Eventbus.unlock_called.connect(func(id): if id == 10 and !exit_door.locked: end_game())

	$RainSound.finished.connect(func(): $RainSound.play())

	for obj in important_objects:
		baseline_transforms.append(obj.global_transform)

	debug_ui.visible = debug_mode
	debug_label.visible = debug_mode

	await get_tree().create_timer(1.2).timeout
	play_intro()

func end_game() -> void:
	Sceneloader.call_deferred("load_scene", "res://ui/escaped screen/end_screen.tscn")

func play_intro() -> void:
	if IntroCam and IntroAnim:
		IntroAnim.play("Eyes")
		await IntroAnim.animation_finished
		IntroAnim.play("Up")
		await IntroAnim.animation_finished
		IntroCam.queue_free()
		Eventbus.game_started.emit()

func power(state: bool) -> void:
	var flicker_times = randi_range(5, 9)
	for i in range(flicker_times):
		var flick_state = not state if i % 2 == 0 else state
		spotlights.visible = flick_state
		Eventbus.power_toggled.emit(flick_state)
		await get_tree().create_timer(randf_range(0.05, 0.15)).timeout

	spotlights.visible = state
	Eventbus.power_toggled.emit(state)

func _process(_delta):
	if debug_mode:
		check_room_changed()

func player_in_kitchen() -> bool:
	return !player_in_room

func player_in_bed() -> bool:
	return bed_active

func get_active_camera_position() -> Vector3:
	return get_viewport().get_camera_3d().global_position

const TAU = PI * 2.0

func _angle_diff(a: float, b: float) -> float:
	var diff = a - b
	while diff > PI:
		diff -= TAU
	while diff < -PI:
		diff += TAU
	return abs(diff)

func _vec3_angle_diff(a: Vector3, b: Vector3) -> Vector3:
	return Vector3(_angle_diff(a.x, b.x), _angle_diff(a.y, b.y), _angle_diff(a.z, b.z))

func check_room_changed() -> bool:
	var changed = false
	var debug_text_content = ""
	for i in range(important_objects.size()):
		var obj = important_objects[i]
		var base = baseline_transforms[i]

		var pos_dist = obj.global_position.distance_to(base.origin)
		var obj_rot = obj.global_transform.basis.get_euler()
		var base_rot = base.basis.get_euler()
		var rot_diff_v = _vec3_angle_diff(obj_rot, base_rot)
		var rot_diff_max = max(rot_diff_v.x, rot_diff_v.y, rot_diff_v.z)
		var obj_scale = obj.global_transform.basis.get_scale()
		var base_scale = base.basis.get_scale()
		var scale_diff_v = Vector3(abs(obj_scale.x - base_scale.x), abs(obj_scale.y - base_scale.y), abs(obj_scale.z - base_scale.z))
		var scale_diff_max = max(scale_diff_v.x, scale_diff_v.y, scale_diff_v.z)

		if pos_dist > pos_threshold or rot_diff_max > rot_threshold or scale_diff_max > scale_threshold:
			changed = true
			if debug_mode:
				debug_text_content += obj.name + "\n"

	debug_ui.visible = debug_mode
	debug_label.visible = debug_mode
	if debug_mode:
		debug_label.text = debug_text_content
	elif debug_label.visible:
		debug_label.text = ""
		debug_label.visible = false

	return changed

func _on_outside_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_room = false
		print("Player left room")

func _on_outside_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_in_room = true
		print("Player entered room")
