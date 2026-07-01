class_name TerminalDisplay
extends Control

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

func _ready() -> void:
	if MultiplayerConnection.username:
		fs_home.name = Terminal.make_item_name(MultiplayerConnection.username)
	Terminal.printed_text.connect(print_text)
	Terminal.root = fs_root
	Terminal.home = fs_home
	Terminal.cwd = fs_home
	Terminal.program_dir = fs_programs
	Map.add_files(fs_maps)
	Terminal.prompt()

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
	if OS.is_keycode_unicode(event.keycode):
		if allow_typing:
			var character := String.chr(event.unicode)
			if character == "[":
				screen_string = screen_string.substr(0, len(screen_string) - cursor_inset_amount) + "[lb]" + screen_string.substr(len(screen_string) - cursor_inset_amount)
			else:
				screen_string = screen_string.substr(0, len(screen_string) - cursor_inset_amount) + character + screen_string.substr(len(screen_string) - cursor_inset_amount)
			if cursor_inset_amount == 0:
				screen_text.add_text(character)
			else:
				update_display_text()
	elif event.keycode == Key.KEY_BACKSPACE:
		if len(screen_string) - cursor_inset_amount > typing_start_string_index:
			if screen_string.substr(len(screen_string) - cursor_inset_amount - 4, 4) == "[lb]":
				screen_string = screen_string.substr(0, len(screen_string) - cursor_inset_amount - 4) + screen_string.substr(len(screen_string) - cursor_inset_amount)
			else:
				screen_string = screen_string.substr(0, len(screen_string) - cursor_inset_amount - 1) + screen_string.substr(len(screen_string) - cursor_inset_amount)
			screen_text.text = "clear" # force a regeneration
			update_display_text()
	elif event.keycode == Key.KEY_ENTER:
		var command := screen_string.substr(typing_start_string_index).replace("[lb]", "[")
		print_text("\n")
		finish_printing()
		Terminal.run(command)
		command_history.append(command)
		command_history_index = len(command_history)
		cursor_inset_amount = 0
	elif event.keycode == Key.KEY_UP:
		command_history_index = maxi(0, command_history_index - 1)
		screen_string = screen_string.substr(0, typing_start_string_index)
		screen_string += command_history[command_history_index].replace("[", "[lb]")
		cursor_inset_amount = 0
		update_display_text()
	elif event.keycode == Key.KEY_DOWN:
		command_history_index = mini(len(command_history), command_history_index + 1)
		screen_string = screen_string.substr(0, typing_start_string_index)
		if command_history_index < len(command_history):
			screen_string += command_history[command_history_index].replace("[", "[lb]")
		cursor_inset_amount = 0
		update_display_text()
	elif event.keycode == Key.KEY_LEFT:
		if screen_string.substr(len(screen_string) - cursor_inset_amount - 4, 4) == "[lb]":
			cursor_inset_amount += 4
		else:
			cursor_inset_amount += 1
		cursor_inset_amount = mini(len(screen_string) - typing_start_string_index, cursor_inset_amount)
	elif event.keycode == Key.KEY_RIGHT:
		if screen_string.substr(len(screen_string) - cursor_inset_amount, 4) == "[lb]":
			cursor_inset_amount -= 4
		else:
			cursor_inset_amount -= 1
		cursor_inset_amount = maxi(0, cursor_inset_amount)

func update_display_text() -> void:
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
