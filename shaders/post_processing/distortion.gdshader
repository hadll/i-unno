shader_type canvas_item;

uniform vec2 centre;
uniform float distortion = 0.0;
uniform float angle_distortion_factor = 4.0;
uniform float angle_distortion_offset = 0.03;
uniform float angle_distortion_extent = 0.3;
uniform float angle_distortion_speed = 2.0;
uniform float angle_distortion_drag = 15.0;

void fragment() {
	vec2 uv = UV - centre;
	float angle = atan(uv.y, uv.x);
	float radius = length(uv);
	float distorted_radius = pow(radius, 1.0 + distortion);
	float angle_distort = max(0.0, angle_distortion_extent * pow(distortion, 0.5) - radius) * distortion * angle_distortion_factor;
	float distorted_angle = angle + angle_distort * (sin(radius * angle_distortion_drag + angle_distortion_speed * TIME) / (radius + angle_distortion_offset));
	vec2 distorted_uv = vec2(cos(distorted_angle), sin(distorted_angle)) * distorted_radius + centre;
	COLOR = texture(TEXTURE, distorted_uv);
}
