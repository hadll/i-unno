class_name TerminalProgramList
extends TerminalProgram

func get_help() -> String:
	return "Lists the contents of a given directory, or the cwd if none given"

func run(args: PackedStringArray) -> void:
	var path := Terminal.EXT
	if len(args) >= 2:
		path = args[1]
	var dir := Terminal.find(path)
	if not dir:
		return
	if dir is TerminalDir:
		var output := ""
		for item: TerminalItem in dir.get_items():
			output += item.get_display_name() + "\n"
		Terminal.out_print(output)
	else:
		Terminal.out_error(Terminal.TError.NOT_A_DIR, {
			"item": Terminal.trans_name_node_to_item(dir.name)
		})
