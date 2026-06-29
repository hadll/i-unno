@abstract
class_name TerminalProgram
extends TerminalFile

@abstract
func get_help() -> String

func check_args(args: PackedStringArray, min_args: int) -> bool:
	if len(args) > min_args:
		return true
	Terminal.out_error(Terminal.TError.MISSING_ARGS, {
		"needed": str(min_args),
		"got": str(len(args) - 1)
	})
	return false
