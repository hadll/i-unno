shader_type spatial;
render_mode unshaded, cull_disabled, wireframe;

#include "res://shaders/abyss_shape.gdshaderinc"

group_uniforms colours;
uniform vec3 back_colour: source_color;
uniform float back_threshold = 0.0;
uniform vec3 front_colour: source_color;
uniform float front_threshold = 0.6;
uniform vec3 main_colour: source_color;

void fragment() {
	float t = TIME * speed;
	float facing = dot(NORMAL, vec3(vec2(cos(t * wobble_speed), sin(t * wobble_speed)) * wobble, 1.0));
	float back = max(0.0, back_threshold - facing);
	float front = max(0.0, facing - front_threshold);
	ALBEDO = (
		back * back_colour + 
		front * front_colour + 
		(1.0 - back - front) * main_colour
	);
	
	
}