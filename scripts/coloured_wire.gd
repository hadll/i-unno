class_name ColouredWire
extends StaticBody3D

signal cut

@export var cut_trigger: Trigger
@export var mesh: MeshInstance3D

func _ready() -> void:
	cut_trigger.trigger.connect(cut.emit)

func set_colours(to: int) -> void:
	var lowest := 0
	while to & (1 << lowest) == 0:
		lowest += 1
	var highest := len(WireRuleManager.COLOUR_NAMES) - 1
	while to & (1 << highest) == 0:
		highest -= 1
	var under: StandardMaterial3D = mesh.material_override
	var over: StandardMaterial3D = under.next_pass
	under.uv1_offset.x = lowest * 0.5 / len(WireRuleManager.COLOUR_NAMES)
	over.uv1_offset.x = highest * 0.5 / len(WireRuleManager.COLOUR_NAMES) + 0.5
