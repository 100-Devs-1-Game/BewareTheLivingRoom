extends Node3D

func interact() -> void:
	Eventbus.bed_used.emit(true)

func uninteract() -> void:
	Eventbus.bed_used.emit(false)
