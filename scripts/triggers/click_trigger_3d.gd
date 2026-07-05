@icon("res://assets/icons/click_trigger_3d.png")
class_name ClickTrigger3D
extends InteractionTrigger3D

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
			trigger.emit()
		MOUSE_BUTTON_WHEEL_DOWN:
			trigger.emit()
		MOUSE_BUTTON_WHEEL_LEFT:
			trigger.emit()
		MOUSE_BUTTON_WHEEL_RIGHT:
			trigger.emit()
		MOUSE_BUTTON_WHEEL_UP:
			trigger.emit()
		MOUSE_BUTTON_XBUTTON1:
			set_active(event.is_pressed())
		MOUSE_BUTTON_XBUTTON2:
			set_active(event.is_pressed())
		_:
			pass
