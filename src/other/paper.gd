extends Control


func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	queue_free()
