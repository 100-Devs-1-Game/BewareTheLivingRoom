extends Node3D

@export var lock_ref: Node
@export var diglbl: Label3D
@export var index: int = 0

func _ready() -> void:
	if lock_ref:
		show_digit()

func show_digit() -> void:
	var code = lock_ref.get_code()
	if index >= 0 and index < code.size():
		var digit = code[index]
		diglbl.text = str(digit)
