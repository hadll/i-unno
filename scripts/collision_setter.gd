class_name TriggerableCollisionShape3D
extends CollisionShape3D

@export var trigger: Trigger
@export var make_passable: bool

func _ready() -> void:
	trigger.trigger_start.connect(set_deferred.bind(&"disabled", make_passable))
	trigger.trigger_end.connect(set_deferred.bind(&"disabled", not make_passable))
	set_deferred(&"disabled", not trigger.active)
