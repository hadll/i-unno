class_name GenerationObjectPicker
extends GenerationObject

@export var scenes: Array[PackedScene]
@export var weights: Array[float]

@export_group("Ranges", "range_")
@export_range(0, 360, 0.1, "radians_as_degrees", "degrees") var range_angle: float
@export var range_x: float
@export var range_y: float
@export var range_z: float

var picked: GenerationObject

func generate(section_def: SectionDef, rng: RandomNumberGenerator) -> void:
	if len(scenes) != len(weights):
		push_error("GenerationObjectPicker weighting size mismatch")
	if not scenes:
		push_error("GenerationObjectPicker needs at least one scene")
	var total := 0.0
	for weight in weights:
		total += weight
	var roll := rng.randf() * total
	for i in len(weights):
		roll -= weights[i]
		if roll < 0.0:
			if not scenes[i]:
				break
			picked = scenes[i].instantiate()
			add_child(picked)
			picked.rotation.y += (rng.randf() - 0.5) * range_angle
			picked.position += Vector3(
				(rng.randf() - 0.5) * range_x,
				(rng.randf() - 0.5) * range_y,
				(rng.randf() - 0.5) * range_z,
			)
			picked.generate(section_def, rng)
			break
