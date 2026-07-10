class_name PostProcessedControl
extends Control

func _ready() -> void:
	hide()
	await get_tree().process_frame
	reparent(PostProcessing.game_viewport, false)
	show()
