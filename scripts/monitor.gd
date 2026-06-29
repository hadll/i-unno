class_name Monitor
extends StaticBody3D

@onready var terminal_display: TerminalDisplay = $SubViewport/TerminalDisplay

func _ready() -> void:
	InputHandler.started_looking_at.connect(func(collider: CollisionObject3D)-> void:
		if collider == self:
			InputHandler.input.connect(on_player_input)
	)
	InputHandler.stopped_looking_at.connect(func(collider: CollisionObject3D)-> void:
		if collider == self:
			InputHandler.input.disconnect(on_player_input)
	)

func on_player_input(event: InputEvent) -> void:
	if event is InputEventKey:
		terminal_display.key_input(event)
