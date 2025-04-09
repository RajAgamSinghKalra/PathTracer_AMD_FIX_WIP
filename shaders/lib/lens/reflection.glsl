#ifndef _LENS_REFLECTION_GLSL
#define _LENS_REFLECTION_GLSL 1

#include "/lib/reflection/sellmeier.glsl"
#include "/lib/reflection/fresnel.glsl"

const sellmeier_coeffs AR_COATING_MATERIAL = MgF2;

float getLensCoatingThickness() {
    // Classic quarter-wavelength coating
    return 540.0 / (4.0 * sellmeier(AR_COATING_MATERIAL, 540)); 
}

float getLensCoatingIOR(int lambda) {
    return sellmeier(AR_COATING_MATERIAL, lambda);
}

float computeLensElementReflectance(float cosTheta, int lambda, float currentEta, float transmittedEta, bool coated) {
    if (currentEta == transmittedEta) {
        return 0.0;
    } else if (coated && (currentEta == 1.0 || transmittedEta == 1.0)) {
        float thickness = getLensCoatingThickness();
        float filmEta = getLensCoatingIOR(lambda);
        return fresnelThinFilm(cosTheta, lambda, vec3(currentEta, filmEta, transmittedEta), thickness);
    } else {
        return fresnelDielectric(cosTheta, currentEta, transmittedEta);
    }
}

#endif // _LENS_REFLECTION_GLSL
