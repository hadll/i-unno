class_name Player
extends CharacterBody3D

signal input(event: InputEvent)
signal started_looking_at(collider: CollisionObject3D)
signal stopped_looking_at(collider: CollisionObject3D)

static var me: Player

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
var detached_freecam := false
var controlling_freecam := false

var camera_request: int

var looking_at: CollisionObject3D

@onready var camera_point: Node3D = $CameraPoint
@onready var raycast: RayCast3D = $CameraPoint/RayCast3D
@onready var freecam: Camera3D = $FreeCamera

@onready var standing_collider: CollisionShape3D = $StandingCollider
@onready var crouching_collider: CollisionShape3D = $CrouchingCollider
@onready var standing_mesh: MeshInstance3D = $StandingMesh
@onready var crouching_mesh: MeshInstance3D = $CrouchingMesh

func _init() -> void:
	me = self

func _ready() -> void:
	camera_request = PlayerCamera.main.request_camera(global_transform, self, false)
	capture_mouse()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"meta_exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.is_action_just_pressed(&"freecam_on"):
		detached_freecam = not detached_freecam
		if detached_freecam:
			freecam.make_current()
			freecam.global_transform = camera_point.global_transform
			controlling_freecam = true
		else:
			PlayerCamera.main.make_current()
			controlling_freecam = false
	if Input.is_action_just_pressed(&"freecam_swap"):
		controlling_freecam = not controlling_freecam
	
	var target_height := crouch_height if crouched else stand_height
	camera_point.position.y = lerpf(target_height, camera_point.position.y, exp(-delta * crouch_speed))
	
	PlayerCamera.main.edit_request_transform(camera_request, camera_point.global_transform)
	raycast.force_raycast_update()
	if raycast.get_collider() != looking_at:
		if looking_at:
			stopped_looking_at.emit(looking_at)
		looking_at = raycast.get_collider() as CollisionObject3D
		if looking_at:
			started_looking_at.emit(looking_at)

func _input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseButton:
			if event.is_pressed():
				capture_mouse()
	elif event is InputEventKey or event is InputEventMouseButton:
		input.emit(event)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			_rotate_camera(event.relative * 0.001)
	if Input.is_action_just_pressed(&"meta_exit"):
		#get_tree().quit()
		release_mouse()

func _rotate_camera(by: Vector2, sens_mod: float = 1.0) -> void:
	if controlling_freecam:
		freecam.rotation.x = clamp(freecam.rotation.x - by.y * sensitivity, -1.5, 1.5)
		freecam.rotation.y -= by.x * sensitivity
	elif PlayerCamera.main.has_camera(self):
		rotation.y -= by.x * sensitivity * sens_mod
		camera_point.rotation.x = clamp(camera_point.rotation.x - by.y * sensitivity * sens_mod, -1.5, 1.5)

func capture_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func release_mouse() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	var inp := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backward")
	var speed := sprint_speed if Input.is_action_pressed(&"move_sprint") and inp.y < 0 else walk_speed
	
	if controlling_freecam:
		var movement := Vector3(inp.x, Input.get_axis(&"move_crouch", &"move_jump"), inp.y)
		freecam.global_position += freecam.global_basis * movement * speed * 2 * delta
		inp = Vector2.ZERO
	
	var target_velocity := inp.rotated(-rotation.y) * speed
	var grip := ground_grip if is_on_floor() else air_grip
	var new_horizontal: Vector2 = lerp(target_velocity,  Vector2(velocity.x, velocity.z), exp(-delta * grip))
	velocity.x = new_horizontal.x
	velocity.z = new_horizontal.y
	
	if is_on_floor():
		if velocity.y < 0:
			velocity.y = 0
		if Input.is_action_just_pressed(&"move_crouch") and not controlling_freecam:
			if crouched:
				var query := PhysicsRayQueryParameters3D.new()
				query.from = position + Vector3(0, crouch_height, 0)
				query.to = position + Vector3(0, stand_height, 0)
				query.exclude = [get_rid()]
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
			velocity.y = jump_force
	elif not disable_gravity:
		velocity.y -= gravity * delta
	move_and_slide()
