class_name RoomDef
extends Resource

@export var name: String
@export var scene: PackedScene
@export var shape: Array[Vector3i]
@export var doors: Array[DoorDef]

var pos_x_dir := LevelGenerator.Direction.POS_X

func transform(origin: Vector3i, new_pos_x_dir: LevelGenerator.Direction, pos: Vector3i) -> RoomDef:
	var transformed := new()
	transformed.name = name
	transformed.scene = scene
	transformed.shape = []
	for point in shape:
		transformed.shape.append(transform_point(origin, new_pos_x_dir, pos, point))
	transformed.doors = []
	for door in doors:
		transformed.doors.append(door.transform(origin, new_pos_x_dir, pos))
	transformed.pos_x_dir = LevelGenerator.rotate_dir(pos_x_dir,  new_pos_x_dir)
	return transformed

static func transform_point(origin: Vector3i, new_pos_x_dir: LevelGenerator.Direction, pos: Vector3i, point: Vector3i) -> Vector3i:
	match new_pos_x_dir:
		LevelGenerator.Direction.POS_X:
			return point - origin + pos
		LevelGenerator.Direction.POS_Z:
			return Vector3i(point.z - origin.z, point.y - origin.y, origin.x - point.x) + pos
		LevelGenerator.Direction.NEG_X:
			return origin - point + pos
		#LevelGenerator.Direction.NEG_Z:
		_:
			return Vector3i(origin.z - point.z, point.y - origin.y, point.x - origin.x) + pos
