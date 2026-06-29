class_name TerminalProgramRead
extends TerminalProgram

func run(args: PackedStringArray) -> void:
	if len(args) < 2:
		Terminal.out_error(Terminal.TError.MISSING_ARGS, {
			"needed": "2",
			"got": str(len(args))
		})
		return
	var file := Terminal.find(args[1])
	if file is TerminalFile:
		Terminal.out_print(file.read() + "\n")
	else:
		Terminal.out_error(Terminal.TError.NOT_A_FILE, {
			"item": Terminal.trans_name_node_to_item(file.name)
		})
