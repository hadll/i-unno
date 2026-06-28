class_name Door
extends Node3D

static var door_codes: Dictionary[Door, String]

@export var security_door_scene: PackedScene
var door_code: String

func generate(section_def: SectionDef, rng: RandomNumberGenerator) -> void:
	if rng.randf() < 0.1:
		var security_door: RelayTrigger = security_door_scene.instantiate()
		generate_door_code(rng)
		var flag = "door_" + door_code
		#security_door.triggers.append()
		add_child(security_door)

func generate_door_code(rng: RandomNumberGenerator) -> void:
	door_code = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[rng.randi() % 26] + str(rng.randi() % 100)
	while door_code in door_codes.values():
		door_code = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"[rng.randi() % 26] + str(rng.randi() % 100)
	door_codes[self] = door_code
