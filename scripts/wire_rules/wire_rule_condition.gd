@abstract
class_name WireRuleCondition
extends WireRuleData

static func generate(rng: RandomNumberGenerator) -> WireRuleCondition:
	if rng.randf() < 0.5:
		return WireRuleConditionIsColour.generate(rng)
	else:
		return WireRuleConditionMatchColour.generate(rng)

@abstract
func check(state: WireRuleManager.State) -> bool
