class_name WireRuleConditionMatchColourSingle
extends WireRuleConditionMatchColour

@export var wire_1: WireRuleManager.Wire
@export var wire_2: WireRuleManager.Wire

static func generate(rng: RandomNumberGenerator) -> WireRuleConditionMatchColour:
	var created := new()
	created.wire_1 = WireRuleManager.random_wire(rng)
	while not created.wire_2 or created.wire_1 == created.wire_2:
		created.wire_2 = WireRuleManager.random_wire(rng)
	return created

func check(state: WireRuleManager.State) -> bool:
	return check_wires([state.wires[wire_1], state.wires[wire_2]])

func wires_desc() -> String:
	return "the %s and %s wires" % [WireRuleManager.WIRE_NAMES[wire_1], WireRuleManager.WIRE_NAMES[wire_2]]
