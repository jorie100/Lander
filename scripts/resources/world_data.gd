extends WorldSettings
class_name WorldData

signal world_updated(world: WorldData)

@export var structures: Array[StructureData] = []

var astar_grid: AStarGrid2D: set = set_astar_grid

var world_points: Array[Array] = []

func _init(world_settings: WorldSettings):
	set_width(world_settings.width)
	set_height(world_settings.height)
	set_floor_height(world_settings.floor_height)
	set_spawn_radius(world_settings.spawn_radius)
	set_structure_spawn_rate(world_settings.structure_spawn_rate)
	set_world_noise(world_settings.world_noise)
	set_noise_scale(world_settings.noise_scale)
	set_noise_spawn_radius(world_settings.noise_spawn_radius)
	set_noise_threshold(world_settings.noise_threshold)
	set_generate_mountains(world_settings.generate_mountains)
	set_generate_structures(world_settings.generate_structures)
	set_world_seed(world_settings.world_seed)

func is_world_point_solid(x: int, y: int) -> bool:
	return astar_grid.is_point_solid(Vector2i(x, y))

func set_world_point(x: int, y: int, solid: bool) -> void:
	astar_grid.set_point_solid(Vector2i(x,y),solid)
	world_updated.emit(self)

func is_world_structure_solid(x: int, y: int, structure: StructureData) -> bool:
	for point in structure.structure_shape:
		if is_world_point_solid(x + point.x, y + point.y):
			return true
	return false

func add_structure(x: int, y: int, structure: StructureData):
	var new_structure: StructureData = structure.duplicate()
	new_structure.structure_position = Vector2(x, y)
	for index in new_structure.structure_shape.size():
		new_structure.structure_shape[index] += Vector2i(int(x), int(y))
		set_world_point(new_structure.structure_shape[index].x, new_structure.structure_shape[index].y, true)
	structures.append(new_structure)

func remove_structure(index: int):
	for point in structures[index].structure_shape:
		set_world_point(point.x, point.y, false)
	structures.remove_at(index)
	world_updated.emit(self)

# Setters and getters
func set_astar_grid(value):
	astar_grid = value
	world_updated.emit()
