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
	var highest := len(WireRuleManager.Colour) - 1
	while to & (1 << highest) == 0:
		highest -= 1
	var under: StandardMaterial3D = mesh.material_override
	var over: StandardMaterial3D = under.next_pass
	under.uv1_offset.x = lowest / 16.0
	over.uv1_offset.x = highest / 16.0 + 0.5
