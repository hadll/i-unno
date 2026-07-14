class_name EnemyAbyss
extends Enemy

@export var wait_timer: Timer
@export var min_wait_time: float
@export var max_wait_time: float
@export var speed: float
@export var grip: float
@export var float_height: float
@export var size: float

var target_position: Vector3
var velocity := Vector3.ZERO

func generate(_section_def: SectionDef, _rng: RandomNumberGenerator) -> void:
	wait_timer.timeout.connect(pick_new_target)

func _physics_process(delta: float) -> void:
	var offset := target_position - global_position
	var desired := Vector3.ZERO
	if offset.length_squared() > 1.0:
		desired = offset.normalized() * speed
	else:
		reached_target()
	velocity = desired.lerp(velocity, exp(-delta * grip))
	global_position += velocity * delta

func reached_target() -> void:
	wait_timer.start(maxf(0.0, randf_range(min_wait_time, max_wait_time)))

func set_target_position(to: Vector3) -> void:
	target_position = to + Vector3(
		randf_range(-2.0, 2.0),
		randf_range(-1.0, 1.0),
		randf_range(-2.0, 2.0),
	)
