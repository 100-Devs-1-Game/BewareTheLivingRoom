extends CSGBox3D

@export var enabled: bool = true
@export var color_id: String = ""
var selected_scale = Vector3.ONE * 1.2
var is_selected = false
signal clicked(block)

func _ready():
	if !enabled:
		$Area3D/CollisionShape3D.disabled = true
	var mat = StandardMaterial3D.new()
	match color_id.to_upper():
		"WHITE": mat.albedo_color = Color(1,1,1)
		"RED": mat.albedo_color = Color(1,0,0)
		"ORANGE": mat.albedo_color = Color(1,0.5,0)
		"YELLOW": mat.albedo_color = Color(1,1,0)
		"GREEN": mat.albedo_color = Color(0,1,0)
		"BLUE": mat.albedo_color = Color(0,0,1)
		"VIOLET": mat.albedo_color = Color(0.5,0,1)
		_: mat.albedo_color = Color(1,1,1)
	material_override = mat

func highlight(on: bool):
	if on:
		scale = selected_scale
		is_selected = true
	else:
		scale = Vector3.ONE
		is_selected = false


func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if enabled:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			emit_signal("clicked", event, self)
