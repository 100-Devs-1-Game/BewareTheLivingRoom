extends Node3D

@export var required_number: int = 0
@export var interactor: InteractionHandler

var first_interact: bool = true

var first_selected: Node3D = null
var correct_order = ["WHITE","RED","ORANGE","YELLOW","GREEN","BLUE","VIOLET"]
var blocks_array: Array = []
var selected_scale = Vector3.ONE * 1.2
var highlight_duration = 0.15
var swap_duration = 0.2
var block_spacing = 0.35
var block_scene = preload("res://components/interactables/puzzles/color_block.tscn")
var seventh_block_added = false

func _ready():
	_reposition_blocks()

	blocks_array = _get_blocks()
	blocks_array.sort_custom(Callable(self, "_compare_blocks_local_x"))

	for block in blocks_array:
		if block.has_signal("clicked"):
			block.connect("clicked", _on_block_clicked)

	Eventbus.unlock_called.connect(_on_seventh_block_unlocked)

func _get_blocks() -> Array:
	var blocks: Array = []
	for child in get_children():
		if child is CSGBox3D:
			blocks.append(child)
	return blocks

func _reposition_blocks():
	var blocks = _get_blocks()
	var count = blocks.size()
	var total_width = (count - 1) * block_spacing
	var start_x = -total_width / 2.0
	for i in range(count):
		blocks[i].position = Vector3(start_x + i * block_spacing, 0, 0)

func _compare_blocks_local_x(a, b) -> int:
	if a.position.x < b.position.x:
		return -1
	if a.position.x > b.position.x:
		return 1
	return 0

func _on_seventh_block_unlocked(number: int) -> void:
	if seventh_block_added or number != required_number:
		return
	var block = block_scene.instantiate()
	block.color_id = "YELLOW"
	add_child(block)
	seventh_block_added = true

	_reposition_blocks()

	blocks_array = _get_blocks()
	blocks_array.sort_custom(Callable(self, "_compare_blocks_local_x"))

	if block.has_signal("clicked"):
		block.connect("clicked", _on_block_clicked)

func _on_block_clicked(event, block):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_selection(block)

func _handle_selection(block):
	if first_selected == null:
		first_selected = block
		_animate_highlight(block, true)
	else:
		var previous = first_selected
		first_selected = null
		_animate_highlight(previous, false)

		var swap_tween = _swap_blocks_smooth(previous, block)
		await swap_tween.finished

		var idx_a = blocks_array.find(previous)
		var idx_b = blocks_array.find(block)
		blocks_array[idx_a] = block
		blocks_array[idx_b] = previous

		_check_completion()

func _animate_highlight(block, on: bool) -> Tween:
	var target_scale = selected_scale if on else Vector3.ONE
	var tween = create_tween()
	tween.tween_property(block, "scale", target_scale, highlight_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	return tween

func _swap_blocks_smooth(a, b) -> Tween:
	var tween = create_tween()
	tween.tween_property(a, "position", b.position, swap_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(b, "position", a.position, swap_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	return tween

func _check_completion() -> bool:
	var current_order = []
	for block in blocks_array:
		current_order.append(str(block.color_id).to_upper())

	print("Current order:")
	for i in range(len(blocks_array)):
		print("Index", i, "color:", current_order[i])

	if current_order == correct_order:
		print("Puzzle Complete!")
		if interactor:
			Eventbus.force_exit_observe.emit()
			interactor.send_signal()
		return true

	return false
