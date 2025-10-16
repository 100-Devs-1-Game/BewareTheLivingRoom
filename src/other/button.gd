extends MeshInstance3D

enum ButtonState { RED, GREEN }
var state = ButtonState.RED

var rmat: StandardMaterial3D
var gmat: StandardMaterial3D

func _ready() -> void:
	rmat.albedo_color = Color.RED
	gmat.albedo_color = Color.GREEN
	toggle_state()

func toggle_state() -> void:
	if state == ButtonState.RED:
		state = ButtonState.GREEN
	else:
		state = ButtonState.RED
	update_color()

func update_color() -> void:
	if state == ButtonState.RED:
		set_surface_override_material(0, rmat)
	else:
		set_surface_override_material(0, gmat)
