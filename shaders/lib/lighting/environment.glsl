#ifndef _ENVIRONMENT_GLSL
#define _ENVIRONMENT_GLSL 1

#include "/lib/buffer/bins.glsl"
#include "/lib/raytracing/ray.glsl"
#include "/lib/spectral/conversion.glsl"
#include "/lib/utility/constants.glsl"
#include "/lib/settings.glsl"

uniform sampler2D environment;

float environmentMap(int lambda, vec3 rayDirection) {
    float u = atan(rayDirection.z, rayDirection.x) / (2.0 * PI);
    float v = acos(rayDirection.y) / PI;
    vec2 uv = fract(vec2(u + ENVMAP_OFFSET_U, v));

    vec3 rgb = texelFetch(environment, ivec2(uv * vec2(environmentMapSize)), 0).rgb;
    return lrgbToEmissionSpectrum(lambda, rgb);
}

float environmentMap(int lambda, ray r) {
    return environmentMap(lambda, r.direction);
}

vec3 sampleEnvironmentMap(vec3 u, out float pdf) {
    int binIndex = int(binBuffer.numBins * u.x);
    bin_data bin = binBuffer.bins[binIndex];

    float binWidth = float(bin.x1 - bin.x0);
    float binHeight = float(bin.y1 - bin.y0);

    vec2 uv = vec2(
        float(bin.x0) + u.y * binWidth,
        float(bin.y0) + u.z * binHeight
    );

    uv /= vec2(environmentMapSize);
    uv.x += ENVMAP_OFFSET_U;

    float phi = mod(uv.x * 2.0 * PI, 2.0 * PI);
    float theta = uv.y * PI;

    float sinTheta = max(sin(theta), 1.0e-10);
    vec3 sampleDir = vec3(cos(phi) * sinTheta, cos(theta), sin(phi) * sinTheta);

    float binArea = binWidth * binHeight;
    float binPDF = float(environmentMapSize.x * environmentMapSize.y) / (float(binBuffer.numBins) * binArea);
    pdf = binPDF / (2.0 * PI * PI * sinTheta);

    return sampleDir;
}

float environmentMapWeight(int lambda, vec3 rayDirection) {
    return environmentMap(lambda, rayDirection);
}
float environmentMapWeight(int lambda, ray r) {
    return environmentMapWeight(lambda, r.direction);
}

#endif // _ENVIRONMENT_GLSL