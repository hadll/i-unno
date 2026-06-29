class_name TerminalProgramMakeDir
extends TerminalProgram

func get_help() -> String:
	return "Creates a directory in at the given location"

func run(args: PackedStringArray) -> void:
	if not check_args(args, 1):
		return
	
	var parts := args[1].rsplit(Terminal.SEP, false, 1)
	if len(parts) == 1:
		parts.insert(0, Terminal.EXT)
	if not parts or not Terminal.valid_item_name(parts[1]):
		Terminal.out_error(Terminal.TError.INVALID_ARG, {
			"arg": "1"
		})
		return
	
	var dir := Terminal.find(parts[0])
	if not dir:
		return
	if dir is TerminalDir:
		if dir.has(parts[1]):
			Terminal.out_error(Terminal.TError.ITEM_EXISTS, {
				"item": parts[1],
				"dir": Terminal.trans_name_node_to_item(dir.name)
			})
		else:
			var new_dir := TerminalDir.new()
			new_dir.name = Terminal.trans_name_item_to_node(parts[1])
			dir.add_child(new_dir)
	else:
		Terminal.out_error(Terminal.TError.NOT_A_DIR, {
			"item": Terminal.trans_name_node_to_item(dir.name)
		})
