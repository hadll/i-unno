@icon("res://assets/icons/auto_trigger.png")
extends Trigger
class_name AutoTrigger

enum BEHAVIORS{
	PULSE, ##triggers start and end immediately upon being added to the scene
	HOLD ##triggers only start immediately upon being added to the scene
}

var behavior_functions = {
	BEHAVIORS.PULSE: beh_pulse, 
	BEHAVIORS.HOLD: beh_hold
}

@export var behavior : BEHAVIORS = BEHAVIORS.PULSE

func beh_pulse():
	set_active(true)
	set_active(false)

func beh_hold():
	set_active(true)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	behavior_functions[behavior].call()
