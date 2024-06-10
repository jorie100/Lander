extends WorldSettings
class_name WorldData

signal world_changed(world: WorldData)

@export var structures: Array[StructureData] = []
@export var entities: Array = []

var astar_grid: AStarGrid2D: set = set_astar_grid
#var world_points: Array

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

# Additional functions to handle interactions with structures
func get_structure_at_position(position: Vector2) -> StructureData:
	for structure in structures:
		if structure.is_point_in_shape(position):
			return structure
	return null


func is_world_point_solid(x: int, y: int) -> bool:
	return astar_grid.is_point_solid(Vector2i(x, y))


func set_world_point(x: int, y: int, solid: bool) -> void:
	astar_grid.set_point_solid(Vector2i(x,y),solid)
	world_changed.emit(self)

# Function to build and add a structure to the world
func add_structure_at(x: int, y: int, structure: StructureData):
	var new_structure: StructureData = structure.duplicate()
	new_structure.structure_position = Vector3(x, floor_height + 0.5, y)
	for index in new_structure.structure_shape.size():
		new_structure.structure_shape[index] += Vector2i(int(x), int(y))
		set_world_point(new_structure.structure_shape[index].x, new_structure.structure_shape[index].y, true)
	structures.append(new_structure)

# Modify data
func add_structure(structure: StructureData):
	structures.append(structure)
	for index in structure.structure_shape.size():
		set_world_point(structure.structure_shape[index].x, structure.structure_shape[index].y, true)
	world_changed.emit(self)

func remove_structure(index: int):
	structures.remove_at(index)
	world_changed.emit(self)

func add_entity(entity):
	entities.append(entity)
	world_changed.emit(self)

func remove_entity(entity):
	entities.erase(entity)
	world_changed.emit(self)

# Setters and getters
func set_astar_grid(value):
	astar_grid = value
	world_changed.emit()
