extends Node3D

var sounds: Array[AudioStream] = []
var options: Array[int] = []
var code_size := 6
var code: Array[int] = []
var code_pos := 0

func _ready() -> void:
	load_sounds()
	generate_code()

func load_sounds() -> void:
	var sounds_dir := DirAccess.open("res://assets/sounds/alphabet")
	if not sounds_dir:
		return
	sounds_dir.list_dir_begin()
	var file_name := sounds_dir.get_next()
	while file_name:
		if not sounds_dir.current_is_dir() and file_name.get_extension() == "ogg":
			sounds.append(load("res://assets/sounds/alphabet/" + file_name))
		file_name = sounds_dir.get_next()

func generate_code() -> void:
	options.assign(range(26))
	for i in code_size:
		var number := randi() % len(options)
		code.append(options.pop_at(number))

#func _on_timer_timeout() -> void:
	#$AudioStreamPlayer3D.stream = sounds[code[code_pos]]
	#$AudioStreamPlayer3D.play()
	#code_pos = (code_pos + 1)%code_size
