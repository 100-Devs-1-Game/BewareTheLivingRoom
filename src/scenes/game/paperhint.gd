extends MeshInstance3D

const PAPER = preload("res://other/paper.tscn")

func interact() -> void:
	var paper = PAPER.instantiate()
	get_tree().root.add_child(paper)
