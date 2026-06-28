#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 0, binding = 0, rgba16f) uniform image2D screen_texture;
layout(set = 0, binding = 1) uniform sampler2D depth_texture;
layout(set = 0, binding = 2, rgba8ui) uniform uimage2D palette;
layout(set = 0, binding = 3, r8ui) uniform uimage2D dither_pattern;

layout(push_constant, std430) uniform Params {
    mat4 inv_projection;
    vec4 rotation;
    vec4 position;
    vec4 viewport_data;
    float calmness;
    float view_dist;
    float view_fog;
} params;

void main() {
    vec3 screen_colour = imageLoad(screen_texture, ivec2(gl_GlobalInvocationID.xy & ~0u)).rgb;
    float dither_value = float(imageLoad(dither_pattern, ivec2((gl_GlobalInvocationID.xy >> 0u) & 7u)).r) / 255.0 * 0.2;
    screen_colour -= vec3(dither_value);
    
    vec2 uv = vec2(gl_GlobalInvocationID.xy) / vec2(imageSize(screen_texture));
    float raw_depth = texture(depth_texture, uv).r;
    vec4 upos = params.inv_projection * vec4(uv * 2.0 - 1.0, raw_depth, 1.0);
    vec3 pixel_position = upos.xyz / upos.w;
    float pixel_distance = length(pixel_position);
    screen_colour *= clamp(1.0 - (pixel_distance - params.view_dist) / params.view_fog, 0.0, 1.0);

    int palette_count = min(15, int(params.calmness * 16.0));
    float palette_dropoff = params.calmness * 16.0 - float(palette_count);
    vec3 closest_colour = vec3(imageLoad(palette, ivec2(palette_count, 0)).rgb) / 255.0;
    vec3 diff = abs(screen_colour - closest_colour) / (palette_dropoff * 0.9 + 0.1);
    float closest_dist = max(diff.r, diff.g) + max(diff.g, diff.b) + max(diff.b, diff.r);
    for (int i = 0; i < palette_count; i++) {
        vec3 trying = vec3(imageLoad(palette, ivec2(i, 0)).rgb) / 255.0;
        vec3 diff = abs(screen_colour - trying);
        float trying_dist = max(diff.r, diff.g) + max(diff.g, diff.b) + max(diff.b, diff.r);
        if (trying_dist < closest_dist) {
            closest_dist = trying_dist;
            closest_colour = trying;
        }
    }
    screen_colour = closest_colour;

    imageStore(screen_texture, ivec2(gl_GlobalInvocationID.xy), vec4(
        screen_colour,
        1.0
    ));
}

