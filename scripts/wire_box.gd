class_name WireBox
extends GenerationObject
signal cut

@export var lid: MeshInstance3D
@export var lid_opener: StaticBody3D
@export var open_lid_trigger: Trigger

@export var top_wire: ColouredWire
@export var bottom_wire: ColouredWire
@export var left_wire: ColouredWire
@export var right_wire: ColouredWire

var state: WireRuleManager.State
var solution: WireRuleManager.Wire

func generate(_section_def: SectionDef, rng: RandomNumberGenerator) -> void:
	open_lid_trigger.trigger.connect(open)
	
	state = WireRuleManager.generate_state(rng)
	solution = WireRuleManager.solve(state)
	
	top_wire.cut.connect(wire_cut.bind(top_wire, WireRuleManager.Wire.TOP))
	bottom_wire.cut.connect(wire_cut.bind(bottom_wire, WireRuleManager.Wire.BOTTOM))
	left_wire.cut.connect(wire_cut.bind(left_wire, WireRuleManager.Wire.LEFT))
	right_wire.cut.connect(wire_cut.bind(right_wire, WireRuleManager.Wire.RIGHT))
	
	top_wire.set_colours(state.wires[WireRuleManager.Wire.TOP])
	bottom_wire.set_colours(state.wires[WireRuleManager.Wire.BOTTOM])
	left_wire.set_colours(state.wires[WireRuleManager.Wire.LEFT])
	right_wire.set_colours(state.wires[WireRuleManager.Wire.RIGHT])

func open() -> void:
	if lid: lid.queue_free()
	if lid_opener: lid_opener.queue_free()

func wire_cut(c_wire: ColouredWire, which: WireRuleManager.Wire) -> void:
	c_wire.queue_free()
	if which != solution:
		print("incorrect wire")
	cut.emit()
