class_name Inventory
extends Control

# can't exactly have 6 root nodes, really don't know how this should work
@export var trigger_item_next: Trigger
@export var trigger_item_previous: Trigger
@export var trigger_item_1: Trigger
@export var trigger_item_2: Trigger
@export var trigger_item_3: Trigger
@export var trigger_item_4: Trigger

@export var slots: Array[ItemSlot]

var selected_slot := 0

func _ready() -> void:
	select_slot(0)
	InputHandler.input.connect(item_input)
	trigger_item_next.trigger_start.connect(func() -> void:
		select_slot(selected_slot + 1)
	)
	trigger_item_previous.trigger_start.connect(func() -> void:
		select_slot(selected_slot - 1)
	)
	trigger_item_1.trigger_start.connect(func() -> void:
		select_slot(0)
	)
	trigger_item_2.trigger_start.connect(func() -> void:
		select_slot(1)
	)
	trigger_item_3.trigger_start.connect(func() -> void:
		select_slot(2)
	)
	trigger_item_4.trigger_start.connect(func() -> void:
		select_slot(3)
	)

func item_input(event: InputEvent) -> void:
	if slots[selected_slot].item:
		slots[selected_slot].item.item_input(event)

func select_slot(slot: int) -> void:
	slots[selected_slot].deselect()
	selected_slot = posmod(slot, len(slots))
	slots[selected_slot].select()

func get_selected_item() -> Item:
	return slots[selected_slot].item

func set_selected_item(to: Item) -> void:
	slots[selected_slot].set_item(to)

func pick_up_item(item: Item) -> bool:
	for slot in slots:
		if not slot.item:
			slot.set_item(item)
			return true
	return false
