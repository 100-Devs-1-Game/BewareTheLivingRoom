extends SpotLight3D

@export var min_energy: float = 0.6
@export var max_energy: float = 2.0
@export var noise_speed: float = 1.0
@export var smooth_amount: float = 8.0

var noise := FastNoiseLite.new()
var time: float = 0.0
var current_energy: float

func _ready() -> void:
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.5
	current_energy = clamp(self.light_energy, min_energy, max_energy)

func _process(delta: float) -> void:
	time += delta * noise_speed #makes a flicky light based off noise1

	var n = noise.get_noise_1d(time)
	var t = (n + 1.0) * 0.5
	var target = lerp(min_energy, max_energy, t)

	current_energy = lerp(current_energy, target, clamp(delta * smooth_amount, 0.0, 1.0))
	self.light_energy = current_energy
