class_name TerminalImmutableDir
extends TerminalDir

func move(_parent: TerminalDir, _new_name := "") -> void:
	Terminal.out_error(Terminal.TError.IMMUTABLE_DIR, {
		"item": Terminal.trans_name_node_to_item(name)
	})

func remove() -> void:
	Terminal.out_error(Terminal.TError.IMMUTABLE_DIR, {
		"item": Terminal.trans_name_node_to_item(name)
	})
