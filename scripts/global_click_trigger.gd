@icon("res://assets/icons/global_click_trigger.png")
extends Trigger
class_name GlobalClickTrigger

@export var button: MouseButton

func get_default_debug_print() -> String:
	return "Clicked"

func on_player_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	if button != event.button_index:
		return
	match button:
		MOUSE_BUTTON_LEFT:
			set_active(event.is_pressed())
		MOUSE_BUTTON_RIGHT:
			set_active(event.is_pressed())
		MOUSE_BUTTON_MIDDLE:
			set_active(event.is_pressed())
		MOUSE_BUTTON_WHEEL_UP:
			trigger.emit(self)
		MOUSE_BUTTON_WHEEL_DOWN:
			trigger.emit(self)
		MOUSE_BUTTON_WHEEL_LEFT:
			trigger.emit(self)
		MOUSE_BUTTON_WHEEL_RIGHT:
			trigger.emit(self)
		MOUSE_BUTTON_WHEEL_UP:
			trigger.emit(self)
		MOUSE_BUTTON_XBUTTON1:
			set_active(event.is_pressed())
		MOUSE_BUTTON_XBUTTON2:
			set_active(event.is_pressed())
		_:
			pass
