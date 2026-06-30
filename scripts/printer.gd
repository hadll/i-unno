class_name Printer
extends Node3D

@export var page_scene: PackedScene

func print_image(img: Image) -> void:
	var page: Page = page_scene.instantiate()
	page.set_image(img)
