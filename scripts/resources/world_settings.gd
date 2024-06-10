extends Resource
class_name WorldSettings

@export var width: int = 512: set = set_width ## Width of the world
@export var height: int = 512: set = set_height ## Height of the world
@export var floor_height: int = 0: set = set_floor_height ## Height of the floor in the world
@export var spawn_radius: int = 8: set = set_spawn_radius ## Radius for spawning entities

@export_category("GenerationSettings")
@export var world_seed: int = 0: set = set_world_seed ## World seed to generate (0 = random)
@export var generate_structures: bool = true: set = set_generate_structures ## Flag to determine if structures should be generated
@export_range(0.0,100.0) var structure_spawn_rate: float = 0.15: set = set_structure_spawn_rate ## Rate at which structures spawn
@export var generate_mountains: bool = true: set = set_generate_mountains ## Flag to determine if mountains should be generated

@export_category("NoiseSettings")
@export var world_noise: FastNoiseLite: set = set_world_noise ## Noise settings for the world generation
@export var noise_scale: int = 85: set = set_noise_scale ## Scale of the noise for world generation
@export var noise_threshold: float = 0.2: set = set_noise_threshold ## Threshold for the noise in world generation
@export var noise_spawn_radius: int = 50: set = set_noise_spawn_radius ## Radius for noise spawn in world generation

func set_width(value: int) -> void:
	width = value

func set_height(value: int) -> void:
	height = value

func set_floor_height(value: int) -> void:
	floor_height = value

func set_spawn_radius(value: int) -> void:
	spawn_radius = value

func set_structure_spawn_rate(value: float):
	if value < 0.0:
		structure_spawn_rate = 0.0
	elif value > 100.0:
		structure_spawn_rate = 100.0
	else:
		structure_spawn_rate = value

func set_world_noise(value: FastNoiseLite):
	world_noise = value

func set_noise_scale(value: int):
	noise_scale = value

func set_noise_threshold(value: float):
	noise_threshold = value

func set_noise_spawn_radius(value: int):
	if value >= spawn_radius:
		noise_spawn_radius = value
	else:
		noise_spawn_radius = spawn_radius

func set_generate_mountains(value: bool):
	generate_mountains = value

func set_generate_structures(value: bool):
	generate_structures = value

func set_world_seed(value: int):
	world_seed = value