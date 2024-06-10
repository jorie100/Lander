extends Node3D

signal new_world_started(world_settings: WorldSettings)

signal world_generated(world: WorldData)
signal built_checked(is_buildable: bool)
signal structure_clicked(structure: StructureData)

# Settings del mundo
@export_category("WorldSettings")
@export var world_settings: WorldSettings

@export_category("WorldNodes")
@export var preview_container: Node3D
@export var structures_container: Node
@export var world_generator: Node

@export_category("ExternalNodes")
@export var main_camera: Node

var world: WorldData

func _ready() -> void:
	world_generator.world_generated.connect(_on_world_generated)
	new_world_started.emit(world_settings)

	if "build_structure" in structures_container:
		main_camera.structure_previewed.connect(_on_structure_previewed)
		main_camera.structure_builded.connect(_on_structure_builded)
		main_camera.structure_destroyed.connect(_on_structure_destroyed)
		main_camera.structure_selected.connect(_on_structure_selected)

func _on_world_generated(world_data: WorldData):
	world = world_data
	world_generated.emit(world)

func _on_main_camera_structure_clicked(collided_structure: CollisionObject3D):
	structure_clicked.emit(world.structures[collided_structure.get_index()])

func _on_structure_previewed(build_position: Vector3, build_structure: StructureData):
	pass

func _on_structure_selected(collided_structure: CollisionObject3D):
	pass

func _on_structure_builded(build_position: Vector3, build_structure: StructureData):
	build_position = Vector3i(build_position)
	if not world.is_world_structure_solid(int(build_position.x), int(build_position.z), build_structure):
		world.add_structure(int(build_position.x), int(build_position.z), build_structure)
		structures_container.build_structure(Vector3(build_position.x, world.floor_height, build_position.z), build_structure)

func _on_structure_destroyed(collided_structure: CollisionObject3D):
	var structure_index = collided_structure.get_index()
	world.remove_structure(structure_index)
	structures_container.remove_child(collided_structure)
