extends Node

const MAP_MARGIN := 16
const ROOM_SCALE := 16
const ROOM_MARGIN := 2
const DOOR_HALF_WIDTH := 2

const BACKGROUND_COLOUR := Color.WHITE
const ROOM_COLOUR := Color.TAN
const WALL_COLOUR := Color.BLACK

enum RoomPattern {
	NONE = 0,
	LONG = 1,
	LEFT_SHORT = 2,
	BOTH_LEFT = 3,
	RIGHT_SHORT = 4,
	BOTH_SHORT = 6,
}

@export var layers: Array[Image]

func draw(level_generator: LevelGenerator) -> void:
	clear(level_generator.gen.map_size)
	for room_def in level_generator.rooms:
		draw_room(room_def)
	for door_def in level_generator.doors:
		if door_def.type != LevelGenerator.DoorType.WALL:
			draw_door(door_def)

func add_files(dir: TerminalDir) -> void:
	for i in len(layers):
		var map_file := TerminalImageFile.new()
		map_file.name = Terminal.trans_name_item_to_node("floor-%02d.png" % (i + 1))
		map_file.content = layers[i]
		dir.add_child(map_file)

func clear(map_size: Vector3i) -> void:
	var width := MAP_MARGIN * 2 + ROOM_SCALE * map_size.x
	var height := MAP_MARGIN * 2 + ROOM_SCALE * map_size.z
	layers = []
	for y in map_size.y:
		layers.append(Image.create_empty(width, height, false, Image.FORMAT_RGB8))
		layers[y].fill(BACKGROUND_COLOUR)

