extends CanvasLayer

signal settings_exited

@export var master_slider: HSlider
@export var sfx_slider: HSlider
@export var music_slider: HSlider

@export var tooltip_checkbox: CheckBox

func _ready() -> void:
	var rect = $TextureRect
	rect.visible = true
	rect.modulate.a = 0.0

	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	Settingsmanager.load_audio_values()
	Settingsmanager.load_additional_values()

	if master_slider:
		master_slider.value = Settingsmanager.volumes["Master"]
		master_slider.value_changed.connect(_on_master_slider_changed)

	if sfx_slider:
		sfx_slider.value = Settingsmanager.volumes["SFX"]
		sfx_slider.value_changed.connect(_on_sfx_slider_changed)

	if music_slider:
		music_slider.value = Settingsmanager.volumes["Music"]
		music_slider.value_changed.connect(_on_music_slider_changed)

	if tooltip_checkbox:
		tooltip_checkbox.button_pressed = Settingsmanager.tooltips_enabled
		tooltip_checkbox.toggled.connect(_on_tooltips_toggled)


func _on_tooltips_toggled(state: bool) -> void:
	Settingsmanager.set_tooltips_state(state)
	Settingsmanager.load_additional_values()

func _on_master_slider_changed(value: float) -> void:
	Settingsmanager.set_bus_volume("Master", value)

func _on_sfx_slider_changed(value: float) -> void:
	Settingsmanager.set_bus_volume("SFX", value)

func _on_music_slider_changed(value: float) -> void:
	Settingsmanager.set_bus_volume("Music", value)


func _on_back_pressed() -> void:
	settings_exited.emit()
	queue_free()
