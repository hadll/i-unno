@tool
extends EditorPlugin


const gizmo_plugin_class = preload("res://addons/camera_angle_gizmo/arrow_gizmo_plugin.gd")

var gizmo_plugin = gizmo_plugin_class.new()

func _enter_tree():
	add_node_3d_gizmo_plugin(gizmo_plugin)

func _exit_tree():
	remove_node_3d_gizmo_plugin(gizmo_plugin)
