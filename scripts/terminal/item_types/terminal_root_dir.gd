class_name TerminalRootDir
extends TerminalImmutableDir

func find(item: String) -> TerminalItem:
	if item == "..":
		return self
	return super(item)

func get_item_node_path() -> String:
	return Terminal.SEP
