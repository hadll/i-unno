class_name ItemPickupTrigger
extends Trigger

@export var sprite: Sprite3D
@export var pickup_trigger: Trigger
@export var item: Item

func _ready() -> void:
	pickup_trigger.trigger_start.connect(pick_up)
	sprite.texture = item.get_item_texture()

func pick_up() -> void:
	if not item:
		return
	if not Player.me.pick_up_item(item):
		return
	trigger.emit()
	queue_free()
