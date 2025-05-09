#ifndef _EXPOSURE_GLSL
#define _EXPOSURE_GLSL 1

const float logLumMin = -5.0;
const float logLumRange = 11.0;

float toLogLuminance(float lum) {
    return clamp((log2(lum) - logLumMin) / logLumRange, 0.0, 1.0);
}

float fromLogLuminance(float logLum) {
    return exp2((logLum / 254.0) * logLumRange + logLumMin);
}

float averageLuminanceToEV100(float avgLum) {
    return log2(avgLum * 100.0 / 12.5);
}

float cameraSettingsToEV100(float shutterSpeed, float iso) {
    return log2(shutterSpeed * 100.0 / iso);
}

float exposureFromEV100(float ev100) {
    return 1.0 / (1.2 * exp2(ev100));
}

#endif // _EXPOSURE_GLSL