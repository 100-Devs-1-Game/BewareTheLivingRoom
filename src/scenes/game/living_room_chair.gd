extends AnimatableBody3D

var moved: bool = false
var first: bool = true

func interact() -> void:
	if first:
		if Settingsmanager.get_tooltips_state():
			Eventbus.announce_tooltip.emit("Tip: Make sure everything is in it's original spot before lights out.")
			first = false
	if !moved:
		$ChairAnim.play("move")
	else:
		$ChairAnim.play_backwards("move")

	moved = !moved
