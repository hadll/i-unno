class_name MultiplayerFlagSetter
extends Node

@export var trigger: Trigger
@export var flag: String

func _ready() -> void:
	trigger.trigger_start.connect(trigger_start)
	trigger.trigger_end.connect(trigger_end)

func trigger_trigger() -> void:
	MultiplayerConnection.update_flags({flag: MultiplayerConnection.FlagUpdate.TOGGLE})

func trigger_start() -> void:
	MultiplayerConnection.update_flags({flag: MultiplayerConnection.FlagUpdate.ON})

func trigger_end() -> void:
	MultiplayerConnection.update_flags({flag: MultiplayerConnection.FlagUpdate.OFF})
