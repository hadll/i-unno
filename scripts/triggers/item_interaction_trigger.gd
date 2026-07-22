class_name ItemInteractionTrigger
extends Trigger

enum FilterMode {
	ANY = 0,
	ITEM = 1,
	ITEM_ID = 2,
}

@export var interact_trigger: Trigger
@export var filter_mode: FilterMode
@export var filter_item_id: StringName
@export var filter_item: Item
@export var consume := false

func _ready() -> void:
	interact_trigger.trigger_start.connect(interact)

func interact() -> void:
	var selected := Player.me.inventory.get_selected_item()
	if not selected:
		return
	match filter_mode:
		FilterMode.ITEM: if selected != filter_item: return
		FilterMode.ITEM_ID: if selected.get_item_id() != filter_item_id: return
	set_active(true)
	if consume:
		Player.me.inventory.set_selected_item(null)
	set_active(false)
