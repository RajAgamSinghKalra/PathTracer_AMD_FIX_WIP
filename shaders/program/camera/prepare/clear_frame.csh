#include "/lib/buffer/state.glsl"
#include "/lib/camera/film.glsl"

layout (local_size_x = 8, local_size_y = 8, local_size_z = 1) in;
const vec2 workGroupsRender = vec2(1.0, 1.0);

void main() {
    ivec2 dim = imageSize(filmBuffer);

    for (int y = int(gl_GlobalInvocationID.y); y < dim.y; y += int(gl_NumWorkGroups.y) * int(gl_WorkGroupSize.y)) {
        for (int x = int(gl_GlobalInvocationID.x); x < dim.x; x += int(gl_NumWorkGroups.x) * int(gl_WorkGroupSize.x)) {
            if (renderState.clear) {
                imageStore(filmBuffer, ivec2(x, y), vec4(0.0));
                imageStore(splatBuffer, ivec2(x, y), vec4(0.0));
            }
        }
    }
}
