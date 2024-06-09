extends Node

# Vector3i to Vector2i
func vect2i(vector: Vector3i) -> Vector2i:
	return Vector2i(vector.x, vector.z)

#Vector2i to Vector3i
func vect3i(vector: Vector2i, z: int) -> Vector3i:
	return Vector3i(vector.x, z,vector.y)

# Vector3 to Vector2
func vect2(vector: Vector3) -> Vector2:
	return Vector2(vector.x, vector.z)

#Vector2 to Vector3
func vect3(vector: Vector2, z: int) -> Vector3:
	return Vector3(vector.x, z,vector.y)

# Iterar en los archivos de un directorio
func dir_contents(path) -> Array:
	var dir = DirAccess.open(path)
	var files = []
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				pass
			else:
				files.append(path + "/" + file_name)
			file_name = dir.get_next()
	else:
		push_error("An error occurred when trying to access the path.")
	return files

# Remover todos los nodos hijos
func remove_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

# Cambia la posicion de la region del Atlas usando un indice
func move_atlas_grid(index: int, atlas: AtlasTexture) -> AtlasTexture:
	atlas.region.position = Vector2(0,0)
	var size_index = atlas.get_atlas().get_size() / atlas.region.end
	var end = Vector2(0,0)
	var index_counter = 0
	for y in size_index.y:
		for x in size_index.x:
			if index_counter == index:
				end.x = x
				end.y = y
				atlas.region.position = end * atlas.region.end
				return atlas
			index_counter+=1
	return atlas

# Arrays
func rotate_right(array: Array, positions: int):
	var n = array.size()
	array = array.slice(n - positions) + array.slice(0, n - positions)
	return array

func rotate_left(array, positions):
	positions %= array.size()
	return array.slice(positions) + array.slice(0, positions)

func move_element(array, from_index, to_index):
	if from_index < 0 or from_index >= array.size() or to_index < 0 or to_index >= array.size():
		return  # Índices fuera de rango, no hacer nada
	
	var element = array[from_index]
	array.remove_at(from_index)
	array.insert(to_index, element)

func shuffle_array(array):
	var n = array.size()
	while n > 1:
		n -= 1
		var k = randi() % (n + 1)
		var temp = array[n]
		array[n] = array[k]
		array[k] = temp
