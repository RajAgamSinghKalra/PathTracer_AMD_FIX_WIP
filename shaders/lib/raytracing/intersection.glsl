#ifndef _INTERSECTION_GLSL
#define _INTERSECTION_GLSL 1

struct intersection {
    float t;
    mat3 tbn;
    vec4 albedo;
    vec4 normal;
    vec4 specular;
};

#endif // _INTERSECTION_GLSL