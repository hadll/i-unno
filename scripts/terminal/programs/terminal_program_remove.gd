class_name TerminalProgramRemove
extends TerminalProgram

func get_help() -> String:
	return "Deletes an item (recursively)"

func run(args: PackedStringArray) -> void:
	if not check_args(args, 1):
		return
	var item := Terminal.find(args[1])
	if not item:
		return
	item.remove()
