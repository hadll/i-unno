class_name TerminalProgramChangeWorkingDir
extends TerminalProgram

func run(args: PackedStringArray) -> void:
	var path := "~"
	if len(args) >= 2:
		path = args[1]
	var dir := Terminal.find(path)
	if dir is TerminalDir:
		Terminal.cwd = dir
	else:
		Terminal.out_error(Terminal.TError.NOT_A_DIR, {
			"item": Terminal.trans_name_node_to_item(dir.name)
		})
