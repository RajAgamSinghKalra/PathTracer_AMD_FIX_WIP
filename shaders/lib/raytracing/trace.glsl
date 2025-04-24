#ifndef _RAYTRACE_GLSL
#define _RAYTRACE_GLSL 1

#include "/lib/buffer/octree.glsl"
#include "/lib/buffer/voxel.glsl"
#include "/lib/buffer/quad.glsl"
#include "/lib/buffer/state.glsl"
#include "/lib/raytracing/intersection.glsl"
#include "/lib/raytracing/ray.glsl"
#include "/lib/settings.glsl"

bool intersectsVoxel(sampler2D atlas, ray r, uint pointer, vec3 voxelPos, float tMax) {
    int traversed = 0;
    while (pointer != 0u && traversed < 64) {
        quad_entry entry = quadBuffer.list[pointer - 1u];

        pointer = entry.next;
        traversed++;

        vec3 normal = cross(entry.tangent.xyz, entry.bitangent.xyz);
        float d = dot(normal, r.direction);
        if (abs(d) < 1.0e-6) continue;

        float t = (entry.point.w - dot(normal, r.origin)) / d;
        if (t <= 0.0 || t > tMax) continue;

        vec3 point = r.origin + r.direction * t;
        vec3 pointInVoxel = point - voxelPos;
        if (clamp(pointInVoxel, -(1.0e-3), 1.0 + 1.0e-3) != pointInVoxel) continue;

        vec3 pLocal = (point - entry.point.xyz) * mat3(entry.tangent.xyz, entry.bitangent.xyz, normal);
        pLocal.xy /= vec2(entry.tangent.w, entry.bitangent.w);
        if (clamp(pLocal.xy, 0.0, 1.0) != pLocal.xy) continue;

        vec2 uv = mix(entry.uv0, entry.uv1, pLocal.xy);
        vec4 albedo = textureLod(atlas, uv, 0);
        if (albedo.a < 0.1) continue;

        return true;
    }

    return false;
}

bool traceShadowRay(ivec3 voxelOffset, sampler2D atlas, ray r, float tMax) {
    scene_aabb aabb = quadBuffer.aabb;

    vec3 bMin = (vec3(aabb.xMin, aabb.yMin, aabb.zMin) - r.origin) / r.direction;
    vec3 bMax = (vec3(aabb.xMax, aabb.yMax, aabb.zMax) - r.origin) / r.direction;
    vec3 t1 = min(bMin, bMax);
    r.origin += r.direction * max(max(max(t1.x, t1.y), t1.z) - 0.5, 0.0);

    vec3 voxel = floor(r.origin);

    voxelOffset += HALF_VOXEL_VOLUME_SIZE;
    voxel += vec3(voxelOffset);

    int octreeLevel = 5;

    vec3 boundMin = vec3(aabb.xMin, aabb.yMin, aabb.zMin) + voxelOffset - 1.0;
    vec3 boundMax = vec3(aabb.xMax, aabb.yMax, aabb.zMax) + voxelOffset + 1.0;

    float t = 0.0;
    for (int i = 0; i < 1024; i++) {
        if (octreeLevel == 0) {
            uint pointer = imageLoad(voxelBuffer, ivec3(voxel)).r;
            if (intersectsVoxel(atlas, r, pointer, voxel - vec3(voxelOffset), tMax)) {
                return true;
            }
        } else if (octree.data[getOctreeIndex(octreeLevel - 1, ivec3(voxel) >> octreeLevel)] != 0u) {
            octreeLevel--;
            continue;
        }

        if (any(lessThan(voxel, boundMin)) || any(greaterThan(voxel, boundMax))) {
            return false;
        }

        float voxelSize = float(1 << octreeLevel);
        vec3 dist = ((floor(voxel / voxelSize) + max(sign(r.direction), 0.0)) * voxelSize - r.origin - voxelOffset) / r.direction;
        float closest = min(dist.x, min(dist.y, dist.z));
        vec3 prevVoxel = voxel;
        r.origin += r.direction * closest;
        voxel = voxelOffset + floor(r.origin + 0.5 * step(dist, vec3(closest)) * sign(r.direction));
        
        t += closest;
        if (t > tMax) {
            return false;;
        }

        if (floor(prevVoxel / (voxelSize * 2.0)) != floor(voxel / (voxelSize * 2.0))) {
            octreeLevel = min(octreeLevel + 1, 5);
        }
    }
    
    return false;
}

