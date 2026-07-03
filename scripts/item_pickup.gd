class_name ItemPickup
extends Node3D

@export var trigger: Trigger
@export var item: Item

func _ready() -> void:
	trigger.trigger_start.connect(pick_up)

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
		else:
			add_child(item)
