@abstract
class_name TerminalFile
extends TerminalItem

func read() -> String:
	Terminal.out_error(Terminal.TError.INVALID_READ, {
		"item": Terminal.trans_name_node_to_item(name)
	})
	return ""

func run(_args: PackedStringArray) -> void:
	Terminal.out_error(Terminal.TError.INVALID_RUN, {
		"item": Terminal.trans_name_node_to_item(name)
	})
