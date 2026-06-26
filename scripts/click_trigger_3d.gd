@icon("res://assets/icons/click_trigger.png")
extends InteractionTrigger3D
class_name ClickTrigger3D

enum BUTTONS{
	LEFT_CLICK,
	RIGHT_CLICK,
	MIDDLE_CLICK,
	SCROLL_UP,
	SCROLL_DOWN
}

@export var button : BUTTONS

func get_default_debug_print() -> String:
	return "Clicked"

func on_player_input(node: CollisionObject3D, event: InputEvent):
	if event is InputEventMouseButton:
		if button == BUTTONS.LEFT_CLICK && event.button_index == MOUSE_BUTTON_LEFT:
			set_active(event.is_pressed())
		elif button == BUTTONS.RIGHT_CLICK && event.button_index == MOUSE_BUTTON_RIGHT:
			set_active(event.is_pressed())
		elif button == BUTTONS.MIDDLE_CLICK && event.button_index == MOUSE_BUTTON_MIDDLE:
			set_active(event.is_pressed())
		elif button == BUTTONS.SCROLL_UP && event.button_index == MOUSE_BUTTON_WHEEL_UP:
			trigger.emit(self)
		elif button == BUTTONS.SCROLL_DOWN && event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			trigger.emit(self)
