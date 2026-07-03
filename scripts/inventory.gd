class_name Inventory
extends Control

@export var slots: Array[ItemSlot]

func pick_up_item(item: Item) -> bool:
	for slot in slots:
		if not slot.item:
			slot.set_item(item)
			return true
	return false
