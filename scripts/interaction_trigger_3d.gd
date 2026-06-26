@abstract
extends Trigger
class_name InteractionTrigger3D

@export var collision_object : CollisionObject3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("InteractionTriggers", true)

@abstract
func on_player_input(node: CollisionObject3D, event: InputEvent)
