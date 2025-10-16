extends Node3D

@export var switch_on: bool = false
@export var switch_id: int = 0

@export var on_angle: float = 41.2
@export var off_angle: float = -41.2

func _ready() -> void:
	switch_id = !switch_on
	interact()

func interact() -> void:
	switch_on = !switch_on
	Eventbus.switch_changed.emit(switch_id, switch_on)
	var t = get_tree().create_tween()
	match switch_on:
		true:
			t.tween_property($light_switch_single_01, "rotation_degrees:x", on_angle, 0.02)
		false:
			t.tween_property($light_switch_single_01, "rotation_degrees:x", off_angle, 0.02)

	await t.finished ; t.kill()
