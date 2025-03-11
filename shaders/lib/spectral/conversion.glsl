#ifndef _SPECTRAL_CONVERSION_GLSL
#define _SPECTRAL_CONVERSION_GLSL 1

#include "/lib/buffer/spectral.glsl"
#include "/lib/utility/color.glsl"

vec3 spectrumToXYZ(int lambda, float spectrum) {
    return (CIE_CMF_XYZ(wavelength) * spectrum) / CIE_Y_Integral();
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

    return lrgbToReflectanceSpectrum(lambda, rgb) * Illuminant_D65(lambda);
}

float srgbToEmissionSpectrum(int lambda, vec3 rgb) {
    if (rgb == vec3(0.0)) {
        return 0.0;
    }

    return srgbToReflectanceSpectrum(lambda, rgb) * Illuminant_D65(lambda);
}

#endif // _SPECTRAL_CONVERSION_GLSL