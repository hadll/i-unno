extends Player
class_name OfficePlayer

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		input.emit(event)

func _ready() -> void:
	camera_point = $MainCamera

func _process(delta: float) -> void:
	var query := PhysicsRayQueryParameters3D.new()
	query.exclude = [get_rid()]
	if free_mouse:
		var mouse_pos := get_viewport().get_mouse_position()
		query.from = PlayerCamera.me.project_ray_origin(mouse_pos)
		query.to = query.from + PlayerCamera.me.project_ray_normal(mouse_pos) * 1000
	else:
		query.from = camera_point.global_position
		query.to = camera_point.global_position - camera_point.global_basis.z * 2.5
	var intersection := get_world_3d().direct_space_state.intersect_ray(query)
	var now_looking_at := intersection.get("collider") as CollisionObject3D
	if now_looking_at != looking_at:
		if looking_at:
			stopped_looking_at.emit(looking_at)
		looking_at = now_looking_at
		if looking_at:
			started_looking_at.emit(looking_at)

func _rotate_camera(by: Vector2, sens_mod: float = 1.0) -> void:
	pass

func capture_mouse() -> void:
	pass

func release_mouse() -> void:
	pass

func _physics_process(delta: float) -> void:
	pass
