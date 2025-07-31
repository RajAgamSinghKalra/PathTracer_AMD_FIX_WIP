#ifndef _EXPOSURE_GLSL
#define _EXPOSURE_GLSL 1

const float logLumMin = -5.0;
const float logLumMax = 5.0;
const float logLumRange = logLumMax - logLumMin;

float toLogLuminance(float lum) {
    return clamp((log2(lum) - logLumMin) / logLumRange, 0.0, 1.0);
}

float fromLogLuminance(float logLum) {
    return exp2(logLum * logLumRange + logLumMin);
}

float averageLuminanceToEV100(float avgLum) {
    return log2(avgLum * 100.0 / 12.5);
}

float cameraSettingsToEV100(float shutterSpeed, float iso, float fNumber) {
    return log2(fNumber * fNumber / shutterSpeed * 100.0 / iso);
}

float exposureFromEV100(float ev100) {
    return 1.0 / (1.2 * exp2(ev100));
}

#endif // _EXPOSURE_GLSL