bool traceVoxel(sampler2D atlas, ray r, uint pointer, vec3 voxelPos, inout intersection it) {
    int traversed = 0;
    while (pointer != 0u && traversed < 64) {
        quad_entry entry = quadBuffer.list[pointer - 1u];

        pointer = entry.next;
        traversed++;

        vec3 normal = cross(entry.tangent.xyz, entry.bitangent.xyz);
        float d = dot(normal, r.direction);
        if (abs(d) < 1.0e-6) continue;

        float t = (entry.point.w - dot(normal, r.origin)) / d;
        if (t <= 0.0 || (it.t >= 0.0 && t > it.t)) continue;

        vec3 point = r.origin + r.direction * t;
        vec3 pointInVoxel = point - voxelPos;
        if (clamp(pointInVoxel, -(1.0e-3), 1.0 + 1.0e-3) != pointInVoxel) continue;

        vec3 pLocal = (point - entry.point.xyz) * mat3(entry.tangent.xyz, entry.bitangent.xyz, normal);
        pLocal.xy /= vec2(entry.tangent.w, entry.bitangent.w);
        if (clamp(pLocal.xy, 0.0, 1.0) != pLocal.xy) continue;

        vec2 uv = mix(entry.uv0, entry.uv1, pLocal.xy);
        vec4 albedo = textureLod(atlas, uv, 0);
        if (albedo.a < 0.1) continue;

        it.t = t;
        it.normal = -sign(d) * normal;
        it.tbn = mat3(-sign(d) * entry.tangent.xyz, sign(d) * entry.bitangent.xyz, it.normal);
        it.albedo = albedo * unpackUnorm4x8(entry.tint);
        it.uv = uv;
    }

    return it.t >= 0.0;
}

bool traceRay(inout intersection it, ivec3 voxelOffset, sampler2D atlas, ray r) {
    vec3 rayPosition = r.origin;

    scene_aabb aabb = quadBuffer.aabb;

    vec3 tMin = (vec3(aabb.xMin, aabb.yMin, aabb.zMin) - rayPosition) / r.direction;
    vec3 tMax = (vec3(aabb.xMax, aabb.yMax, aabb.zMax) - rayPosition) / r.direction;
    vec3 t1 = min(tMin, tMax);
    rayPosition += r.direction * max(max(max(t1.x, t1.y), t1.z) - 0.5, 0.0);

    vec3 voxel = floor(rayPosition);

    voxelOffset += HALF_VOXEL_VOLUME_SIZE;
    voxel += vec3(voxelOffset);

    int octreeLevel = 5;

    it.t = -1.0;

    vec3 boundMin = vec3(aabb.xMin, aabb.yMin, aabb.zMin) + voxelOffset - 1.0;
    vec3 boundMax = vec3(aabb.xMax, aabb.yMax, aabb.zMax) + voxelOffset + 1.0;
    for (int i = 0; i < 1024; i++) {
        if (octreeLevel == 0) {
            uint pointer = imageLoad(voxelBuffer, ivec3(voxel)).r;
            if (traceVoxel(atlas, r, pointer, voxel - vec3(voxelOffset), it)) {
                return true;
            }
        } else if (octree.data[getOctreeIndex(octreeLevel - 1, ivec3(voxel) >> octreeLevel)] != 0u) {
            octreeLevel--;
            continue;
        }

        if (any(lessThan(voxel, boundMin)) || any(greaterThan(voxel, boundMax))) {
            return false;
        }

        float voxelSize = float(1 << octreeLevel);
        vec3 dist = ((floor(voxel / voxelSize) + max(sign(r.direction), 0.0)) * voxelSize - rayPosition - voxelOffset) / r.direction;
        float closest = min(dist.x, min(dist.y, dist.z));
        vec3 prevVoxel = voxel;
        rayPosition += r.direction * closest;
        voxel = voxelOffset + floor(rayPosition + 0.5 * step(dist, vec3(closest)) * sign(r.direction));

        if (floor(prevVoxel / (voxelSize * 2.0)) != floor(voxel / (voxelSize * 2.0))) {
            octreeLevel = min(octreeLevel + 1, 5);
        }
    }
    
    return false;
}

#endif // _RAYTRACE_GLSL