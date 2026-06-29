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

func get_items() -> Array[TerminalItem]:
	var items: Array[TerminalItem] = []
	items.assign(get_children())
	items.sort_custom(func(a: TerminalItem, b: TerminalItem) -> bool:
		if a is TerminalDir and b is not TerminalDir:
			return true
		return Terminal.trans_name_node_to_item(a.name) < Terminal.trans_name_node_to_item(b.name)
	)
	return items

func get_display_name(_follow_alias := true) -> String:
	return super(_follow_alias) + "/"
