class_name Monitor
extends Node3D

@export var terminal_display: TerminalDisplay
@export var trigger: Trigger
@export var screen_mesh: MeshInstance3D
@export var sub_viewport: SubViewport

var focused := false

func _ready() -> void:
	trigger.trigger_start.connect(get_focus)
	trigger.trigger_end.connect(release_focus)
	screen_mesh.material_override = screen_mesh.material_override.duplicate()
	screen_mesh.material_override.set_shader_parameter(&"screen_texture", sub_viewport.get_texture())

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
