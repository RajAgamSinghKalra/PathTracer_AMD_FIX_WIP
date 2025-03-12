#ifndef _SPECTRAL_SAMPLING_GLSL
#define _SPECTRAL_SAMPLING_GLSL 1

#include "/lib/buffer/spectral.glsl"

int sampleWavelength(float u) {
    return int(u * float(WL_MAX - WL_MIN + 1)) + WL_MIN;
}

float wavelengthPDF(int lambda) {
    if (lambda < WL_MIN || lambda > WL_MAX) {
        return 0.0;
    }
    return 1.0 / float(WL_MAX - WL_MIN + 1);
}

#endif // _SPECTRAL_SAMPLING_GLSL