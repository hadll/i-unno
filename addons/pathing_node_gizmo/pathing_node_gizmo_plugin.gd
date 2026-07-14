@tool
class_name PathingNodeGizmoPlugin
extends EditorNode3DGizmoPlugin

var node_mesh: Mesh

func _init() -> void:
	create_material("main", Color(0, 1, 1))
	create_handle_material("handles")
	
	node_mesh = SphereMesh.new()

func _get_gizmo_name() -> String:
	return "CameraAngleGizmo"

func _has_gizmo(node: Node3D) -> bool:
	return node is PathingNode

func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	
	var node := gizmo.get_node_3d()
	
	gizmo.add_mesh(node_mesh, get_material("main", gizmo))
	
	gizmo.add_collision_segments(node_mesh.get_faces())
