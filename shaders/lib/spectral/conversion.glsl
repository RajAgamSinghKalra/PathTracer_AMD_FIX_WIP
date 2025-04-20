#ifndef _SPECTRAL_CONVERSION_GLSL
#define _SPECTRAL_CONVERSION_GLSL 1

#include "/lib/buffer/spectral.glsl"
#include "/lib/utility/color.glsl"

vec3 spectrumToXYZ(int lambda, float power) {
    return (CIE_CMF_XYZ(lambda) * max(power, 0.0) * 683.0);
}

float lrgbToReflectanceSpectrum(int lambda, vec3 rgb) {
    return dot(rgb, CIE_BT709_Basis(lambda));
}

float srgbToReflectanceSpectrum(int lambda, vec3 rgb) {
    return lrgbToReflectanceSpectrum(lambda, srgbToLinear(rgb));
}

float lrgbToEmissionSpectrum(int lambda, vec3 rgb) {
    if (rgb == vec3(0.0)) {
        return 0.0;
    }

    return lrgbToReflectanceSpectrum(lambda, rgb) * Illuminant_D65(lambda) / 100.0;
}

float srgbToEmissionSpectrum(int lambda, vec3 rgb) {
    if (rgb == vec3(0.0)) {
        return 0.0;
    }

    return srgbToReflectanceSpectrum(lambda, rgb) * Illuminant_D65(lambda) / 100.0;
}

#endif // _SPECTRAL_CONVERSION_GLSL