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
    vec3 w1, w2;
    buildOrthonormalBasis(mat.normal, w1, w2);

    mat3 localToWorld = mat3(w1, w2, mat.normal);
    vec3 wi = viewDirection * localToWorld;
    vec3 wo = lightDirection * localToWorld;

    return bsdf_value(evalMicrosurfaceBSDF(mat, wi, wo) / abs(wo.z), 0.0);
}

bool sampleBSDF(out bsdf_sample bsdfSample, material mat, vec3 viewDirection, vec3 geoNormal) {
    vec3 w1, w2;
    buildOrthonormalBasis(mat.normal, w1, w2);

    mat3 localToWorld = mat3(w1, w2, mat.normal);
    vec3 wi = viewDirection * localToWorld;

    float throughput;
    if (!sampleMicrosurfaceBSDF(mat, wi, bsdfSample.direction, throughput)) {
        return false;
    }

    bsdfSample.direction = localToWorld * bsdfSample.direction;
    bsdfSample.pdf = 1.0;
    bsdfSample.dirac = false;
    
    bsdfSample.value = bsdf_value(throughput / dot(bsdfSample.direction, mat.normal), 0.0);

    return dot(bsdfSample.direction, geoNormal) > 0.0;
}

#endif // _BSDF_GLSL