class_name ItemSlot
extends Control

var item: Item

func set_item(to: Item) -> void:
	item = to
	if item:
		item.hide()
		add_child(item)
