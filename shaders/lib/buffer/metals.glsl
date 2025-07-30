#ifndef _METALS_GLSL
#define _METALS_GLSL 1

#include "/lib/buffer/spectral.glsl"
#include "/lib/complex/float.glsl"

// metals/iron: 89 entries
// metals/gold: 89 entries
// metals/aluminium: 89 entries
// metals/chrome: 89 entries
// metals/copper: 89 entries
// metals/lead: 89 entries
// metals/platinum: 89 entries
// metals/silver: 89 entries

layout (std430, binding = 4) readonly buffer metal_data {
    vec2 iors[];
} metalData;

complexFloat getMeasuredMetalIOR(int lambda, int id) {
    int lowerIndex = (lambda - WL_MIN) / 5;
    int upperIndex = lowerIndex + 1;
    float t = float(lambda - WL_MIN - lowerIndex * 5) / 5.0;
    return complexFloat(mix(metalData.iors[lowerIndex + id * 89], metalData.iors[upperIndex + id * 89], t));
}

#endif // _METALS_GLSL
