class_name TerminalZipFile
extends TerminalFile

const EXTENSION := "zip"

@export var password: String

func decompress(with_password := "") -> TerminalDir:
	if with_password != password:
		return null
	var dir := TerminalDir.new()
	dir.name = name.trim_suffix(Terminal.EXT_REPLACE + EXTENSION)
	for item in get_children():
		item.reparent(dir)
	var parent := get_parent()
	parent.remove_child(self)
	parent.add_child(dir)
	return dir
