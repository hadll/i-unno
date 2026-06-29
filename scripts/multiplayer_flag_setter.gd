class_name MultiplayerFlagSetter
extends Node

@export var trigger: Trigger
@export var flag: String

func _ready() -> void:
	trigger.trigger_start.connect(trigger_start)
	trigger.trigger_end.connect(trigger_end)

func trigger_trigger(_node: Trigger) -> void:
	MultiplayerConnection.update_flags({flag: MultiplayerConnection.FlagUpdate.TOGGLE})

func trigger_start(_node: Trigger) -> void:
	MultiplayerConnection.update_flags({flag: MultiplayerConnection.FlagUpdate.ON})

func trigger_end(_node: Trigger) -> void:
	MultiplayerConnection.update_flags({flag: MultiplayerConnection.FlagUpdate.OFF})
