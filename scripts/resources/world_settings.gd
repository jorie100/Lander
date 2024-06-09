extends Resource
class_name WorldSettings

@export var width: int = 512: set = set_width
@export var height: int = 512: set = set_height
@export var floor_height: int = 0: set = set_floor_height
@export var spawn_radius: int = 8: set = set_spawn_radius
@export_range(0.0,100.0) var structure_spawn_rate: float = 0.15: set = set_structure_spawn_rate

@export_category("NoiseSettings")
@export var world_noise: FastNoiseLite: set = set_world_noise
@export var noise_scale: int = 85: set = set_noise_scale
@export var noise_threshold: float = 0.2: set = set_noise_threshold
@export var noise_spawn_radius: int = 50: set = set_noise_spawn_radius

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
	noise_spawn_radius = value

	# Generar matriz
	#var world_points: Array
	#world_points.resize(width)
	#for x in width:
		#var world_points_y = []
		#world_points_y.resize(height)
		#world_points[x] = world_points_y
		#for y in height:
			#world_points[x][y] = 0
	#world.world_points = world_points