func draw_room(room_def: RoomDef) -> void:
	for cell in room_def.shape:
		var top_left := Vector2i(MAP_MARGIN, MAP_MARGIN) + Vector2i(cell.x, cell.z) * ROOM_SCALE
		
		var up := cell + Vector3i.FORWARD in room_def.shape
		var down := cell + Vector3i.BACK in room_def.shape
		var left := cell + Vector3i.LEFT in room_def.shape
		var right := cell + Vector3i.RIGHT in room_def.shape
		var up_left := cell + Vector3i.FORWARD + Vector3i.LEFT in room_def.shape
		var up_right := cell + Vector3i.FORWARD + Vector3i.RIGHT in room_def.shape
		var down_left := cell + Vector3i.BACK + Vector3i.LEFT in room_def.shape
		var down_right := cell + Vector3i.BACK + Vector3i.RIGHT in room_def.shape
		
		var up_pattern := room_corner_pattern(left, up, up_left)
		var right_pattern := room_corner_pattern(up, right, up_right)
		var down_pattern := room_corner_pattern(right, down, down_right)
		var left_pattern := room_corner_pattern(down, left, down_left)
		
		for i in range(ROOM_MARGIN + 1, ROOM_SCALE - 1 - ROOM_MARGIN):
			for y in range(ROOM_MARGIN + 1, ROOM_SCALE - 1 - ROOM_MARGIN):
				layers[cell.y].set_pixel(top_left.x + i, top_left.y + y, ROOM_COLOUR)
			for m in range(ROOM_MARGIN + 1):
				if not up_pattern & RoomPattern.LONG:
					layers[cell.y].set_pixel(top_left.x + i, top_left.y + m, ROOM_COLOUR)
				if not right_pattern & RoomPattern.LONG:
					layers[cell.y].set_pixel(top_left.x + ROOM_SCALE - 1 - m, top_left.y + i, ROOM_COLOUR)
				if not down_pattern & RoomPattern.LONG:
					layers[cell.y].set_pixel(top_left.x + i, top_left.y + ROOM_SCALE - 1 - m, ROOM_COLOUR)
				if not left_pattern & RoomPattern.LONG:
					layers[cell.y].set_pixel(top_left.x + m, top_left.y + i, ROOM_COLOUR)
		
		for i in range(ROOM_MARGIN, ROOM_SCALE - ROOM_MARGIN):
			if up_pattern & RoomPattern.LONG:
				layers[cell.y].set_pixel(top_left.x + i, top_left.y + ROOM_MARGIN, WALL_COLOUR)
			if right_pattern & RoomPattern.LONG:
				layers[cell.y].set_pixel(top_left.x + ROOM_SCALE - 1 - ROOM_MARGIN, top_left.y + i, WALL_COLOUR)
			if down_pattern & RoomPattern.LONG:
				layers[cell.y].set_pixel(top_left.x + i, top_left.y + ROOM_SCALE - 1 - ROOM_MARGIN, WALL_COLOUR)
			if left_pattern & RoomPattern.LONG:
				layers[cell.y].set_pixel(top_left.x + ROOM_MARGIN, top_left.y + i, WALL_COLOUR)
		
		for i in range(ROOM_MARGIN + 1):
			for m in range(ROOM_MARGIN + 1):
				if not up_pattern:
					layers[cell.y].set_pixel(top_left.x + i, top_left.y + m, ROOM_COLOUR)
				if not right_pattern:
					layers[cell.y].set_pixel(top_left.x + ROOM_SCALE - 1 - ROOM_MARGIN + i, top_left.y + m, ROOM_COLOUR)
				if not down_pattern:
					layers[cell.y].set_pixel(top_left.x + ROOM_SCALE - 1 - m, top_left.y + ROOM_SCALE - 1 - ROOM_MARGIN + i, ROOM_COLOUR)
				if not left_pattern:
					layers[cell.y].set_pixel(top_left.x + i, top_left.y + ROOM_SCALE - 1 - m, ROOM_COLOUR)
			if up_pattern & RoomPattern.LEFT_SHORT:
				layers[cell.y].set_pixel(top_left.x + i, top_left.y + ROOM_MARGIN, WALL_COLOUR)
			if up_pattern & RoomPattern.RIGHT_SHORT:
				layers[cell.y].set_pixel(top_left.x + ROOM_MARGIN, top_left.y + i, WALL_COLOUR)
			if right_pattern & RoomPattern.LEFT_SHORT:
				layers[cell.y].set_pixel(top_left.x + ROOM_SCALE - 1 - ROOM_MARGIN, top_left.y + i, WALL_COLOUR)
			if right_pattern & RoomPattern.RIGHT_SHORT:
				layers[cell.y].set_pixel(top_left.x + ROOM_SCALE - 1 - ROOM_MARGIN + i, top_left.y + ROOM_MARGIN, WALL_COLOUR)
			if down_pattern & RoomPattern.LEFT_SHORT:
				layers[cell.y].set_pixel(top_left.x + ROOM_SCALE - 1 - ROOM_MARGIN + i, top_left.y + ROOM_SCALE - 1 - ROOM_MARGIN, WALL_COLOUR)
			if down_pattern & RoomPattern.RIGHT_SHORT:
				layers[cell.y].set_pixel(top_left.x + ROOM_SCALE - 1 - ROOM_MARGIN, top_left.y + ROOM_SCALE - 1 - ROOM_MARGIN + i, WALL_COLOUR)
			if left_pattern & RoomPattern.LEFT_SHORT:
				layers[cell.y].set_pixel(top_left.x + ROOM_MARGIN, top_left.y + ROOM_SCALE - 1 - ROOM_MARGIN + i, WALL_COLOUR)
			if left_pattern & RoomPattern.RIGHT_SHORT:
				layers[cell.y].set_pixel(top_left.x + i, top_left.y + ROOM_SCALE - 1 - ROOM_MARGIN, WALL_COLOUR)

func draw_door(door_def: DoorDef) -> void:
	var from := Vector2i(door_def.from.x, door_def.from.z)
	var dir := LevelGenerator.dir_vector(door_def.dir)
	var sum := from * 2 + Vector2i(dir.x + 1, dir.z + 1)
	@warning_ignore("integer_division")
	var middle := Vector2i(MAP_MARGIN, MAP_MARGIN) + sum * Vector2i(ROOM_SCALE, ROOM_SCALE) / 2
	var horz := dir.x != 0
	for w in range(-DOOR_HALF_WIDTH, DOOR_HALF_WIDTH):
		var colour := WALL_COLOUR if w == DOOR_HALF_WIDTH - 1 or w == -DOOR_HALF_WIDTH else ROOM_COLOUR
		for l in range(-ROOM_MARGIN - 1, ROOM_MARGIN + 1):
			layers[door_def.from.y].set_pixel(middle.x + (l if horz else w), middle.y + (w if horz else l), colour)


func room_corner_pattern(left: bool, right: bool, corner: bool) -> RoomPattern:
	if left and right and corner:
		return RoomPattern.NONE
	if left and right:
		return RoomPattern.BOTH_SHORT
	if left:
		return RoomPattern.BOTH_LEFT
	if right:
		return RoomPattern.RIGHT_SHORT
	return RoomPattern.LONG
