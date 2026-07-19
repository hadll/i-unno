class_name Level
extends Node3D

const ROOM_SCALE := Vector3(8, 5, 8)

@export var nav_region: NavigationRegion3D

func _ready() -> void:
	await generate()

func generate() -> void:
	var generation_seed := await LevelGenerator.generate()
	
	var wire_rule_rng := RandomNumberGenerator.new()
	wire_rule_rng.seed = generation_seed + 2
	WireRuleManager.generate_rules(wire_rule_rng)
	
	var placement_rng := RandomNumberGenerator.new()
	placement_rng.seed = generation_seed
	
	for room_def in LevelGenerator.rooms:
		var room: GenerationObject = room_def.scene.instantiate()
		room.position = Vector3(room_def.pos) * ROOM_SCALE
		room.rotation.y = -LevelGenerator.dir_angle(room_def.pos_x_dir)
		add_child(room)
		room.generate(room_def.section, placement_rng)
	for door_def in LevelGenerator.doors:
		var door: GenerationObject = LevelGenerator.gen.door_scenes[door_def.type].instantiate()
		door.position = Vector3(door_def.from + door_def.get_target()) / 2.0 * ROOM_SCALE
		door.rotation.y = -LevelGenerator.dir_angle(door_def.dir) + PI * (randi() % 2)
		add_child(door)
		door.generate(door_def.section, placement_rng)
	
	nav_region.bake_navigation_mesh()
	PathingNode.precalculate_orderings()
	
	var enemy_rng := RandomNumberGenerator.new()
	enemy_rng.seed = generation_seed + 1
	
	for section_def in LevelGenerator.gen.sections:
		var section_nodes: Array[PathingNode] = []
		for node in PathingNode.all_nodes:
			section_nodes.append(node)
		for i in section_def.enemy_count:
			var enemy: Enemy = section_def.enemy_pool[enemy_rng.randi() % len(section_def.enemy_pool)].instantiate()
			var node_index := enemy_rng.randi() % len(section_nodes)
			section_nodes.remove_at(node_index)
			var node := section_nodes[node_index]
			add_child(enemy)
			enemy.global_position = node.global_position
			enemy.generate(section_def, enemy_rng)
			enemy.set_target_node(node)
