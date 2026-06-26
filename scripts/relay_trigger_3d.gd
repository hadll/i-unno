@icon("res://assets/icons/relay_trigger.png")
extends Trigger
class_name RelayTrigger

enum CONDITIONS{
	AND,
	OR,
	XOR,
	NAND,
	NOR,
	ONE
}

var condition_functions = {
	CONDITIONS.AND: cond_and,
	CONDITIONS.OR: cond_or,
	CONDITIONS.XOR: cond_xor,
	CONDITIONS.NAND: cond_nand,
	CONDITIONS.NOR: cond_nor,
	CONDITIONS.ONE: cond_one
}

@export var condition : CONDITIONS = CONDITIONS.OR
@export var triggers : Array[Trigger]

var triggered_triggers = {}

func on_trigger_start(node: Trigger):
	triggered_triggers[node.unique_key] = true
	check_cond()
func on_trigger_end(node: Trigger):
	triggered_triggers[node.unique_key] = false
	check_cond()


func connect_trigger(node: Trigger):
	node.trigger_start.connect(on_trigger_start)
	node.trigger_end.connect(on_trigger_end)
	triggered_triggers[node.unique_key] = false

func cond_and(input : Dictionary):
	for trigger_active in input.values():
		if !trigger_active:
			return false
	return true

func cond_or(input : Dictionary):
	for trigger_active in input.values():
		if trigger_active:
			return true
	return false

func count_triggers(input : Dictionary):
	var count = 0
	for trigger_active in input.values():
		if trigger_active:
			count += 1
	return count

func cond_xor(input : Dictionary):
	return count_triggers(input)%2 == 1

func cond_one(input : Dictionary):
	return count_triggers(input) == 1

func cond_nand(input : Dictionary):
	return !cond_and(input)
	
func cond_nor(input : Dictionary):
	return !cond_or(input)

func check_cond():
	set_active(condition_functions[condition].call(triggered_triggers))

func _ready():
	for node in triggers:
		connect_trigger(node)
