@icon("res://scripts/triggers/multiplayer_flag_trigger.gd")
class_name MultiplayerFlagTrigger
extends Trigger

@export var flag: String

func _ready() -> void:
	MultiplayerConnection.flag_updated.connect(func(updated: String, value: bool) -> void:
		if updated == flag:
			set_active(value)
	)

func get_default_debug_print() -> String:
	return "Multiplayer Flag Updated"
