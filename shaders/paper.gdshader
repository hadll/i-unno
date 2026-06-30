shader_type spatial;
render_mode cull_disabled;

uniform sampler2D tex: filter_nearest;

void fragment() {
	ALBEDO = texture(tex, UV).rgb;
}
