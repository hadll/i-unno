class_name LevelGenerator
extends Node

const LOG_GEN := true

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

var spaces: Dictionary[Vector3i, RoomDef] = {}
var unfilled_doors: Array[DoorDef] = []
var doors: Dictionary[DoorDef, bool] = {}
var min_placed := Vector3i.ZERO
var max_placed := Vector3i.ZERO

static func rotate_dir(pos_x_dir: Direction, new_pos_x_dir: Direction) -> Direction:
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

func generate() -> void:
	var total_space := gen.map_size.x * gen.map_size.y * gen.map_size.z
	try_place(gen.start)
	for section_id in len(gen.sections):
		var section := gen.sections[section_id]
		if LOG_GEN: print("Generating Section %d" % section_id)
		while float(spaces.size()) / total_space <= section.required_density:
			var start_door_index = randi() % len(unfilled_doors)
			var start_door := unfilled_doors[start_door_index]
			var room_index = randi() % len(section.rooms)
			var room := section.rooms[room_index]
			var end_door_index = randi() % len(room.doors)
			var end_door := room.doors[end_door_index]
			var transformed := room.transform(
				end_door.from, 
				posmod(start_door.dir - end_door.dir + 2, 4) as Direction, 
				start_door.get_target()
			)
			try_place(transformed)
		while true:
			var start_door_index = randi() % len(unfilled_doors)
			var start_door := unfilled_doors[start_door_index]
			var end_door_index = randi() % (len(section.end.doors) - 1)
			var end_door := section.end.doors[end_door_index]
			var transformed := section.end.transform(
				end_door.from, 
				posmod(start_door.dir - end_door.dir + 2, 4) as Direction, 
				start_door.get_target()
			)
			if try_place(transformed, true):
				break
		
	if LOG_GEN: print("Generation Done")

func try_place(room_def: RoomDef, must_continue := false) -> bool:
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
	if LOG_GEN: print("Placed %s" % room_def.name)
	
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
