#include "/lib/buffer/octree.glsl"

layout (local_size_x = 64, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(224695, 1, 1);

void main() {
    if (gl_GlobalInvocationID.x >= 14380464) return;
    octree.data[gl_GlobalInvocationID.x] = 0u;
}