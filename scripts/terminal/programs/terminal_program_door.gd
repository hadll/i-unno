class_name TerminalProgramDoor
extends TerminalProgram

func get_help() -> String:
	return "Controls Security Doors"

func run(args: PackedStringArray) -> void:
	if not check_args(args, 1):
		return
	MultiplayerConnection.update_flags({
		DoorSubTypeSecurity.get_flag_for(args[1]): MultiplayerConnection.FlagUpdate.TOGGLE
	})
