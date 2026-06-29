class_name TerminalRootDir
extends TerminalDir

func find(item: String) -> TerminalItem:
	if item == "..":
		return self
	return super(item)
