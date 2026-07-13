shader_type spatial;
render_mode unshaded, cull_disabled;

#include "res://shaders/abyss/abyss_shape.gdshaderinc"

void vertex() {
	VERTEX = abyss_shape(VERTEX, UV, TIME);
}

void fragment() {
	ALBEDO = vec3(0.0);
}