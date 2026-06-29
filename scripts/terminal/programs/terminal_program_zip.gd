class_name TerminalProgramZip
extends TerminalProgram

func get_help() -> String:
	return "Zips the given directory, optionally with a password"

func run(args: PackedStringArray) -> void:
	if not check_args(args, 1):
		return
	var dir := Terminal.find(args[1])
	if not dir:
		return
	if dir is TerminalDir:
		if dir is TerminalImmutableDir:
			Terminal.out_error(Terminal.TError.IMMUTABLE_DIR, {
				"item": Terminal.trans_name_node_to_item(dir.name)
			})
		else:
			var zip := TerminalZipFile.new()
			zip.name = dir.name + Terminal.EXT_REPLACE + TerminalZipFile.EXTENSION
			zip.password = args[2] if len(args) >= 3 else ""
			for item in dir.get_children():
				item.reparent(zip)
			var parent := dir.get_parent()
			parent.remove_child(dir)
			parent.add_child(zip)
	else:
		Terminal.out_error(Terminal.TError.NOT_A_DIR, {
			"item": Terminal.trans_name_node_to_item(dir.name)
		})
