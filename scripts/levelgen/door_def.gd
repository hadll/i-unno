class_name DoorDef
extends Resource

## type of door (only identical types can connect)
@export var type: LevelGenerator.DoorType
## space in the room that this door comes from
@export var from: Vector3i
## direction this door goes out to
@export var dir: LevelGenerator.Direction

func transform(origin: Vector3i, new_pos_x_dir: LevelGenerator.Direction, offset: Vector3i) -> DoorDef:
	var transformed := new()
	transformed.type = type
	transformed.from = RoomDef.transform_point(origin, new_pos_x_dir, offset, from)
	transformed.dir = LevelGenerator.dir_rotate(dir, new_pos_x_dir)
	return transformed

func get_target() -> Vector3i:
	return from + LevelGenerator.dir_vector(dir)
