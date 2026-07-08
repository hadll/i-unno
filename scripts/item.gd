@abstract
class_name Item
extends Node3D

signal held_sprite_update

@abstract
func get_item_name() -> String

@abstract
func get_item_id() -> StringName

func item_input(_event: InputEvent) -> void:
	pass

@abstract
func get_item_icon() -> Image

@abstract
func get_item_held_sprite() -> Image
