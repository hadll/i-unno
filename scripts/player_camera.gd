extends SceneCamera

func _ready() -> void:
	process_priority = 1000
	environment = Environment.new()
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_DISABLED
