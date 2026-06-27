@tool
class_name CameraAngle
extends Node3D

@export var trigger: Trigger

@export var tween := true

var level: Level

func _ready() -> void:
	if not Engine.is_editor_hint():
		trigger.trigger_start.connect(on_trigger_start)
		trigger.trigger_end.connect(on_trigger_end)
		level = get_tree().current_scene
		if trigger.active:
			on_trigger_start(trigger)

func on_trigger_start(_node: Trigger) -> void:
	level.player_camera.request_camera(global_transform, self, tween)

func on_trigger_end(_node: Trigger) -> void:
	level.player_camera.release_camera_by_requester(self)
