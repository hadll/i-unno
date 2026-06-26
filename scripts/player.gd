extends CharacterBody3D
class_name Player

static var me: Player

signal input(event: InputEvent)
signal started_looking_at(collider: CollisionObject3D)
signal stopped_looking_at(collider: CollisionObject3D)

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var camera : PlayerCamera
var camera_request 

@onready var camera_point = $CameraPoint
@onready var raycast = $CameraPoint/RayCast3D

var look_dir: Vector2 # Input direction for look/aim
var mouse_captured: bool = false
var looking_at: CollisionObject3D

@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1

func _ready() -> void:
	me = self
	camera = get_tree().current_scene.player_camera 
	camera_request = camera.request_camera(global_transform, self, false)
	capture_mouse()

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouseButton:
		raycast.force_raycast_update()
		if raycast.get_collider() != looking_at:
			if looking_at:
				stopped_looking_at.emit(looking_at)
			looking_at = raycast.get_collider()
			if looking_at:
				started_looking_at.emit(looking_at)
		input.emit(event)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured && camera.has_camera(self): _rotate_camera()
	if Input.is_action_just_pressed("meta_exit"):
		#get_tree().quit()
		release_mouse()

func _rotate_camera(sens_mod: float = 1.0) -> void:
	self.rotation.y -= look_dir.x * camera_sens * sens_mod
	camera_point.rotation.x = clamp(camera_point.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _process(_delta: float) -> void:
	camera.edit_request_transform(camera_request, $CameraPoint.global_transform)
