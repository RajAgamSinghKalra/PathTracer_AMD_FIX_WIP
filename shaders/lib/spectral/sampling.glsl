#ifndef _SPECTRAL_SAMPLING_GLSL
#define _SPECTRAL_SAMPLING_GLSL 1

#include "/lib/spectral/definitions.glsl"

wavelength sampleWavelength(float u) {
    return wavelength(u * float(WL_MAX - WL_MIN + 1)) + WL_MIN;
}

float wavelengthPDF(wavelength lambda) {
    if (lambda < WAVELENGTH_MIN || lambda > WAVELENGTH_MAX) {
        return 0.0;
    }
    return 1.0 / float(WAVELENGTH_MAX - WAVELENGTH_MIN + 1);
}

#endif // _SPECTRAL_SAMPLING_GLSL