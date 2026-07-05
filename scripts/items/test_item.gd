class_name TestItem
extends Item

func get_item_name() -> String:
	return "Test Item"

func get_item_id() -> StringName:
	return &"test_item"

func item_input(event: InputEvent) -> void:
	pass
	#print("Test Item Input: ", event)
