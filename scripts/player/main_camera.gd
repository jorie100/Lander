extends Camera3D

signal builded(build_position: Vector3, is_preview: bool)
signal destroyed(destroy_position: Vector3, collided_structure: CollisionObject3D)

signal player_moved(target_position: Vector3)
signal structure_clicked(collided_structure: CollisionObject3D)
signal build_mode_toggled(is_building: bool, structure: StructureData)
signal structure_changed(structure: StructureData)

# Speed of the camera movement
@export_category("MainCamera")
@export var speed = 15.0

# Nodes
@export var grid: MeshInstance3D

# Temporal
@export var structures: Array[StructureData]

# Public variables
var movement_dir: Vector2 = Vector2(0,0)
var camera_position: Vector3
var camera_zoom: float
var build_mode: bool = false
var current_structure: StructureData

func _ready() -> void:
	current_structure = structures.front()
	camera_position = self.global_position
	camera_zoom = self.size
	if grid:
		grid.visible = build_mode

func _input(_event) -> void:
	
	if Input.is_action_just_pressed("cycle_structures") and build_mode:
		structures = Utils.rotate_right(structures,1)
		current_structure = structures.front()
		structure_changed.emit(current_structure)
	
	if Input.is_action_just_pressed("toggle_build_mode"):
		build_mode = not build_mode
		build_mode_toggled.emit(build_mode, current_structure)
		if grid:
			grid.visible = build_mode
		
	
	if build_mode:
		
		if Input.is_action_pressed("build"):
			var raycast_result = raycast_from_camera(1)
			if raycast_result:
				var mouse_3d_position = raycast_result.get("position")
				if mouse_3d_position.x < 0:
					mouse_3d_position.x += -1
				if mouse_3d_position.z < 0:
					mouse_3d_position.z += -1
				builded.emit(mouse_3d_position, false)
		
		if Input.is_action_just_pressed("destroy"):
			var raycast_result_collider = raycast_from_camera(4)
			if raycast_result_collider:
				var mouse_3d_position = raycast_result_collider.get("collider").global_position
				raycast_result_collider.get("collider").queue_free()
				print(mouse_3d_position)
				destroyed.emit(mouse_3d_position, raycast_result_collider.get("collider"))
	else:
		if Input.is_action_just_pressed("move_player"):
			var raycast_result = raycast_from_camera(-1)
			if raycast_result:
				if raycast_result.get("collider").collision_layer == 1:
					var mouse_3d_position = raycast_result.get("position")
					if mouse_3d_position.x < 0:
						mouse_3d_position.x += -1
					if mouse_3d_position.z < 0:
						mouse_3d_position.z += -1
					player_moved.emit(mouse_3d_position)
				if raycast_result.get("collider").collision_layer == 4:
					structure_clicked.emit(raycast_result.get("collider"))

# Utility function to rotate around the Y-axis
#func rotate_y(angle):
	#var rotation = self.rotation_degrees
	#rotation.y += angle
	#self.rotation_degrees = rotation

func _process(delta) -> void:
	var raycast_result2 = raycast_from_camera(-1)
	if raycast_result2:
		var mouse_3d_position = raycast_result2.get("position")
		if mouse_3d_position.x < 0:
			mouse_3d_position.x += -1
		if mouse_3d_position.z < 0:
			mouse_3d_position.z += -1
		$Label2.text = str(Vector3i(mouse_3d_position))
		$Label.text = raycast_result2.get("collider").name
	else:
		$Label2.text = ""
		$Label.text = ""
	
	if build_mode:
		var raycast_result = raycast_from_camera(1)
		if raycast_result:
			var mouse_3d_position = raycast_result.get("position")
			if mouse_3d_position.x < 0:
				mouse_3d_position.x += -1
			if mouse_3d_position.z < 0:
				mouse_3d_position.z += -1
			if raycast_result.get("collider").collision_layer == 1:
				builded.emit(mouse_3d_position, true)
	
	if Input.is_action_just_released("cam_zoom_down") and camera_zoom < 50:
		camera_zoom += 100 * delta * (camera_zoom/20)
	if Input.is_action_just_released("cam_zoom_up") and camera_zoom > 2:
		camera_zoom -= 100 * delta * (camera_zoom/20)
	size = lerpf(size, camera_zoom, 8.0 * delta)
	
	if Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down") != Vector2(0,0):
		movement_dir = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
		camera_position += (Vector3(movement_dir.x, 0.0, movement_dir.y)).normalized() * delta * speed
	else:
		movement_dir = Vector2(0.0, 0.0)
	global_position.x = lerpf(global_position.x, camera_position.x, 12.0 * delta)
	global_position.z = lerpf(global_position.z, camera_position.z, 12.0 * delta)
	
	if grid and build_mode:
		var grid_raycast = raycast_from_camera(1)
		if grid_raycast:
			grid.get_surface_override_material(0).set_shader_parameter("line_width", (camera_zoom * 0.0018) + 0.001)
			var grid_fixed_position = grid_raycast.get("position")
			if grid_fixed_position.x < 0:
				grid_fixed_position.x += -1
			if grid_fixed_position.z < 0:
				grid_fixed_position.z += -1
			grid.global_position = Vector3(Vector3i(grid_fixed_position)) + Vector3(0.5,0.01,0.5)
			grid.get_surface_override_material(0).set_shader_parameter("center", -grid.global_position)

# Raycast desde la camara distancia 100. Acepta capa collision mask
# Si capa collider_mask = -1, activa todas las capas
func raycast_from_camera(collider_mask) -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 4000
	var from = project_ray_origin(mouse_pos)
	var to = from + project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	if collider_mask != -1:
		ray_query.collision_mask = collider_mask
	ray_query.from = from
	ray_query.to = to
	var result = space.intersect_ray(ray_query)
	return result

func _on_world_generator_built_checked(is_buildable):
	if is_buildable:
		grid.get_surface_override_material(0).set_shader_parameter("line_color", Color8(0,255,0,255))
	else:
		grid.get_surface_override_material(0).set_shader_parameter("line_color", Color8(255,0,0,255))
