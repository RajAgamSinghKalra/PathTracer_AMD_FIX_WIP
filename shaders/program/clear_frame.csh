#include "/lib/buffer/state.glsl"
#include "/lib/camera/film.glsl"

layout (local_size_x = 8, local_size_y = 8, local_size_z = 1) in;
const vec2 workGroupsRender = vec2(1.0, 1.0);

void main() {
    if (renderState.clear) {
        imageStore(filmBuffer, ivec2(gl_GlobalInvocationID.xy), vec4(0.0));
        imageStore(splatBufferX, ivec2(gl_GlobalInvocationID.xy), vec4(0.0));
        imageStore(splatBufferY, ivec2(gl_GlobalInvocationID.xy), vec4(0.0));
        imageStore(splatBufferZ, ivec2(gl_GlobalInvocationID.xy), vec4(0.0));
    }
}