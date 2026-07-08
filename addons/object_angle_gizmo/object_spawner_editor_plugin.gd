@tool
class_name ObjectSpawnerEditorPlugin
extends EditorPlugin

var gizmo_plugin := ObjectSpawnerGizmoPlugin.new()

func _enter_tree() -> void:
	add_node_3d_gizmo_plugin(gizmo_plugin)

func _exit_tree() -> void:
	remove_node_3d_gizmo_plugin(gizmo_plugin)
