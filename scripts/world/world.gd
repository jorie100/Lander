extends Node3D

signal new_world_started(world_settings: WorldSettings)
signal world_generated(world: WorldData)
signal built_checked(is_buildable: bool)
signal structure_clicked(structure: StructureData)

# Settings del mundo
@export_category("WorldSettings")
@export var world_settings: WorldSettings
@export var current_structure: StructureData

@export_category("WorldNodes")
@export var preview_container: Node3D
@export var structures_container: Node
@export var world_generator: Node

var world: WorldData

func _ready() -> void:
	world_generator.new_world_generated.connect(_on_new_world_generated)
	new_world_started.emit(world_settings)

func _on_new_world_generated(world_data: WorldData):
	world = world_data
	world_generated.emit(world)

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
