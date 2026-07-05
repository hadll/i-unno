class_name ItemSlot
extends Control

@export var animation_speed := 1.0
@export var selection_scale := 1.1

var item: Item
var target_scale := 1.0
var current_scale := 1.0

func _process(delta: float) -> void:
	current_scale = lerpf(target_scale, current_scale, exp(-delta * animation_speed))
	offset_transform_scale = Vector2.ONE * current_scale

func set_item(to: Item) -> void:
	item = to
	if item:
		item.hide()
		add_child(item)

func select() -> void:
	target_scale = selection_scale

func deselect() -> void:
	target_scale = 1.0
