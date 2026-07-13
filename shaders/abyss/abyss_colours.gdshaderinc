
group_uniforms colours;
uniform vec3 back_colour: source_color;
uniform float back_threshold = 0.0;
uniform vec3 front_colour: source_color;
uniform float front_threshold = 0.6;
uniform vec3 main_colour: source_color;
uniform float wobble = 0.2;
uniform float wobble_speed = 3.0;

vec3 abyss_colour(vec3 normal, float t) {
	float facing = dot(normal, vec3(vec2(cos(t * wobble_speed), sin(t * wobble_speed)) * wobble, 1.0));
	float back = max(0.0, back_threshold - facing);
	float front = max(0.0, facing - front_threshold);
	return (
		back * back_colour + 
		front * front_colour + 
		(1.0 - back - front) * main_colour
	);
}
