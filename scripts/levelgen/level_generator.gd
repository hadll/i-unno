extends Node

const LOG_GEN := false
const MAX_CONSECUTIVE_FAILS := 128

enum Direction {
	POS_X = 0,
	POS_Z = 1,
	NEG_X = 2,
	NEG_Z = 3
}
enum RoomType {
	STANDARD = 0,
	
	START = 8,
	CHECKPOINT = 9,
}
enum DoorType {
	STANDARD = 0,
	WALL = 1,
}
var gen: GenerationDef = load("res://assets/levelgen/generation.tres")
var spaces: Dictionary[Vector3i, RoomDef]
var unfilled_doors: Array[DoorDef]
var rooms: Array[RoomDef]
var doors: Array[DoorDef]
var min_placed: Vector3i
var max_placed: Vector3i
var level_seed: int
var rng: RandomNumberGenerator

func dir_rotate(pos_x_dir: Direction, new_pos_x_dir: Direction) -> Direction:
	return posmod(pos_x_dir - new_pos_x_dir, 4) as Direction

func dir_vector(dir: Direction) -> Vector3i:
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

func dir_angle(dir: Direction) -> float:
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

func generate() -> int:
	var seed_finder := RandomNumberGenerator.new()
	if MultiplayerConnection.in_room:
		seed_finder.seed = hash(MultiplayerConnection.room_code)
	else:
		seed_finder.seed = randi()
	print("Generation Seed: %d" % seed_finder.seed)
	while not try_generate(seed_finder.randi()):
		if LOG_GEN: print("Generation Failed... Retrying")
		await get_tree().process_frame
	if LOG_GEN: print("Generation Done")
	return seed_finder.randi()

func try_generate(seed_value: int) -> bool:
	spaces = {}
	unfilled_doors = []
	rooms = []
	doors = []
	min_placed = Vector3i.ZERO
	max_placed = Vector3i.ZERO
	level_seed = seed_value
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	
	try_place(gen.start.transform(Vector3i.ZERO, Direction.POS_X, Vector3i.ZERO), gen.sections[0], null)
	var existing_density := 0.0
	var section_start_rough := Vector3i.ZERO
	for section_def in gen.sections:
		if LOG_GEN: print("Generating Section %s" % section_def.name)
		var holes: Array[Vector2i] = []
		for i in section_def.hole_density * gen.map_size.x * gen.map_size.y * 4:
			var at := Vector2i(rng.randi() % (gen.map_size.x * 2) - gen.map_size.x, rng.randi() % (gen.map_size.y * 2) - gen.map_size.y)
			if at in holes:
				continue
			holes.append(at)
			var size := int(rng.randf() * (1 + section_def.hole_size))
			for j in size:
				at += Vector2i(rng.randi() % 3 - 1, rng.randi() % 3 - 1)
				if at in holes:
					continue
				holes.append(at)
		
		var room_weight_total := 0.0
		for weight in section_def.rooms.values():
			room_weight_total += weight
		var room_list: Array[RoomDef] = []
		room_list.assign(section_def.rooms.keys())
		
		var consecutive_fails := 0
		while get_density() - existing_density <= section_def.required_density:
			var start_door_index = clampi(int(rng.randf()**(1 - section_def.sprawl) * len(unfilled_doors)), 0, len(unfilled_doors) - 1)
			var start_door := unfilled_doors[start_door_index]
			var room_weighted_choice := rng.randf() * room_weight_total
			var room_index := -1
			while room_weighted_choice >= 0.0:
				room_index += 1
				room_weighted_choice -= section_def.rooms[room_list[room_index]]
			var room := room_list[room_index]
			var end_door_index = rng.randi() % len(room.doors)
			var end_door := room.doors[end_door_index]
			var transformed := room.transform(
				end_door.from, 
				posmod(end_door.dir - start_door.dir + 2, 4) as Direction, 
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
			var start_door_index = clampi(int(rng.randf() * (1 - section_def.end_depth) * len(unfilled_doors)), 0, len(unfilled_doors) - 1)
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
	
	for room in rooms:
		room.pos -= min_placed
		for i in len(room.shape):
			room.shape[i] -= min_placed
	for door in doors:
		door.from -= min_placed
	
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
			cell.z <= max_added.z - gen.map_size.y or cell.z >= min_added.z + gen.map_size.y
		):
			return false
		min_added = min_added.min(cell)
		max_added = max_added.max(cell)
	# filter non matching doors
	if important_door:
		var important_door_connects := false
		var important_door_target := important_door.get_target()
		for door in room_def.doors:
			if door.from == important_door_target and door.get_target() == important_door.from:
				if door.type == important_door.type:
					important_door_connects = true
					break
				else:
					return false
		if not important_door_connects:
			push_error("Important Door failed to connect in %s" % room_def.name)
			return false
	
	min_placed = min_added
	max_placed = max_added
	if LOG_GEN: print("Placed %s in %s" % [room_def.name, section_def.name])
	
	room_def.section = section_def
	rooms.append(room_def)
	for cell in room_def.shape:
		spaces[cell] = room_def
	for door in room_def.doors:
		door.section = section_def
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
		var door := filled_doors[door_index]
		if door_index in paired_doors:
			continue
		var door_target := door.get_target()
		for pair_index in range(door_index + 1, len(filled_doors)):
			var pair := filled_doors[pair_index]
			if door.type == pair.type and door_target == pair.from and pair.get_target() == door.from:
				if door == important_door or rng.randf() < (
					section_def.duplicate_door_chance
					if spaces[door.from] in connected_rooms else 
					section_def.extra_door_chance
				):
					paired_doors.append(door_index)
					paired_doors.append(pair_index)
					unfilled_doors.erase(door)
					unfilled_doors.erase(pair)
					doors.append(door)
					connected_rooms.append(spaces[door.from])
				break
	# remove unpaired doors
	for door_index in len(filled_doors):
		if door_index in paired_doors:
			continue
		var door := filled_doors[door_index]
		if door == important_door:
			push_error("Removed important door during generation of %s" % room_def.name)
		door.type = DoorType.WALL
		unfilled_doors.erase(door)
		doors.append(door)
	# reset for next section
	if must_continue:
		for door_index in len(unfilled_doors) - 1:
			var door := unfilled_doors[door_index]
			door.type = DoorType.WALL
			doors.append(door)
		unfilled_doors = [room_def.doors[len(room_def.doors) - 1]]
	return true

func get_density() -> float:
	return float(spaces.size()) / (gen.map_size.x * gen.map_size.y)
