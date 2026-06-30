extends Node

var printer: Printer

func queue_image(img: Image) -> void:
	printer.queue_image(img)

func queue_text(text: String) -> void:
	push_error("todo: finish this conversion to image to be able to print " + text)
	pass
