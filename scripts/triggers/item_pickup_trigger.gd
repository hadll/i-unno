class_name ItemPickupTrigger
extends Trigger

@export var pickup_trigger: Trigger
@export var item: Item
@export var hold := false

func _ready() -> void:
	pickup_trigger.trigger_start.connect(pick_up)

func set_item(to: Item) -> void:
	item = to
	if item:
		item.show()
		add_child(item)

func pick_up(_t: Trigger) -> void:
	if item:
		remove_child(item)
		if Player.me.pick_up_item(item):
			queue_free()
			if hold:
				activate()
			else:
				trigger.emit()
		else:
			add_child(item)
