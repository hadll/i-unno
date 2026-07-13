group_uniforms shape;
uniform sampler2D noise;
uniform float speed = 1.0;
uniform float spikiness = 0.25;
uniform float max_spike = 3.0;
uniform float agitation: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float expand = 0.0;

vec3 abyss_shape(vec3 vertex, vec2 uv, float t) {
	float ts = t * speed;
	vec2 noise_uv = uv + vec2(cos(ts), sin(ts)) * vertex.xy + vec2(sin(ts), -cos(ts)) * vertex.yz;
	float value = texture(noise, noise_uv).r;
	float spikey = mix(1.0, min(max_spike, pow(value, -spikiness)), agitation);
	return vertex * (spikey + expand);
}
