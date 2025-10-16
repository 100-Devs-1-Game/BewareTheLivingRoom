extends SpotLight3D
class_name SignalSpotLight3D


@export var event_signal_value: int = 0

func _ready() -> void:
	Eventbus.switch_changed.connect(check_signal)

func check_signal(signal_id: int, state: bool) -> void:
	if signal_id == event_signal_value:
		visible = state
