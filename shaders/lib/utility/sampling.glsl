#ifndef _SAMPLING_GLSL
#define _SAMPLING_GLSL 1

#include "/lib/utility/constants.glsl"
#include "/lib/utility/orthonormal.glsl"

vec2 sampleDisk(vec2 rand) {
    float angle = rand.y * 2.0 * PI;
    float sr = sqrt(rand.x);
    return vec2(sr * cos(angle), sr * sin(angle));
}

vec3 sampleSphere(vec2 rand) {
    float angle = rand.x * 2.0 * PI;
    float u = rand.y * 2.0 - 1.0;
    float sr = sqrt(1.0 - u * u);
    return vec3(sr * cos(angle), sr * sin(angle), u);
}

vec3 sampleHemisphere(vec2 rand) {
    vec3 point = sampleSphere(rand);
    point.y = abs(point.y);
    return point;
}

vec3 sampleHemisphere(vec2 rand, vec3 normal) {
    vec3 onSphere = sampleSphere(rand);
    return onSphere * sign(dot(onSphere, normal));
}

vec3 sampleCosineWeightedHemisphere(vec2 rand) {
    vec2 p = sampleDisk(rand);
    return vec3(p, sqrt(1.0 - dot(p, p)));
}

vec3 sampleCosineWeightedHemisphere(vec2 rand, vec3 n) {
    vec3 p = sampleCosineWeightedHemisphere(rand);

    vec3 w1, w2;
    buildOrthonormalBasis(n, w1, w2);
    return w1 * p.x + w2 * p.y + n * p.z;
}

float cosineWeightedHemispherePDF(vec3 sampleDir, vec3 n) {
    return dot(sampleDir, n) / PI;
}

#endif // _SAMPLING_GLSL