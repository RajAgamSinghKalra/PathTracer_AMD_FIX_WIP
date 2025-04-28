#ifndef _RAYTRACE_GLSL
#define _RAYTRACE_GLSL 1

#include "/lib/buffer/octree.glsl"
#include "/lib/buffer/voxel.glsl"
#include "/lib/buffer/quad.glsl"
#include "/lib/buffer/state.glsl"
#include "/lib/raytracing/intersection.glsl"
#include "/lib/raytracing/ray.glsl"
#include "/lib/utility/constants.glsl"
#include "/lib/utility/intersectors.glsl"
#include "/lib/utility/orthonormal.glsl"
#include "/lib/settings.glsl"

float intersectSceneBounds(scene_aabb aabb, ray r) {
    vec3 bMin = (vec3(aabb.xMin, aabb.yMin, aabb.zMin) - r.origin) / r.direction;
    vec3 bMax = (vec3(aabb.xMax, aabb.yMax, aabb.zMax) - r.origin) / r.direction;
    vec3 t1 = min(bMin, bMax);

    return max(max(max(t1.x, t1.y), t1.z) - 0.5, 0.0);
}

void getSceneBounds(scene_aabb aabb, ivec3 voxelOffset, out vec3 minBound, out vec3 maxBound) {
    minBound = vec3(aabb.xMin, aabb.yMin, aabb.zMin) + vec3(voxelOffset) - 1.0;
    maxBound = vec3(aabb.xMax, aabb.yMax, aabb.zMax) + vec3(voxelOffset) + 1.0;
}

float stepVoxel(inout vec3 voxel, inout vec3 origin, vec3 direction, float voxelSize, ivec3 offset) {
    vec3 dist = ((floor(voxel / voxelSize) + max(sign(direction), 0.0)) * voxelSize - origin - vec3(offset)) / direction;
    float t = min(dist.x, min(dist.y, dist.z));

    origin += direction * t;

    vec3 voxelDirection = step(dist, vec3(t)) * sign(direction);
    voxel = vec3(offset) + floor(origin + 0.5 * voxelDirection);

    return t;
}

bool rayEscapedScene(vec3 voxel, vec3 boundMin, vec3 boundMax) {
    return any(lessThan(voxel, boundMin)) || any(greaterThan(voxel, boundMax));
}

bool intersectModelElement(inout quad_entry entry, sampler2D atlas, ray r, vec3 voxelPos, float tMax, out vec3 normal, out float d, out float t, out vec2 uv, out vec4 albedo) {
#ifdef ENABLE_SPHERES
    if ((entry.tint >> 24u) == 254u) {
        vec2 t2 = intersectSphere(r, voxelPos + 0.5, 0.5);
        if (t2.y < 0.0) {
            return false;
        }

        t = t2.x < 0.0 ? t2.y : t2.x;
        if (t > tMax) {
            return false;
        }

        normal = normalize(r.origin + r.direction * t - voxelPos - 0.5);
        d = dot(normal, r.direction);

        buildOrthonormalBasis(normal, entry.tangent.xyz, entry.bitangent.xyz);
        vec2 unwrap = vec2(atan(-normal.z, normal.x) / (2.0 * PI) + 0.5, acos(-normal.y) / PI);
        uv = mix(entry.uv0, entry.uv1, unwrap);
        albedo = textureLod(atlas, uv, 0) * vec4(unpackUnorm4x8(entry.tint).rgb, 1.0);
        return true;
    }
#endif
    
    normal = cross(entry.tangent.xyz, entry.bitangent.xyz);
    d = dot(normal, r.direction);
    if (abs(d) < 1.0e-6) {
        return false;
    }

    t = (entry.point.w - dot(normal, r.origin)) / d;
    if (t <= 0.0 || t > tMax) {
        return false;
    }

    vec3 point = r.origin + r.direction * t;
    vec3 pLocal = point - voxelPos;
    if (clamp(pLocal, -0.001, 1.001) != pLocal) {
        return false;
    }

    vec3 pTangent = (point - entry.point.xyz) * mat3(entry.tangent.xyz, entry.bitangent.xyz, normal);
    pTangent.xy /= vec2(entry.tangent.w, entry.bitangent.w);
    if (clamp(pTangent.xy, 0.0, 1.0) != pTangent.xy) {
        return false;
    }

    uv = mix(entry.uv0, entry.uv1, pTangent.xy);
    albedo = textureLod(atlas, uv, 0);
    if (albedo.a < 0.1) {
        return false;
    }

    return true;
}

