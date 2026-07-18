class_name GenerationObjectMultiple
extends GenerationObject

func generate(section_def: SectionDef, rng: RandomNumberGenerator) -> void:
	for child in get_children():
		if child is GenerationObject:
			child.generate(section_def, rng)
