#ifndef _LENS_INTERSECTION_GLSL
#define _LENS_INTERSECTION_GLSL 1

#include "/lib/raytracing/ray.glsl"

bool intersectSphericalLensElement(float radius, float z, ray r, out float t, out vec3 normal) {
    r.origin -= vec3(0.0, 0.0, z + radius);

    float b = dot(r.origin, r.direction);
    float c = dot(r.origin, r.origin) - radius * radius;
    float d = b * b - c;
    if (d < 0.0) {
        return false;
    }

    d = sqrt(d);
    float t0 = -b - d;
    float t1 = -b + d;
    t = radius * r.direction.z > 0.0 ? t0 : t1;
    
    normal = normalize(r.origin + t * r.direction);
    normal *= -sign(dot(r.direction, normal));

    return true;
}

bool intersectPlanarLensElement(float z, ray r, out float t, out vec3 normal) {
    t = (z - r.origin.z) / r.direction.z;
    normal = vec3(0.0, 0.0, -sign(r.direction.z));
    return t >= 0.0;
}

#endif // _LENS_INTERSECTION_GLSL
