extends Camera3D

signal builded(build_position: Vector3)

func _input(event) -> void:
	var raycast_result = raycast_from_camera(-1)
	var mouse_3d_position = raycast_result.get("position")
	
	if Input.is_action_pressed("build") and mouse_3d_position:
		var mouse_position_fixed = mouse_3d_position
		if mouse_position_fixed.x < 0:
			mouse_position_fixed.x += -1
		if mouse_position_fixed.z < 0:
			mouse_position_fixed.z += -1
		builded.emit(mouse_position_fixed)


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
