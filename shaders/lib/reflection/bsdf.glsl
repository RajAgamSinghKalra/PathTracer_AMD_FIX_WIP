#ifndef _BSDF_GLSL
#define _BSDF_GLSL 1

#include "/lib/utility/material.glsl"
#include "/lib/utility/random.glsl"
#include "/lib/utility/sampling.glsl"

struct bsdf_value {
    vec3 full;
    vec3 specular;
};

#include "/lib/reflection/lambertian.glsl"

struct bsdf_sample {
    vec3 direction;
    bsdf_value value;
    float pdf;
    bool dirac;
};

bsdf_value evaluateBSDF(material mat, inout vec3 seed, vec3 lightDirection, vec3 viewDirection, bool dirac) {
    return bsdfLambertian(mat);
}

bool sampleBSDF(out bsdf_sample bsdfSample, material mat, inout vec3 seed, vec3 viewDirection, vec3 geoNormal) {
    bsdfSample.direction = sampleCosineWeightedHemisphere(random2(seed), mat.normal);
    bsdfSample.pdf = cosineWeightedHemispherePDF(bsdfSample.direction, mat.normal);
    bsdfSample.dirac = false;
    
    bsdfSample.value = evaluateBSDF(mat, seed, bsdfSample.direction, viewDirection, bsdfSample.dirac);

    return dot(bsdfSample.direction, geoNormal) > 0.0;
}

#endif // _BSDF_GLSL