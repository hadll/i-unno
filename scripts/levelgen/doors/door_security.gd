class_name DoorSecurity
extends GenerationObject

static var door_codes: Dictionary[DoorSecurity, String]

@onready var security_door: RelayTrigger = $SecurityDoor
@onready var multiplayer_flag_trigger: MultiplayerFlagTrigger = $MultiplayerFlagTrigger

var door_code: String

static func get_flag_for(code: String) -> String:
	return "door_%s" % code

static func generate_door_code(rng: RandomNumberGenerator) -> String:
	return "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[rng.randi() % 26] + str(rng.randi() % 100)

func generate(_section_def: SectionDef, rng: RandomNumberGenerator) -> void:
	door_code = generate_door_code(rng)
	while door_code in door_codes.values():
		door_code = generate_door_code(rng)
	door_codes[self] = door_code
	multiplayer_flag_trigger.flag = get_flag_for(door_code)
