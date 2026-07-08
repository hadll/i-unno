class_name Room
extends GenerationObject

@export var objects: Array[GenerationObject]
@export_group("Material Meshes", "meshes_")
@export var meshes_wall: Array[MeshInstance3D]
@export var meshes_floor: Array[MeshInstance3D]

func generate(section_def: SectionDef, rng: RandomNumberGenerator) -> void:
	for mesh in meshes_wall:
		mesh.material_override = section_def.material_wall
	for mesh in meshes_floor:
		mesh.material_override = section_def.material_floor
	for object in objects:
		object.generate(section_def, rng)
