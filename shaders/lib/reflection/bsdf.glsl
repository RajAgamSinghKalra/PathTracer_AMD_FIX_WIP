#ifndef _BSDF_GLSL
#define _BSDF_GLSL 1

#include "/lib/utility/material.glsl"
#include "/lib/utility/orthonormal.glsl"
#include "/lib/utility/random.glsl"
#include "/lib/utility/sampling.glsl"

struct bsdf_value {
    float full;
    float specular;
};

#include "/lib/reflection/lambertian.glsl"
#include "/lib/reflection/heitz.glsl"

struct bsdf_sample {
    vec3 direction;
    bsdf_value value;
    float pdf;
    bool dirac;
};

bsdf_value evaluateBSDF(material mat, vec3 lightDirection, vec3 viewDirection, bool dirac) {
    if (mat.type == MATERIAL_BLACKBODY) {
        return bsdf_value(0.0, 0.0);
    }

    vec3 w1, w2;
    buildOrthonormalBasis(mat.normal, w1, w2);

    mat3 localToWorld = mat3(w1, w2, mat.normal);
    vec3 wi = viewDirection * localToWorld;
    vec3 wo = lightDirection * localToWorld;

    return bsdf_value(evalMicrosurfaceBSDF(mat, wi, wo) / abs(wo.z), 0.0);
}

float evaluateBSDFSamplePDF(material mat, vec3 lightDirection, vec3 viewDirection) {
    if (mat.type == MATERIAL_BLACKBODY) {
        return 0.0;
    }

    vec3 w1, w2;
    buildOrthonormalBasis(mat.normal, w1, w2);
    mat3 localToWorld = mat3(w1, w2, mat.normal);

    vec3 wi = viewDirection * localToWorld;
    vec3 wo = lightDirection * localToWorld;

    vec3 halfway = normalize(wi + wo);
    if (mat.type == MATERIAL_DEFAULT) {
        float fresnelIn = fresnelDielectric(dot(wi, halfway), mat.ior.x);
        return fresnelIn * slope_D(mat, halfway) * G1(mat, wi) / abs(4.0 * wi.z) + (1.0 - fresnelIn) * abs(wo.z) / PI;
    } else if (mat.type == MATERIAL_METAL) {
        return slope_D(mat, halfway) * G1(mat, wi) / abs(4.0 * wi.z) + abs(wo.z);
    } else {
        return 1.0 / (2.0 * PI);
    }
}

bool sampleBSDF(out bsdf_sample bsdfSample, material mat, vec3 viewDirection, vec3 geoNormal) {
    if (mat.type == MATERIAL_BLACKBODY) {
        return false;
    }

    vec3 w1, w2;
    buildOrthonormalBasis(mat.normal, w1, w2);

    mat3 localToWorld = mat3(w1, w2, mat.normal);
    vec3 wi = viewDirection * localToWorld;

    float throughput;
    if (!sampleMicrosurfaceBSDF(mat, wi, bsdfSample.direction, throughput)) {
        return false;
    }

    bsdfSample.direction = localToWorld * bsdfSample.direction;
    bsdfSample.pdf = evaluateBSDFSamplePDF(mat, bsdfSample.direction, viewDirection);
    bsdfSample.dirac = false;
    
    bsdfSample.value = bsdf_value(bsdfSample.pdf * throughput / dot(bsdfSample.direction, mat.normal), 0.0);

    return dot(bsdfSample.direction, geoNormal) > 0.0;
}

#endif // _BSDF_GLSL