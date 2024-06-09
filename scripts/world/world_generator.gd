extends Node3D

const CUBE = preload("res://scenes/world/world_resources/Cube.tscn")
const BUILDABLE_MATERIAL = preload("res://assets/materials/structures/preview_buildable.tres")
const NOT_BUILDABLE_MATERIAL = preload("res://assets/materials/structures/preview_not_buildable.tres")

signal world_generated(world: WorldData)
signal built_checked(is_buildable: bool)
signal structure_clicked(structure: StructureData)

# Settings del mundo
@export_category("WorldSettings")
@export var world_settings: WorldSettings
@export var preview_container: Node3D
@export var structures_container: Node
@export var current_structure: StructureData

@export_category("GeneratorSettings")
@export var mountains: bool = true
@export var structures: bool = true

var world: WorldData
var generation_thread = Thread.new()

func _ready() -> void:
	# Para que el punto (0,0) sea el centro del mundo
	var width = world_settings.width
	var height = world_settings.height
	var width_fixed = int(ceil(-width/2.0))
	var height_fixed = int(ceil(-height/2.0))
	
	# Generar Astar2DGrid
	var astar_grid = AStarGrid2D.new()
	astar_grid.region = Rect2i(width_fixed,height_fixed, width, height)
	astar_grid.cell_size = Vector2(16,16)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar_grid.update()
	var new_world: WorldData = WorldData.new(world_settings)
	new_world.astar_grid = astar_grid
	world = new_world
	
	# Generar terreno
	if mountains:
		var noise = setup_noise(world_settings.world_noise)
		var noise_grid = generate_noise_grid(width, height, noise, world_settings.noise_scale)
		generate_mountains(noise_grid, world_settings.noise_threshold)
	if structures:
		var rng = RandomNumberGenerator.new()
		generate_structures(rng)
	world_generated.emit(world)

# Noise
func setup_noise(noise: FastNoiseLite):
	if noise:
		noise.seed = randi()
		return noise

func generate_noise_grid(width, height, noise, n_scale):
	var grid = []
	var scale_factor
	if width >= height:
		scale_factor = width
	else:
		scale_factor = height
	for y in range(height):
		var row = []
		for x in range(width):
			var nx = (float(x) / float(width)) * (10 * n_scale) * (scale_factor * 0.002)
			var ny = (float(y) / float(height)) * (10 * n_scale) * (scale_factor * 0.002)
			var value = noise.get_noise_2d(nx, ny)
			row.append(value)
		grid.append(row)
	return grid

# Generate
func generate_mountains(noise_grid: Array, noise_value: float):
	var width = world.width
	var height = world.height
	var half_width = floor(width / 2.0)
	var half_height = floor(height / 2.0)
	var spawn_radius = world.noise_spawn_radius
	var spawn_radius_squared = spawn_radius * spawn_radius

	for x in range(-width / 2.0, int(ceil(width / 2.0))):
		for y in range(-height / 2.0, int(ceil(height / 2.0))):
			var distance_squared = x * x + y * y
			if distance_squared > spawn_radius_squared:
				if noise_grid[x - half_width][y - half_height] > noise_value:
					world.add_structure_at(int(x), int(y), current_structure)
					build_structure(int(x), int(y), current_structure)

func generate_structures(rng: RandomNumberGenerator):
	var width = world.width
	var height = world.height
	var spawn_radius = world.spawn_radius
	var spawn_radius_squared = spawn_radius * spawn_radius

	for x in range(-width / 2.0, ceil(width / 2.0)):
		for y in range(-height / 2.0, ceil(height / 2.0)):
			var distance_squared = x * x + y * y
			if not (distance_squared <= spawn_radius_squared):
				if rng.randf_range(0.0, 100.0) < world.structure_spawn_rate:
					var is_generatable = true
					for point in current_structure.structure_shape:
						if world.is_world_point_solid(int(x) + point.x, int(y) + point.y):
							is_generatable = false
							break  # Stop checking if we find a solid point
					if is_generatable:
						world.add_structure_at(int(x), int(y), current_structure)
						build_structure(int(x), int(y), current_structure)

func build_structure(x: int, y:int, structure: StructureData) -> void:
	#var new_structure: StructureData = structure.duplicate()
	var new_structure_scene = structure.structure_scene.instantiate()
	structures_container.add_child(new_structure_scene)
	new_structure_scene.global_position = Vector3(x, world.floor_height + 0.5, y)

func _on_main_camera_builded(build_position: Vector3, is_preview: bool):
	build_position = Vector3i(build_position)
	var is_solid: bool = false
	for point in current_structure.structure_shape:
		if world.is_world_point_solid(int(build_position.x) + point.x, int(build_position.z) + point.y):
			is_solid = true
			break
	built_checked.emit(!is_solid)
	if not is_preview:
		if not is_solid:
			world.add_structure_at(int(build_position.x), int(build_position.z), current_structure)
			build_structure(int(build_position.x), int(build_position.z), current_structure)

func _on_main_camera_destroyed(destroy_position: Vector3, collided_structure: CollisionObject3D):
	destroy_position = Vector3i(destroy_position)
	if world.is_world_point_solid(int(destroy_position.x), int(destroy_position.z)):
		var structure_index = collided_structure.get_index()
		for point in world.structures[structure_index].structure_shape:
			world.set_world_point(point.x, point.y, false)
		world.remove_structure(structure_index)

func _on_main_camera_structure_changed(structure):
	current_structure = structure

func _on_main_camera_structure_clicked(collided_structure: CollisionObject3D):
	structure_clicked.emit(world.structures[collided_structure.get_index()])
