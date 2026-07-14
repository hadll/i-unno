extends Node

var main_viewport: SubViewport
var pass_0_display: TextureRect
var pass_0_material: ShaderMaterial

var pass_1_viewport: SubViewport
var pass_1_display: TextureRect
var pass_1_material: ShaderMaterial

func _ready() -> void:
	main_viewport = SubViewport.new()
	add_child(main_viewport)
	pass_1_viewport = SubViewport.new()
	add_child(pass_1_viewport)
	
	pass_0_display = TextureRect.new()
	pass_0_display.set_anchors_preset(Control.PRESET_FULL_RECT)
	pass_0_material = load("res://assets/post_processing/distortion_material.tres").duplicate()
	pass_0_display.material = pass_0_material
	pass_0_display.texture = main_viewport.get_texture()
	pass_1_viewport.add_child(pass_0_display)
	
	pass_1_display = TextureRect.new()
	pass_1_display.set_anchors_preset(Control.PRESET_FULL_RECT)
	pass_1_material = load("res://assets/post_processing/dithering_material.tres").duplicate()
	pass_1_display.material = pass_1_material
	pass_1_display.texture = pass_1_viewport.get_texture()
	add_child(pass_1_display)
	
	assign_camera(PlayerCamera.get_camera_rid())
	
	get_window().size_changed.connect(update_size)
	update_size()
	
	InputHandler.input.connect(main_viewport.push_input)

func assign_camera(camera: RID) -> void:
	RenderingServer.viewport_attach_camera(main_viewport.get_viewport_rid(), camera)

func update_size() -> void:
	main_viewport.size = get_window().size
	pass_1_viewport.size = get_window().size

func get_dithering_material() -> ShaderMaterial:
	return pass_1_material

func get_distortion_material() -> ShaderMaterial:
	return pass_0_material
