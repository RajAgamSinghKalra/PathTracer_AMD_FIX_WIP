#ifndef _MATERIAL_GLSL
#define _MATERIAL_GLSL 1

#include "/lib/spectral/blackbody.glsl"
#include "/lib/spectral/conversion.glsl"
#include "/lib/utility/color.glsl"
#include "/lib/utility/complex.glsl"
#include "/lib/utility/orthonormal.glsl"

#define MATERIAL_LAYERED   0
#define MATERIAL_METAL     1
#define MATERIAL_GLASS     2
#define MATERIAL_BLACKBODY 3
//#define MATERIAL_THINFILM  4

struct material {
    int type;
    float albedo;
    float emission;
    vec2 alpha;
    complex ior;
    vec3 normal;
    float ao;
};

float F0toIOR(float f0) {
    float r = sqrt(f0);
    return (1.0 + r) / max(1.0 - r, 1.0e-5);
}

material decodeMaterial(int lambda, mat3 tbn, vec4 albedo, vec4 specular, vec4 normal) {
    material mat;

    mat.type = MATERIAL_LAYERED;
    mat.albedo = srgbToReflectanceSpectrum(lambda, albedo.rgb);
    mat.emission = fract(specular.a) * srgbToEmissionSpectrum(lambda, albedo.rgb) * EMISSION_STRENGTH;
    mat.alpha = vec2(pow(1.0 - specular.r, 2.0));
    mat.normal = vec3(0.0, 0.0, 1.0);
    mat.ao = 1.0;

    // if (albedo.a < 1.0) {
    //     mat.type = MATERIAL_GLASS;
    // }

    float f0;
    if (specular.g > 229.5 / 255.0) {
        int id = int(round(specular.g * 255.0));

        mat.type = MATERIAL_METAL;
        mat.ior = complex(F0toIOR(mat.albedo), 0.0);

        if (id == 238) {
            mat.type = MATERIAL_BLACKBODY;
            int temperature = int(round(specular.b * 255.0) * 100.0);
            mat.emission = blackbodyScaled(lambda, temperature);
        }
    } else {
        mat.ior = complex(F0toIOR(specular.g), 0.0);
    }

    if (normal != vec4(0.0)) {
        normal.xy = normal.xy * 2.0 - 1.0;
        mat.normal = vec3(normal.x, normal.y, sqrt(1.0 - dot(normal.xy, normal.xy)));
        vec3 b1, b2;
        buildOrthonormalBasis(tbn[2], b1, b2);
        mat.normal = (tbn * mat.normal) * mat3(b1, b2, tbn[2]);
        mat.ao = normal.b;
    }

    return mat;
}

#endif // _MATERIAL_GLSL