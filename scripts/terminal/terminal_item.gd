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
