extends MeshInstance3D

signal state_changed(new_state: bool)

@export var knob_id: int = 0

var target_rot_x: float = 0.0
var changing: bool = false
var cooldown: float = 0.3
var timer: float = 0.0
var is_on: bool = false

func _ready() -> void:
	add_to_group("oven_knob")
	is_on = false
	target_rot_x = rotation.x

func _process(delta: float) -> void:
	if changing:
		rotation.x = rotation.x + (target_rot_x - rotation.x) * 9.0 * delta
		if abs(rotation.x - target_rot_x) < 0.01:
			rotation.x = target_rot_x
			changing = false
			timer = cooldown
	elif timer > 0.0:
		timer -= delta

func _on_interaction_handler_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not changing and timer <= 0.0:
			if can_interact():
				change_rotation()

func can_interact() -> bool:
	for oven in get_tree().get_nodes_in_group("oven"):
		if oven.has_method("can_turn_knob"):
			if not oven.can_turn_knob(knob_id):
				return false
	return true

func change_rotation() -> void:
	is_on = !is_on
	target_rot_x = deg_to_rad(90.0) if is_on else 0.0
	changing = true
	emit_signal("state_changed", self)
