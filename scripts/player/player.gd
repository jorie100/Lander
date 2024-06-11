# extends CharacterBody3D

# # Visual target y mesh
# @export var target: Marker3D
# @export var mesh: MeshInstance3D

# # AStarGrid2D
# var astar_grid: AStarGrid2D
# var floor_height: int

# # Robot settings
# @export_category("RobotSettings")
# @export var movement_speed = 0.1
# @export var rotation_speed = 10

# # Variables publicas
# var grid_offset: float = 0.5               # El offset de la rejilla para centrar el Robot
# var current_id_path: Array[Vector2i]        # Array con los puntos del pathfinding
# var target_position: Vector3                # La posición objetivo a moverse
# var is_moving: bool                         # Objeto en movimiento
# var current_rotation: Basis                 # Rotacion del objeto para traducirla en mesh
# var speed_multiplier = 1                    # Multiplicador de velocidad de movimiento

# var static_objective

# func _physics_process(delta):
	
# 	# Actualizar mesh instance con la posicion y rotacion del robot (con rotacion suave)
# 	current_rotation = current_rotation.slerp(self.global_transform.basis, rotation_speed * delta)
	
# 	# Revisa si hay puntos para hacer pathfinding
# 	if current_id_path.is_empty():
		
# 		# Si no los hay, hace el target invisible y reinicia el multiplicador de movimiento
# 		speed_multiplier = 1
# 		if target.visible:
# 			target.visible = false
	
# 	# Si los hay, empieza el movimiento
# 	else:
# 		# Si no se esta moviendo cambia el target_position y el estado moverse
# 		if !is_moving:
# 			target_position = Vector3(
# 				current_id_path.front().x + grid_offset,
# 				floor_height+0.5,
# 				current_id_path.front().y + grid_offset
# 			)
# 			is_moving = true
		
		
# 		# Distancia desde el Robot hasta la posicion objetivo (current_id_path)
# 		var distance_to_target = global_position.distance_to(target_position)
		
# 		# Cambia el multiplicador de velocidad si esta cerca del final del recorrido o si lo empieza
# 		if current_id_path.size() == 1 and distance_to_target < 1.0 and distance_to_target > 0.12:
# 			speed_multiplier = distance_to_target
# 		elif speed_multiplier < 1:
# 			speed_multiplier += delta
# 			if speed_multiplier > 1:
# 				speed_multiplier = 1
		
# 		# Mover el Robot a la posicion objetivo
# 		global_position = global_position.move_toward(target_position, movement_speed * speed_multiplier)
# 		# Rotar el Robot hacia la posicion objetivo
# 		if !self.global_position.is_equal_approx(target_position):
# 			self.look_at(target_position)
		
# 		# Mover el target visual al final del recorrido (posicion clickada)
# 		var id_path_end = Vector3(
# 			current_id_path.back().x + grid_offset,
# 			floor_height,
# 			current_id_path.back().y + grid_offset
# 		)
# 		target.global_position = id_path_end
		
# 		# Si el Robot llego a la posicion objetivo, borrarla del arreglo del camino
# 		if global_position.x == target_position.x and global_position.z == target_position.z:
# 			current_id_path.pop_front()
			
# 			# Si aun quedan puntos en el camino cambiar posicion objetivo, sino cambiar estado movimiento
# 			if !current_id_path.is_empty():
# 				target_position = Vector3(
# 					current_id_path.front().x + grid_offset,
# 					floor_height+0.5,
# 					current_id_path.front().y + grid_offset
# 				)
# 			else:
# 				is_moving = false

# func _process(delta):
# 	mesh.global_transform.basis = mesh.global_transform.basis.slerp(current_rotation, 40 * delta)
# 	mesh.global_transform.origin = mesh.global_transform.origin.lerp(self.global_transform.origin, 40 * delta)

# # Obtener el camino en el AStarGrid2D
# func obtain_id_path(objective_position: Vector2i) -> Array[Vector2i]:
# 	var id_path
	
# 	if is_moving:
# 		id_path = astar_grid.get_id_path(
# 			Vector2i(int(target_position.x-grid_offset), int(target_position.z-grid_offset)),
# 			objective_position
# 		)
# 	else:
# 		id_path = astar_grid.get_id_path(
# 			Vector2i(int(self.global_position.x-grid_offset), int(self.global_position.z-grid_offset)),
# 			objective_position
# 		)
	
# 	return id_path

# func path_distance(path_array):
# 	var path_total_distance = 0
# 	for i in range(path_array.size() - 1):
# 		path_total_distance += Vector2(path_array[i]).distance_to(Vector2(path_array[i + 1]))
# 	return path_total_distance

# func calculate_path_to_target(target_path_position: Vector3) -> void:
# 	var id_path = obtain_id_path(Vector2i(int(target_path_position.x),int(target_path_position.z)))
	
# 	if not id_path.is_empty():
# 		static_objective = null
		
# 		current_id_path = id_path
		
# 		target.visible = true
		
# 		if is_moving:
# 			speed_multiplier = 1
# 		else:
# 			speed_multiplier = 0.5

# func _on_world_generator_world_generated(world: WorldData):
# 	astar_grid = world.astar_grid
# 	floor_height = world.floor_height
# 	world.world_updated.connect(_on_world_updated)

# func _on_world_updated(world: WorldData):
# 	astar_grid = world.astar_grid
# 	floor_height = world.floor_height
	
# 	var fixed_target_position = target.global_position
# 	if fixed_target_position.x < 0:
# 		fixed_target_position.x += -1
# 	if fixed_target_position.z < 0:
# 		fixed_target_position.z += -1
# 	calculate_path_to_target(fixed_target_position)

# func _on_main_camera_player_moved(target_move_position):
# 	calculate_path_to_target(target_move_position)

# func _on_world_generator_structure_clicked(structure: StructureData):
# 	var point_array = []
# 	# Revisar si static_target tiene point_array para calcular cercano
# 	point_array = structure.structure_shape
	
# 	var neighbour_array: Array = []
	
# 	# Revisar la distancia entre el Robot y cada posible punto alcanzable del static_target
# 	for static_point in point_array:
# 		var global_static_point = Vector2(static_point)
		
# 		var rango = 1  # Define el rango a tu alrededor
		
# 		for i in range(-rango, rango + 1):
# 			for j in range(-rango, rango + 1):
# 				var neighbour = Vector2(global_static_point.x + i, global_static_point.y + j)
# 				if neighbour != global_static_point and !astar_grid.is_point_solid(neighbour) and neighbour not in neighbour_array:
# 					neighbour_array.append(neighbour)

# 	# Si es alcanzable entonces hace pathfind hasta el punto mas cercano (target point), sino no hace nada
# 	if not neighbour_array.is_empty():
		
# 		var id_path: Array = []
# 		var path_size: float = 0.0
		
# 		for neighbour in neighbour_array:
# 			var neighbour_path: Array = obtain_id_path(neighbour)
# 			var distance = path_distance(neighbour_path)
# 			if not neighbour_path.is_empty():
# 				if distance == 0.0:
# 					id_path = neighbour_path
# 					path_size = 0.0
# 					break
# 				elif path_size == 0.0:
# 					id_path = neighbour_path
# 					path_size = distance
# 				elif path_size > distance:
# 					path_size = distance
# 					id_path = neighbour_path
		
# 		if not id_path.is_empty():
# 			static_objective = structure
			
# 			current_id_path = id_path
			
# 			target.visible = true
			
# 			if is_moving:
# 				speed_multiplier = 1
# 			else:
# 				speed_multiplier = 0.5
