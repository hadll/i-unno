class_name TerminalProgramUnzip
extends TerminalProgram

func get_help() -> String:
	return "Unzips the given zip file, optionally with a password"

func run(args: PackedStringArray) -> void:
	if not check_args(args, 1):
		return
	var file := Terminal.find(args[1])
	if not file:
		return
	if file is TerminalFile:
		if file is TerminalZipFile:
			var password := args[2] if len(args) >= 3 else ""
			var unzipped: TerminalDir = file.decompress(password)
			if unzipped:
				Terminal.out_print("Successfully unzipped %s to %s\n" % [
					Terminal.trans_name_node_to_item(file.name),
					Terminal.trans_name_node_to_item(unzipped.name),
				])
			else:
				Terminal.out_error(Terminal.TError.MISC, {
					"msg": "Failed to unzip %s with password: %s" % [
						Terminal.trans_name_node_to_item(file.name),
						password
					]
				})
				
		else:
			Terminal.out_error(Terminal.TError.MISC, {
				"msg": "%s is not a zip file" % Terminal.trans_name_node_to_item(file.name)
			})
	else:
		Terminal.out_error(Terminal.TError.NOT_A_FILE, {
			"item": Terminal.trans_name_node_to_item(file.name)
		})
