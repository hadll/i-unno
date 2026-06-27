@icon("res://assets/icons/auto_trigger.png")
class_name AutoTrigger
extends Trigger

enum Behaviour {
	PULSE, ##triggers start and end immediately upon being added to the scene
	HOLD ##triggers only start immediately upon being added to the scene
}

var behavior_functions: Dictionary[Behaviour, Callable]= {
	Behaviour.PULSE: beh_pulse, 
	Behaviour.HOLD: beh_hold
}

@export var behavior := Behaviour.PULSE

func _ready() -> void:
	behavior_functions[behavior].call()

func beh_pulse() -> void:
	set_active(true)
	set_active(false)

func beh_hold() -> void:
	set_active(true)
