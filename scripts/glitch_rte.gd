class_name GlitchRTE
extends RichTextEffect

var bbcode := "glitch"

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	if char_fx.glyph_index == 0:
		return false
	var t := floorf(char_fx.elapsed_time * 8.0) / 8.0 * (3.0 + sin(char_fx.relative_index)) / 3.0 + char_fx.relative_index
	char_fx.glyph_index += roundi(sin(t * 10.0) * 3)
	char_fx.offset += Vector2(0, cos(t * 80.0) * 3)
	return true
