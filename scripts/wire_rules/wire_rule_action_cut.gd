class_name WireRuleActionCut
extends WireRuleAction

@export var wire: WireRuleManager.Wire

static func generate(rng: RandomNumberGenerator, _first: bool) -> WireRuleActionCut:
	var created := new()
	created.wire = WireRuleManager.random_wire(rng)
	return created

func desc() -> String:
	return "cut the %s wire" % WireRuleManager.WIRE_NAMES[wire]
