@icon("res://assets/icons/trigger.png")
@abstract
extends Node3D
class_name Trigger

## Fires once at the start of the event
signal trigger_start
## Fires once at the end of the event
signal trigger_end
## Fires every frame that the trigger is active
signal trigger

var able = true
var active = false

@onready var unique_key: String = str(self.get_path()) 

func set_active(state:bool):
	if state==active:
		return
	active = state
	if state:
		trigger_start.emit(self)
	else:
		trigger_end.emit(self)

func set_able(state:bool):
	able = state

func enable():
	set_able(true)

func disable():
	set_able(false)

func _process(_delta: float) -> void:
	if active:
		trigger.emit(self)

func get_default_debug_print() -> String:
	return "Triggered"
