extends Node3D

@export var required_correct: int = 4
@export var unlock_id: int = 9

var current_correct: int = 0
var solved: bool = false

func add_correct() -> void:
	if solved:
		return
	current_correct += 1
	_check_solved()

func remove_correct() -> void:
	if solved:
		return
	current_correct = max(current_correct - 1, 0)

func _check_solved() -> void:
	if current_correct >= required_correct and not solved:
		solved = true
		print("Puzzle solved")
		Eventbus.announced_dialogue.emit("It seems like something opened!")
		Eventbus.unlock_called.emit(unlock_id)
	else:
		print("Remaining:", str(current_correct), "/", str(required_correct))
