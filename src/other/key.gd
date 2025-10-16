extends Node3D

@export var interactor: InteractionHandler

func _on_interaction_handler_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_mask == 1:
			interactor.send_signal()
			interactor._do_interact()
			Eventbus.announced_dialogue.emit("Found a key to the front door.")
