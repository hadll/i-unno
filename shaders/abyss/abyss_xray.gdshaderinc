
group_uniforms xray;
uniform float alpha = 0.5;
uniform float max_dist = 10.0;
uniform float min_dist = 3.0;

float get_fade_in(vec3 vertex) {
	return alpha * clamp((length(vertex) - max_dist) / (min_dist - max_dist), 0.0, 1.0);
}
