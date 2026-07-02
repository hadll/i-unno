class_name RoomDef
extends Resource

## name of this room
@export var name: String
## scene to use for this room
@export var scene: PackedScene
## every grid space used by this room
@export var shape: Array[Vector3i]
## possible doors for this room (must be empty space)
@export var doors: Array[DoorDef]
## type of room, controls map colour
@export var type: LevelGenerator.RoomType

var pos := Vector3i.ZERO
var pos_x_dir := LevelGenerator.Direction.POS_X
var section: SectionDef

func transform(origin: Vector3i, new_pos_x_dir: LevelGenerator.Direction, offset: Vector3i) -> RoomDef:
	var transformed := new()
	transformed.name = name
	transformed.scene = scene
	transformed.shape = []
	for point in shape:
		transformed.shape.append(transform_point(origin, new_pos_x_dir, offset, point))
	transformed.doors = []
	for door in doors:
		transformed.doors.append(door.transform(origin, new_pos_x_dir, offset))
	transformed.type = type
	
	transformed.pos = transform_point(origin, new_pos_x_dir, offset, pos)
	transformed.pos_x_dir = LevelGenerator.dir_rotate(pos_x_dir,  new_pos_x_dir)
	return transformed

static func transform_point(origin: Vector3i, new_pos_x_dir: LevelGenerator.Direction, offset: Vector3i, point: Vector3i) -> Vector3i:
	match new_pos_x_dir:
		LevelGenerator.Direction.POS_X:
			return point - origin + offset
		LevelGenerator.Direction.POS_Z:
			return Vector3i(point.z - origin.z, point.y - origin.y, origin.x - point.x) + offset
		LevelGenerator.Direction.NEG_X:
			return origin - point + offset
		#LevelGenerator.Direction.NEG_Z:
		_:
			return Vector3i(origin.z - point.z, point.y - origin.y, point.x - origin.x) + offset
