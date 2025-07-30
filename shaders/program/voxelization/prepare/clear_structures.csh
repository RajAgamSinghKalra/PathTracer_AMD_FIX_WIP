#include "/lib/buffer/octree.glsl"
#include "/lib/buffer/state.glsl"
#include "/lib/buffer/voxel.glsl"

layout (local_size_x = 64, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(224695, 1, 1);

void main() {
    // Only clear voxels on the frame F1 was pressed to start tracing
    if (renderState.frame > 1) {
        return;
    }

    for (int i = 0; i < 8; i++) {
        uint index = gl_GlobalInvocationID.x * 8 + i;
        if (index >= 512u * 386u * 512u) break;

        uint x = index % 512u;
        uint y = (index / 512u) % 386u;
        uint z = (index / 512u) / 386u;

        imageStore(voxelBuffer, ivec3(x, y, z), uvec4(0, 0, 0, 0));
    }

    if (gl_GlobalInvocationID.x < 1024) {
        renderState.entityData.hashTable[gl_GlobalInvocationID.x] = -1;
        renderState.entityData.tableLock[gl_GlobalInvocationID.x] = 0u;
    }

    if (gl_GlobalInvocationID.x < 256) {
        renderState.entityData.subdividedCells[gl_GlobalInvocationID.x].index = -1;
    } 

    if (gl_GlobalInvocationID.x >= 14380464) return;
    octree.data[gl_GlobalInvocationID.x] = 0u;
}
