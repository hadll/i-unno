@icon("res://assets/icons/global_key_trigger.png")
extends Trigger
class_name GlobalKeyTrigger

@export var use_action: bool

@export_custom(PROPERTY_HINT_INPUT_NAME, "show_builtin") var action: StringName
@export var button: InputEventKey

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	InputHandler.input.connect(on_player_input)

func get_default_debug_print() -> String:
	return "Keyboard Pressed"


func on_player_input(event: InputEvent):
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

func unlock() -> void:
	super()
	set_active(false)
