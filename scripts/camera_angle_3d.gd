@tool
@icon("res://assets/icons/camera_angle_3d.png")
class_name CameraAngle3D
extends Node3D

@export_category("Camera")
@export var camera: PlayerCamera
@export var use_player_camera := true

@export_category("Settings")
@export var trigger: Trigger

@export var tween := true

func _ready() -> void:
	if not Engine.is_editor_hint():
		trigger.trigger_start.connect(on_trigger_start)
		trigger.trigger_end.connect(on_trigger_end)
		if trigger.active:
			on_trigger_start(trigger)

func on_trigger_start(_node: Trigger) -> void:
	if use_player_camera:
		PlayerCamera.main.request_camera(global_transform, self, tween)
	else:
		camera.request_camera(global_transform, self, tween)

func on_trigger_end(_node: Trigger) -> void:
	if use_player_camera:
		PlayerCamera.main.release_camera_by_requester(self)
	else:
		camera.release_camera_by_requester(self)
