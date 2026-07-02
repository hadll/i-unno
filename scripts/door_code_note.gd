class_name DoorCodeNote
extends Node3D

const CHAR_SIZE := 32

@onready var letter: Sprite3D = $Letter
@onready var number_1: Sprite3D = $Number1
@onready var number_2: Sprite3D = $Number2

func set_code(code: String) -> void:
	letter.region_rect.position.x = CHAR_SIZE * DoorSecurity.LETTERS.find(code[0])
	number_1.region_rect.position.x = CHAR_SIZE * DoorSecurity.DIGITS.find(code[1])
	number_2.region_rect.position.x = CHAR_SIZE * DoorSecurity.DIGITS.find(code[2])
