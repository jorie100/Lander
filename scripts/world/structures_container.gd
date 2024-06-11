extends Node

# Build in structure container
func build_structure(build_position: Vector3, structure: StructureData) -> void:
	call_deferred("_build_structure", build_position, structure)

func _build_structure(build_position: Vector3, structure: StructureData) -> void:
	var new_structure_scene = structure.structure_scene.instantiate()
	self.add_child(new_structure_scene)
	new_structure_scene.global_position = build_position + Vector3(0.0, 0.5, 0.0)
