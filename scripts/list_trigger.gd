@icon("res://assets/icons/list_trigger.png")
extends Trigger
class_name ListTrigger

@export_category("triggers")
## a dictionary of triggers organised by (Trigger) : (Amount to change index by).
@export var triggers: Dictionary[Trigger, int] 

@export_category("settings")

## child index to start at.
@export var starting_index = 0 

## when this is true, a trigger with a value of 0 will be required to trigger any of the child triggers. when this is false, changing the index triggers the new selected child and untriggers the old one.
@export var use_zero_as_confirm = false 

## whether or not to have the selected trigger wrap around when reaching either extreme.
@export var wrap_index = true 

var trigger_children = true

var index = 0

var output_triggers = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	index = starting_index
	trigger_children = not use_zero_as_confirm
	self.child_entered_tree.connect(add_output_trigger)
	for trigger : Trigger in triggers.keys():
		trigger.trigger_start.connect(change_index)
		trigger.trigger_end.connect(disable_trigger_children)
	for child in self.get_children():
		add_output_trigger(child)

func add_output_trigger(child):
	if child is Trigger:
		output_triggers.append(child)

func increment_index(amount):
	if wrap_index:
		index = posmod((index + amount),output_triggers.size())
	else:
		index = clamp(index + amount,0, output_triggers.size()-1)

func change_index(trigger):
	if output_triggers.size() == 0:
		return
	if triggers[trigger] == 0 and not trigger_children:
		output_triggers[index].set_active(true)
		trigger_children = true
	elif not use_zero_as_confirm or trigger_children:
		output_triggers[index].set_active(false)
		increment_index(triggers[trigger])
		output_triggers[index].set_active(true)
	else:
		increment_index(triggers[trigger])

func disable_trigger_children(trigger):
	if not use_zero_as_confirm:
		return
	var found_active = false
	for trigger_i : Trigger in triggers.keys():
		if triggers[trigger_i] == 0 and trigger_i.active:
			found_active = true
			break
	if not found_active:
		trigger_children = false
		output_triggers[index].set_active(false)
	
