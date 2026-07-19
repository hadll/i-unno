class_name Office
extends Node3D

func _ready() -> void:
	var generation_seed := await LevelGenerator.generate()
	
	var wire_rule_rng := RandomNumberGenerator.new()
	wire_rule_rng.seed = generation_seed + 2
	WireRuleManager.generate_rules(wire_rule_rng)
	
	TerminalDisplay.me.initialise()
