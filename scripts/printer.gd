class_name Printer
extends Node3D
signal printed

const PAGE_HEIGHT := 1000
const PAGE_WIDTH := 707
const PAGES_PER_INK_BLACK := 1.0
const PAGES_PER_INK_COLOUR := 0.5

@export var page_scene: PackedScene

var queue: Array[Image] = []

var ink_c: float
var ink_m: float
var ink_y: float
var ink_k: float

func _ready() -> void:
	refill()
	PrinterManager.printer = self

func refill() -> void:
	ink_c = PAGE_WIDTH * PAGE_HEIGHT * PAGES_PER_INK_COLOUR
	ink_m = PAGE_WIDTH * PAGE_HEIGHT * PAGES_PER_INK_COLOUR
	ink_y = PAGE_WIDTH * PAGE_HEIGHT * PAGES_PER_INK_COLOUR
	ink_k = PAGE_WIDTH * PAGE_HEIGHT * PAGES_PER_INK_BLACK

func queue_image(img: Image) -> void:
	img = img.duplicate()
	img.resize(PAGE_WIDTH, PAGE_HEIGHT, Image.INTERPOLATE_BILINEAR)
	
	use_ink_for(img)
	
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

func use_ink_for(img: Image) -> void:
	for y in PAGE_HEIGHT:
		for x in PAGE_WIDTH:
			var pix := img.get_pixel(x, y)
			var pix_k := 1.0 - maxf(pix.r, maxf(pix.g, pix.b))
			var pix_c := minf(clampf(1.0 - pix.r - pix_k, 0.0, 1.0), ink_c)
			var pix_m := minf(clampf(1.0 - pix.g - pix_k, 0.0, 1.0), ink_m)
			var pix_y := minf(clampf(1.0 - pix.b - pix_k, 0.0, 1.0), ink_y)
			pix_k = minf(pix_k, ink_k)
			ink_c -= pix_c
			ink_m -= pix_m
			ink_y -= pix_y
			ink_k -= pix_k
			pix.r = 1.0 - pix_k - pix_c
			pix.g = 1.0 - pix_k - pix_m
			pix.b = 1.0 - pix_k - pix_y
			img.set_pixel(x, y, pix)
