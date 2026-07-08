class_name GenerationObjectOffset
extends GenerationObject

@export_group("Ranges", "range_")
@export_range(0, 360, 0.1, "radians_as_degrees", "degrees") var range_angle: float
@export var range_x: float
@export var range_y: float
@export var range_z: float

func generate(_section_def: SectionDef, rng: RandomNumberGenerator) -> void:
	rotation.y += (rng.randf() - 0.5) * range_angle
	position += Vector3(
		(rng.randf() - 0.5) * range_x,
		(rng.randf() - 0.5) * range_y,
		(rng.randf() - 0.5) * range_z,
	)
