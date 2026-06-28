@icon("res://assets/icons/trigger.png")
class_name Trigger
extends Node3D

## Fires once at the start of the event
signal trigger_start(t: Trigger)
## Fires once at the end of the event
signal trigger_end(t: Trigger)
## Fires every frame that the trigger is active
signal trigger(t: Trigger)

var able := true
var active := false

func _process(_delta: float) -> void:
	if active:
		trigger.emit(self)

func set_active(state: bool) -> void:
	if state == active:
		return
	active = state
	if state:
		trigger_start.emit(self)
	else:
		trigger_end.emit(self)

func set_able(state: bool) -> void:
	able = state

func enable():
	set_able(true)

func disable():
	set_able(false)

func get_default_debug_print() -> String:
	return "Triggered"
