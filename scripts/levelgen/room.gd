class_name Room
extends Node3D

@export_group("Material Meshes", "meshes_")
@export var meshes_wall: Array[MeshInstance3D]
@export var meshes_floor: Array[MeshInstance3D]

func generate(section_def: SectionDef) -> void:
	for mesh in meshes_wall:
		mesh.material_override = section_def.material_wall
	for mesh in meshes_floor:
		mesh.material_override = section_def.material_floor
