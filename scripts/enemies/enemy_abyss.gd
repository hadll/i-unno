class_name EnemyAbyss
extends Enemy

static var closest: EnemyAbyss
static var closest_dist: float

@export var audio_player: AudioStreamPlayer3D
@export var wait_timer: Timer
@export var mesh: MeshInstance3D
@export var min_wait_time: float
@export var max_wait_time: float
@export var speed: float
@export var grip: float
@export var float_height: float
@export var size: float
@export var sanity_drain: float
@export var size_gain: float
@export var distortion_distance: float
@export var distortion_falloff: float
@export var distortion_strength: float

var target_position: Vector3
var velocity := Vector3.ZERO

var audio_playback: AudioStreamGeneratorPlayback
var audio_sample_rate: float
var audio_sin_t := 0.0
var audio_saw_t := 0.0
var audio_sqr_t := 0.0

func _ready() -> void:
	wait_timer.timeout.connect(pick_new_target)
	audio_playback = audio_player.get_stream_playback() as AudioStreamGeneratorPlayback
	audio_sample_rate = (audio_player.stream as AudioStreamGenerator).mix_rate

func _process(delta: float) -> void:
	var offset := global_position - PlayerCamera.global_position
	var distance := offset.length()
	var distortion := maxf(0.0, 1.0 - pow(distance / distortion_distance, distortion_falloff))
	var screen_pos := PlayerCamera.unproject_position(global_position)
	var centre := (screen_pos / Vector2(get_window().size))
	var on_screen := centre.x >= 0.0 and centre.x <= 1.0 and centre.y >= 0.0 and centre.y <= 1.0
	centre = centre.clampf(0.0, 1.0)
	var camera_angle_factor := maxf(0.0, PlayerCamera.global_basis.z.angle_to(offset) / TAU * 4 - 1.0)
	
	if on_screen:
		Player.me.reduce_sanity(distortion * camera_angle_factor * sanity_drain * delta)
	
	if not closest or closest == self or distance < closest_dist:
		closest = self
		closest_dist = distance
		var mat := PostProcessing.get_distortion_material()
		mat.set_shader_parameter(&"distortion", distortion * camera_angle_factor * distortion_strength)
		mat.set_shader_parameter(&"centre", centre)
	
	generate_audio(distortion)
	
	mesh.scale = Vector3.ONE * (size + size_gain * (1.0 - Player.me.calmness))

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
		randf_range(-1.0, 1.0) + float_height,
		randf_range(-2.0, 2.0),
	)

func generate_audio(distortion: float) -> void:
	var hz := pow(5.0 + 20.0 * (randf() * lerpf(0.4, 1.0, distortion)), 2.0)
	var increment := hz / audio_sample_rate
	var quant := exp(lerpf(log(audio_sample_rate) * 0.5, 0.0, pow(distortion, 0.35)))
	for f in range(audio_playback.get_frames_available()):
		var sin_t := floorf(audio_sin_t * quant) / quant + randf() * distortion * 0.5
		var saw_t := floorf(audio_saw_t * quant) / quant + randf() * distortion * 0.5
		var sqr_t := floorf(audio_sqr_t * quant) / quant + randf() * distortion * 0.5
		audio_playback.push_frame(Vector2.ONE * (sin(sin_t * TAU) + saw_t - 0.5 + (0.4 if sqr_t > 0.5 else -0.4)))
		audio_sin_t = fmod(audio_sin_t + increment, 1.0)
		audio_saw_t = fmod(audio_saw_t + increment * 1.6345893, 1.0)
		audio_sqr_t = fmod(audio_sqr_t + increment * 0.7376426, 1.0)
