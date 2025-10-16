extends Node3D

@export var num_stages: int = 2
@export var num_knobs: int = 6
@export var emit_id: int = 0

@export var stage_lights: Array[OmniLight3D] = []

var stages: Array = []
var current_stage: int = 0
var _current_step: int = 0

func _ready() -> void:
	add_to_group("oven")
	_generate_stages()
	print("Stage sequences:", stages)
	_update_stage_lights()
	
	for knob in get_tree().get_nodes_in_group("oven_knob"):
		knob.connect("state_changed", Callable(self, "knob_changed"))

func interact() -> void:
	Eventbus.announce_tooltip.emit("Tip: Click the oven knobs in the correct sequence twice to complete.")

func _generate_stages() -> void:
	stages.clear()
	var knobs := []
	for i in range(num_knobs):
		knobs.append(i)
	for x in range(num_stages):
		var stage_knobs = knobs.duplicate()
		stage_knobs.shuffle()
		stages.append(stage_knobs)
	current_stage = 0
	_current_step = 0

func knob_changed(knob) -> void:
	var current_order = stages[current_stage]
	
	if knob.knob_id == current_order[_current_step]:
		_current_step += 1
		print("Stage:", current_stage + 1, "Step:", _current_step)
		if _current_step >= current_order.size():
			_light_up_stage(current_stage)
			current_stage += 1
			_current_step = 0
			if current_stage == num_stages:
				_on_oven_ready()
			else:
				print("Stage", current_stage + 1, "complete, Next stage activated.")
	else:
		reset_knobs()

func reset_knobs() -> void:
	current_stage = 0
	_current_step = 0
	for knob in get_tree().get_nodes_in_group("oven_knob"):
		knob.is_on = false
		knob.target_rot_x = 0.0
		knob.changing = true
	_update_stage_lights()
	print("Wrong one reset to Stage 1")

func _light_up_stage(stage_index: int) -> void:
	if stage_index < stage_lights.size():
		var light = stage_lights[stage_index]
		if light:
			light.light_color = Color(0.0, 1.0, 0.0)

func _update_stage_lights() -> void:
	for i in range(stage_lights.size()):
		var light = stage_lights[i]
		if light:
			light.light_color = Color(1.0, 0.0, 0.0)

func _on_oven_ready() -> void:
	Eventbus.announced_dialogue.emit("What kind of oven is this.")
	Eventbus.unlock_called
	$oven_inside_light.visible = true
	$h.visible = false
