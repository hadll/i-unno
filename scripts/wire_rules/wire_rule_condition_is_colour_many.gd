class_name WireRuleConditionIsColourMany
extends WireRuleConditionIsColour

@export var all: bool

static func generate(rng: RandomNumberGenerator) -> WireRuleConditionIsColourMany:
	var created := new()
	created.all = rng.randf() < 0.5
	return created

func check(state: WireRuleManager.State) -> bool:
	return (
		int(check_wire(state.wires[WireRuleManager.Wire.TOP])) +
		int(check_wire(state.wires[WireRuleManager.Wire.BOTTOM])) +
		int(check_wire(state.wires[WireRuleManager.Wire.LEFT])) +
		int(check_wire(state.wires[WireRuleManager.Wire.RIGHT]))
	) >= (4 if all else 1)

func wire_desc() -> String:
	return "%s wires" % WireRuleManager.WIRE_NAME_ALL if all else "%s wire" % WireRuleManager.WIRE_NAME_ANY

func op_desc() -> String:
	return ("are" if strict else "have") if all else ("is" if strict else "has")
