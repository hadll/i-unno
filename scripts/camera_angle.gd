@tool
extends Node3D
class_name CameraAngle

@export var trigger : Trigger

@export var tween : bool = true

var level : Level

func _ready() -> void:
	trigger.trigger_start.connect(on_trigger_start)
	trigger.trigger_end.connect(on_trigger_end)
	level = get_tree().current_scene
	if trigger.active:
		on_trigger_start(trigger)


func on_trigger_start(node: Trigger):
	level.player_camera.request_camera(global_transform, self, tween)
func on_trigger_end(node: Trigger):
	level.player_camera.release_camera_by_requester(self)
