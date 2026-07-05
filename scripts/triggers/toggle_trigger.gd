@icon("res://assets/icons/toggle_trigger.png")
extends Trigger
class_name ToggleTrigger

enum Mode {
	OFF = 0,
	ON = 1,
	TOGGLE = 2
}

var mode_funcs: Dictionary[Mode, Callable] = {
	Mode.OFF: deactivate,
	Mode.ON: activate,
	Mode.TOGGLE: trigger_toggle
}

#use whichever one youd prefer 
@export var triggers: Dictionary[Trigger, Mode] 

func trigger_toggle() -> void:
	set_active(not active)

func _ready() -> void:
	for i_trigger in triggers:
		i_trigger.trigger_start.connect(on_trigger_start.bind(i_trigger))
		# you might want to remove this line depending on how you want it to behave
		if i_trigger.active:
			on_trigger_start(i_trigger)

func on_trigger_start(i_trigger: Trigger) -> void:
	mode_funcs[triggers[i_trigger]].call()
