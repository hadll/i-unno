@icon("res://assets/icons/animationtrigger.png")
extends Trigger
class_name AnimationTrigger

@export var triggers: Array[Trigger]

@export var animation_player : AnimationPlayer
@export var start_animation_name : String
@export var end_animation_name : String

@export_category("Settings")
@export var force_animation := false

@export var limit_copies := true

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
		animation_player.queue(animation_name)
		if limit_copies:
			var queue = animation_player.get_queue()
			var size = queue.size()
			for i in range(size):
				if queue[i] == start_animation_name and i+1 < size and queue[i+1] == end_animation_name:
					print(queue)
					queue.remove_at(i+1)
					queue.remove_at(i)
					animation_player.clear_queue()
					print("refilling_queue")
					for anim in queue:
						print(anim)
						animation_player.queue(anim)
					return
	else:
		animation_player.stop()
		animation_player.play(animation_name)
