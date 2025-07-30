#ifndef _INTERSECTORS_GLSL
#define _INTERSECTORS_GLSL 1

#include "/lib/raytracing/ray.glsl"

vec2 intersectSphere(ray r, vec3 center, float radius) {
    vec3 oc = r.origin - center;
    float b = dot(oc, r.direction);
    vec3 qc = oc - b * r.direction;
    float h = radius * radius - dot(qc, qc);
    if(h < 0.0) {
        return vec2(-1.0);
    }

    h = sqrt(h);
    return vec2(-b - h, -b + h);
}

#endif // _INTERSECTORS_GLSL
