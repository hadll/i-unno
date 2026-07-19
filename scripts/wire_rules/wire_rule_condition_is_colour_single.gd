class_name WireRuleConditionIsColourSingle
extends WireRuleConditionIsColour

@export var wire: WireRuleManager.Wire

static func generate(rng: RandomNumberGenerator) -> WireRuleConditionIsColourSingle:
	var created := new()
	created.wire = WireRuleManager.random_wire(rng)
	return created

func check(state: WireRuleManager.State) -> bool:
	return check_wire(state.wires[wire])

func wire_desc() -> String:
	return "the %s wire" % WireRuleManager.WIRE_NAMES[wire]

func op_desc() -> String:
	return "is" if strict else "has"
