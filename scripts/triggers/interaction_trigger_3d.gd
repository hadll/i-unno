@abstract
class_name InteractionTrigger3D
extends Trigger

@export var collision_object: CollisionObject3D

func _ready() -> void:
	if not collision_object:
		push_error("InteractionTrigger3D requires a collision object to function properly")
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

func unlock() -> void:
	super()
	set_active(false)
