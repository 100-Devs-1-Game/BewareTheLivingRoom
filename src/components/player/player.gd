extends CharacterBody3D

@export var move_speed: float = 5.0
@export var mouse_sensitivity: float = 0.2

@export var ray: RayCast3D
@export var camera_pivot: Node3D

@export var camera_breathe_strength: float = 0.05
@export var camera_breathe_speed: float = 1.0
@export var camera_bob_strength: float = 0.03
@export var camera_bob_speed: float = 7.0
@export var footstep_bob_speed: float = 10.0

@export var UI: Control
@export var audio_player: AudioStreamPlayer3D

var camera: Camera3D
var yaw: float = 180.0
var pitch: float = 0.0
var breathe_time: float = 0.0

var can_control: bool = false
var paused: bool = false

var _last_observed: InteractionHandler = null

var _camera_offset: Vector3 = Vector3.ZERO
var _camera_focus_active: bool = false
var _returning: bool = false

var _temp_camera: Camera3D = null
var _main_camera: Camera3D = null
var _observe_target: Vector3 = Vector3.ZERO
var step_sounds = [FOOTSTEPS_01, FOOTSTEPS_02, FOOTSTEPS_03]

var _bob_phase: float = 0.0
var _step_phase: float = 0.0
var _last_step_value: float = 0.0

const DEBUG = preload("res://other/debug.tscn")
const SHADED_CAM = preload("res://other/shaded_cam.tscn")

const FOOTSTEPS_01 = preload("res://assets/audio/steps/footsteps_01.ogg")
const FOOTSTEPS_02 = preload("res://assets/audio/steps/footsteps_02.ogg")
const FOOTSTEPS_03 = preload("res://assets/audio/steps/footsteps_03.ogg")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera = $CamPiv/Camera3D
	Eventbus.escaped_house.connect(disable_player)
	Eventbus.game_started.connect(enable_player)
	Eventbus.camera_move_to.connect(observe)
	Eventbus.interactable_unobserved.connect(_on_interactable_unobserved)
	Eventbus.force_exit_observe.connect(return_camera)

	add_to_group("player")

func test(from: Vector3, to: Vector3) -> void:
	var world = get_tree().get_first_node_in_group("world")
	if not world:
		push_warning("World group not found!")
		return
	var from_instance = DEBUG.instantiate()
	from_instance.global_position = from
	world.add_child(from_instance)
	var to_instance = DEBUG.instantiate()
	to_instance.global_position = to
	world.add_child(to_instance)

func _input(event: InputEvent) -> void:
	if _camera_focus_active and not _returning:
		if event is InputEventKey and event.pressed:
			return_camera()
			return
	if can_control and not _camera_focus_active and event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -80, 80)
		rotation_degrees.y = yaw
		camera.rotation_degrees.x = pitch
	if event is InputEventKey and event.pressed:
		if event.is_action_pressed("pause"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().quit()

func _process(delta: float) -> void:
	if _temp_camera:
		_temp_camera.look_at(_observe_target, Vector3.UP)
	if not can_control:
		return
	breathe_time += delta * camera_breathe_speed
	var breathe_offset = Vector3(
		sin(breathe_time) * camera_breathe_strength,
		cos(breathe_time * 0.7) * camera_breathe_strength,
		0
	)
	var move_dir = Vector3.ZERO
	if Input.is_action_pressed("forward") or Input.is_action_pressed("back") or Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		move_dir = velocity
	_bob_phase += delta * camera_bob_speed
	var bob_offset = Vector3(0, sin(_bob_phase) * camera_bob_strength, 0)
	_step_phase += delta * footstep_bob_speed
	var step_value = sin(_step_phase)
	if move_dir.length() > 0.01 and _last_step_value <= 0.0 and step_value > 0.0:
		play_sound(step_sounds)
	_last_step_value = step_value
	camera_pivot.position = breathe_offset + bob_offset + _camera_offset


func _physics_process(_delta: float) -> void:
	if not can_control or _camera_focus_active:
		return
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("forward"): input_dir.z -= 1
	if Input.is_action_pressed("back"): input_dir.z += 1
	if Input.is_action_pressed("left"): input_dir.x -= 1
	if Input.is_action_pressed("right"): input_dir.x += 1
	input_dir = input_dir.normalized()
	var direction = (transform.basis * input_dir).normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	move_and_slide()
	if ray.is_colliding():
		var col = ray.get_collider()
		if col is InteractionHandler:
			if col != _last_observed:
				if _last_observed:
					Eventbus.interactable_unobserved.emit(_last_observed)
				_last_observed = col
				Eventbus.interactable_observed.emit(col)
			if Input.is_action_just_released("interact"):
				col.interact()
		else:
			if _last_observed:
				Eventbus.interactable_unobserved.emit(_last_observed)
				_last_observed = null
	else:
		if _last_observed:
			Eventbus.interactable_unobserved.emit(_last_observed)
			_last_observed = null

func observe(from: Vector3, to: Vector3, observed_obj: Node3D, duration: float = 0.3) -> void:
	disable_player()
	if _temp_camera:
		_temp_camera.queue_free()
	_main_camera = camera
	_temp_camera = SHADED_CAM.instantiate()
	add_child(_temp_camera)
	_temp_camera.current = true
	_temp_camera.global_position = _main_camera.global_position
	_observe_target = to
	_camera_focus_active = true
	_last_observed = observed_obj
	var tween = create_tween()
	tween.tween_property(_temp_camera, "global_position", from, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.play()

func return_camera(duration: float = 0.3) -> void:
	if not _temp_camera or _returning:
		return
	Eventbus.exited_observe.emit()
	_returning = true
	var end_transform = _main_camera.global_transform
	var tween = create_tween()
	tween.tween_property(_temp_camera, "global_transform", end_transform, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func():
		_main_camera.current = true
		_temp_camera.queue_free()
		_temp_camera = null
		_camera_focus_active = false
		enable_player()
		_returning = false
	)
	tween.play()

func _on_interactable_unobserved(obj: Node3D) -> void:
	if obj == _last_observed:
		_last_observed = null

func play_sound(sounds: Array) -> void:
	if audio_player:
		audio_player.set_stream(sounds.pick_random())
		audio_player.play()

func disable_player() -> void:
	can_control = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if UI and UI.has_method("toggle_crosshair"):
		UI.toggle_crosshair(false)

func enable_player() -> void:
	can_control = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if UI and UI.has_method("toggle_crosshair"):
		UI.toggle_crosshair(true)
