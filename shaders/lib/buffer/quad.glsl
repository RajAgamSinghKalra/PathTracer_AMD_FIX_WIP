#ifndef _QUAD_GLSL
#define _QUAD_GLSL 1

struct quad_entry {
    vec4 point;
    vec4 tangent;
    vec4 bitangent;
    vec2 uv0;
    vec2 uv1;
    uint tint;
    uint next;
};

struct scene_aabb {
    int xMin;
    int yMin;
    int zMin;
    int xMax;
    int yMax;
    int zMax;
};

layout (std430, binding = 0) buffer quad_buffer {
    scene_aabb aabb;
    uint count;
    quad_entry list[];
} quadBuffer;

void extendSceneBounds(vec3 minPos, vec3 maxPos) {
    ivec3 voxMin = ivec3(floor(minPos));
    ivec3 voxMax = ivec3(ceil(maxPos));

    atomicMin(quadBuffer.aabb.xMin, voxMin.x);
    atomicMin(quadBuffer.aabb.yMin, voxMin.y);
    atomicMin(quadBuffer.aabb.zMin, voxMin.z);

    atomicMax(quadBuffer.aabb.xMax, voxMax.x);
    atomicMax(quadBuffer.aabb.yMax, voxMax.y);
    atomicMax(quadBuffer.aabb.zMax, voxMax.z);
}

#endif // _QUAD_GLSL
