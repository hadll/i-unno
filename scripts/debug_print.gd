@icon("res://assets/icons/debug_print.png")
extends Node
class_name DebugPrint

@export var trigger : Trigger
@export var print_text : String
@export_category("Events")
@export var show_start : bool = true
@export var show_trigger : bool = false
@export var show_end : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	trigger.trigger.connect(trigger_trigger)
	trigger.trigger_start.connect(trigger_start)
	trigger.trigger_end.connect(trigger_end)
	if print_text == "":
		print_text = trigger.get_default_debug_print()

func trigger_trigger(node: Trigger):
	if show_trigger:
		print("["+node.name+" Trigger] "+print_text)
func trigger_start(node: Trigger):
	if show_start:
		print("["+node.name+" Trigger Start] "+print_text)
func trigger_end(node: Trigger):
	if show_end:
		print("["+node.name+" Trigger End] "+print_text)
