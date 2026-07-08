class_name GenerationObjectPicker
extends GenerationObject

@export var scenes: Array[PackedScene]
@export var weights: Array[float]

var picked: GenerationObject

func generate(section_def: SectionDef, rng: RandomNumberGenerator) -> void:
	if len(scenes) != len(weights):
		push_error("GenerationObjectPicker weighting size mismatch")
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
			picked.generate(section_def, rng)
			break
