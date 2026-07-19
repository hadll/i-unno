class_name WireRuleConditionMatchColourMany
extends WireRuleConditionMatchColour

@export var all: bool

static func generate(rng: RandomNumberGenerator) -> WireRuleConditionMatchColourMany:
	var created := new()
	created.all = rng.randf() < 0.5
	return created

func check(state: WireRuleManager.State) -> bool:
	if all:
		return check_wires([
			state.wires[WireRuleManager.Wire.TOP], 
			state.wires[WireRuleManager.Wire.BOTTOM], 
			state.wires[WireRuleManager.Wire.LEFT], 
			state.wires[WireRuleManager.Wire.RIGHT]
		])
	return (
		check_wires([state.wires[WireRuleManager.Wire.TOP], state.wires[WireRuleManager.Wire.BOTTOM]]) or
		check_wires([state.wires[WireRuleManager.Wire.TOP], state.wires[WireRuleManager.Wire.LEFT]]) or
		check_wires([state.wires[WireRuleManager.Wire.TOP], state.wires[WireRuleManager.Wire.RIGHT]]) or
		check_wires([state.wires[WireRuleManager.Wire.BOTTOM], state.wires[WireRuleManager.Wire.LEFT]]) or
		check_wires([state.wires[WireRuleManager.Wire.BOTTOM], state.wires[WireRuleManager.Wire.RIGHT]]) or
		check_wires([state.wires[WireRuleManager.Wire.LEFT], state.wires[WireRuleManager.Wire.RIGHT]])
	)

func wires_desc() -> String:
	return "%s wires" % WireRuleManager.WIRE_NAME_ALL if all else "%s wires" % WireRuleManager.WIRE_NAME_ANY
