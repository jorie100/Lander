@tool
extends MeshInstance3D

# Actualizar viewport de edit mode
@export var update = false

# Asignar material
@export var material = Material

# Tamaño piso
@export var width: int = 16
@export var height: int = 16

# Borrar todos los hijos y generar el piso
func _ready():
	for child in get_children():
		child.queue_free()
	gen_mesh()

# Funcion para generar el piso con material
func gen_mesh():
	
	# Nuevo mesh con vertices, normales e indices
	var a_mesh = ArrayMesh.new()
	var vertices := PackedVector3Array([
		Vector3(ceil(-width / 2.0), 0, ceil(-height / 2.0)),
		Vector3(ceil(width / 2.0), 0, ceil(-height / 2.0)),
		Vector3(ceil(width / 2.0), 0, ceil(height / 2.0)),
		Vector3(ceil(-width / 2.0), 0, ceil(height / 2.0))
	])
	
	var normals := PackedVector3Array([
		Vector3(0,1,0),
		Vector3(0,1,0),
		Vector3(0,1,0),
		Vector3(0,1,0)
	])
	
	var indices := PackedInt32Array(
		[
			0,1,2,
			0,2,3
		]
	)
	
	var uvs := PackedVector2Array([
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(1, 1),
		Vector2(0, 1)
	])

	# Crear y agregar la primera cara
	var array = []
	array.resize(Mesh.ARRAY_MAX)
	array[Mesh.ARRAY_VERTEX] = vertices
	array[Mesh.ARRAY_INDEX] = indices
	array[Mesh.ARRAY_TEX_UV] = uvs
	array[Mesh.ARRAY_NORMAL] = normals
	a_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
	a_mesh.surface_set_material(0, material)  # Material para la segunda cara
	self.mesh = a_mesh
	
	# Crear collision
	self.create_trimesh_collision()

func _process(_delta):
	# Actualizar el mesh en el viewport
	if update:
		for child in get_children():
			child.queue_free()
		gen_mesh()
		update = false
	
		# Cambiar las capas de colisiones a la asignada para "floor"
		if self.get_child_count() > 0:
			if "collision_layer" in self.get_child(0):
				if self.get_child(0).collision_layer != 1:
					self.get_child(0).collision_layer = 1
			if "collision_mask" in self.get_child(0):
				if self.get_child(0).collision_mask != 0:
					self.get_child(0).collision_mask = 0

# Funcion para cambiar el tamaño del piso, borrar colisiones previas y generar mesh y colisiones de nuevo
func update_size(updated_width, updated_height):
	width = updated_width
	height = updated_height
	for child in get_children():
		child.queue_free()
	update = true
	# var new_material = StandardMaterial3D.new()
	# new_material.albedo_color = Color8(randi_range(0,180),randi_range(0,50),randi_range(0,180),1)
	# self.set_surface_override_material(0, new_material)

func generate_floor(world_settings: WorldSettings):
	update_size(world_settings.width,world_settings.height)
	self.global_position.y = world_settings.floor_height
