class_name ItemSlot
extends Control

@export var texture_rect: TextureRect
@export var animation_speed := 1.0
@export var selection_scale := 1.1

var item: Item
var target_scale := 1.0
var current_scale := 1.0

func _process(delta: float) -> void:
	current_scale = lerpf(target_scale, current_scale, exp(-delta * animation_speed))
	offset_transform_scale = Vector2.ONE * current_scale

func set_item(to: Item) -> void:
	if item:
		item.update_texture.disconnect(update_texture)
		item.queue_free()
	item = to
	if item:
		item.hide()
		item.get_parent().remove_child(item)
		add_child(item)
		item.slot = self
		item.update_texture.connect(update_texture)
	update_texture()

func update_texture() -> void:
	if item:
		texture_rect.texture = item.get_item_texture()
	else:
		texture_rect.texture = null

func select() -> void:
	target_scale = selection_scale

func deselect() -> void:
	target_scale = 1.0
