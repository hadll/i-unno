class_name TerminalProgramRead
extends TerminalProgram

func get_help() -> String:
	return "Displays the content of a given file"

func run(args: PackedStringArray) -> void:
	if not check_args(args, 1):
		return
	var file := Terminal.find(args[1])
	if not file:
		return
	if file is TerminalFile:
		Terminal.out_print(file.read() + "\n")
	else:
		Terminal.out_error(Terminal.TError.NOT_A_FILE, {
			"item": Terminal.trans_name_node_to_item(file.name)
		})
