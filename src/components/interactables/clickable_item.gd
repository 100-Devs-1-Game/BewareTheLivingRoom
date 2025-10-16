extends CSGBox3D

@export var emit_signal_id: int = 0
@export var clickable_area: Area3D

func _ready() -> void:
	if clickable_area:
		clickable_area.input_event.connect(Callable(self, "on_area_clicked"))

func on_area_clicked(_camera: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		Eventbus.unlock_called.emit(emit_signal_id)
		print("Signal fired")
		Eventbus.announced_dialogue.emit("I found a yellow block, I wonder what it's for.")
		call_deferred("queue_free")
