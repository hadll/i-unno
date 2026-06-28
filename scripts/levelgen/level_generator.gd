class_name LevelGenerator
extends Node

const LOG_GEN := true
const MAX_CONSECUTIVE_FAILS := 128

enum Direction {
	POS_X = 0,
	POS_Z = 1,
	NEG_X = 2,
	NEG_Z = 3
}
enum DoorType {
	STANDARD = 0,
}

@export var gen: GenerationDef

var spaces: Dictionary[Vector3i, RoomDef]
var unfilled_doors: Array[DoorDef]
var rooms: Dictionary[RoomDef, SectionDef]
var doors: Dictionary[DoorDef, bool]
var min_placed: Vector3i
var max_placed: Vector3i

static func dir_rotate(pos_x_dir: Direction, new_pos_x_dir: Direction) -> Direction:
	return posmod(pos_x_dir - new_pos_x_dir, 4) as Direction

static func dir_vector(dir: Direction) -> Vector3i:
	match dir:
		Direction.POS_X:
			return Vector3i(1, 0, 0)
		Direction.POS_Z:
			return Vector3i(0, 0, 1)
		Direction.NEG_X:
			return Vector3i(-1, 0, 0)
		#Direction.NEG_Z:
		_:
			return Vector3i(0, 0, -1)

static func dir_angle(dir: Direction) -> float:
	match dir:
		Direction.POS_X:
			return 0
		Direction.POS_Z:
			return TAU/4
		Direction.NEG_X:
			return TAU/2
		#Direction.NEG_Z:
		_:
			return TAU*3/4

func generate() -> void:
	while not try_generate():
		if LOG_GEN: print("Generation Failed... Retrying")
	if LOG_GEN: print("Generation Done")

func try_generate() -> bool:
	spaces = {}
	unfilled_doors = []
	rooms = {}
	doors = {}
	min_placed = Vector3i.ZERO
	max_placed = Vector3i.ZERO
	
	try_place(gen.start, gen.sections[0])
	var existing_density := 0.0
	for section_def in gen.sections:
		if LOG_GEN: print("Generating Section %s" % section_def.name)
		var consecutive_fails := 0
		while get_density() - existing_density <= section_def.required_density:
			var start_door_index = randi() % len(unfilled_doors)
			var start_door := unfilled_doors[start_door_index]
			var room_index = randi() % len(section_def.rooms)
			var room := section_def.rooms[room_index]
			var end_door_index = randi() % len(room.doors)
			var end_door := room.doors[end_door_index]
			var transformed := room.transform(
				end_door.from, 
				posmod(start_door.dir - end_door.dir + 2, 4) as Direction, 
				start_door.get_target()
			)
			if try_place(transformed, section_def):
				consecutive_fails = 0
			else:
				consecutive_fails += 1
			if consecutive_fails > MAX_CONSECUTIVE_FAILS:
				return false
		while true:
			var start_door_index = randi() % len(unfilled_doors)
			var start_door := unfilled_doors[start_door_index]
			var end_door_index = randi() % (len(section_def.end.doors) - 1)
			var end_door := section_def.end.doors[end_door_index]
			var transformed := section_def.end.transform(
				end_door.from, 
				posmod(start_door.dir - end_door.dir + 2, 4) as Direction, 
				start_door.get_target()
			)
			if try_place(transformed, section_def, true):
				break
			else:
				consecutive_fails += 1
			if consecutive_fails > MAX_CONSECUTIVE_FAILS:
				return false
		existing_density = get_density()
	return true

func try_place(room_def: RoomDef, section_def: SectionDef, must_continue := false) -> bool:
	if must_continue and room_def.doors[len(room_def.doors) - 1].get_target() in spaces:
		return false
	var min_added := min_placed
	var max_added := max_placed
	for cell in room_def.shape:
		if cell in spaces or (
			cell.x <= max_added.x - gen.map_size.x or cell.x >= min_added.x + gen.map_size.x or
			cell.y <= max_added.y - gen.map_size.y or cell.y >= min_added.y + gen.map_size.y or
			cell.z <= max_added.z - gen.map_size.z or cell.z >= min_added.z + gen.map_size.z
		):
			return false
		min_added = min_added.min(cell)
		max_added = max_added.max(cell)
	min_placed = min_added
	max_placed = max_added
	rooms[room_def] = section_def
	if LOG_GEN: print("Placed %s in %s" % [room_def.name, section_def.name])
	
	for cell in room_def.shape:
		spaces[cell] = room_def
	for door in room_def.doors:
		unfilled_doors.append(door)
	
	var filled_doors: Array[DoorDef] = []
	for door in unfilled_doors:
		if door.get_target() in spaces:
			filled_doors.append(door)
	for door_index in len(filled_doors):
		var door := filled_doors[door_index]
		unfilled_doors.erase(door)
		for pair_index in range(door_index + 1, len(filled_doors)):
			var pair := filled_doors[door_index]
			if door.get_target() == pair.from and pair.get_target() == door.from:
				doors[door] = true
	for door in filled_doors:
		if door not in doors:
			doors[door] = false
	return true

func get_density() -> float:
	return float(spaces.size()) / (gen.map_size.x * gen.map_size.z)
