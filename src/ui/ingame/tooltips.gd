extends CanvasLayer

@export var tooltip: Label

func _ready() -> void:
	Eventbus.announce_tooltip.connect(_display_tooltip)

func _display_tooltip(text: String) -> void:
	tooltip.text = text
	tooltip.modulate.a = 0.0
	tooltip.visible = true
	
	var tween = create_tween()
	tween.tween_property(tooltip, "modulate:a", 1.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
	await get_tree().create_timer(5.0).timeout
	
	tween = create_tween()
	tween.tween_property(tooltip, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	
	tooltip.text = ""
