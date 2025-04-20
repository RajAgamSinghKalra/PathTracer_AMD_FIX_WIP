#include "/lib/buffer/quad.glsl"
#include "/lib/buffer/state.glsl"

layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

uniform bool hideGUI;

uniform vec3 sunPosition;
uniform mat4 gbufferModelViewInverse;

uniform ivec3 currentDate;
uniform ivec2 currentYearTime;

void main() {
    quadBuffer.count = 0u;
    quadBuffer.aabb = scene_aabb(10000, 10000, 10000, -10000, -10000, -10000);

    if (hideGUI) {
        renderState.frame++;
    } else {
        renderState.frame = 0;
        renderState.startTime = ivec2(currentDate.x, currentYearTime.x);
        renderState.sunDirection = normalize(mat3(gbufferModelViewInverse) * sunPosition);
    }

    renderState.clear = (renderState.frame <= 1);
}