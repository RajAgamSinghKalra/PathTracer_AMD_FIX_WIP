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
#include "/lib/reflection/mbnm.glsl"

struct bsdf_sample {
    vec3 direction;
    bsdf_value value;
    float pdf;
    bool dirac;
};

float evalMBNMicrofacetBSDF(material m, vec3 wi, vec3 wo) {
    return evalMicrosurfaceBSDF(m, wi, wo);
}

bool sampleMBNMicrofacetBSDF(material m, vec3 wi, out vec3 wo, out float weight) {
    return sampleMicrosurfaceBSDF(m, wi, wo, weight);
}
float evalMBNMicrofacetPDF(material m, vec3 wi, vec3 wo) {
    return evalMicrosurfacePDF(m, wi, wo);
}

bsdf_value evaluateBSDF(material mat, vec3 wi, vec3 wo, bool dirac) {
    if (mat.type == MATERIAL_BLACKBODY) {
        return bsdf_value(0.0, 0.0);
    }

    return bsdf_value(evalMicrosurfaceBSDF_MBN(mat, wi, wo) / abs(wo.z), 0.0);
}

float evaluateBSDFSamplePDF(material mat, vec3 wi, vec3 wo) {
    if (mat.type == MATERIAL_BLACKBODY) {
        return 0.0;
    }

    // Not a valid PDF, but works fine as a MIS weight
    return evalMicrosurfacePDF_MBN(mat, wi, wo);
}

bool sampleBSDF(out bsdf_sample bsdfSample, material mat, vec3 wi) {
    if (mat.type == MATERIAL_BLACKBODY) {
        return false;
    }

    float throughput;
    if (!sampleMicrosurfaceBSDF_MBN(mat, wi, bsdfSample.direction, throughput)) {
        return false;
    }

    bsdfSample.direction = bsdfSample.direction;
    bsdfSample.pdf = evaluateBSDFSamplePDF(mat, wi, bsdfSample.direction);
    bsdfSample.dirac = false;
    
    bsdfSample.value = bsdf_value(bsdfSample.pdf * throughput / abs(bsdfSample.direction.z), 0.0);

    return bsdfSample.direction.z > 0.0;
}

#endif // _BSDF_GLSL