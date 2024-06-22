extends Camera3D

signal structure_previewed(build_position: Vector3, build_structure: StructureData)
signal structure_builded(build_position: Vector3, build_structure: StructureData)
signal structure_destroyed(collided_structure: CollisionObject3D)
signal structure_selected(collided_structure: CollisionObject3D)
signal build_mode_toggled(is_building: bool)

# Speed of the camera movement
@export_category("MainCameraSettings")
@export var speed = 15.0
# Sensitivity of the mouse movement
@export_range(0.0,0.2) var mouse_sensitivity = 0.1

@export_category("MainCameraNodes")
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
var world_generated: bool = false

var pivot_point = Vector3(0, 0, 0)  # Replace with your pivot point
var rotation_speed = 1.0  # Speed of rotation

func _ready() -> void:
	current_structure = structures.front()
	camera_position = self.global_position
	camera_zoom = self.size
	grid.top_level = true
	if grid:
		grid.visible = build_mode

func _input(event) -> void:
	
	if Input.is_action_pressed("rotate_camera") and event is InputEventMouseMotion:
		var resolution_ratio = 1152 / get_viewport().get_visible_rect().size.x
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity * resolution_ratio))

	if world_generated:
		
		if Input.is_action_just_pressed("cycle_structures") and build_mode:
			structures = Utils.rotate_right(structures,1)
			current_structure = structures.front()
		
		if Input.is_action_just_pressed("toggle_build_mode"):
			build_mode = not build_mode
			build_mode_toggled.emit(build_mode)
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
					#builded.emit(mouse_3d_position, false)
					structure_builded.emit(mouse_3d_position, current_structure)
			
			if Input.is_action_just_pressed("destroy"):
				var raycast_result_collider = raycast_from_camera(4)
				if raycast_result_collider:
					structure_destroyed.emit(raycast_result_collider.get("collider"))
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
						#player_moved.emit(mouse_3d_position)
					if raycast_result.get("collider").collision_layer == 4:
						pass
						#structure_clicked.emit(raycast_result.get("collider"))

func _process(delta) -> void:
	if world_generated:

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
					structure_previewed.emit(mouse_3d_position, current_structure)
		
		if Input.is_action_just_released("cam_zoom_down") and camera_zoom < 50:
			camera_zoom += 100 * delta * (camera_zoom/20)
		if Input.is_action_just_released("cam_zoom_up") and camera_zoom > 2:
			camera_zoom -= 100 * delta * (camera_zoom/20)
		size = lerpf(size, camera_zoom, 8.0 * delta)

		if Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down") != Vector2(0,0):
			movement_dir = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
			var movement_vector = Vector3(movement_dir.x, 0.0, movement_dir.y).normalized()
			var y_rotation = self.rotation.y
			var rotated_vector = movement_vector.rotated(Vector3.UP, y_rotation)
			camera_position += rotated_vector * delta * speed
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
				grid.global_rotation_degrees.x = -90
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

func _on_buildable_check(is_buildable):
	if is_buildable:
		grid.get_surface_override_material(0).set_shader_parameter("line_color", Color8(0,255,0,255))
	else:
		grid.get_surface_override_material(0).set_shader_parameter("line_color", Color8(255,0,0,255))

func _on_world_updated(_world: WorldData) -> void:
	world_generated = true