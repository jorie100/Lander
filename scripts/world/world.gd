extends Node3D

signal new_world_started(world_settings: WorldSettings)
signal buildable_check(is_buildable: bool)

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
	if "build_structure" in structures_container:

		# World generation
		world_generator.world_generated.connect(_on_world_generated)
		self.new_world_started.connect(world_generator._on_new_world_started)
		new_world_started.emit(world_settings)

		# Camera connections
		main_camera.structure_previewed.connect(_on_structure_previewed)
		main_camera.structure_builded.connect(_on_structure_builded)
		main_camera.structure_destroyed.connect(_on_structure_destroyed)
		# main_camera.structure_selected.connect(_on_structure_selected)

		# Preview container connections
		main_camera.structure_previewed.connect(preview_container._on_structure_previewed)
		main_camera.build_mode_toggled.connect(preview_container._on_build_mode_toggled)

		# Buildable checks
		self.buildable_check.connect(main_camera._on_buildable_check)
		self.buildable_check.connect(preview_container._on_buildable_check)


func _on_world_generated(world_data: WorldData):
	call_deferred("_on_world_generated_def", world_data)

func _on_world_generated_def(world_data: WorldData):
	world = world_data
	print("Finished generating world")
	print("seed: ",world.world_seed)
	world.world_updated.connect(preview_container._on_world_updated)
	world.world_updated.connect(main_camera._on_world_updated)
	world.world_updated.emit(world)

func _on_structure_previewed(build_position: Vector3, build_structure: StructureData):
	build_position = Vector3i(build_position)
	buildable_check.emit(!world.is_world_structure_solid(int(build_position.x), int(build_position.z), build_structure))

# func _on_structure_selected(collided_structure: CollisionObject3D):
# 	pass

func _on_structure_builded(build_position: Vector3, build_structure: StructureData):
	build_position = Vector3i(build_position)
	if not world.is_world_structure_solid(int(build_position.x), int(build_position.z), build_structure):
		world.add_structure(int(build_position.x), int(build_position.z), build_structure)
		structures_container.build_structure(Vector3(build_position.x, world.floor_height, build_position.z), build_structure)

func _on_structure_destroyed(collided_structure: CollisionObject3D):
	var structure_index = collided_structure.get_index()
	world.remove_structure(structure_index)
	structures_container.remove_child(collided_structure)
