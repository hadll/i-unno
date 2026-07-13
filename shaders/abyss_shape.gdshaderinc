group_uniforms shape;
uniform sampler2D noise;
uniform float speed = 1.0;
uniform float spikiness = 0.25;
uniform float max_spike = 3.0;
uniform float agitation: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float wobble = 0.2;
uniform float wobble_speed = 3.0;
uniform float expand = 0.0;

void vertex() {
	float t = TIME * speed;
	vec2 noise_uv = UV + vec2(cos(t), sin(t)) * VERTEX.xy + vec2(sin(t), -cos(t)) * VERTEX.yz;
	float value = texture(noise, noise_uv).r;
	float spikey = mix(1.0, min(max_spike, pow(value, -spikiness)), agitation);
	VERTEX *= spikey + expand;
}
