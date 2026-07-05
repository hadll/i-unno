@icon("res://assets/icons/axis_trigger-alt.png")
extends Trigger
class_name AxisTrigger

enum Directions{
	LEFT,
	RIGHT,
	UP,
	DOWN,
	NEUTRAL
}

var direction_map = {
	Directions.LEFT: Vector2.LEFT,
	Directions.RIGHT: Vector2.RIGHT,
	Directions.UP: Vector2.UP,
	Directions.DOWN: Vector2.DOWN,
	Directions.NEUTRAL: Vector2.ZERO
}

#use whichever one youd prefer 
@export var triggers: Dictionary[Trigger, Directions] 

@export var output_triggers: Dictionary[Directions, Trigger]

@export_category("Settings")
@export var allow_multiple_outputs := false

var pressed_order = []

func _ready() -> void:
	for i_trigger in triggers.keys():
		i_trigger.trigger_start.connect(on_trigger_start.bind(i_trigger))
		i_trigger.trigger_end.connect(on_trigger_end.bind(i_trigger))
		# you might want to remove this line depending on how you want it to behave
	update()

func evaluate_net_vector() -> Vector2: #this vector is intentionally non normalised
	var used_directions = []
	var net_vector = Vector2.ZERO
	for i_trigger in triggers.keys():
		if i_trigger.active and not triggers[i_trigger] in used_directions:
			used_directions.append(triggers[i_trigger])
			net_vector += direction_map[triggers[i_trigger]]
	return net_vector

func get_directions_from_vector(vec: Vector2) -> Array:
	var applicable_vectors = []
	if vec.x >= 1:
		applicable_vectors.append(Directions.RIGHT)
	elif vec.x <= -1:
		applicable_vectors.append(Directions.LEFT)
	if vec.y >= 1:
		applicable_vectors.append(Directions.DOWN)
	elif vec.y <= -1:
		applicable_vectors.append(Directions.UP)
	elif len(applicable_vectors) == 0:
		applicable_vectors.append(Directions.NEUTRAL)
	return applicable_vectors

func get_newest_direction(dirs: Array) -> Array:
	for i in range(len(pressed_order)):
		print(i, pressed_order[len(pressed_order)-i-1])
		if triggers[pressed_order[len(pressed_order)-i-1]] in dirs:
			return [triggers[pressed_order[len(pressed_order)-i-1]]]
	return [Directions.NEUTRAL]

func activate_triggers(dirs: Array):
	if not allow_multiple_outputs:
		dirs = get_newest_direction(dirs) # seperate function in case we want more behaviors
	for dir in output_triggers.keys():
		output_triggers[dir].set_active(dir in dirs)

func update():
	var dir = evaluate_net_vector()
	dir = get_directions_from_vector(dir)
	activate_triggers(dir)

func on_trigger_start(i_trigger: Trigger):
	pressed_order.append(i_trigger)
	update()

func on_trigger_end(i_trigger: Trigger):
	for i in range(len(pressed_order)):
		if pressed_order[len(pressed_order)-i-1] == i_trigger:
			pressed_order.remove_at(len(pressed_order)-i-1)
	update()
