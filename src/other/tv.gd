extends Node3D

const BLUE_E = preload("res://materials/emission/blue_e.tres")
const BLACK_E = preload("res://materials/emission/black_e.tres")

func _ready() -> void:
	Eventbus.power_toggled.connect(toggle_emission)

func toggle_emission(state: bool) -> void:
	match state:
		true:
			$tv_001.set_surface_override_material(2, BLUE_E)
		false:
			$tv_001.set_surface_override_material(2, BLACK_E)
