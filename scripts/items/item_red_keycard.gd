class_name ItemRedKeycard
extends Item

func get_item_name() -> String:
	return "Red Keycard"

func get_item_id() -> StringName:
	return &"red_keycard"

func get_item_texture() -> Texture2D:
	return preload("res://assets/items/red_keycard.png")
