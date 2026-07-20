class_name PathMover
extends PathFollow3D

@export var speed: float

var moving := false

func _process(delta: float) -> void:
	if moving:
		progress += speed * delta

func move() -> void:
	moving = true
