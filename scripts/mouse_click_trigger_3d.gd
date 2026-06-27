extends GlobalClickTrigger
class_name MouseClickTrigger3D

func on_player_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	var from = Player.me.camera.project_ray_origin(event.position)
	var to = from + Player.me.camera.project_ray_normal(event.position) * 1000
	
	super(event)
