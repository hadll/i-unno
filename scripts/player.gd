class_name Player
extends Node3D

static var me: Player

@export var camera_point: Node3D
@export var flashlight: Light3D
@export var inventory: Inventory
@export var freecam: Camera3D

var detached_freecam := false
var controlling_freecam := false
var debug_map_display: TextureRect
var debug_map_display_layer := 0

var camera_request: int

func _init() -> void:
	me = self

func _ready() -> void:
	InputHandler.world_3d = get_world_3d()

func _process(_delta: float) -> void:
	if InputHandler.is_action_just_pressed(&"freecam_on"):
		if detached_freecam:
			freecam_stop()
		else:
			freecam_start()
	if detached_freecam and InputHandler.is_action_just_pressed(&"freecam_swap"):
		controlling_freecam = not controlling_freecam
	if InputHandler.is_action_just_pressed(&"debug_map"):
		if debug_map_display:
			debug_map_display_layer += 1
			if debug_map_display_layer >= len(Map.layers):
				remove_child(debug_map_display)
				debug_map_display = null
			else:
				debug_map_display.texture = ImageTexture.create_from_image(Map.layers[debug_map_display_layer])
		else:
			Map.draw()
			debug_map_display = TextureRect.new()
			debug_map_display.texture = ImageTexture.create_from_image(Map.layers[0])
			add_child(debug_map_display)
			debug_map_display_layer = 0

func pick_up_item(item: Item) -> bool:
	return inventory.pick_up_item(item)

func freecam_start() -> void:
	detached_freecam = true
	controlling_freecam = true
	freecam.make_current()
	freecam.global_transform = camera_point.global_transform

func freecam_stop() -> void:
	detached_freecam = false
	controlling_freecam = false
	PlayerCamera.make_current()
