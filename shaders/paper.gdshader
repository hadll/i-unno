shader_type spatial;

uniform sampler2D image: filter_nearest;

void fragment() {
	ALBEDO = texture(image, UV).rgb;
}
