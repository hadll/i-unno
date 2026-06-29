extends Node
signal printed_text(text: String)

const SEP := "/"
const INVALID_NAME_CHARS := "=:@/\"%"

enum TError {
	MISC = 0,
	NOT_A_FILE = 1, ## using an item that isn't a file as one
	NOT_A_DIR = 2, ## using an item that isn't a dir as one
	INVALID_NAME = 3, ## using invalid characters in a name
	NOT_FOUND = 4, ## dir does not contain an item
	INVALID_READ = 8, ## reading a non-readable file
	INVALID_RUN = 9, ## running a non-runnable file
	MOVING_INSIDE = 16, ## moving an item inside itself
}

var root: TerminalRootDir
var cwd: TerminalDir
var program_dir: TerminalDir
var error_messages: Dictionary[TError, String] = {
	TError.MISC: "ERROR",
	TError.NOT_A_FILE: "ERROR: {item} is not a file",
	TError.NOT_A_DIR: "ERROR: {item} is not a directory",
	TError.INVALID_NAME: "ERROR: {name} is not a valid name (do not use {chars})",
	TError.NOT_FOUND: "ERROR: {item} not found in {dir}",
	TError.INVALID_READ: "ERROR: {item} is not readable",
	TError.INVALID_RUN: "ERROR: {item} is not runnable",
	TError.MOVING_INSIDE: "ERROR: cannot move {item} to {parent} because {parent} is inside {item}",
}

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
	if item_name.contains("=:@/\"%"):
		out_error(TError.INVALID_NAME, {
			"name": item_name,
			"chars": INVALID_NAME_CHARS
		})
	return item_name.replace_char(".".unicode_at(0), "=".unicode_at(0))

func find(path: String, from: TerminalDir = null) -> TerminalItem:
	var spl := path.split(Terminal.SEP, false)
	var at: TerminalDir = root if path.begins_with("/") else (from if from else cwd)
	
	for item in spl.slice(0, -1):
		var next := at.find(item)
		if not next:
			out_error(TError.NOT_FOUND, {
				"item": item,
				"dir": Terminal.trans_name_node_to_item(at.name)
			})
		if next is not TerminalDir:
			out_error(TError.NOT_A_DIR, {
				"item": Terminal.trans_name_node_to_item(at.name)
			})
			return null
	var found_item := at.find(spl[-1])
	if not found_item:
		out_error(TError.NOT_FOUND, {
			"item": spl[-1],
			"dir": Terminal.trans_name_node_to_item(at.name)
		})
	return found_item

func out_error(code: TError, args: Dictionary[String, String]) -> void:
	out_print(error_messages[code].format(args) + "\n")

func out_print(text: String) -> void:
	printed_text.emit(text)
