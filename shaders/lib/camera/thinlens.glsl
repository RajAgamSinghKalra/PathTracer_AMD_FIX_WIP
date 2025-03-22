#ifndef _THINLENS_GLSL
#define _THINLENS_GLSL 1

#include "/lib/buffer/state.glsl"
#include "/lib/raytracing/ray.glsl"
#include "/lib/utility/projection.glsl"
#include "/lib/utility/random.glsl"
#include "/lib/utility/sampling.glsl"

const float lensRadius = 0.05;

ray generateCameraRay(vec3 position, mat4 projectionInverse, mat4 viewInverse, vec2 filmSample) {
    vec3 rayDirection = normalize(projectAndDivide(projectionInverse, vec3(filmSample, 1.0)));
    if (renderState.focalDistance <= 0.0) return ray(position, normalize((mat3(viewInverse) * rayDirection).xyz));

    vec3 origin = vec3(lensRadius * sampleDisk(random2()), 0.0);
    rayDirection = normalize((rayDirection * renderState.focalDistance / -rayDirection.z) - origin);

    ray r = ray((mat3(viewInverse) * origin).xyz, normalize((mat3(viewInverse) * rayDirection).xyz));
    r.origin += position;

    return r;
}

#endif // _THINLENS_GLSL