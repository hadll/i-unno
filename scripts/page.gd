class_name Page
extends Node3D

@onready var paper: MeshInstance3D = $Paper

func set_image(img: Image) -> void:
	var sm: ShaderMaterial = paper.material_override
	sm.set_shader_parameter(&"image", img)
