#ifndef _ENVIRONMENT_GLSL
#define _ENVIRONMENT_GLSL 1

#include "/lib/raytracing/ray.glsl"
#include "/lib/utility/constants.glsl"
#include "/lib/settings.glsl"

uniform sampler2D environment;

vec3 environmentMap(vec3 rayDirection) {
    float u = atan(rayDirection.z, rayDirection.x) / (2.0 * PI);
    float v = acos(rayDirection.y) / PI;
    u = fract(u + ENVMAP_OFFSET_U);

    return texture(environment, vec2(u, v)).rgb;
}

vec3 environmentMap(ray r) {
    return environmentMap(r.direction);
}

#endif // _ENVIRONMENT_GLSL