class_name ItemFlashlight
extends Item

func get_item_name() -> String:
	return "Flashlight"

func get_item_id() -> StringName:
	return &"flashlight"

func init_item_slot() -> void:
	pass

func use() -> void:
	Player.me.flashlight.visible = not Player.me.flashlight.visible
