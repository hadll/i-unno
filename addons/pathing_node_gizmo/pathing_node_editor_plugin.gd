@tool
class_name PathingNodeEditorPlugin
extends EditorPlugin

var gizmo_plugin := PathingNodeGizmoPlugin.new()

func _enter_tree() -> void:
	add_node_3d_gizmo_plugin(gizmo_plugin)

func _exit_tree() -> void:
	remove_node_3d_gizmo_plugin(gizmo_plugin)
