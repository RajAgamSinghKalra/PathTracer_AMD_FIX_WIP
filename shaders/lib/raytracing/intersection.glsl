#ifndef _INTERSECTION_GLSL
#define _INTERSECTION_GLSL 1

struct intersection {
    float t;
    vec3 normal;
    mat3 tbn;
    vec4 albedo;
    vec2 uv;
};

#endif // _INTERSECTION_GLSL