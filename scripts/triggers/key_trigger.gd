@icon("res://assets/icons/key_trigger_3d.png")
class_name KeyTrigger3D
extends InteractionTrigger3D

@export var use_action: bool

@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var action: StringName
@export var button: InputEventKey

func get_default_debug_print() -> String:
	return "Pressed"

func on_player_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if use_action:
		if event.is_action_pressed(action):
			activate()
		elif event.is_action_released(action):
			deactivate()
	elif event.is_match(button):
		if event.is_pressed():
			activate()
		elif event.is_released():
			deactivate()
