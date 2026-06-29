class_name TerminalDir
extends TerminalItem

func find(item_name: String) -> TerminalItem:
	if item_name == "..":
		return get_parent()
	if item_name == ".":
		return self
	var node_name: String = Terminal.trans_name_item_to_node(item_name)
	if has_node(node_name):
		return get_node(node_name)
	return null
