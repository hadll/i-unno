extends Node3D

const INTERACTION_MASK := 3
const LOG_LOOKING := false

signal input(event: InputEvent)
signal started_looking_at(collider: CollisionObject3D)
signal stopped_looking_at(collider: CollisionObject3D)

var looking_at: CollisionObject3D
## allow "looking" anywhere on the screen using mouse to interact with 3d objects
var allow_free_mouse_look := true
## disable all input handler methods (e.g. when using monitor)
var disable_input := false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"meta_exit"):
		release_mouse()
	update_look()

func update_look() -> void:
	if not PlayerCamera.me:
		return
	var query := PhysicsRayQueryParameters3D.new()
	query.collision_mask = INTERACTION_MASK
	if allow_free_mouse_look and not mouse_captured():
		var mouse_pos := get_viewport().get_mouse_position()
		query.from = PlayerCamera.me.project_ray_origin(mouse_pos)
		query.to = query.from + PlayerCamera.me.project_ray_normal(mouse_pos) * 1000
	else:
		query.from = PlayerCamera.me.global_position
		query.to = PlayerCamera.me.global_position - PlayerCamera.me.global_basis.z * 2.5
	var intersection := get_world_3d().direct_space_state.intersect_ray(query)
	var now_looking_at := intersection.get("collider") as CollisionObject3D
	if now_looking_at != looking_at:
		if looking_at:
			if LOG_LOOKING: print("Stopped looking at %s" % str(looking_at))
			stopped_looking_at.emit(looking_at)
		looking_at = now_looking_at
		if looking_at:
			if LOG_LOOKING: print("Started looking at %s" % str(looking_at))
			started_looking_at.emit(looking_at)

func _input(event: InputEvent) -> void:
	if disable_input:
		return
	if event is InputEventKey or event is InputEventMouseButton:
		input.emit(event)

func is_action_pressed(action: StringName, exact_match: bool = false) -> bool:
	return false if disable_input else Input.is_action_pressed(action, exact_match)

func is_action_just_pressed(action: StringName, exact_match: bool = false) -> bool:
	return false if disable_input else Input.is_action_just_pressed(action, exact_match)

func is_action_just_released(action: StringName, exact_match: bool = false) -> bool:
	return false if disable_input else Input.is_action_just_released(action, exact_match)

func get_vector(negative_x: StringName, positive_x: StringName, negative_y: StringName, positive_y: StringName, deadzone: float = -1.0) -> Vector2:
	return Vector2.ZERO if disable_input else Input.get_vector(negative_x, positive_x, negative_y, positive_y, deadzone)

func get_axis(negative_action: StringName, positive_action: StringName) -> float:
	return 0.0 if disable_input else Input.get_axis(negative_action, positive_action)

func capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func mouse_captured() -> bool:
	return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