bool intersectsVoxel(sampler2D atlas, ray r, uint pointer, vec3 voxelPos, float tMax) {
    int traversed = 0;
    while (pointer != 0u && traversed < 64) {
        quad_entry entry = quadBuffer.list[pointer - 1u];

        pointer = entry.next;
        traversed++;

        vec3 normal;
        float d, t;
        vec2 uv;
        vec4 albedo;
        if (!intersectModelElement(entry, atlas, r, voxelPos, tMax, normal, d, t, uv, albedo)) {
            continue;
        }

        return true;
    }

    return false;
}

bool traceShadowRay(ivec3 voxelOffset, sampler2D atlas, ray r, float tMax) {
    scene_aabb aabb = quadBuffer.aabb;

    float t = intersectSceneBounds(aabb, r);
    r.origin += r.direction * t;

    vec3 voxel = floor(r.origin);

    voxelOffset += HALF_VOXEL_VOLUME_SIZE;
    voxel += vec3(voxelOffset);

    vec3 boundMin, boundMax;
    getSceneBounds(aabb, voxelOffset, boundMin, boundMax);

    int octreeLevel = 5;
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

        if (rayEscapedScene(voxel, boundMin, boundMax)) {
            return false;
        }

        vec3 prevVoxel = voxel;
        float voxelSize = float(1 << octreeLevel);
        
        t += stepVoxel(voxel, r.origin, r.direction, voxelSize, voxelOffset);
        if (t > tMax) {
            return false;
        }

        if (floor(prevVoxel / (voxelSize * 2.0)) != floor(voxel / (voxelSize * 2.0))) {
            octreeLevel = min(octreeLevel + 1, 5);
        }
    }
    
    return false;
}

bool traceVoxel(sampler2D atlas, ray r, uint pointer, vec3 voxelPos, inout intersection it) {
    int traversed = 0;

    bool hasIntersection = false;
    while (pointer != 0u && traversed < 64) {
        quad_entry entry = quadBuffer.list[pointer - 1u];

        pointer = entry.next;
        traversed++;

        float d, t;
        vec2 uv;
        vec4 albedo;
        vec3 normal;
        if (!intersectModelElement(entry, atlas, r, voxelPos, it.t, normal, d, t, uv, albedo)) {
            continue;
        }

        d = sign(d);

        it.t = t;
        it.tbn = mat3(-d * entry.tangent.xyz, d * entry.bitangent.xyz, -d * normal);
        it.albedo = albedo * unpackUnorm4x8(entry.tint);
        it.uv = uv;

        hasIntersection = true;
    }

    return hasIntersection;
}

bool traceRay(inout intersection it, ivec3 voxelOffset, sampler2D atlas, ray r) {
    scene_aabb aabb = quadBuffer.aabb;

    vec3 rayPosition = r.origin;
    rayPosition += r.direction * intersectSceneBounds(aabb, r);

    voxelOffset += HALF_VOXEL_VOLUME_SIZE;
    vec3 voxel = floor(rayPosition) + vec3(voxelOffset);

    vec3 boundMin, boundMax;
    getSceneBounds(aabb, voxelOffset, boundMin, boundMax);

    it.t = 1.0e16;
    int octreeLevel = 5;
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

        if (rayEscapedScene(voxel, boundMin, boundMax)) {
            return false;
        }

        vec3 prevVoxel = voxel;
        float voxelSize = float(1 << octreeLevel);

        stepVoxel(voxel, rayPosition, r.direction, voxelSize, voxelOffset);

        if (floor(prevVoxel / (voxelSize * 2.0)) != floor(voxel / (voxelSize * 2.0))) {
            octreeLevel = min(octreeLevel + 1, 5);
        }
    }
    
    return false;
}

#endif // _RAYTRACE_GLSL