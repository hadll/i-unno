class_name MovingPlayer
extends Player

@export var walk_speed := 4.0
@export var sprint_speed := 8.0
@export var ground_grip := 20.0
@export var air_grip := 2.0
@export var gravity := 16.0
@export var jump_height := 1.0
@export var stand_height := 1.6
@export var crouch_height := 1.0
@export var crouch_speed := 10.0
@export var sensitivity := 1.0
@export var disable_gravity := false

@export_group("Steps", "step_")
@export var step_walk_distance := 1.5
@export var step_sprint_distance := 2.0
@export var step_bob_vertical := 0.15
@export var step_bob_horizontal := 0.2
@export var step_influence_velocity := 1.0
@export var step_group_sounds: Dictionary[StringName, AudioStream]
@export var step_audio_player: AudioStreamPlayer3D

@export var body: CharacterBody3D
@export var standing_collider: CollisionShape3D
@export var crouching_collider: CollisionShape3D
@export var standing_mesh: MeshInstance3D
@export var crouching_mesh: MeshInstance3D


@onready var jump_force := sqrt(2 * jump_height * gravity)

var crouched := false
var step_progress := 0.0
var left_step := true

func _ready() -> void:
	camera_request = PlayerCamera.me.request_camera(global_transform, self, false)
	InputHandler.capture_mouse()
	InputHandler.allow_free_mouse_look = false
	InputHandler.input.connect(input)

func _process(delta: float) -> void:
	super(delta)
	if InputHandler.is_action_just_pressed(&"freecam_tp"):
		body.global_position = freecam.global_position - camera_point.position
		body.reset_physics_interpolation()
		freecam_stop()
	
	var step_factor := minf(body.velocity.length() / step_influence_velocity, 1.0) if body.is_on_floor() else 0.0
	var target_y := (crouch_height if crouched else stand_height) - step_progress * step_bob_vertical * step_factor
	var target_x := (-1 if left_step else 1) * sin(step_progress * PI) * step_bob_horizontal * step_factor
	camera_point.position.y = lerpf(target_y, camera_point.position.y, exp(-delta * crouch_speed))
	camera_point.position.x = lerpf(target_x, camera_point.position.x, exp(-delta * crouch_speed))
	
	PlayerCamera.me.edit_request_transform(camera_request, camera_point.global_transform)

func input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if InputHandler.mouse_captured():
			rotate_camera(event.relative * 0.001)
	elif event is InputEventMouseButton:
		if event.is_pressed():
			InputHandler.capture_mouse()

func _physics_process(delta: float) -> void:
	var was_on_floor := body.is_on_floor()
	var inp := InputHandler.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backward")
	var speed := sprint_speed if InputHandler.is_action_pressed(&"move_sprint") and inp.y < 0 and not crouched else walk_speed
	
	if controlling_freecam:
		var movement := Vector3(inp.x, InputHandler.get_axis(&"move_crouch", &"move_jump"), inp.y)
		freecam.global_position += freecam.global_basis * movement * speed * 2 * delta
		inp = Vector2.ZERO
	
	var target_velocity := inp.rotated(-body.rotation.y) * speed
	var grip := ground_grip if was_on_floor else air_grip
	var new_horizontal: Vector2 = lerp(target_velocity,  Vector2(body.velocity.x, body.velocity.z), exp(-delta * grip))
	body.velocity.x = new_horizontal.x
	body.velocity.z = new_horizontal.y
	
	if body.velocity.length() < 0.001:
		body.velocity = Vector3.ZERO
		if step_progress > 0.0:
			step()
			reset_step()
	
	if was_on_floor:
		if InputHandler.is_action_just_pressed(&"move_crouch") and not controlling_freecam:
			if crouched:
				var query := PhysicsRayQueryParameters3D.new()
				query.from = body.global_position + Vector3(0, crouch_height, 0)
				query.to = body.global_position + Vector3(0, stand_height, 0)
				query.exclude = [body.get_rid()]
				var intersection := get_world_3d().direct_space_state.intersect_ray(query)
				if intersection.size() == 0:
					crouched = false
					step()
			else:
				crouched = true
				step()
			standing_collider.disabled = crouched
			crouching_collider.disabled = not crouched
			standing_mesh.visible = not crouched
			crouching_mesh.visible = crouched
		if InputHandler.is_action_pressed(&"move_jump") and not crouched and not controlling_freecam:
			body.velocity.y = jump_force
		
		step_progress += body.velocity.length() * delta / get_step_length()
		if step_progress > 1.0:
			step()
	else:
		body.velocity.y -= gravity * delta
	
	body.move_and_slide()
	
	if not was_on_floor and body.is_on_floor():
		step()

func rotate_camera(by: Vector2, sens_mod: float = 1.0) -> void:
	if controlling_freecam:
		freecam.rotation.x = clamp(freecam.rotation.x - by.y * sensitivity, -1.5, 1.5)
		freecam.rotation.y -= by.x * sensitivity
	elif PlayerCamera.me.has_camera(self):
		body.rotation.y -= by.x * sensitivity * sens_mod
		camera_point.rotation.x = clamp(camera_point.rotation.x - by.y * sensitivity * sens_mod, -1.5, 1.5)

func get_step_length() -> float:
	return (
		(step_sprint_distance if InputHandler.is_action_pressed(&"move_sprint") else step_walk_distance) *
		(stand_height / crouch_height if crouched else 1.0)
	)

func reset_step() -> void:
	left_step = false

func step() -> void:
	step_progress = 0.0
	left_step = not left_step
	
	var query := PhysicsRayQueryParameters3D.new()
	query.from = body.global_position
	query.to = body.global_position + Vector3.DOWN
	query.exclude = [body.get_rid()]
	var intersection := get_world_3d().direct_space_state.intersect_ray(query)
	var collider := intersection.get("collider") as CollisionObject3D
	if collider:
		for group in collider.get_groups():
			if group in step_group_sounds:
				step_audio_player.stream = step_group_sounds[group]
				break
	
	step_audio_player.play()
