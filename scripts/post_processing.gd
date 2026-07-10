extends Node

var game_viewport: SubViewport
var display: TextureRect

func _ready() -> void:
	game_viewport = SubViewport.new()
	add_child(game_viewport)
	
	display = TextureRect.new()
	display.set_anchors_preset(Control.PRESET_FULL_RECT)
	display.material = preload("res://assets/dithering_material.tres")
	display.texture = game_viewport.get_texture()
	add_child(display)
	
	RenderingServer.viewport_attach_camera(game_viewport.get_viewport_rid(), PlayerCamera.get_camera_rid())
	get_window().size_changed.connect(update_size)
	update_size()
	
	InputHandler.input.connect(game_viewport.push_input)

func update_size() -> void:
	game_viewport.size = get_window().size
