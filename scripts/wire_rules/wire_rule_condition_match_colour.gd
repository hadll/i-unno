@abstract
class_name WireRuleConditionMatchColour
extends WireRuleCondition

@export var strict: bool

static func generate(rng: RandomNumberGenerator) -> WireRuleConditionMatchColour:
	var created: WireRuleConditionMatchColour
	if rng.randf() < 0.5:
		created = WireRuleConditionMatchColourSingle.generate(rng)
	else:
		created = WireRuleConditionMatchColourMany.generate(rng)
	created.strict = rng.randf() < 0.5
	return created

func check_wires(wires: Array[int]) -> bool:
	var matching := wires[0]
	for i in range(1, len(wires)):
		if strict and matching != wires[i]:
			return false
		matching &= wires[i]
		if not matching:
			return false
	return true

func desc() -> String:
	return "%s %s" % [wires_desc(), "match" if strict else "share a colour"]

@abstract
func wires_desc() -> String
