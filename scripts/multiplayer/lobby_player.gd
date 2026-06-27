class_name LobbyPlayer
extends PanelContainer

@export var room_player_id: int

@onready var username: Label = $Username

func set_username(to: String) -> void:
	username.text = to
