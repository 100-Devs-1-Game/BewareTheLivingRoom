extends Camera3D

@export var sensitivity: float = 0.008
@export var max_angle: float = 0.05
@export var smooth_speed: float = 5.0

var target_rotation: Vector2 = Vector2.ZERO
var current_rotation: Vector2 = Vector2.ZERO
var base_rotation: Vector3 = Vector3.ZERO

func _ready() -> void:
	base_rotation = rotation

func _process(delta: float) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var mouse_pos = get_viewport().get_mouse_position()
	
	var normalized = Vector2((mouse_pos.x / viewport_size.x - 0.5) * 2.0, (mouse_pos.y / viewport_size.y - 0.5) * 2.0)
	
	target_rotation.x = clamp(-normalized.y * sensitivity, -max_angle, max_angle)
	target_rotation.y = clamp(-normalized.x * sensitivity, -max_angle, max_angle)
	
	current_rotation = current_rotation.lerp(target_rotation, delta * smooth_speed)
	
	rotation.x = base_rotation.x + current_rotation.x
	rotation.y = base_rotation.y + current_rotation.y
