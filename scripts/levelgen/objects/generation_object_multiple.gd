class_name GenerationObjectMultiple
extends GenerationObject

func generate(section_def: SectionDef, rng: RandomNumberGenerator) -> void:
	for child: GenerationObject in get_children():
		child.generate(section_def, rng)
