class_name Printer
extends Node3D
signal printed

@export var page_scene: PackedScene

var queue: Array[Image] = []

var ink_c := 1.0
var ink_m := 1.0
var ink_y := 1.0
var ink_k := 1.0

func _ready() -> void:
	PrinterManager.printer = self

func queue_image(img: Image) -> void:
	queue.append(img)
	if len(queue) == 1:
		print_next()

func print_next() -> void:
	var page: Page = page_scene.instantiate()
	page.set_image(queue[0])
	add_child(page)
	
	# animate
	page.position = Vector3.BACK
	
	queue.pop_front()
	printed.emit(page)
	if queue:
		print_next()
