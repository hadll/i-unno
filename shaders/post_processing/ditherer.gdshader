shader_type canvas_item;

uniform sampler2D dither_pattern: filter_nearest, source_color;
uniform sampler2D palette: filter_nearest, source_color;

uniform float calmness = 1.0;

void fragment() {
	vec3 screen_colour = texture(TEXTURE, UV).rgb;
	float dither_influence = mix(0.5, 0.2, calmness);
	float dither_value = (texelFetch(dither_pattern, ivec2(FRAGCOORD.xy) & ivec2(7), 0).r - 0.5) * dither_influence;
	screen_colour += vec3(dither_value);
	
	// vec2 uv = vec2(gl_GlobalInvocationID.xy) / vec2(imageSize(screen_texture));
	// float raw_depth = texture(depth_texture, uv).r;
	// vec4 upos = params.inv_projection * vec4(uv * 2.0 - 1.0, raw_depth, 1.0);
	// vec3 pixel_position = upos.xyz / upos.w;
	// float pixel_distance = length(pixel_position);
	// screen_colour *= clamp(1.0 - (pixel_distance - params.view_dist) / params.view_fog, 0.0, 1.0);
	
	float desired_palette = clamp(calmness * 16.0, 2.0, 16.0);
	int palette_count = int(desired_palette);
	float palette_dropoff = desired_palette - float(palette_count);
	vec3 closest_colour = texelFetch(palette, ivec2(palette_count, 0), 0).rgb;
	vec3 diff = abs(screen_colour - closest_colour) / (palette_dropoff * 0.9 + 0.1);
	float closest_dist = max(diff.r, diff.g) + max(diff.g, diff.b) + max(diff.b, diff.r);
	for (int i = 0; i < palette_count; i++) {
		vec3 trying = texelFetch(palette, ivec2(i, 0), 0).rgb;
		vec3 diff = abs(screen_colour - trying);
		float trying_dist = max(diff.r, diff.g) + max(diff.g, diff.b) + max(diff.b, diff.r);
		if (trying_dist < closest_dist) {
			closest_dist = trying_dist;
			closest_colour = trying;
		}
	}
	screen_colour = closest_colour;
	COLOR = vec4(screen_colour, 1.0);
	
	//COLOR = vec4(dither_value, 0.0, 0.0, 1.0);
	//
	//COLOR = vec4(vec2(ivec2(FRAGCOORD.xy) & ivec2(255)) / 255.0, 0.0, 1.0);
}
