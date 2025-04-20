#ifndef _PINHOLE_GLSL
#define _PINHOLE_GLSL 1

#include "/lib/raytracing/ray.glsl"
#include "/lib/utility/projection.glsl"

ray generateCameraRay(vec3 position, mat4 projectionInverse, mat4 viewInverse, vec2 filmSample) {
    vec3 rayDirection = projectAndDivide(projectionInverse, vec3(filmSample, 1.0));
    vec3 near = projectAndDivide(projectionInverse, vec3(filmSample, -1.0));
    return ray(position + (viewInverse * vec4(near, 1.0)).xyz, normalize((viewInverse * vec4(rayDirection, 1.0)).xyz));
}

float imagePlaneArea(mat4 projectionInverse) {
    vec3 pMin = projectAndDivide(projectionInverse, vec3(-1.0, -1.0, 0.0));
    vec3 pMax = projectAndDivide(projectionInverse, vec3(1.0, 1.0, 0.0));
    pMin.xy /= pMin.z;
    pMax.xy /= pMax.z;
    return abs((pMax.x - pMin.x) * (pMax.y - pMin.y));
}

bool connectLightRayToFilm(vec3 x1, vec3 x2, mat4 projection, mat4 view, out vec2 filmPosition) {
    vec3 position = (view * vec4(x2 - x1, 1.0)).xyz;
    position = projectAndDivide(projection, position);
    if (clamp(position, -1.0, 1.0) != position) return false;
    filmPosition = position.xy;
    return true;
}

#endif // _PINHOLE_GLSL