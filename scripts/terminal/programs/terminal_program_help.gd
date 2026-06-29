class_name TerminalProgramHelp
extends TerminalProgram

func get_help() -> String:
	return "Lists all global programs, or provides info on a given program"

func run(args: PackedStringArray) -> void:
	if len(args) == 1:
		var output := ""
		for item: TerminalItem in Terminal.program_dir.get_items():
			if item is not TerminalDir:
				output += item.get_display_name() + "\n"
		Terminal.out_print(output)
	else:
		var file := Terminal.find_program_item(args[1])
		if not file:
			return
		if file is TerminalFile:
			if file is TerminalProgram:
				Terminal.out_print(file.get_help() + "\n")
			else:
				Terminal.out_error(Terminal.TError.INVALID_RUN, {
					"item": Terminal.trans_name_node_to_item(file.name)
				})
		else:
			Terminal.out_error(Terminal.TError.NOT_A_FILE, {
				"item": Terminal.trans_name_node_to_item(file.name)
			})
