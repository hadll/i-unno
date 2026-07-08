class_name RoomStart
extends Room

@export var player_scene: PackedScene
@export var spawn_point: Node3D

func _ready() -> void:
	if not Player.me:
		var player := player_scene.instantiate()
		add_child(player)
		player.global_position = spawn_point.global_position
