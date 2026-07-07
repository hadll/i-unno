extends Trigger
class_name BufferTrigger

enum Delays{
	BEFORE_START, ##Adds a delay before the trigger_start event is sent
	AFTER_START, ##Adds a delay after the trigger_start event before the trigger_end event can be sent
	BEFORE_END, ##Adds a delay before the trigger_end event is sent
	AFTER_END ##Adds a delay after the trigger_end event preventing the trigger_start event from being sent
}

#use whichever one youd prefer 
@export var input_trigger: Trigger

@export_category("Settings")
@export var delay_type: Delays
@export var delay_amount: float

func _ready() -> void:
	input_trigger.trigger_start.connect(on_trigger_start.bind(input_trigger))
	input_trigger.trigger_end.connect(on_trigger_end.bind(input_trigger))
	# you might want to remove this line depending on how you want it to behave
	if input_trigger.active:
		on_trigger_start(input_trigger)

func on_trigger_start(trigger: Trigger):
	# this runs whenever a trigger in the triggers array starts
	pass

func on_trigger_end(trigger:Trigger):
	# this runs whenever a trigger in the triggers array ends
	pass
