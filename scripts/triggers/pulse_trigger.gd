extends Trigger
class_name PulseTrigger

#use whichever one youd prefer 
@export var triggers: Array[Trigger]

@export_category("Settings")
@export var on_release = false ##makes the pulse happen when the trigger ends instead

func _ready() -> void:
	for i_trigger in triggers:
		i_trigger.trigger_start.connect(on_trigger_start.bind(i_trigger))
		i_trigger.trigger_end.connect(on_trigger_end.bind(i_trigger))
		# you might want to remove this line depending on how you want it to behave
		if i_trigger.active:
			on_trigger_start(i_trigger)

func on_trigger_start(trigger: Trigger):
	print("wawa")
	if not on_release:
		set_active(true)
		set_active(false)

func on_trigger_end(trigger:Trigger):
	if on_release:
		set_active(true)
		set_active(false)
