extends Node3D

var sounds = []
var options = range(26)
var code_size = 6
var code = []
var code_pos = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_sounds()
	generate_code()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_sounds():
	var sounds_dir = DirAccess.open("res://assets/sounds/alphabet")
	if sounds_dir:
		sounds_dir.list_dir_begin()
		var file_name = sounds_dir.get_next()
		while file_name != "":
			if !sounds_dir.current_is_dir() and file_name.ends_with(".ogg"):
				sounds.append(load("res://assets/sounds/alphabet/"+file_name))
			file_name = sounds_dir.get_next()

func generate_code():
	for i in code_size:
		var number = randi_range(0,len(options))
		code.append(options.pop_at(number))

#func _on_timer_timeout() -> void:
	#$AudioStreamPlayer3D.stream = sounds[code[code_pos]]
	#$AudioStreamPlayer3D.play()
	#code_pos = (code_pos + 1)%code_size
