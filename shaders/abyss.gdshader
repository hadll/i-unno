shader_type spatial;
render_mode unshaded, cull_disabled;

#include "res://shaders/abyss_shape.gdshaderinc"

void fragment() {
	ALBEDO = vec3(0.0);
}