#include "/lib/buffer/octree.glsl"
#include "/lib/buffer/state.glsl"
#include "/lib/buffer/voxel.glsl"

layout (local_size_x = 64, local_size_y = 1, local_size_z = 1) in;
// Original dispatch count exceeded AMD's work group limit (65,535)
// Reduce the dispatch size and iterate over the remaining range
const ivec3 workGroups = ivec3(65535, 1, 1);
uniform bool hideGUI;
void main() {
    if (!hideGUI) {
        return;
    }
    // Clear voxel structures every frame so newly loaded chunks do not keep stale data
    if (renderState.frame != 1) {
        return;
    }

    for (uint id = gl_GlobalInvocationID.x * 8u; id < 512u * 384u * 512u; id += 65535u * 8u) {
        for (int i = 0; i < 8; i++) {
            uint index = id + uint(i);
            if (index >= 512u * 384u * 512u) break;

            uint x = index % 512u;
            uint y = (index / 512u) % 384u;
            uint z = (index / 512u) / 384u;

            imageStore(voxelBuffer, ivec3(x, y, z), uvec4(0, 0, 0, 0));
        }
    }

    for (uint id = gl_GlobalInvocationID.x; id < 1024u; id += 65535u) {
        renderState.entityData.hashTable[id] = -1;
        renderState.entityData.tableLock[id] = 0u;
    }

    for (uint id = gl_GlobalInvocationID.x; id < 256u; id += 65535u) {
        renderState.entityData.subdividedCells[id].index = -1;
    }

    for (uint id = gl_GlobalInvocationID.x; id < 14380464u; id += 65535u) {
        octree.data[id] = 0u;
    }
}
