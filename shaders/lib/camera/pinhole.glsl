#ifndef _PINHOLE_GLSL
#define _PINHOLE_GLSL 1

#include "/lib/raytracing/ray.glsl"
#include "/lib/utility/projection.glsl"

ray generateCameraRay(vec3 position, mat4 projectionInverse, mat4 viewInverse, vec2 filmSample) {
	vec3 rayDirection = projectAndDivide(projectionInverse, vec3(filmSample, 1.0));
	return ray(position, normalize((viewInverse * vec4(rayDirection, 1.0)).xyz));
}

#endif // _PINHOLE_GLSL