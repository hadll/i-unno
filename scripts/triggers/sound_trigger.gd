@icon("res://assets/icons/sound_trigger.png")
extends Trigger
class_name SoundTrigger

#use whichever one youd prefer 
@export var triggers: Dictionary[Trigger, AudioStream] 
@export var audio_player: Node

@export_category("Settings")
@export var stop_audio_on_end = false

var stream = AudioStreamPolyphonic.new()

func _ready() -> void:
	for i_trigger in triggers:
		i_trigger.trigger_start.connect(on_trigger_start.bind(i_trigger))
		i_trigger.trigger_start.connect(on_trigger_end)
	audio_player.stream = stream

func on_trigger_start(i_trigger: Trigger):
	if not audio_player.playing:
		audio_player.play()
	audio_player.get_stream_playback().play_stream(triggers[i_trigger])

func on_trigger_end():
	if stop_audio_on_end:
		audio_player.stop()
