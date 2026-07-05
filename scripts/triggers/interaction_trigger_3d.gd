@abstract
class_name InteractionTrigger3D
extends Trigger

@export var collision_object: CollisionObject3D

func _ready() -> void:
	InputHandler.started_looking_at.connect(func(collider: CollisionObject3D):
		if collider == collision_object:
			InputHandler.input.connect(on_player_input)
	)
	InputHandler.stopped_looking_at.connect(func(collider: CollisionObject3D):
		if collider == collision_object:
			InputHandler.input.disconnect(on_player_input)
			deactivate()
	)

@abstract
func on_player_input(event: InputEvent) -> void
