class_name WireRuleStep
extends WireRuleData

@export var condition: WireRuleCondition
@export var action: WireRuleAction

static func generate(rng: RandomNumberGenerator, first: bool) -> WireRuleStep:
	var created := new()
	created.condition = WireRuleCondition.generate(rng)
	created.action = WireRuleAction.generate(rng, first)
	return created

func desc() -> String:
	return "if %s, %s" % [condition.desc(), action.desc()]
