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

@onready var jump_force := sqrt(2 * jump_height * gravity)

var crouched := false

@export var body: CharacterBody3D
@export var standing_collider: CollisionShape3D
@export var crouching_collider: CollisionShape3D
@export var standing_mesh: MeshInstance3D
@export var crouching_mesh: MeshInstance3D

func _ready() -> void:
	camera_request = PlayerCamera.me.request_camera(global_transform, self, false)
	InputHandler.capture_mouse()
	InputHandler.allow_free_mouse_look = false

func _process(delta: float) -> void:
	super(delta)
	var target_height := crouch_height if crouched else stand_height
	camera_point.position.y = lerpf(target_height, camera_point.position.y, exp(-delta * crouch_speed))
	
	PlayerCamera.me.edit_request_transform(camera_request, camera_point.global_transform)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			InputHandler.capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if InputHandler.mouse_captured():
			rotate_camera(event.relative * 0.001)

func _physics_process(delta: float) -> void:
	var inp := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backward")
	var speed := sprint_speed if Input.is_action_pressed(&"move_sprint") and inp.y < 0 else walk_speed
	
	if controlling_freecam:
		var movement := Vector3(inp.x, Input.get_axis(&"move_crouch", &"move_jump"), inp.y)
		freecam.global_position += freecam.global_basis * movement * speed * 2 * delta
		inp = Vector2.ZERO
	
	var target_velocity := inp.rotated(-body.rotation.y) * speed
	var grip := ground_grip if body.is_on_floor() else air_grip
	var new_horizontal: Vector2 = lerp(target_velocity,  Vector2(body.velocity.x, body.velocity.z), exp(-delta * grip))
	body.velocity.x = new_horizontal.x
	body.velocity.z = new_horizontal.y
	
	if body.is_on_floor():
		if body.velocity.y < 0:
			body.velocity.y = 0
		if Input.is_action_just_pressed(&"move_crouch") and not controlling_freecam:
			if crouched:
				var query := PhysicsRayQueryParameters3D.new()
				query.from = body.global_position + Vector3(0, crouch_height, 0)
				query.to = body.global_position + Vector3(0, stand_height, 0)
				query.exclude = [body.get_rid()]
				var intersection := get_world_3d().direct_space_state.intersect_ray(query)
				if intersection.size() == 0:
					crouched = false
			else:
				crouched = true
			standing_collider.disabled = crouched
			crouching_collider.disabled = not crouched
			standing_mesh.visible = not crouched
			crouching_mesh.visible = crouched
		if Input.is_action_pressed(&"move_jump") and not crouched and not controlling_freecam:
			body.velocity.y = jump_force
	elif not disable_gravity:
		body.velocity.y -= gravity * delta
	body.move_and_slide()

func rotate_camera(by: Vector2, sens_mod: float = 1.0) -> void:
	if controlling_freecam:
		freecam.rotation.x = clamp(freecam.rotation.x - by.y * sensitivity, -1.5, 1.5)
		freecam.rotation.y -= by.x * sensitivity
	elif PlayerCamera.me.has_camera(self):
		body.rotation.y -= by.x * sensitivity * sens_mod
		camera_point.rotation.x = clamp(camera_point.rotation.x - by.y * sensitivity * sens_mod, -1.5, 1.5)
