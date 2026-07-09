class_name ItemFlashlight
extends Item

func _ready() -> void:
	Player.me.flashlight.visibility_changed.connect(update_texture.emit)

func get_item_name() -> String:
	return "Flashlight"

func get_item_id() -> StringName:
	return &"flashlight"

func get_item_texture() -> Texture2D:
	return preload("res://assets/items/flashlight_on.png") if Player.me.flashlight.visible else preload("res://assets/items/flashlight_off.png")

func init_item_slot() -> void:
	pass

func use() -> void:
	Player.me.flashlight.visible = not Player.me.flashlight.visible
