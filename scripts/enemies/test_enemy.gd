class_name TestEnemy
extends Enemy

@export var body: CharacterBody3D
@export var agent: NavigationAgent3D
@export var nav_timer: Timer
@export var speed := 1.0

func _ready() -> void:
	nav_timer.timeout.connect(update_nav)

func _physics_process(_delta: float) -> void:
	var target := agent.get_next_path_position()
	var dir := (target - body.global_position).normalized()
	body.velocity = dir * speed
	body.move_and_slide()

func update_nav() -> void:
	target_player()

func target_player() -> void:
	agent.set_target_position(Player.me.global_position)
