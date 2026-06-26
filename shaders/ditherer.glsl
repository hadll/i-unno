#[compute]
#version 450

layout(local_size_x = 8, local_size_y = 8, local_size_z = 1) in;

layout(set = 0, binding = 0, rgba16f) uniform image2D screen_texture;
layout(set = 0, binding = 1) uniform sampler2D depth_texture;
layout(set = 0, binding = 2, rgba8ui) uniform uimage2D palette;
layout(set = 0, binding = 3, r8ui) uniform uimage2D dither_pattern;

layout(push_constant, std430) uniform Params {
    float calmness;
} params;

void main() {
    vec3 screen_colour = imageLoad(screen_texture, ivec2(gl_GlobalInvocationID.xy & ~1u)).rgb;
    float dither_value = float(imageLoad(dither_pattern, ivec2((gl_GlobalInvocationID.xy >> 1u) & 7u)).r) / 255.0 * 0.2 - 0.1;
    vec3 dithered = screen_colour - vec3(dither_value);

    vec3 closest_colour = vec3(0, 0, 0);
    float closest_dist = 10000000000.0;
    for (int i = 0; i < 16; i++) {
        vec3 trying = vec3(imageLoad(palette, ivec2(i, 0)).rgb) / 255.0;
        vec3 diff = abs(dithered - trying);
        float trying_dist = max(diff.r, diff.g) + max(diff.g, diff.b) + max(diff.b, diff.r);
        if (trying_dist < closest_dist) {
            closest_dist = trying_dist;
            closest_colour = trying;
        }
    }

    imageStore(screen_texture, ivec2(gl_GlobalInvocationID.xy), vec4(
        closest_colour,
        1.0
    ));
}

