extends Trigger
class_name AnimationTrigger

@export var triggers: Array[Trigger]

@export var animation_player : AnimationPlayer
@export var start_animation_name : String
@export var end_animation_name : String

@export_category("Settings")
@export var force_animation := false

@export var limit_copies := true
@export var start_limit := 1
@export var end_limit := 2

func _ready() -> void:
	for i_trigger in triggers:
		i_trigger.trigger_start.connect(on_trigger_start)
		i_trigger.trigger_end.connect(on_trigger_end)

func on_trigger_start(trigger: Trigger):
	play_animation(start_animation_name)
	
func on_trigger_end(trigger:Trigger):
	play_animation(end_animation_name)

func play_animation(animation_name:String):
	if not force_animation:
		var copies = 0
		for animation in animation_player.get_queue():
			if animation == animation_name:
				copies+=1
		if (copies >= start_limit and animation_name == start_animation_name) or (copies >= end_limit and animation_name == end_animation_name):
			return
		animation_player.queue(animation_name)
	else:
		animation_player.stop()
		animation_player.play(animation_name)
