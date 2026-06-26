@icon("res://assets/icons/relay_trigger.png")
class_name RelayTrigger
extends Trigger

enum Condition {
	AND,
	OR,
	XOR,
	NAND,
	NOR,
	ONE
}

static var condition_functions: Dictionary[Condition, Callable] = {
	Condition.AND: cond_and,
	Condition.OR: cond_or,
	Condition.XOR: cond_xor,
	Condition.NAND: cond_nand,
	Condition.NOR: cond_nor,
	Condition.ONE: cond_one
}

@export var condition: Condition = Condition.OR
@export var triggers: Array[Trigger]

var triggered_triggers: Dictionary[int, bool] = {}

static func cond_and(input: Dictionary[int, bool]) -> bool:
	for trigger_active in input.values():
		if not trigger_active:
			return false
	return true

static func cond_or(input: Dictionary[int, bool]) -> bool:
	for trigger_active in input.values():
		if trigger_active:
			return true
	return false

static func count_triggers(input: Dictionary[int, bool]) -> int:
	var count = 0
	for trigger_active in input.values():
		if trigger_active:
			count += 1
	return count

static func cond_xor(input : Dictionary[int, bool]) -> bool:
	return count_triggers(input) % 2 == 1

static func cond_one(input : Dictionary[int, bool]) -> bool:
	return count_triggers(input) == 1

static func cond_nand(input : Dictionary[int, bool]) -> bool:
	return not cond_and(input)
	
static func cond_nor(input : Dictionary[int, bool]) -> bool:
	return not cond_or(input)

func _ready():
	for node in triggers:
		connect_trigger(node)

func on_trigger_start(node: Trigger) -> void:
	triggered_triggers[node.get_instance_id()] = true
	check_cond()

func on_trigger_end(node: Trigger) -> void:
	triggered_triggers[node.get_instance_id()] = false
	check_cond()

func connect_trigger(node: Trigger) -> void:
	node.trigger_start.connect(on_trigger_start)
	node.trigger_end.connect(on_trigger_end)
	triggered_triggers[node.get_instance_id()] = false

func check_cond() -> void:
	set_active(condition_functions[condition].call(triggered_triggers))
