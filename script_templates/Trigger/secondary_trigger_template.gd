# meta-description: A template for triggers triggered by other triggers, such as relays and lists
extends _BASE_
class_name _CLASS_

#use whichever one youd prefer 
@export var triggers: Array[Trigger]
@export var triggers: Dictionary[Trigger, TYPE] 


func _ready() -> void:
	for i_trigger in triggers:
		i_trigger.trigger_start.connect(on_trigger_start)
		i_trigger.trigger_start.connect(on_trigger_end)

func on_trigger_start(trigger: Trigger):
	# this runs whenever a trigger in the triggers array starts
	pass

func on_trigger_end(trigger:Trigger):
	# this runs whenever a trigger in the triggers array ends
	pass
