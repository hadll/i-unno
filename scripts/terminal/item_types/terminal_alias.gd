class_name TerminalAlias
extends TerminalItem

@export var item: TerminalItem

func get_display_name(follow_alias := true) -> String:
	if follow_alias:
		return "%s => %s" % [super(false), item.get_display_name(false)]
	else:
		return super(false)
