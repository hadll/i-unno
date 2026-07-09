class_name PostProcessing
extends Node

@export var game_viewport: SubViewport
@export var display: TextureRect

func _ready() -> void:
	get_window().size_changed.connect(update_size)
	update_size()

func update_size() -> void:
	game_viewport.size = get_window().size
