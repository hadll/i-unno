extends Node

const SEP := "/"
const INVALID_NAME_CHARS := "=:@/\"%"

enum TError {
	MISC = 0,
	NOT_A_FILE = 1, ## using an item that isn't a file as one
	NOT_A_DIR = 2, ## using an item that isn't a dir as one
	INVALID_NAME = 3, ## using invalid characters in a name
	INVALID_READ = 8, ## reading a non-readable file
	INVALID_RUN = 9, ## running a non-runnable file
	MOVING_INSIDE = 16, ## moving an item inside itself
}

var root: TerminalRootDir
var cwd: TerminalDir
var error_messages: Dictionary[TError, String] = {
	TError.MISC: "ERROR",
	TError.NOT_A_FILE: "ERROR: {item} is not a file",
	TError.NOT_A_DIR: "ERROR: {item} is not a directory",
	TError.INVALID_NAME: "ERROR: {name} is not a valid name (do not use {chars})",
	TError.INVALID_READ: "ERROR: {item} is not readable",
	TError.INVALID_RUN: "ERROR: {item} is not runnable",
	TError.MOVING_INSIDE: "ERROR: cannot move {item} to {parent} because {parent} is inside {item}",
}

func trans_name_node_to_item(node_name: String) -> String:
	return node_name.replace_char("=".unicode_at(0), ".".unicode_at(0))

func trans_name_item_to_node(item_name: String) -> String:
	if item_name.contains("=:@/\"%"):
		out_error(TError.INVALID_NAME, {
			"name": item_name,
			"chars": INVALID_NAME_CHARS
		})
	return item_name.replace_char(".".unicode_at(0), "=".unicode_at(0))

func find(path: String) -> TerminalItem:
	var spl := path.split(Terminal.SEP, false)
	var at: TerminalItem = root if path.begins_with("/") else cwd
	
	for item in spl:
		at = at.find(item)
		if at is not TerminalDir:
			out_error(TError.NOT_A_DIR, {
				"item": Terminal.trans_name_node_to_item(at.name)
			})
	return at

func out_error(code: TError, args: Dictionary[String, String]) -> void:
	out_print(error_messages[code].format(args))

func out_print(text: String) -> void:
	print(text)
