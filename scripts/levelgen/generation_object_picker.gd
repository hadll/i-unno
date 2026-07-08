class_name GenerationObjectPicker
extends GenerationObject

@export var scenes: Dictionary[PackedScene, float]

var picked: GenerationObject

func generate(section_def: SectionDef, rng: RandomNumberGenerator) -> void:
	var total := 0.0
	for weight in scenes.values():
		total += weight
	var roll := rng.randf() * total
	for scene in scenes:
		roll -= scenes[scene]
		if roll < 0.0:
			if not scenes[scene]:
				break
			picked = scene.instantiate()
			add_child(picked)
			picked.generate(section_def, rng)
			break
