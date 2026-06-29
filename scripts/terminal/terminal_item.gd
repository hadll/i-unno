@abstract
class_name TerminalItem
extends Node

func move(parent: TerminalDir) -> void:
	if is_ancestor_of(parent):
		Terminal.out_errror(Terminal.TError.MOVING_INSIDE, {
			"item": Terminal.trans_name_node_to_item(name)
		})
		return
	reparent(parent)

func get_item_node_path() -> String:
	var parent: TerminalItem = get_parent()
	return parent.get_item_node_path() + name

func get_display_name(_follow_alias := true) -> String:
	return Terminal.trans_name_node_to_item(name)
