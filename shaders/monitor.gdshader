shader_type spatial;

uniform sampler2D screen_texture: filter_nearest, source_color;
group_uniforms glitch;
uniform float chromatic_abberation;
uniform vec2 shift;
uniform vec2 skew;
uniform vec2 quantisation;


void fragment() {
	vec2 uv = UV;
	
	
	uv = uv * 2.0 - 1.0;
	vec2 uv_r = (uv * vec2(1.0 + chromatic_abberation * 1.0)) * 0.5 + 0.5;
	vec2 uv_g = (uv * vec2(1.0 + chromatic_abberation * 2.0)) * 0.5 + 0.5;
	vec2 uv_b = (uv * vec2(1.0 + chromatic_abberation * 3.0)) * 0.5 + 0.5;
	uv_r = mix(round(uv_r / quantisation) * quantisation, uv_r, equal(quantisation, vec2(0.0)));
	uv_g = mix(round(uv_g / quantisation) * quantisation, uv_g, equal(quantisation, vec2(0.0)));
	uv_b = mix(round(uv_b / quantisation) * quantisation, uv_b, equal(quantisation, vec2(0.0)));
	uv_r = mod(uv_r + uv_r.yx * skew + shift, vec2(1.0));
	uv_g = mod(uv_g + uv_g.yx * skew + shift, vec2(1.0));
	uv_b = mod(uv_b + uv_b.yx * skew + shift, vec2(1.0));
	vec3 colour = vec3(
		texture(screen_texture, uv_r).r, 
		texture(screen_texture, uv_g).g, 
		texture(screen_texture, uv_b).b
	);
	ALBEDO = colour;
}