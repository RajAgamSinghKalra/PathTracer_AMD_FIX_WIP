#ifndef _RAYTRACE_GLSL
#define _RAYTRACE_GLSL 1

#include "/lib/buffer/voxel.glsl"
#include "/lib/buffer/quad.glsl"
#include "/lib/raytracing/intersection.glsl"
#include "/lib/raytracing/ray.glsl"
#include "/lib/settings.glsl"

bool intersectsVoxel(sampler2D atlas, ray r, uint pointer) {
	int traversed = 0;
	while (pointer != 0u && traversed < 64) {
		quad_entry entry = quadBuffer.list[pointer - 1u];

		pointer = entry.next;
		traversed++;

		vec3 normal = cross(entry.tangent.xyz, entry.bitangent.xyz);
		float d = dot(normal, r.direction);
		if (abs(d) < 1.0e-6) continue;

		float t = (entry.point.w - dot(normal, r.origin)) / d;
		if (t <= 0.0) continue;

		vec3 pLocal = (r.origin + r.direction * t - entry.point.xyz) * mat3(entry.tangent.xyz, entry.bitangent.xyz, normal);
		pLocal.xy /= vec2(entry.tangent.w, entry.bitangent.w);
		if (clamp(pLocal.xy, 0.0, 1.0) != pLocal.xy) continue;

		vec2 uv = mix(entry.uv0, entry.uv1, pLocal.xy);
		vec4 albedo = textureLod(atlas, uv, 0);
		if (albedo.a < 0.1) continue;

		return true;
	}

	return false;
}

bool traceShadowRay(sampler2D atlas, ray r) {
    ivec3 voxel = ivec3(floor(r.origin));
    vec3 delta = abs(1.0 / r.direction);
    ivec3 rayStep = ivec3(sign(r.direction));
    vec3 side = (sign(r.direction) * (vec3(voxel) - r.origin) + (sign(r.direction) * 0.5) + 0.5) * delta;

	voxel += HALF_VOXEL_VOLUME_SIZE;

    for (int i = 0; i < 128; i++) {
		if (any(lessThan(voxel, ivec3(0, 0, 0))) || any(greaterThanEqual(voxel, VOXEL_VOLUME_SIZE))) {
			break;
		}
		
        uint pointer = imageLoad(voxelBuffer, voxel).r;
		if (intersectsVoxel(atlas, r, pointer)) {
			return true;
		}

        bvec3 mask = lessThanEqual(side.xyz, min(side.yzx, side.zxy));
        side += vec3(mask) * delta;
        voxel += ivec3(mask) * rayStep;
    }
    
    return false;
}

bool traceVoxel(sampler2D atlas, ray r, uint pointer, inout intersection it) {
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

		vec3 pLocal = (r.origin + r.direction * t - entry.point.xyz) * mat3(entry.tangent.xyz, entry.bitangent.xyz, normal);
		pLocal.xy /= vec2(entry.tangent.w, entry.bitangent.w);
		if (clamp(pLocal.xy, 0.0, 1.0) != pLocal.xy) continue;

		vec2 uv = mix(entry.uv0, entry.uv1, pLocal.xy);
		vec4 albedo = textureLod(atlas, uv, 0);
		if (albedo.a < 0.1) continue;

		it.t = t;
		it.normal = -sign(d) * normal;
		it.albedo = albedo * unpackUnorm4x8(entry.tint);
		it.uv = uv;
	}

	return it.t >= 0.0;
}

intersection traceRay(sampler2D atlas, ray r, int voxels) {
	ivec3 voxel = ivec3(floor(r.origin));
    vec3 delta = abs(1.0 / r.direction);
    ivec3 rayStep = ivec3(sign(r.direction));
    vec3 side = (sign(r.direction) * (vec3(voxel) - r.origin) + (sign(r.direction) * 0.5) + 0.5) * delta;

	voxel += HALF_VOXEL_VOLUME_SIZE;

	intersection it = noHit();

    for (int i = 0; i < voxels; i++) {
		if (any(lessThan(voxel, ivec3(0, 0, 0))) || any(greaterThanEqual(voxel, VOXEL_VOLUME_SIZE))) {
			break;
		}

        uint pointer = imageLoad(voxelBuffer, voxel).r;
		if (traceVoxel(atlas, r, pointer, it)) {
			return it;
		}

        bvec3 mask = lessThanEqual(side.xyz, min(side.yzx, side.zxy));
        side += vec3(mask) * delta;
        voxel += ivec3(mask) * rayStep;
    }
    
    return it;
}

#endif // _RAYTRACE_GLSL