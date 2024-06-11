extends Node

signal world_generated(world: WorldData)

@export var current_structure: StructureData ## Structure being generated randomly
@export var structures_container: Node
@export var world_floor: Node3D

func _on_new_world_started(world_settings: WorldSettings):
	# Generar piso
	world_floor.generate_floor(world_settings)

	# Para que el punto (0,0) sea el centro del mundo
	var width = world_settings.width
	var height = world_settings.height
	var mountains = world_settings.generate_mountains
	var structures = world_settings.generate_structures
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
	
	# Generar terreno
	var world_seed = world_settings.world_seed
	if world_seed == 0:
		world_seed = randi()

	var rng = RandomNumberGenerator.new()
	rng.seed = world_seed
	
	if mountains:
		var noise = setup_noise(world_settings.world_noise, rng)
		var noise_grid = generate_noise_grid(width, height, noise, world_settings.noise_scale)
		new_world = generate_mountains(noise_grid, new_world)
	if structures:
		new_world = generate_structures(rng, new_world)
	
	new_world.world_seed = rng.seed
	print("seed: ",new_world.world_seed)
	world_generated.emit(new_world)

# Noise
func setup_noise(noise: FastNoiseLite, noise_rng: RandomNumberGenerator):
	if noise:
		if not noise_rng:
			noise.seed = randi()
		else:
			noise.seed = noise_rng.seed
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
func generate_mountains(noise_grid: Array, world: WorldData):
	var noise_value = world.noise_threshold
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
					world.add_structure(int(x), int(y), current_structure)
					structures_container.build_structure(Vector3(int(x), world.floor_height, int(y)), current_structure)
	
	return world

func generate_structures(rng: RandomNumberGenerator, world: WorldData):
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
						world.add_structure(int(x), int(y), current_structure)
						structures_container.build_structure(Vector3(int(x), world.floor_height, int(y)), current_structure)
	
	return world