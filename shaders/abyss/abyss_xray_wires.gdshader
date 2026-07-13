shader_type spatial;
render_mode unshaded, wireframe, depth_test_inverted;

#include "res://shaders/abyss/abyss_shape.gdshaderinc"
#include "res://shaders/abyss/abyss_colours.gdshaderinc"
#include "res://shaders/abyss/abyss_xray.gdshaderinc"

void vertex() {
	VERTEX = abyss_shape(VERTEX, UV, TIME);
}

void fragment() {
	float fade_in = clamp((length(VERTEX) - max_dist) / (min_dist - max_dist), 0.0, 1.0);
	ALPHA = alpha * fade_in;
	ALBEDO = abyss_colour(NORMAL, TIME);
}
