@icon("res://assets/icons/trigger.png")
class_name Trigger
extends Node3D

## Fires once at the start of the event
signal trigger_start()
## Fires once at the end of the event
signal trigger_end()
## Fires every frame that the trigger is active
signal trigger()

var locked := false
var active := false

func _process(_delta: float) -> void:
	if active:
		trigger.emit()

func set_active(state: bool) -> void:
	if state == active or locked:
		return
	active = state
	if state:
		trigger_start.emit()
	else:
		trigger_end.emit()

func activate() -> void:
	set_active(true)

func deactivate() -> void:
	set_active(false)

func set_locked(state: bool) -> void:
	locked = state

func enable() -> void:
	set_locked(false)

func disable() -> void:
	set_locked(true)

func get_default_debug_print() -> String:
	return "Triggered"
