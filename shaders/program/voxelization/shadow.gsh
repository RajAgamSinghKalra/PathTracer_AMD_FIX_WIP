#include "/lib/buffer/octree.glsl"
#include "/lib/buffer/quad.glsl"
#include "/lib/buffer/state.glsl"
#include "/lib/buffer/voxel.glsl"
#include "/lib/settings.glsl"

layout (triangles) in;
layout (points, max_vertices = 1) out;

uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPositionFract;

in vec3 vPosition[3];
in vec3 vMidOffset[3];
in vec4 vColor[3];
in vec2 vUV[3];

void main() {
    if (gl_PrimitiveIDIn % 2 != 0 || renderState.frame > 1) {
        return;
    }

    quad_entry entry;
    entry.point.xyz = vPosition[1] + cameraPositionFract;
    entry.tangent.xyz = vPosition[2] - vPosition[1];
    entry.bitangent.xyz = vPosition[0] - vPosition[1];
    entry.uv0 = vUV[1];
    entry.uv1 = vUV[2] + vUV[0] - vUV[1];
    entry.tint = packUnorm4x8(vColor[0]);

    vec3 vPos3 = entry.point.xyz + entry.tangent.xyz + entry.bitangent.xyz;
    
    entry.tangent.w = length(entry.tangent.xyz);
    entry.tangent.xyz /= entry.tangent.w;
    entry.bitangent.w = length(entry.bitangent.xyz);
    entry.bitangent.xyz /= entry.bitangent.w;
    entry.point.w = dot(cross(entry.tangent.xyz, entry.bitangent.xyz), entry.point.xyz);

    vec3 center = vPosition[0] + vMidOffset[0] + cameraPositionFract;
    ivec3 voxelOffset = ivec3(gbufferModelViewInverse[2].xyz * VOXEL_OFFSET);
    ivec3 voxelPos = ivec3(floor(center)) + HALF_VOXEL_VOLUME_SIZE + voxelOffset;
    if (clamp(voxelPos, ivec3(0, 0, 0), VOXEL_VOLUME_SIZE - 1) != voxelPos) return;

    uint index = atomicAdd(quadBuffer.count, 1u);
    entry.next = imageAtomicExchange(voxelBuffer, voxelPos, index + 1u);

    quadBuffer.list[index] = entry;

    extendSceneBounds(
        min(min(vPosition[0], vPosition[1]), min(vPosition[2], vPos3)),
        max(max(vPosition[0], vPosition[1]), max(vPosition[2], vPos3))
    );

    occupyOctreeVoxel(voxelPos);
}