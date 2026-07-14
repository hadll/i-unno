class_name PathingNode
extends Node3D

static var all_nodes: Array[PathingNode]

var closest_nodes: Array[PathingNode]

static func precalculate_orderings() -> void:
	for node in all_nodes:
		node.sort_by_distance()

func _ready() -> void:
	all_nodes.append(self)

func sort_by_distance() -> void:
	var distances: Array[float] = []
	var indices: Array[int] = []
	indices.assign(range(len(all_nodes)))
	for node in all_nodes:
		distances.append(global_position.distance_squared_to(node.global_position))
	indices.sort_custom(func(a: int, b: int) -> bool:
		return distances[a] < distances[b]
	)
	closest_nodes = []
	for index in indices:
		if all_nodes[index] != self:
			closest_nodes.append(all_nodes[index])
