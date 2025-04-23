#ifndef _BSDF_GLSL
#define _BSDF_GLSL 1

#include "/lib/utility/material.glsl"
#include "/lib/utility/orthonormal.glsl"
#include "/lib/utility/random.glsl"
#include "/lib/utility/sampling.glsl"
#include "/lib/settings.glsl"

#include "/lib/reflection/heitz.glsl"
#include "/lib/reflection/mbnm.glsl"

struct bsdf_sample {
    vec3 direction;
    float value;
    float pdf;
    bool dirac;
};

float evalMBNMicrofacetBSDF(material m, vec3 wi, vec3 wo) {
    if (any(lessThan(m.alpha, vec2(0.001)))) {
        return evalSmoothBSDF(m, wi, wo);
    } else {
        return evalMicrosurfaceBSDF(m, wi, wo);
    }
}

bool sampleMBNMicrofacetBSDF(material m, vec3 wi, out vec3 wo, out float weight, out bool dirac) {
    if (any(lessThan(m.alpha, vec2(0.001)))) {
        return sampleSmoothBSDF(m, wi, wo, weight, dirac);
    } else {
        dirac = false;
        return sampleMicrosurfaceBSDF(m, wi, wo, weight);
    }
}

float evalMBNMicrofacetPDF(material m, vec3 wi, vec3 wo) {
    if (any(lessThan(m.alpha, vec2(0.001)))) {
        return evalSmoothBSDFSamplePDF(m, wi, wo);
    } else {
        return evalMicrosurfacePDF(m, wi, wo);
    }
}

float evaluateBSDF(material mat, vec3 wi, vec3 wo, bool dirac) {
    if (mat.type == MATERIAL_BLACKBODY) {
        return 0.0;
    }

    return evalMicrosurfaceBSDF_MBN(mat, wi, wo) / abs(wo.z);
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
    if (!sampleMicrosurfaceBSDF_MBN(mat, wi, bsdfSample.direction, throughput, bsdfSample.dirac)) {
        return false;
    }

    bsdfSample.direction = bsdfSample.direction;
    bsdfSample.pdf = evaluateBSDFSamplePDF(mat, wi, bsdfSample.direction);
    
    bsdfSample.value = bsdfSample.pdf * throughput / abs(bsdfSample.direction.z), 0.0;

    return bsdfSample.direction.z > 0.0;
}

#endif // _BSDF_GLSL