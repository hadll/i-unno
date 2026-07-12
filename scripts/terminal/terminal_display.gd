class_name TerminalDisplay
extends Control

const CURSOR_PRE := "[c]"
const CURSOR_POST := "[/c]"

@export var print_speed: float

@export var fs_root: TerminalRootDir
@export var fs_home: TerminalHomeDir
@export var fs_programs: TerminalDir
@export var fs_maps: TerminalDir
@export var screen_text: RichTextLabel

var screen_string := ""
var true_visible := 0.0
var typing_start_text_index := 0
var typing_start_string_index := 0
var allow_typing := true
var printing := false
var command_history: Array[String] = []
var command_history_index := 0
var cursor_inset_amount := 0
var tab_completions: Array[String] = []
var tab_completion_index := 0
var has_cursor := false

func _ready() -> void:
	if MultiplayerConnection.username:
		fs_home.name = Terminal.make_item_name(MultiplayerConnection.username)
	Terminal.printed_text.connect(print_text)
	Terminal.root = fs_root
	Terminal.home = fs_home
	Terminal.cwd = fs_home
	Terminal.program_dir = fs_programs
	Terminal.prompt()
	add_cursor()
	update_display_text()
	Map.add_files(fs_maps)

func _process(delta: float) -> void:
	if printing:
		true_visible += delta * print_speed
		var now_visible := mini(typing_start_text_index, int(true_visible))
		if now_visible == typing_start_text_index:
			finish_printing()
		else:
			screen_text.visible_characters = now_visible
		
func key_input(event: InputEventKey) -> void:
	if not event.is_pressed():
		return
	remove_cursor()
	if event.keycode == Key.KEY_ENTER:
		var command := screen_string.substr(typing_start_string_index).replace("[lb]", "[")
		print_text("\n")
		finish_printing()
		Terminal.run(command)
		command_history.append(command)
		command_history_index = len(command_history)
		cursor_inset_amount = 0
		tab_completions = []
		add_cursor()
		update_display_text()
		return
	
	if event.unicode:
		if allow_typing:
			type_ahead(String.chr(event.unicode))
			tab_completions = []
	elif event.keycode == Key.KEY_BACKSPACE:
		if len(screen_string) - cursor_inset_amount > typing_start_string_index:
			delete_behind(1)
			tab_completions = []
	elif event.keycode == Key.KEY_UP:
		command_history_index = maxi(0, command_history_index - 1)
		screen_string = screen_string.substr(0, typing_start_string_index)
		screen_string += command_history[command_history_index].replace("[", "[lb]")
		cursor_inset_amount = 0
		tab_completions = []
		update_display_text()
	elif event.keycode == Key.KEY_DOWN:
		command_history_index = mini(len(command_history), command_history_index + 1)
		screen_string = screen_string.substr(0, typing_start_string_index)
		if command_history_index < len(command_history):
			screen_string += command_history[command_history_index].replace("[", "[lb]")
		cursor_inset_amount = 0
		tab_completions = []
		update_display_text()
	elif event.keycode == Key.KEY_LEFT:
		if screen_string.substr(len(screen_string) - cursor_inset_amount - 4, 4) == "[lb]":
			cursor_inset_amount += 4
		else:
			cursor_inset_amount += 1
		cursor_inset_amount = mini(len(screen_string) - typing_start_string_index, cursor_inset_amount)
		tab_completions = []
	elif event.keycode == Key.KEY_RIGHT:
		if screen_string.substr(len(screen_string) - cursor_inset_amount, 4) == "[lb]":
			cursor_inset_amount -= 4
		else:
			cursor_inset_amount -= 1
		cursor_inset_amount = maxi(0, cursor_inset_amount)
		tab_completions = []
	elif event.keycode == Key.KEY_TAB:
		if not tab_completions:
			var typed := screen_string.substr(typing_start_string_index, len(screen_string) - cursor_inset_amount)
			var arg_index = typed.count(" ")
			var incomplete_path := typed.get_slice(" ", arg_index)
			var parts := incomplete_path.rsplit(Terminal.SEP, true, 1)
			if parts:
				var dir_path := Terminal.EXT if len(parts) == 1 else parts[0]
				var partial := parts[0] if len(parts) == 1 else parts[1]
				var dir := Terminal.find_program_item(dir_path) if arg_index == 0 else Terminal.find(dir_path)
				if dir is TerminalDir:
					tab_completions = []
					for item in dir.get_items(false):
						var item_name := Terminal.trans_name_node_to_item(item.name)
						if item_name.begins_with(partial):
							tab_completions.append(item_name.substr(len(partial)))
					tab_completion_index = 0
					if tab_completions:
						type_ahead(tab_completions[tab_completion_index])
		else:
			delete_behind(len(tab_completions[tab_completion_index]))
			tab_completion_index = posmod(tab_completion_index + (-1 if event.shift_pressed else 1), len(tab_completions))
			type_ahead(tab_completions[tab_completion_index])
	add_cursor()
	update_display_text()

func add_cursor() -> void:
	if has_cursor:
		return
	if cursor_inset_amount == 0:
		screen_string = screen_string + CURSOR_PRE + " " + CURSOR_POST
	else:
		screen_string = (
			screen_string.substr(0, len(screen_string) - cursor_inset_amount) + 
			CURSOR_PRE + 
			screen_string[len(screen_string) - cursor_inset_amount] + 
			CURSOR_POST + 
			screen_string.substr(len(screen_string) - cursor_inset_amount + 1)
		)
	has_cursor = true

func remove_cursor() -> void:
	if not has_cursor:
		return
	if cursor_inset_amount == 0:
		screen_string = screen_string.substr(0, len(screen_string) - len(CURSOR_PRE) - 1 - len(CURSOR_POST))
	else:
		screen_string = (
			screen_string.substr(0, len(screen_string) - cursor_inset_amount - len(CURSOR_PRE) - len(CURSOR_POST)) + 
			screen_string[len(screen_string) - cursor_inset_amount - len(CURSOR_POST)] + 
			screen_string.substr(len(screen_string) - cursor_inset_amount + 1)
		)
	has_cursor = false

func type_ahead(text: String) -> void:
	screen_string = screen_string.substr(0, len(screen_string) - cursor_inset_amount) + text.replace("[", "[lb]") + screen_string.substr(len(screen_string) - cursor_inset_amount)

func delete_behind(amount: int) -> void:
	var true_amount := 0
	for i in amount:
		if screen_string.substr(len(screen_string) - cursor_inset_amount - true_amount - 4, 4) == "[lb]":
			true_amount += 4
		else:
			true_amount += 1
	screen_string = screen_string.substr(0, len(screen_string) - cursor_inset_amount - true_amount) + screen_string.substr(len(screen_string) - cursor_inset_amount)


func update_display_text() -> void:
	screen_text.text = "clear" # force a regeneration
	screen_text.text = screen_string

func print_text(text: String, bbcode_start := "", bbcode_end := "") -> void:
	if not printing:
		screen_text.visible_characters = typing_start_text_index
		true_visible = typing_start_text_index
		printing = true
	var appending := bbcode_start + text.replace("[", "[lb]") + bbcode_end
	screen_text.append_text(appending)
	screen_string += appending
	typing_start_text_index = screen_text.get_total_character_count()
	typing_start_string_index = len(screen_string)

func finish_printing() -> void:
	printing = false
	screen_text.visible_characters = -1
