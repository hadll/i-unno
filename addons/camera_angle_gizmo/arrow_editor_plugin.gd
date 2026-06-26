@tool
class_name ArrowEditorPlugin
extends EditorPlugin

var gizmo_plugin := ArrowGizmoPlugin.new()

func _enter_tree() -> void:
	add_node_3d_gizmo_plugin(gizmo_plugin)

func _exit_tree() -> void:
	remove_node_3d_gizmo_plugin(gizmo_plugin)
