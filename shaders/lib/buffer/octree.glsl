#ifndef _OCTREE_GLSL
#define _OCTREE_GLSL 1

#include "/lib/settings.glsl"

layout (std430, binding = 5) buffer octree_buffer {
    uint data[];
} octree;

const int[] OCTREE_OFFSETS = int[](0, 12582912, 14155776, 14352384, 14376960, 14380032, 14380416);

int getOctreeBitIndex(ivec3 localPos) {
    return localPos.y * 4 + localPos.z * 2 + localPos.x;
}

int getOctreeIndex(int level, ivec3 lodPos) {
    ivec3 levelSize = VOXEL_VOLUME_SIZE >> (level + 1);
    return OCTREE_OFFSETS[level] + lodPos.y * levelSize.x * levelSize.z + lodPos.z * levelSize.x + lodPos.x;
}

int getOctreeIndex(int level, ivec3 voxelPos, out ivec3 localPos) {
    ivec3 levelSize = VOXEL_VOLUME_SIZE >> (level + 1);
    localPos = voxelPos >> level;
    ivec3 lodPos = localPos >> 1;
    localPos -= lodPos * 2;
    return OCTREE_OFFSETS[level] + lodPos.y * levelSize.x * levelSize.z + lodPos.z * levelSize.x + lodPos.x;
}

void occupyOctreeVoxel(int level, ivec3 voxelPos) {
    ivec3 localPos;
    int index = getOctreeIndex(level, voxelPos, localPos);
    int bitIndex = getOctreeBitIndex(localPos);
    atomicOr(octree.data[index], 1u << uint(bitIndex));
}

void occupyOctreeVoxel(ivec3 voxelPos) {
    occupyOctreeVoxel(0, voxelPos);
    occupyOctreeVoxel(1, voxelPos);
    occupyOctreeVoxel(2, voxelPos);
    occupyOctreeVoxel(3, voxelPos);
    occupyOctreeVoxel(4, voxelPos);
    occupyOctreeVoxel(5, voxelPos);
}

#endif // _OCTREE_GLSL
