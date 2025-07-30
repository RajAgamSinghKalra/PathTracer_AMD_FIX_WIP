#ifndef _SPECTRAL_SAMPLING_GLSL
#define _SPECTRAL_SAMPLING_GLSL 1

#include "/lib/buffer/spectral.glsl"

int sampleWavelength(float u, out float pdf) {
    float wl = 556.638293609 - 130.023639424 * atanh(0.85691062 - 1.82750197 * u);
    float denom = cosh(4.28105 - 0.00769091 * wl);
    pdf = 0.00420843 / (denom * denom);
    return int(wl);
}

#endif // _SPECTRAL_SAMPLING_GLSL
