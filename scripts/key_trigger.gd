@icon("res://assets/icons/key_trigger.png")
extends InteractionTrigger
class_name KeyTrigger

@export var use_action : bool

@export var action : String
@export var button : InputEventKey

func get_default_debug_print() -> String:
	return "Pressed"

func on_player_input(node: CollisionObject3D, event: InputEvent):
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
