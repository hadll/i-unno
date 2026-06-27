@icon("res://assets/icons/key_trigger_3d.png")
class_name KeyTrigger3D
extends InteractionTrigger3D

@export var use_action: bool

@export var action: StringName
@export var button: InputEventKey

func get_default_debug_print() -> String:
	return "Pressed"

func on_player_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if use_action:
		if event.is_action_pressed(action):
			set_active(true)
		elif event.is_action_released(action):
			set_active(false)
	elif event.is_match(button):
		if event.is_pressed():
			set_active(true)
		elif event.is_released():
			set_active(false)
