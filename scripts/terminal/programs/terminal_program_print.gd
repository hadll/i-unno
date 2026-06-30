class_name TerminalProgramPrint
extends TerminalProgram

func get_help() -> String:
	return "Connects to the printer and prints a given file"

func run(args: PackedStringArray) -> void:
	if not check_args(args, 1):
		return
	var item := Terminal.find(args[1])
	if not item:
		return
	if item is TerminalImageFile:
		PrinterManager.queue_image(item.content)
		Terminal.out_print("Printing image...\n")
		return
	if item is TerminalTextFile:
		PrinterManager.queue_text(item.content)
		Terminal.out_print("Printing text...\n")
		return
	Terminal.out_error(Terminal.TError.MISC, {
		"msg": "Unable to print file of this type"
	})
