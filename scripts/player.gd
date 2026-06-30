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
	if InputHandler.is_action_just_pressed(&"freecam_on"):
		if detached_freecam:
			freecam_stop()
		else:
			freecam_start()
	if detached_freecam and InputHandler.is_action_just_pressed(&"freecam_swap"):
		controlling_freecam = not controlling_freecam

func freecam_start() -> void:
	detached_freecam = true
	controlling_freecam = true
	freecam.make_current()
	freecam.global_transform = camera_point.global_transform

func freecam_stop() -> void:
	detached_freecam = false
	controlling_freecam = false
	PlayerCamera.me.make_current()
