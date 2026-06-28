class_name Level
extends Node3D

@onready var level_generator: LevelGenerator = $LevelGenerator

func _ready() -> void:
	level_generator.generate()
