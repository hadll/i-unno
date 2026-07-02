extends Node3D

@onready var level_generator: LevelGenerator = $LevelGenerator

func _ready() -> void:
	generate()

func generate() -> void:
	var placement_rng := RandomNumberGenerator.new()
	placement_rng.seed = level_generator.generate()
	Map.draw(level_generator)
