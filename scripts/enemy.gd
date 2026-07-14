@abstract
class_name Enemy
extends GenerationObject

var target_node: PathingNode
var visited_nodes: Array[PathingNode] = []

func pick_new_target() -> void:
	for node in target_node.closest_nodes:
		if node not in visited_nodes:
			set_target_node(node)
			return
	visited_nodes.clear()
	pick_new_target()
	set_target_node(target_node.closest_nodes[0])

func set_target_node(to: PathingNode) -> void:
	target_node = to
	visited_nodes.append(target_node)
	set_target_position(target_node.global_position)

@abstract
func set_target_position(to: Vector3) -> void
