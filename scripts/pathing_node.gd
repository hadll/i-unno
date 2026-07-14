class_name PathingNode
extends GenerationObject

static var all_nodes: Array[PathingNode]

var section: SectionDef
var closest_nodes: Array[PathingNode]

static func precalculate_orderings() -> void:
	for node in all_nodes:
		node.sort_by_distance()

func generate(section_def: SectionDef, _rng: RandomNumberGenerator) -> void:
	section = section_def
	all_nodes.append(self)

func sort_by_distance() -> void:
	var distances: Array[float] = []
	var indices: Array[int] = []
	for index in len(all_nodes):
		var node := all_nodes[index]
		if node.section == section:
			distances.append(global_position.distance_to(node.global_position))
			indices.append(index)
	indices.sort_custom(func(a: int, b: int) -> bool:
		return distances[a] < distances[b]
	)
	closest_nodes = []
	for index in indices:
		if all_nodes[index] != self:
			closest_nodes.append(all_nodes[index])
