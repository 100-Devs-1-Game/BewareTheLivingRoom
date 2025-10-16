extends Node3D

@export var locked: bool = true
@export var enabled: bool = true
@export var unlock_id: int = 0

func _ready() -> void:
	Eventbus.unlock_called.connect(check_requirements)

func check_requirements(id: int) -> void:
	if unlock_id == id and locked:
		locked = false
		print("Door unlocked")

func interact() -> void:
	if enabled:
		if !locked:
			print("Door interacted with")
			Eventbus.escaped_house.emit()
		else:
			print("This door is locked")
