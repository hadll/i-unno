class_name DoorSecurity
extends GenerationObject

const LETTERS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const DIGITS := "0123456789"

static var door_codes: Dictionary[DoorSecurity, String]

@onready var security_door: RelayTrigger = $SecurityDoor
@onready var multiplayer_flag_trigger: MultiplayerFlagTrigger = $MultiplayerFlagTrigger
@onready var door_code_note1: DoorCodeNote = $DoorCodeNote1
@onready var door_code_note2: DoorCodeNote = $DoorCodeNote2

var door_code: String

static func get_flag_for(code: String) -> String:
	return "door_%s" % code

static func generate_door_code(rng: RandomNumberGenerator) -> String:
	return LETTERS[rng.randi() % 26] + DIGITS[rng.randi() % 10] + DIGITS[rng.randi() % 10]

func generate(_section_def: SectionDef, rng: RandomNumberGenerator) -> void:
	door_code = generate_door_code(rng)
	while door_code in door_codes.values():
		door_code = generate_door_code(rng)
	door_codes[self] = door_code
	door_code_note1.set_code(door_code)
	door_code_note2.set_code(door_code)
	multiplayer_flag_trigger.flag = get_flag_for(door_code)
