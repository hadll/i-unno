class_name TerminalProgramMove
extends TerminalProgram

func get_help() -> String:
	return "Moves the given item to another location"

func run(args: PackedStringArray) -> void:
	if not check_args(args, 2):
		return
	var item := Terminal.find(args[1])
	if not item:
		return
	var parts := args[2].rsplit(Terminal.SEP, false, 1)
	if not parts:
		Terminal.out_error(Terminal.TError.INVALID_ARG, {
			"arg": "2"
		})
		return
	if len(parts) == 1:
		parts.insert(0, Terminal.EXT)
	var dir := Terminal.find(parts[0])
	if not dir:
		return
	if dir is TerminalDir:
		var new_parent: TerminalItem = dir.find(parts[1])
		if new_parent is TerminalDir:
			item.move(new_parent)
		else:
			item.move(dir, parts[1])
	else:
		Terminal.out_error(Terminal.TError.NOT_A_DIR, {
			"item": Terminal.trans_name_node_to_item(dir.name)
		})
