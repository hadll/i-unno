class_name PostProcessedControl
extends Control

var was_visible: bool

func _ready() -> void:
	was_visible = visible
	visible = false
	await get_tree().process_frame
	reparent(PostProcessing.game_viewport, false)
	visible = was_visible
