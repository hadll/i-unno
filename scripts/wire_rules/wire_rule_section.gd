class_name WireRuleSection
extends WireRuleData

const STEP_HEADINGS := "abcdefghijklmnopqrstuvwxyz"

@export var steps: Array[WireRuleStep]
@export var otherwise: WireRuleAction

static func generate(rng: RandomNumberGenerator, samples: Array[WireRuleManager.State], first: bool) -> WireRuleSection:
	var created := new()
	created.steps = []
	for i in rng.randi_range(3, 8):
		var rule := WireRuleStep.generate(rng, first)
		var passed: Array[WireRuleManager.State] = []
		var failed: Array[WireRuleManager.State] = []
		for state in samples:
			if rule.condition.check(state):
				passed.append(state)
			else:
				failed.append(state)
		if passed and failed:
			created.steps.append(rule)
			WireRuleManager.try_init_new_section(rng, passed, false)
			samples = failed
	created.otherwise = WireRuleAction.generate(rng, first)
	WireRuleManager.try_init_new_section(rng, samples, false)
	return created

func desc() -> String:
	var text := ""
	for i in len(steps):
		text += " %s) %s\n" % [STEP_HEADINGS[i], steps[i].desc()]
	text += " %s) otherwise, %s" % [STEP_HEADINGS[len(steps)], otherwise.desc()] if steps else " %s" % otherwise.desc()
	return text
