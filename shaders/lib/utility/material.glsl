#ifndef _MATERIAL_GLSL
#define _MATERIAL_GLSL 1

#include "/lib/utility/color.glsl"

#define MATERIAL_DEFAULT   0
#define MATERIAL_METAL     1
#define MATERIAL_GLASS     2
//#define MATERIAL_BLACKBODY 3
//#define MATERIAL_THINFILM  4

struct material {
    int type;
    vec3 albedo;
    vec3 emission;
    float roughness;
    float ior;
    vec3 normal;
    float ao;
    vec3 n;
    vec3 k;
};

float F0toIOR(float f0) {
    float r = sqrt(f0);
    return (1.0 + r) / max(1.0 - r, 1.0e-5);
}

vec3 F0toIOR(vec3 f0) {
    vec3 r = sqrt(f0);
    return (1.0 + r) / max(1.0 - r, 1.0e-5);
}

material decodeMaterial(mat3 tbn, vec4 albedo, vec4 specular, vec4 normal) {
    material mat;

    mat.type = MATERIAL_DEFAULT;
    mat.albedo = srgbToLinear(albedo.rgb);
    mat.emission = fract(specular.a) * mat.albedo * EMISSION_STRENGTH;
    mat.roughness = pow(1.0 - specular.r, 2.0);
    mat.normal = tbn[2];
    mat.ao = 1.0;
    mat.n = vec3(1.0);
    mat.k = vec3(0.0);

    if (albedo.a < 1.0) {
        mat.type = MATERIAL_GLASS;
    }

    if (specular.g > 229.5) {
        // TODO: Hardcoded metals
        mat.type = MATERIAL_METAL;
        mat.ior = 1.0;
        mat.n = F0toIOR(mat.albedo);
        mat.k = vec3(0.0);
    } else {
        mat.ior = F0toIOR(specular.g);
    }

    if (normal != vec4(0.0)) {
        normal.xy = normal.xy * 2.0 - 1.0;
        vec3 normalMapping = vec3(normal.xy, sqrt(1.0 - dot(normal.xy, normal.xy)));
        mat.normal = tbn * normalMapping;
        mat.ao = normal.b;
    }

    return mat;
}

#endif // _MATERIAL_GLSL