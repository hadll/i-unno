@abstract
class_name WireRuleConditionIsColour
extends WireRuleCondition

@export var colour: int
@export var strict: bool

static func generate(rng: RandomNumberGenerator) -> WireRuleConditionIsColour:
	var created: WireRuleConditionIsColour
	if rng.randf() < 0.5:
		created = WireRuleConditionIsColourSingle.generate(rng)
	else:
		created = WireRuleConditionIsColourMany.generate(rng)
	created.strict = rng.randf() < 0.5
	created.colour = WireRuleManager.random_colour(rng, 0.25 if created.strict else 0.0)
	return created

func check_wire(wire_colour: int) -> bool:
	return wire_colour == colour if strict else wire_colour & colour != 0

func desc() -> String:
	return "%s %s %s" % [wire_desc(), op_desc(), WireRuleManager.get_colour_name(colour)]

@abstract
func wire_desc() -> String

@abstract
func op_desc() -> String
