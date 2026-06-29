class_name Player
extends Node3D

static var me: Player

var detached_freecam := false
var controlling_freecam := false

var camera_request: int

@export var camera_point: Node3D
@export var freecam: Camera3D

func _init() -> void:
	me = self

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(&"freecam_on"):
		detached_freecam = not detached_freecam
		if detached_freecam:
			freecam.make_current()
			freecam.global_transform = camera_point.global_transform
			controlling_freecam = true
		else:
			PlayerCamera.me.make_current()
			controlling_freecam = false
	if Input.is_action_just_pressed(&"freecam_swap"):
		controlling_freecam = not controlling_freecam
