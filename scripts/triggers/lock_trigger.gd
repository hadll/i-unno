@icon("res://assets/icons/lock_trigger.png")
extends Trigger
class_name LockTrigger

@export var input_triggers: Array[Trigger]

@export var triggers_to_lock: Array[Trigger]

@export_category("Settings")
@export var deactivate_on_lock: bool

func _ready() -> void:
	for i_trigger in input_triggers:
		i_trigger.trigger_start.connect(on_trigger_start)
		i_trigger.trigger_end.connect(on_trigger_end)
		# you might want to remove this line depending on how you want it to behave
		if i_trigger.active:
			on_trigger_start(i_trigger)

func set_all_locked(state: bool) -> void:
	for i_trigger in triggers_to_lock:
		if deactivate_on_lock:
			i_trigger.deactivate()
		i_trigger.set_locked(state)

func are_any_triggered() -> bool:
	for i_trigger in input_triggers:
		if i_trigger.active:
			return true
	return false

func on_trigger_start(_t: Trigger):
	if are_any_triggered():
		set_all_locked(true)

func on_trigger_end(_t: Trigger):
	if not are_any_triggered():
		set_all_locked(false)
