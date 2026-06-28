class_name Level
extends Node3D

const ROOM_SCALE := Vector3i(5, 5, 5)

@onready var level_generator: LevelGenerator = $LevelGenerator

func generate() -> void:
	level_generator.generate()
	for room_def in level_generator.rooms:
		var section_def := level_generator.rooms[room_def]
		var room: Room = room_def.scene.instantiate()
		room.position = room_def.pos * ROOM_SCALE
		room.rotation.y = -LevelGenerator.dir_angle(room_def.pos_x_dir)
		room.scale = Vector3(0.9, 0.9, 0.9)
		room.generate(section_def)
		add_child(room)
