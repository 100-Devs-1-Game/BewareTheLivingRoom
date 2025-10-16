extends RigidBody3D

@export var emit_unlock_id: int = 0
@export var locked: bool = true
@export var random_code: bool = true
@export var custom_code: String = ""

@export var interactor: InteractionHandler

var current_code: Array[int] = [0,0,0,0,0]
var correct_code: Array[int] = [0,0,0,0,0]
var rotation_targets: Array[float] = [0,0,0,0,0]

func _ready() -> void:
	if custom_code != "":
		var s = custom_code
		while s.length() < 5:
			s = "0" + s
		correct_code.clear()
		for c in s:
			correct_code.append(int(c))
		current_code = [0,0,0,0,0]
		rotation_targets = [0,0,0,0,0]
		$FirstDigit.rotation_degrees.x = 0
		$SecondDigit.rotation_degrees.x = 0
		$ThirdDigit.rotation_degrees.x = 0
		$FourthDigit.rotation_degrees.x = 0
		$FifthDigit.rotation_degrees.x = 0
		print("Custom code set: ", correct_code)
	elif random_code:
		generate_code()

func generate_code() -> void:
	var rand_num = randi() % 100000
	var s = str(rand_num)
	while s.length() < 5:
		s = "0" + s
	
	correct_code.clear()
	for c in s:
		correct_code.append(int(c))
	
	current_code = [0,0,0,0,0]
	rotation_targets = [0,0,0,0,0]
	$FirstDigit.rotation_degrees.x = 0
	$SecondDigit.rotation_degrees.x = 0
	$ThirdDigit.rotation_degrees.x = 0
	$FourthDigit.rotation_degrees.x = 0
	$FifthDigit.rotation_degrees.x = 0

	print("Generated code: ", correct_code)

func get_code() -> Array[int]:
	return correct_code

func set_code(code: int) -> void:
	var s = str(code)
	while s.length() < 5:
		s = "0" + s
	current_code.clear()
	for c in s:
		current_code.append(int(c))

func check_code() -> void:
	if current_code == correct_code:
		print("Code correct")
		Eventbus.unlock_called.emit(emit_unlock_id)
		freeze = false
		if interactor:
			Eventbus.force_exit_observe.emit()

func _rotate_digit(digit_node: Node3D, index: int) -> void:
	current_code[index] = (current_code[index] + 1) % 10
	rotation_targets[index] += 36.0
	
	var tween = create_tween()
	tween.tween_property(digit_node, "rotation_degrees:x", rotation_targets[index], 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	check_code()

func first_clicker(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_mask == 0:
		_rotate_digit($FirstDigit, 0)

func second_clicker(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_mask == 0:
		_rotate_digit($SecondDigit, 1)

func third_clicker(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_mask == 0:
		_rotate_digit($ThirdDigit, 2)

func fourth_clicker(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_mask == 0:
		_rotate_digit($FourthDigit, 3)

func fifth_clicker(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_mask == 0:
		_rotate_digit($FifthDigit, 4)
