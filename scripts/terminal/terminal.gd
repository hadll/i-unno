extends Node
signal printed_text(text: String)

const SEP := "/"
const INVALID_NAME_CHARS := "=:@/\"%~"

enum TError {
	MISC = 0,
	NOT_A_FILE = 1, ## using an item that isn't a file as one
	NOT_A_DIR = 2, ## using an item that isn't a dir as one
	INVALID_NAME = 3, ## using invalid characters in a name
	NOT_FOUND = 4, ## dir does not contain an item
	MISSING_ARGS = 5, ## program not given enough args
	INVALID_ARG = 6, ## program given invalid args
	INVALID_READ = 8, ## reading a non-readable file
	INVALID_RUN = 9, ## running a non-runnable file
	MOVING_INSIDE = 16, ## moving an item inside itself
}

var root: TerminalRootDir
var home: TerminalHomeDir
var cwd: TerminalDir
var program_dir: TerminalDir

var error_messages: Dictionary[TError, String] = {
	TError.MISC: "ERROR",
	TError.NOT_A_FILE: "ERROR: {item} is not a file",
	TError.NOT_A_DIR: "ERROR: {item} is not a directory",
	TError.INVALID_NAME: "ERROR: {name} is not a valid name (do not use {chars})",
	TError.NOT_FOUND: "ERROR: {item} not found in {dir}",
	TError.MISSING_ARGS: "ERROR: only got {got} arg(s), needed {needed}",
	TError.INVALID_ARG: "ERROR: arg {arg} is invalid",
	TError.INVALID_READ: "ERROR: {item} is not readable",
	TError.INVALID_RUN: "ERROR: {item} is not runnable",
	TError.MOVING_INSIDE: "ERROR: cannot move {item} to {parent} because {parent} is inside {item}",
}
var error_colour: Color = Color.RED

func prompt() -> void:
	out_print("%s> " % [trans_name_node_to_item(cwd.get_item_node_path())])

func run(command: String) -> void:
	var args := command.split(" ", false)
	if args:
		if args[0].begins_with("./") or args[0].begins_with("/"):
			var local_program := find(args[0])
			if local_program:
				run_item(local_program, args)
		else:
			var program := find(args[0], program_dir)
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
	return node_name.replace_char("=".unicode_at(0), ".".unicode_at(0))

func trans_name_item_to_node(item_name: String) -> String:
	if item_name.contains(INVALID_NAME_CHARS):
		out_error(TError.INVALID_NAME, {
			"name": item_name,
			"chars": INVALID_NAME_CHARS
		})
	return item_name.replace_char(".".unicode_at(0), "=".unicode_at(0))

func find(path: String, from: TerminalDir = null) -> TerminalItem:
	var at: TerminalDir = from if from else cwd
	if not path:
		return at
	if path[0] == "/":
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
