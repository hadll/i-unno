class_name DoorPicker
extends Door

@export var sub_type_scenes: Array[PackedScene]
@export var sub_type_weights: Array[float]

func generate(section_def: SectionDef, rng: RandomNumberGenerator) -> void:
	var total := 0.0
	for weight in sub_type_weights:
		total += weight
	var roll := rng.randf() * total
	for i in len(sub_type_weights):
		roll -= sub_type_weights[i]
		if roll < 0.0:
			var sub_type: DoorSubType = sub_type_scenes[i].instantiate()
			add_child(sub_type)
			sub_type.generate(section_def, rng)
			return
