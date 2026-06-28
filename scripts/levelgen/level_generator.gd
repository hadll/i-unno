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
var level_seed: int
var rng: RandomNumberGenerator

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
	var seed_finder := RandomNumberGenerator.new()
	if MultiplayerConnection.in_room:
		seed_finder.seed = hash(MultiplayerConnection.room_code)
	else:
		seed_finder.seed = randi()
	while not try_generate(seed_finder.randi()):
		if LOG_GEN: print("Generation Failed... Retrying")
	if LOG_GEN: print("Generation Done")

func try_generate(seed_value: int) -> bool:
	spaces = {}
	unfilled_doors = []
	rooms = {}
	doors = {}
	min_placed = Vector3i.ZERO
	max_placed = Vector3i.ZERO
	level_seed = seed_value
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	try_place(gen.start, gen.sections[0], null)
	var existing_density := 0.0
	var section_start_rough := Vector3i.ZERO
	for section_def in gen.sections:
		if LOG_GEN: print("Generating Section %s" % section_def.name)
		var holes: Array[Vector2i] = []
		for i in section_def.hole_density * gen.map_size.x * gen.map_size.z * 4:
			var at := Vector2i(rng.randi() % (gen.map_size.x * 2) - gen.map_size.x, rng.randi() % (gen.map_size.z * 2) - gen.map_size.z)
			if at in holes:
				continue
			holes.append(at)
			var size := int(rng.randf() * (1 + section_def.hole_size))
			for j in size:
				at += Vector2i(rng.randi() % 3 - 1, rng.randi() % 3 - 1)
				if at in holes:
					continue
				holes.append(at)
		
		var consecutive_fails := 0
		while get_density() - existing_density <= section_def.required_density:
			var start_door_index = int(rng.randf()**(1 - section_def.sprawl) * len(unfilled_doors))
			var start_door := unfilled_doors[start_door_index]
			var room_index = rng.randi() % len(section_def.rooms)
			var room := section_def.rooms[room_index]
			var end_door_index = rng.randi() % len(room.doors)
			var end_door := room.doors[end_door_index]
			var transformed := room.transform(
				end_door.from, 
				posmod(start_door.dir - end_door.dir + 2, 4) as Direction, 
				start_door.get_target()
			)
			var in_hole := false
			for cell in transformed.shape:
				if Vector2i(cell.x, cell.z) in holes:
					in_hole = true
					break
			if in_hole:
				continue
			if try_place(transformed, section_def, start_door):
				consecutive_fails = 0
			else:
				consecutive_fails += 1
			if consecutive_fails > MAX_CONSECUTIVE_FAILS:
				return false
		unfilled_doors.sort_custom(func(a: DoorDef, b: DoorDef) -> bool:
			return a.from.distance_squared_to(section_start_rough) > b.from.distance_squared_to(section_start_rough)
		)
		while true:
			var start_door_index = int(rng.randf() * (1 - section_def.end_depth) * len(unfilled_doors))
			var start_door := unfilled_doors[start_door_index]
			var end_door_index = rng.randi() % (len(section_def.end.doors) - 1)
			var end_door := section_def.end.doors[end_door_index]
			var transformed := section_def.end.transform(
				end_door.from, 
				posmod(start_door.dir - end_door.dir + 2, 4) as Direction, 
				start_door.get_target()
			)
			if try_place(transformed, section_def, start_door, true):
				break
			else:
				consecutive_fails += 1
			if consecutive_fails > MAX_CONSECUTIVE_FAILS:
				return false
		existing_density = get_density()
		section_start_rough = unfilled_doors[0].get_target()
	return true

func try_place(room_def: RoomDef, section_def: SectionDef, important_door: DoorDef, must_continue := false) -> bool:
	if must_continue and room_def.doors[len(room_def.doors) - 1].get_target() in spaces:
		return false
	# filter fitting
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
	# filter non matching doors
	if important_door:
		var important_door_target := important_door.get_target()
		for door in unfilled_doors:
			if door.from == important_door_target and door.get_target() == important_door.from:
				if door.type != important_door.type:
					return false
		
	min_placed = min_added
	max_placed = max_added
	rooms[room_def] = section_def
	if LOG_GEN: print("Placed %s in %s" % [room_def.name, section_def.name])
	
	for cell in room_def.shape:
		spaces[cell] = room_def
	for door in room_def.doors:
		unfilled_doors.append(door)
	
	# find now blocked doors
	var filled_doors: Array[DoorDef] = []
	for door in unfilled_doors:
		if door.get_target() in spaces:
			filled_doors.append(door)
	# find door pairs that connect
	var connected_rooms: Array[RoomDef] = []
	var paired_doors: Array[int] = []
	for door_index in len(filled_doors):
		if door_index in paired_doors:
			continue
		var door := filled_doors[door_index]
		var door_target := door.get_target()
		unfilled_doors.erase(door)
		for pair_index in range(door_index + 1, len(filled_doors)):
			var pair := filled_doors[door_index]
			if door.type == pair.type and door_target == pair.from and pair.get_target() == door.from:
				paired_doors.append(door_index)
				paired_doors.append(pair_index)
				if door == important_door or rng.randf() < (
					section_def.duplicate_door_chance 
					if spaces[door.from] in connected_rooms else 
					section_def.extra_door_chance
				):
					doors[door] = true
					connected_rooms.append(spaces[door.from])
				break
	# remove unpaired doors
	for door_index in len(filled_doors):
		if door_index in paired_doors:
			continue
		var door := filled_doors[door_index]
		if door not in doors:
			doors[door] = false
	# reset for next section
	if must_continue:
		unfilled_doors = [room_def.doors[len(room_def.doors) - 1]]
	return true

func get_density() -> float:
	return float(spaces.size()) / (gen.map_size.x * gen.map_size.z)
