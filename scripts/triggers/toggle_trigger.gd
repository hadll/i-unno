@icon("res://assets/icons/toggle_trigger.png")
extends Trigger
class_name ToggleTrigger

enum MODES{
	OFF,
	ON,
	TOGGLE
}

var mode_funcs = {
	MODES.OFF: trigger_off,
	MODES.ON: trigger_on,
	MODES.TOGGLE: trigger_toggle
}

#use whichever one youd prefer 
@export var triggers: Dictionary[Trigger, MODES] 

func trigger_off():
	set_active(false)

func trigger_on():
	set_active(true)

func trigger_toggle():
	set_active(not active)

func _ready() -> void:
	for i_trigger in triggers:
		i_trigger.trigger_start.connect(on_trigger_start)
		# you might want to remove this line depending on how you want it to behave
		if i_trigger.active:
			on_trigger_start(i_trigger)

func on_trigger_start(t: Trigger):
	mode_funcs[triggers[t]].call()
