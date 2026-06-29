class_name TerminalDir
extends TerminalItem

func find(item_name: String) -> TerminalItem:
	if item_name == Terminal.EXT.repeat(2):
		return get_parent()
	if item_name == Terminal.EXT:
		return self
	var node_name: String = Terminal.trans_name_item_to_node(item_name)
	if has_node(node_name):
		return get_node(node_name)
	return null

func get_items() -> Array[TerminalItem]:
	var items: Array[TerminalItem] = []
	items.assign(get_children())
	items.sort_custom(func(a: TerminalItem, b: TerminalItem) -> bool:
		if a is TerminalDir and b is not TerminalDir:
			return true
		if a is not TerminalDir and b is TerminalDir:
			return false
		if a is TerminalAlias and b is not TerminalAlias:
			return false
		if a is not TerminalAlias and b is TerminalAlias:
			return true
		return Terminal.trans_name_node_to_item(a.name) < Terminal.trans_name_node_to_item(b.name)
	)
	return items

func has(item_name: String) -> bool:
	var node_name := Terminal.trans_name_item_to_node(item_name)
	return has_node(NodePath(node_name))

func get_display_name(_follow_alias := true) -> String:
	return super(_follow_alias) + Terminal.SEP
