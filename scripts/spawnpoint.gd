class_name SpawnPoint
extends Node3D

@export var player_scene: PackedScene

func _ready() -> void:
	if not Player.me:
		var player := player_scene.instantiate()
		add_child(player)
		player.global_position = global_position
