@icon("res://assets/icons/debug_print.png")
extends Node
class_name DebugPrint

@export var trigger: Trigger
@export var print_text: String
@export_category("Events")
@export var show_start := true
@export var show_trigger := false
@export var show_end := true

func _ready() -> void:
	trigger.trigger.connect(trigger_trigger)
	trigger.trigger_start.connect(trigger_start)
	trigger.trigger_end.connect(trigger_end)
	if not print_text:
		print_text = trigger.get_default_debug_print()

func trigger_trigger() -> void:
	if show_trigger:
		print("[%s Trigger] %s" % [trigger.name, print_text])

func trigger_start() -> void:
	if show_start:
		print("[%s Trigger Start] %s" % [trigger.name, print_text])

func trigger_end() -> void:
	if show_end:
		print("[%s Trigger End] %s" % [trigger.name, print_text])
