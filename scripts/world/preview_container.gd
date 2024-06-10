extends Node3D

@export var buildable_material: StandardMaterial3D
@export var not_buildable_material: StandardMaterial3D

@export var default_structure: StructureData

var current_structure: StructureData
var floor_height: int = 0

func _on_main_camera_build_mode_toggled(is_building, structure):
	if not structure is StructureData:
		current_structure = default_structure
	else:
		current_structure = structure
	if is_building:
		update_mesh(current_structure)
		self.visible = true
	else:
		self.visible = false

func _on_main_camera_structure_changed(structure):
	current_structure = structure
	update_mesh(current_structure)

func _on_world_generator_built_checked(is_buildable):
	for child in self.get_children():
		if is_buildable:
			child.set_surface_override_material(0, buildable_material)
		else:
			child.set_surface_override_material(0, not_buildable_material)

func _on_main_camera_builded(build_position, _is_preview):
	build_position = Vector3i(build_position)
	self.global_position = build_position
	self.global_position.y = floor_height + 0.5

func _on_world_generator_world_generated(world):
	floor_height = world.floor_height

func update_mesh(structure: StructureData):
	for child in self.get_children():
		child.queue_free()
	var preview_building = structure.structure_scene.instantiate()
	for child in preview_building.get_children():
		if child is MeshInstance3D:
			var new_mesh_instance = MeshInstance3D.new()
			new_mesh_instance.mesh = child.mesh
			new_mesh_instance.transform = child.transform
			new_mesh_instance.set_surface_override_material(0, buildable_material)
			self.add_child(new_mesh_instance)
	preview_building.queue_free()
