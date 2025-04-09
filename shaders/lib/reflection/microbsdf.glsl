#ifndef _MICROBSDF_GLSL
#define _MICROBSDF_GLSL 1

// Conductor Microsurface
float evalConductorMicrosurfacePhaseFunction(material m, vec3 wi, vec3 wo) {
    vec3 wh = normalize(wi + wo);
    if (wh.z < 0.0) {
        return 0.0;
    }

    return fresnelConductor(dot(wi, wh), m.ior) * slope_D_wi(m, wi, wh) / (4.0 * dot(wi, wh));
}

vec3 sampleConductorMicrosurfacePhaseFunction(material m, vec3 wi, out float weight) {
    float U1 = random1();
    float U2 = random1();

    vec3 wm = slope_sampleD_wi(m, wi, random2());
    vec3 wo = reflect(-wi, wm);

    weight = fresnelConductor(dot(wi, wm), m.ior);

    return wo;
}

// Diffuse Microsurface
float evalDiffuseMicrosurfacePhaseFunction(material m, vec3 wi, vec3 wo) {
    vec3 wm = slope_sampleD_wi(m, wi, random2());
    return m.albedo / PI * max(0.0, dot(wo, wm));
}

vec3 sampleDiffuseMicrosurfacePhaseFunction(material m, vec3 wi, out float weight) {
    weight = m.albedo;

    vec3 wm = slope_sampleD_wi(m, wi, random2());
    return sampleCosineWeightedHemisphere(random2(), wm);
}

// Interfaced Lambertian Microsurface
// https://hal.science/hal-01711532v1/document
float evalInterfacedMicrosurfacePhaseFunction(material m, vec3 wi, vec3 wo) {
    vec3 wm = slope_sampleD_wi(m, wi, random2());

    float fresnelIn = fresnelDielectric(dot(wi, wm), 1.0, m.ior.x);
    float fresnelOut = fresnelDielectric(dot(wo, wm), 1.0, m.ior.x);

    float diffuse = (1.0 - fresnelIn) * (1.0 - fresnelOut) * m.albedo / PI * max(0.0, dot(wo, wm)) / (1.0 - m.albedo * fresnelOverHemisphere(m.ior.x));

    vec3 wh = normalize(wi + wo);
    if (wh.z < 0.0) {
        return diffuse;
    }

    float specular = fresnelDielectric(dot(wi, wh), 1.0, m.ior.x) * slope_D_wi(m, wi, wh) / (4.0 * dot(wi, wh));
    return specular + diffuse;
}

vec3 sampleInterfacedMicrosurfacePhaseFunction(material m, vec3 wi, out float weight) {
    weight = 1.0;

    vec3 wm = slope_sampleD_wi(m, wi, random2());

    float fresnelIn = fresnelDielectric(dot(wi, wm), 1.0, m.ior.x);
    float specularProb = fresnelIn / (fresnelIn + (1.0 - fresnelIn) * m.albedo);

    if (random1() < specularProb) {
        weight = fresnelIn / specularProb;
        return reflect(-wi, wm);
    } else {
        vec3 wo = sampleCosineWeightedHemisphere(random2(), wm);
        float fresnelOut = fresnelDielectric(dot(wo, wm), 1.0, m.ior.x);
        weight = (1.0 - fresnelIn) * (1.0 - fresnelOut) * m.albedo / (1.0 - specularProb) / (1.0 - m.albedo * fresnelOverHemisphere(m.ior.x));
        return wo;
    }
}

// General Microfacet BSDF
float evalMicrofacetBSDF(material m, vec3 wi, vec3 wo) {
    if (m.type == MATERIAL_INTERFACED) {
        return evalInterfacedMicrosurfacePhaseFunction(m, wi, wo);
    } else if (m.type == MATERIAL_METAL) {
        return evalConductorMicrosurfacePhaseFunction(m, wi, wo);
    } else {
        return 0.0;
    }
}

bool sampleMicrofacetBSDF(material m, vec3 wi, out vec3 wo, out float weight) {
    if (m.type == MATERIAL_INTERFACED) {
        wo = sampleInterfacedMicrosurfacePhaseFunction(m, wi, weight);
        return true;
    } else if (m.type == MATERIAL_METAL) {
        wo = sampleConductorMicrosurfacePhaseFunction(m, wi, weight);
        return true;
    }
    return false;
}

#endif // _MICROBSDF_GLSL