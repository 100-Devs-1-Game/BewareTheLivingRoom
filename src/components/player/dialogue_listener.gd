extends CanvasLayer

@export var dialoguer: Label
@export var default_display_time: float = 2.0

var _queue: Array[String] = []
var _is_showing: bool = false

func _ready() -> void:
	Eventbus.announced_dialogue.connect(display_dialogue)

func display_dialogue(text: String) -> void:
	_queue.append(text)
	if not _is_showing:
		_show_next()

func _show_next() -> void:
	if _queue.is_empty():
		_is_showing = false
		return

	_is_showing = true
	dialoguer.text = _queue.pop_front()
	await get_tree().create_timer(default_display_time).timeout
	dialoguer.text = ""
	_show_next()
