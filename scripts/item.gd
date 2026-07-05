@abstract
class_name Item
extends Node3D

@abstract
func get_item_name() -> String

@abstract
func get_item_id() -> StringName

func item_input(_event: InputEvent) -> void:
	pass
