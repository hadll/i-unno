class_name TerminalDisplay
extends Control

@export var print_speed: float

@onready var fs_root: TerminalRootDir = $FileSystem/root
@onready var fs_home: TerminalHomeDir = $FileSystem/root/users/USERNAME
@onready var fs_programs: TerminalDir = $FileSystem/root/bin

@onready var screen_text: RichTextLabel = $ScreenText
var screen_string := ""
var true_visible := 0.0
var typing_start_text_index := 0
var typing_start_string_index := 0
var allow_typing := true
var printing := false

func _ready() -> void:
	Terminal.printed_text.connect(print_text)
	Terminal.root = fs_root
	Terminal.home = fs_home
	Terminal.cwd = fs_home
	Terminal.program_dir = fs_programs
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
			screen_text.add_text(character)
			if character == "[":
				screen_string += "[lb]"
			else:
				screen_string += character
	elif event.keycode == Key.KEY_BACKSPACE:
		if len(screen_string) > typing_start_string_index:
			if screen_string.substr(len(screen_string) - 4) == "[lb]":
				screen_string = screen_string.substr(0, len(screen_string) - 4)
			else:
				screen_string = screen_string.substr(0, len(screen_string) - 1)
			screen_text.text = screen_string
	elif event.keycode == Key.KEY_ENTER:
		var command := screen_string.substr(typing_start_string_index).replace("[lb]", "[")
		print_text("\n")
		finish_printing()
		Terminal.run(command)

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
