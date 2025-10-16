extends Node

var volumes: Dictionary = {
	"Master": 1.0,
	"SFX": 1.0,
	"Music": 1.0,
}

var tooltips_enabled: bool = true

const CONFIG_PATH := "user://settings.cfg"
const SECTION_A := "audio"
const SECTION_M := "misc"

func _ready() -> void:
	load_audio_values()
	load_additional_values()
	_apply_all_bus_volumes()


func set_bus_volume(bus: String, linear_value: float) -> void:
	var linear = clamp(linear_value, 0.0, 1.0)
	volumes[bus] = linear
	_apply_bus_volume(bus, linear)
	save_audio_values()


func _apply_bus_volume(bus: String, linear: float) -> void:
	var db = linear_to_db(linear)
	var bus_index = AudioServer.get_bus_index(bus)
	if bus_index != -1:
		AudioServer.set_bus_volume_db(bus_index, db)


func _apply_all_bus_volumes() -> void:
	for bus_name in volumes.keys():
		_apply_bus_volume(bus_name, volumes[bus_name])


func load_audio_values() -> void:
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		for bus_name in volumes.keys():
			volumes[bus_name] = float(config.get_value(SECTION_A, bus_name, volumes[bus_name]))
	else:
		save_audio_values()


func save_audio_values() -> void:
	var config = ConfigFile.new()
	for bus_name in volumes.keys():
		config.set_value(SECTION_A, bus_name, volumes[bus_name])
	config.save(CONFIG_PATH)


func save_additional_values() -> void:
	var config = ConfigFile.new()
	config.load(CONFIG_PATH)
	config.set_value(SECTION_M, "tooltips_enabled", tooltips_enabled)
	config.save(CONFIG_PATH)


func load_additional_values() -> void:
	var config = ConfigFile.new()
	if config.load(CONFIG_PATH) == OK:
		tooltips_enabled = bool(config.get_value(SECTION_M, "tooltips_enabled", tooltips_enabled))


func set_tooltips_state(state: bool) -> void:
	print_debug("Tooltips | ", state)
	tooltips_enabled = state


func get_tooltips_state() -> bool:
	return tooltips_enabled
