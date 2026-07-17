extends Node
signal printed_text(text: String)
signal printed_text_raw(text: String)

const SEP := "/"
const EXT := "."
const EXT_REPLACE := "="
const HOME := "~"
const INVALID_NAME_CHARS := ":@\"%" + SEP + EXT_REPLACE + HOME

enum TError {
	MISC = 0,
	NOT_A_FILE = 1, ## using an item that isn't a file as one
	NOT_A_DIR = 2, ## using an item that isn't a dir as one
	INVALID_NAME = 3, ## using invalid characters in a name
	NOT_FOUND = 4, ## dir does not contain an item
	MISSING_ARGS = 5, ## program not given enough args
	INVALID_ARG = 6, ## program given invalid args
	ITEM_EXISTS = 7, ## creating an item that already exists
	INVALID_READ = 8, ## reading a non-readable file
	INVALID_RUN = 9, ## running a non-runnable file
	MOVING_INSIDE = 16, ## moving an item inside itself
	IMMUTABLE_DIR = 17, ## trying to change an immutable dir (root, home...)
}

var root: TerminalRootDir
var home: TerminalHomeDir
var cwd: TerminalDir
var program_dir: TerminalDir

var error_messages: Dictionary[TError, String] = {
	TError.MISC: "ERROR: {msg}",
	TError.NOT_A_FILE: "ERROR: {item} is not a file",
	TError.NOT_A_DIR: "ERROR: {item} is not a directory",
	TError.INVALID_NAME: "ERROR: {name} is not a valid name (do not use {chars})",
	TError.NOT_FOUND: "ERROR: {item} not found in {dir}",
	TError.MISSING_ARGS: "ERROR: only got {got} arg(s), needed {needed}",
	TError.INVALID_ARG: "ERROR: arg {arg} is invalid",
	TError.ITEM_EXISTS: "ERROR: {item} already exists in {dir}",
	TError.INVALID_READ: "ERROR: {item} is not readable",
	TError.INVALID_RUN: "ERROR: {item} is not runnable",
	TError.MOVING_INSIDE: "ERROR: cannot move {item} to {dir} because {dir} is inside {item}",
}
var error_colour: Color = Color.RED

func prompt() -> void:
	out_print("%s> " % [trans_name_node_to_item(cwd.get_item_node_path())])

func run(command: String) -> void:
	var args := command.split(" ", false)
	if args:
		var program := find_program_item(args[0])
		if program:
			run_item(program, args)
	prompt()

func run_item(item: TerminalItem, args: PackedStringArray) -> void:
	if item is TerminalFile:
		item.run(args)
	else:
		out_error(TError.NOT_A_FILE, {
			"item": Terminal.trans_name_node_to_item(item.name)
		})

func trans_name_node_to_item(node_name: String) -> String:
	return node_name.replace_char(Terminal.EXT_REPLACE.unicode_at(0), Terminal.EXT.unicode_at(0))

func trans_name_item_to_node(item_name: String) -> String:
	if item_name.contains(INVALID_NAME_CHARS):
		out_error(TError.INVALID_NAME, {
			"name": item_name,
			"chars": INVALID_NAME_CHARS
		})
	return item_name.replace_char(Terminal.EXT.unicode_at(0), Terminal.EXT_REPLACE.unicode_at(0))

func make_item_name(from: String) -> String:
	return (from
		.replace_chars(INVALID_NAME_CHARS, "_".unicode_at(0))
		.replace_char(Terminal.EXT.unicode_at(0), Terminal.EXT_REPLACE.unicode_at(0))
	)

func valid_item_name(item_name: String) -> bool:
	if item_name == EXT:
		return false
	if item_name == EXT.repeat(2):
		return false
	for c in INVALID_NAME_CHARS:
		if item_name.contains(c):
			return false
	return true

func can_remove(item: TerminalItem) -> bool:
	return not (
		item.is_ancestor_of(cwd) or item == cwd or
		item.is_ancestor_of(home) or item == home or
		item.is_ancestor_of(program_dir) or item == program_dir
	)

func find_program_item(path: String) -> TerminalItem:
	var dir := program_dir
	if path.begins_with(EXT + SEP):
		dir = cwd
	return find(path, dir)

func find(path: String, from: TerminalDir = null) -> TerminalItem:
	var at: TerminalDir = from if from else cwd
	if not path:
		return at
	if path[0] == SEP:
		at = root
		path = path.substr(1)
	elif path[0] == "~":
		at = home
		path = path.substr(1)
	
	var spl := path.split(Terminal.SEP, false)
	if not spl:
		return at
	
	for item in spl.slice(0, -1):
		var next := at.find(item)
		if not next:
			out_error(TError.NOT_FOUND, {
				"item": item,
				"dir": Terminal.trans_name_node_to_item(at.name)
			})
			return null
		while next is TerminalAlias:
			next = next.item
		if next is TerminalDir:
			at = next
		else:
			out_error(TError.NOT_A_DIR, {
				"item": Terminal.trans_name_node_to_item(at.name)
			})
			return null
	var found_item := at.find(spl[-1])
	while found_item is TerminalAlias:
		found_item = found_item.item
	if not found_item:
		out_error(TError.NOT_FOUND, {
			"item": spl[-1],
			"dir": Terminal.trans_name_node_to_item(at.name)
		})
	return found_item

func out_error(code: TError, args: Dictionary[String, String]) -> void:
	printed_text.emit(error_messages[code].format(args) + "\n", "[color=#%s]" % error_colour.to_html(false), "[/color]")

func out_print(text: String) -> void:
	printed_text.emit(text)

func out_print_raw(text: String) -> void:
	printed_text_raw.emit(text)
