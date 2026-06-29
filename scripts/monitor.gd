class_name Monitor
extends StaticBody3D

@onready var terminal_display: TerminalDisplay = $SubViewport/TerminalDisplay
@onready var start_using_trigger: Trigger = $ClickTrigger3D

var focused := false

func _ready() -> void:
	start_using_trigger.trigger.connect(func(_t: Trigger) -> void: get_focus())

func _input(event: InputEvent) -> void:
	if not focused:
		return
	if event is InputEventKey:
		terminal_display.key_input(event)
	elif event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_RIGHT:
				release_focus()

func get_focus() -> void:
	if focused:
		return
	InputHandler.disable_input = true
	focused = true

func release_focus() -> void:
	if not focused:
		return
	InputHandler.disable_input = false
	focused = false
