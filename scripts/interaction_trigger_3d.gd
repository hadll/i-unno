@abstract
extends Trigger
class_name InteractionTrigger3D

@export var collision_object : CollisionObject3D

func _ready() -> void:
	Player.me.started_looking_at.connect(func(collider: CollisionObject3D):
		if collider == collision_object:
			Player.me.input.connect(on_player_input)
	)
	Player.me.stopped_looking_at.connect(func(collider: CollisionObject3D):
		if collider == collision_object:
			Player.me.input.disconnect(on_player_input)
			set_active(false)
	)

@abstract
func on_player_input(event: InputEvent) -> void
