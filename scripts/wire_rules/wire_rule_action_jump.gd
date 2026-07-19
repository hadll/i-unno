class_name WireRuleActionJump
extends WireRuleAction

@export var section: int

static func generate(_rng: RandomNumberGenerator, _first: bool) -> WireRuleActionJump:
	var created := new()
	created.section = WireRuleManager.assign_new_section()
	return created

func desc() -> String:
	return "see section %d" % (section + 1)
