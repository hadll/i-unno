@abstract
class_name WireRuleAction
extends WireRuleData

static func generate(rng: RandomNumberGenerator, first: bool) -> WireRuleAction:
	if rng.randf() < 0.8 if first else rng.randf() < 0.1:
		return WireRuleActionJump.generate(rng, first)
	else:
		return WireRuleActionCut.generate(rng, first)
