@abstract
class_name Item
extends Node3D
@warning_ignore("unused_signal")
signal update_texture

var held := false
var slot: ItemSlot

@abstract
func get_item_name() -> String

@abstract
func get_item_id() -> StringName

@abstract
func get_item_texture() -> Texture2D

@abstract
func init_item_slot() -> void

func use() -> void:
	pass
