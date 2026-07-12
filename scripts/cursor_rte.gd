class_name CursorRTE
extends RichTextEffect

var bbcode := "c"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	if char_fx.glyph_index == 0:
		return false
	var colour_time := fmod(char_fx.elapsed_time, 5.0)
	var blink_time := fmod(colour_time, 1.0)
	var colour: Color
	if colour_time < 1.0:
		colour = Color.SKY_BLUE
	elif colour_time < 2.0:
		colour = Color.PINK
	elif colour_time < 3.0:
		colour = Color.WHITE
	elif colour_time < 4.0:
		colour = Color.WHITE
	else:
		colour = Color.SKY_BLUE
	char_fx.color = colour
	if blink_time < 0.5:
		char_fx.glyph_index = TextServerManager.get_primary_interface().font_get_glyph_index(char_fx.font, 1, "_".unicode_at(0), 0)
	return true
