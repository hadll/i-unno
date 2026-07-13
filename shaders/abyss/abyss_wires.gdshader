shader_type spatial;
render_mode unshaded, cull_disabled, wireframe;

#include "res://shaders/abyss/abyss_shape.gdshaderinc"
#include "res://shaders/abyss/abyss_colours.gdshaderinc"

void vertex() {
	VERTEX = abyss_shape(VERTEX, UV, TIME);
}

void fragment() {
	ALBEDO = abyss_colour(NORMAL, TIME);
}