extends Control

@onready var crosshair_normal = $Crosshair
@onready var crosshair_obs = $CrosshairObs

func _ready() -> void:
	Eventbus.interactable_observed.connect(_on_observed)
	Eventbus.interactable_unobserved.connect(_on_unobserved)

func _on_observed(_observed: Node) -> void:
	crosshair_normal.visible = false
	crosshair_obs.visible = true

func _on_unobserved(_observed: Node) -> void:
	crosshair_normal.visible = true
	crosshair_obs.visible = false

func toggle_crosshair(state: bool) -> void:
	visible = state
