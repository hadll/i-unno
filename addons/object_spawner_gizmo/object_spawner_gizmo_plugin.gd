@tool
class_name ObjectSpawnerGizmoPlugin
extends EditorNode3DGizmoPlugin

var arrow_mesh: Mesh

func _init() -> void:
	create_material("main", Color(1, 0, 0))  # Red arrow
	create_handle_material("handles")
	
	arrow_mesh = load("res://assets/models/dev/object_arrow.obj")

func _get_gizmo_name() -> String:
	return "CameraAngleGizmo"

func _has_gizmo(node: Node3D) -> bool:
	return node is GenerationObjectSpawner

func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	
	var node := gizmo.get_node_3d()
	
	gizmo.add_mesh(arrow_mesh, get_material("main", gizmo))
	
	gizmo.add_collision_segments(arrow_mesh.get_faces())
