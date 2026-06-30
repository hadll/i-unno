class_name Page
extends Node3D

@export var paper: MeshInstance3D

func set_image(img: Image) -> void:
	var sm: StandardMaterial3D = paper.material_override
	sm.albedo_texture = ImageTexture.create_from_image(img)
