extends Node

enum Wire {
	TOP = 0,
	BOTTOM = 1,
	LEFT = 2,
	RIGHT = 3,
}
enum Colour {
	K = 1 << 0,
	R = 1 << 1,
	G = 1 << 2,
	B = 1 << 3,
	O = 1 << 4,
	Y = 1 << 5,
	W = 1 << 6,
}

const SAMPLE_COUNT := 1024
const MAX_SECTIONS := 8
const WIRE_NAMES: Dictionary[WireRuleManager.Wire, String] = {
	WireRuleManager.Wire.TOP: "[b]top[/b]",
	WireRuleManager.Wire.BOTTOM: "[b]bottom[/b]",
	WireRuleManager.Wire.LEFT: "[b]left[/b]",
	WireRuleManager.Wire.RIGHT: "[b]right[/b]",
}
const WIRE_NAME_ALL := "[b]all[/b]"
const WIRE_NAME_ANY := "[b]any[/b]"
const COLOUR_NAMES: Dictionary[WireRuleManager.Colour, String] = {
	WireRuleManager.Colour.K: "[b][color=gray]Black[/color][/b]",
	WireRuleManager.Colour.R: "[b][color=red]Red[/color][/b]",
	WireRuleManager.Colour.G: "[b][color=green]Green[/color][/b]",
	WireRuleManager.Colour.B: "[b][color=blue]Blue[/color][/b]",
	WireRuleManager.Colour.O: "[b][color=orange]Orange[/color][/b]",
	WireRuleManager.Colour.Y: "[b][color=yellow]Yellow[/color][/b]",
	WireRuleManager.Colour.W: "[b][color=white]White[/color][/b]",
}

var sections: Dictionary[int, WireRuleSection]
var section_count: int
var new_section: bool

func generate_rules(rng: RandomNumberGenerator) -> void:
	sections = {}
	section_count = 0
	new_section = false
	var samples: Array[WireRuleManager.State] = []
	for i in SAMPLE_COUNT:
		samples.append(generate_state(rng))
	init_new_section(rng, samples, true)

func assign_new_section() -> int:
	new_section = true
	return section_count

func try_init_new_section(rng: RandomNumberGenerator, samples: Array[WireRuleManager.State], first: bool) -> void:
	if not new_section:
		return
	new_section = false
	init_new_section(rng, samples, first)

func init_new_section(rng: RandomNumberGenerator, samples: Array[WireRuleManager.State], first: bool) -> void:
	var index := section_count
	section_count += 1
	sections[index] = WireRuleSection.generate(rng, samples, first)

func more_sections_allowed() -> bool:
	return section_count < MAX_SECTIONS

func get_colour_name(colour: int) -> String:
	var names: PackedStringArray = []
	for mask: int in COLOUR_NAMES.keys():
		if mask & colour != 0:
			names.append(COLOUR_NAMES[mask])
	return " and ".join(names)

func random_wire(rng: RandomNumberGenerator) -> WireRuleManager.Wire:
	return (rng.randi() % len(Wire)) as WireRuleManager.Wire

func random_colour(rng: RandomNumberGenerator, multi: float) -> int:
	return 1 << (rng.randi() % len(Colour)) | (1 << (rng.randi() % len(Colour)) if rng.randf() < multi else 0)

func generate_state(rng: RandomNumberGenerator) -> WireRuleManager.State:
	return WireRuleManager.State.new({
		WireRuleManager.Wire.TOP: random_colour(rng, 0.5),
		WireRuleManager.Wire.BOTTOM: random_colour(rng, 0.5),
		WireRuleManager.Wire.LEFT: random_colour(rng, 0.5),
		WireRuleManager.Wire.RIGHT: random_colour(rng, 0.5),
	})

func solve(state: WireRuleManager.State) -> WireRuleManager.Wire:
	var section := sections[0]
	var step_index := 0
	while true:
		var action: WireRuleAction
		if step_index < len(section.steps):
			var step := section.steps[step_index]
			step_index += 1
			if step.condition.check(state):
				action = step.action
			else:
				continue
		else:
			action = section.otherwise
		if action is WireRuleActionJump:
			section = sections[action.section]
			step_index = 0
		elif action is WireRuleActionCut:
			return action.wire
		else:
			push_error("invalid WireRuleAction")
	return WireRuleManager.Wire.TOP # unreachable

func get_instructions() -> String:
	var text := ""
	for i in section_count:
		text += "%d.\n%s\n" % [i + 1, sections[i].desc()]
	return text

class State:
	var wires: Dictionary[Wire, int]
	
	func _init(w: Dictionary[Wire, int]) -> void:
		wires = w
