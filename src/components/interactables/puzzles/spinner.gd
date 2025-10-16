extends CSGCylinder3D

@export var twister_parent: Node
@export var box_spin: CSGBox3D
@export var target_step: int = 0
@export var rotate_increment: float = 90.0

var steps: int = 4
var _current_step: int = 0
var is_correct: bool = false

func _ready() -> void:
	if not box_spin:
		push_error("box_spin not assigned!")
		return
	_current_step = 0
	_apply_step_rotation_immediately()
	check_correct_rotation()

func interact() -> void:
	_current_step = (_current_step + 1) % steps
	_apply_step_rotation_immediately()
	check_correct_rotation()

func _apply_step_rotation_immediately() -> void:
	box_spin.rotation_degrees.y = float(_current_step) * rotate_increment
	print("cur rot: ", box_spin.rotation_degrees.y, " need rot: ", target_step)

func check_correct_rotation() -> void:
	if float(_current_step) * rotate_increment == float(target_step):
		if not is_correct:
			is_correct = true
			if twister_parent and twister_parent.has_method("add_correct"):
				twister_parent.call("add_correct")
			print("this one is correct")
	else:
		if is_correct:
			is_correct = false
			if twister_parent and twister_parent.has_method("remove_correct"):
				twister_parent.call("remove_correct")
			print("this one is incorrect")

func _on_twist_area_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		interact()
