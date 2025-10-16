extends Area3D
class_name InteractionHandler

@export var parent: Node3D
## Removes the parent when interacting with an item
@export var delete_on_interact: bool = false
## Disables the item/area when interacting with an item
@export var disable_on_interact: bool = false
## When observe is enabled, disable the area until exiting observe
@export var disable_collision_on_observe: bool = false
## Emits a signal with a given value on interacting
@export var emit_signal_on_interact: bool = false
## Signal id for if emit_signal_on_interact is true, uses an int
@export var emit_signal_id: int = 0
## Time between being able to interact with this area or item
@export var interaction_cooldown: float = 1.0

## Creates a new camera and smoothly moves it to a certain position
@export var observe_camera: bool = false
## Enables mouse clicking on this area if can_click is true
@export var click_to_interact: bool = false
## Calls a function upon exiting observe if enabled, uses function_name as the function name
@export var call_func_on_unobserve: bool
## The name that the interactor will search for and call if call_func_on_unobserve is true
@export var function_name: String = "uninteract"
## If enabled, will automatically interact with the item upon focusing
@export var interact_on_focus: bool = false
## The position the observing camera will move to
@export var camera_from: Marker3D
## The position the observing camera will look at
@export var camera_to: Marker3D

## Child handlers for the Interactor to interact with, helpful for enabling can_click on other areas.
@export var child_handlers: Array[InteractionHandler] = []

var _can_interact: bool = true
var _can_click: bool = false
var _observing: bool = false

@export var collision: CollisionShape3D

func _ready() -> void:
	if not parent:
		parent = get_parent() as Node3D
		if not parent:
			push_warning("InteractionHandler has no parent!")
	Eventbus.interactable_unobserved.connect(_on_unobserved)
	Eventbus.exited_observe.connect(renable_collisions)

	if collision == null:
		if get_child_count() > 0:
			if get_child(0) is CollisionShape3D:
				collision = get_child(0)
			else:
				push_warning("Could not find CollisionShape")

 
func renable_collisions() -> void:
	if disable_collision_on_observe and collision:
		if collision.disabled == true:
			collision.disabled = false


func interact() -> void:
	if not _can_interact:
		return
	_can_interact = false

	if observe_camera and camera_from and camera_to:
		_set_observing(true)
		Eventbus.camera_move_to.emit(camera_from.global_position, camera_to.global_position, self)
		Eventbus.interactable_observed.emit(self)
		if interact_on_focus:
			_do_interact()
	elif click_to_interact:
		_set_can_click(true)
	else:
		_do_interact()

	await get_tree().create_timer(interaction_cooldown).timeout
	_can_interact = true

## Sends the signal set on emit_signal_id variable
func send_signal() -> void:
	Eventbus.unlock_called.emit(emit_signal_id)


func _do_interact() -> void:
	var target = parent if parent else self
	if target and target.has_method("interact"):
		target.interact()
	if emit_signal_on_interact:
		Eventbus.unlock_called.emit(emit_signal_id)
	if disable_on_interact and target:
		target.set_physics_process(false)
		target.set_process(false)
	if delete_on_interact and target:
		target.queue_free()


func _on_input_event(_camera: Node, event: InputEvent, _pos: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and _can_click and _observing:
		_do_interact()


func _on_unobserved(obj: Node3D) -> void:
	if obj == self:
		if call_func_on_unobserve:
			if parent:
				if parent.has_method(function_name):
					parent.call(function_name)
				else:
					push_warning("Parent does not have method: %s" % function_name)
			else:
				push_warning("No parent assigned to call function on unobserve")
		_set_observing(false)


func _set_observing(value: bool) -> void:
	_observing = value
	if disable_collision_on_observe and collision:
		collision.disabled = value
	_set_can_click(value)
	for child in child_handlers:
		child._set_observing(value)


func _set_can_click(value: bool) -> void:
	_can_click = value
	for child in child_handlers:
		child._set_can_click(value)
		if collision:
			collision.disabled = value
