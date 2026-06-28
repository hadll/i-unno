class_name Level
extends Node3D

const ROOM_SCALE := Vector3(5, 5, 5)

@onready var level_generator: LevelGenerator = $LevelGenerator


func _ready() -> void:
	generate()

func generate() -> void:
	level_generator.generate()
	for room_def in level_generator.rooms:
		var section_def := level_generator.rooms[room_def]
		var room: Room = room_def.scene.instantiate()
		room.position = Vector3(room_def.pos) * ROOM_SCALE
		room.rotation.y = -LevelGenerator.dir_angle(room_def.pos_x_dir)
		room.scale = Vector3(0.9, 0.9, 0.9)
		room.generate(section_def)
		add_child(room)
	for door_def in level_generator.doors:
		var section_def := level_generator.doors[door_def]
		var door: Door = level_generator.gen.door_scenes[door_def.type].instantiate()
		door.position = Vector3(door_def.from + door_def.get_target()) / 2.0 * ROOM_SCALE
		door.rotation.y = -LevelGenerator.dir_angle(door_def.dir)
		door.generate(section_def)
		add_child(door)
