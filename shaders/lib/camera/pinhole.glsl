#ifndef _PINHOLE_GLSL
#define _PINHOLE_GLSL 1

#include "/lib/buffer/state.glsl"
#include "/lib/raytracing/ray.glsl"
#include "/lib/utility/projection.glsl"

ray generatePinholeCameraRay(vec2 filmSample) {
    vec3 pNear = projectAndDivide(renderState.projectionInverse, vec3(filmSample, -1.0));
    vec3 pDirection = projectAndDivide(renderState.projectionInverse, vec3(filmSample, 1.0));

    vec3 near = (renderState.viewMatrixInverse * vec4(pNear, 1.0)).xyz;
    vec3 direction = normalize((renderState.viewMatrixInverse * vec4(pDirection, 1.0)).xyz);

    return ray(renderState.cameraPosition + near, direction);
}

#endif // _PINHOLE_GLSL