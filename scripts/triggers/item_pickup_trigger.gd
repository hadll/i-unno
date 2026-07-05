class_name ItemPickupTrigger
extends Trigger

@export var pickup_trigger: Trigger
@export var item: Item

func _ready() -> void:
	pickup_trigger.trigger_start.connect(pick_up)

func pick_up() -> void:
	if not item:
		return
	if not Player.me.pick_up_item(item):
		return
	trigger.emit()
