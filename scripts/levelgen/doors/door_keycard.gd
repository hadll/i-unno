class_name DoorKeycard
extends GenerationObject

@export var item_id: StringName

@onready var security_door: RelayTrigger = $SecurityDoor
@onready var item_interaction_trigger: ItemInteractionTrigger = $ItemInteractionTrigger

func generate(_section_def: SectionDef, _rng: RandomNumberGenerator) -> void:
	item_interaction_trigger.filter_item_id = item_id
	
