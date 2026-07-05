class_name Monitor
extends Node3D

@onready var terminal_display: TerminalDisplay = $SubViewport/TerminalDisplay
@onready var trigger: Trigger = self.get_parent()

var focused := false

func _ready() -> void:
	trigger.trigger_start.connect(get_focus)
	trigger.trigger_end.connect(release_focus)

func _input(event: InputEvent) -> void:
	if not focused:
		return
	if event is InputEventKey:
		terminal_display.key_input(event)

func get_focus() -> void:
	if focused:
		return
	#InputHandler.disable_input = true
	focused = true

func release_focus() -> void:
	if not focused:
		return
	#InputHandler.disable_input = false
	focused = false
