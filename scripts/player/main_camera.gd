extends Camera3D

signal builded(build_position: Vector3)
signal destroyed(destroy_position: Vector3)

signal player_moved(target_position: Vector3)
signal build_mode_toggled(build_mode_state: bool)

@export var grid: MeshInstance3D

# Speed of the camera movement
var speed = 10.0

var movement_dir: Vector2 = Vector2(0,0)
var camera_position: Vector3 = Vector3.ZERO
var build_mode: bool = false

func _ready() -> void:
	if grid:
		grid.visible = build_mode

func _input(_event) -> void:
	
	if Input.is_action_just_pressed("toggle_build_mode"):
		build_mode = not build_mode
		build_mode_toggled.emit(build_mode)
		if grid:
			grid.visible = build_mode
		
	
	if build_mode:
		if Input.is_action_pressed("build"):
			var raycast_result = raycast_from_camera(-1)
			if raycast_result:
				if raycast_result.get("collider").collision_layer == 1:
					var mouse_3d_position = raycast_result.get("position")
					if mouse_3d_position.x < 0:
						mouse_3d_position.x += -1
					if mouse_3d_position.z < 0:
						mouse_3d_position.z += -1
					builded.emit(mouse_3d_position)
		
		if Input.is_action_just_pressed("destroy"):
			var raycast_result = raycast_from_camera(-1)
			if raycast_result:
				if raycast_result.get("collider").collision_layer == 4:
					raycast_result.get("collider").queue_free()
					var mouse_3d_position = raycast_result.get("position")
					if mouse_3d_position.x < 0:
						mouse_3d_position.x += -1
					if mouse_3d_position.z < 0:
						mouse_3d_position.z += -1
					destroyed.emit(mouse_3d_position)
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

func _process(delta):
	if Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down") != Vector2(0,0):
		movement_dir = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	else:
		movement_dir = Vector2(0.0, 0.0)
	camera_position += (Vector3(movement_dir.x, 0.0, movement_dir.y)).normalized() * delta * speed
	global_position.x = lerpf(global_position.x, camera_position.x, 11.0 * delta)
	global_position.z = lerpf(global_position.z, camera_position.z, 11.0 * delta)
	
	if grid and build_mode:
		grid.global_position = raycast_from_camera(1).get("position") + Vector3(0.0,0.01,0.0)
		grid.get_surface_override_material(0).set_shader_parameter("center", -grid.global_position)

# Raycast desde la camara distancia 100. Acepta capa collision mask
# Si capa collider_mask = -1, activa todas las capas
func raycast_from_camera(collider_mask) -> Dictionary:
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_length = 100
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
