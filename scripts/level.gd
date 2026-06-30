class_name Level
extends Node3D

const ROOM_SCALE := Vector3(5, 5, 5)

@onready var level_generator: LevelGenerator = $LevelGenerator


func _ready() -> void:
	generate()

func generate() -> void:
	var placement_rng := RandomNumberGenerator.new()
	placement_rng.seed = level_generator.generate()
	Map.draw(level_generator)
	
	for room_def in level_generator.rooms:
		var room: GenerationObject = room_def.scene.instantiate()
		room.position = Vector3(room_def.pos) * ROOM_SCALE
		room.rotation.y = -LevelGenerator.dir_angle(room_def.pos_x_dir)
		add_child(room)
		room.generate(room_def.section, placement_rng)
	for door_def in level_generator.doors:
		var door: GenerationObject = level_generator.gen.door_scenes[door_def.type].instantiate()
		door.position = Vector3(door_def.from + door_def.get_target()) / 2.0 * ROOM_SCALE
		door.rotation.y = -LevelGenerator.dir_angle(door_def.dir) + PI * (randi() % 2)
		add_child(door)
		door.generate(door_def.section, placement_rng)
