@abstract
class_name Item
extends Node3D

@export var default_texture: Texture2D

var held := false
var slot: ItemSlot

@abstract
func get_item_name() -> String

@abstract
func get_item_id() -> StringName

@abstract
func init_item_slot() -> void

func use() -> void:
	pass
