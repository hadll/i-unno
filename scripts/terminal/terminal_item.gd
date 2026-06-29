@abstract
class_name TerminalItem
extends Node

func move(parent: TerminalDir, new_name := "") -> void:
	if is_ancestor_of(parent) or self == parent:
		Terminal.out_error(Terminal.TError.MOVING_INSIDE, {
			"item": Terminal.trans_name_node_to_item(name),
			"dir": Terminal.trans_name_node_to_item(parent.name)
		})
		return
	if not new_name:
		new_name = Terminal.trans_name_node_to_item(name)
	if parent.has(new_name):
		Terminal.out_error(Terminal.TError.ITEM_EXISTS, {
			"item": Terminal.trans_name_node_to_item(name),
			"dir": Terminal.trans_name_node_to_item(parent.name)
		})
		return
	var old_parent := get_parent()
	old_parent.remove_child(self)
	name = Terminal.trans_name_item_to_node(new_name)
	parent.add_child(self)

func remove() -> void:
	if Terminal.can_remove(self):
		queue_free()
		get_parent().remove_child(self)

func get_item_node_path() -> String:
	var parent: TerminalItem = get_parent()
	return parent.get_item_node_path() + Terminal.SEP + name

func get_display_name(_follow_alias := true) -> String:
	return Terminal.trans_name_node_to_item(name)
