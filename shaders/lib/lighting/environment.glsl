#ifndef _ENVIRONMENT_GLSL
#define _ENVIRONMENT_GLSL 1

#include "/lib/buffer/bins.glsl"
#include "/lib/buffer/quad.glsl"
#include "/lib/raytracing/ray.glsl"
#include "/lib/spectral/conversion.glsl"
#include "/lib/utility/constants.glsl"
#include "/lib/utility/orthonormal.glsl"
#include "/lib/utility/random.glsl"
#include "/lib/utility/sampling.glsl"
#include "/lib/settings.glsl"

uniform sampler2D environment;

// I'll make a path traced atmosphere one day.
// http://karim.naaji.fr/environment_map_importance_sampling.html

float environmentMap(int lambda, vec3 rayDirection) {
    float u = atan(rayDirection.z, rayDirection.x) / (2.0 * PI);
    float v = acos(rayDirection.y) / PI;
    vec2 uv = fract(vec2(u + ENVMAP_OFFSET_U, v));

    vec3 rgb = texelFetch(environment, ivec2(uv * vec2(environmentMapSize)), 0).rgb;
    return lrgbToEmissionSpectrum(lambda, rgb) * 2.0e4;
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
    uv.x -= ENVMAP_OFFSET_U;

    float phi = mod(uv.x * 2.0 * PI, 2.0 * PI);
    float theta = uv.y * PI;

    float sinTheta = max(sin(theta), 1.0e-10);
    vec3 sampleDir = vec3(cos(phi) * sinTheta, cos(theta), sin(phi) * sinTheta);

    float binArea = binWidth * binHeight;
    float binPDF = float(environmentMapSize.x * environmentMapSize.y) / (float(binBuffer.numBins) * binArea);
    pdf = binPDF / (2.0 * PI * PI * sinTheta);

    return sampleDir;
}

float environmentMapPDF(vec3 rayDirection) {
    float u = atan(rayDirection.z, rayDirection.x) / (2.0 * PI);
    float v = acos(rayDirection.y) / PI;
 
    vec2 uv = fract(vec2(u + ENVMAP_OFFSET_U, v));
    ivec2 coord = ivec2(uv * vec2(environmentMapSize));
    int pixelIndex = environmentMapSize.x * coord.y + coord.x;
    int binIndex = binBuffer.binIndexes[pixelIndex];
    bin_data bin = binBuffer.bins[binIndex];
 
    float binWidth = float(bin.x1 - bin.x0);
    float binHeight = float(bin.y1 - bin.y0);

    float theta = uv.y * PI;
    float sinTheta = max(sin(theta), 1.0e-10);
    float binArea = binWidth * binHeight;
    float binPDF = float(environmentMapSize.x * environmentMapSize.y) / (float(binBuffer.numBins) * binArea);
    return binPDF / (2.0 * PI * PI * sinTheta);
}

float environmentMapWeight(int lambda, vec3 rayDirection) {
    return environmentMapPDF(rayDirection);
}
float environmentMapWeight(int lambda, ray r) {
    return environmentMapWeight(lambda, r.direction);
}

void projectBoundingBox(vec3 corner, vec3 u, vec3 v, inout vec2 minuv, inout vec2 maxuv) {
    vec2 dotuv = vec2(dot(corner, u), dot(corner, v));
    minuv = min(minuv, dotuv);
    maxuv = max(maxuv, dotuv);
}

ray generateEnvironmentRay(int lambda, out float L, out float L_pdf) {
    float p;
    vec3 omega = -sampleEnvironmentMap(random3(), p);
    
    L = environmentMap(lambda, -omega);

    vec3 u, v;
    buildOrthonormalBasis(omega, u, v);

    vec2 minuv = vec2(1.0e4);
    vec2 maxuv = -minuv;

    vec3 aabbMin = vec3(quadBuffer.aabb.xMin, quadBuffer.aabb.yMin, quadBuffer.aabb.zMin);
    vec3 aabbMax = vec3(quadBuffer.aabb.xMax, quadBuffer.aabb.yMax, quadBuffer.aabb.zMax);
    projectBoundingBox(vec3(aabbMin.x, aabbMin.y, aabbMin.z), u, v, minuv, maxuv);
    projectBoundingBox(vec3(aabbMax.x, aabbMin.y, aabbMin.z), u, v, minuv, maxuv);
    projectBoundingBox(vec3(aabbMin.x, aabbMax.y, aabbMin.z), u, v, minuv, maxuv);
    projectBoundingBox(vec3(aabbMax.x, aabbMax.y, aabbMin.z), u, v, minuv, maxuv);
    projectBoundingBox(vec3(aabbMin.x, aabbMin.y, aabbMax.z), u, v, minuv, maxuv);
    projectBoundingBox(vec3(aabbMax.x, aabbMin.y, aabbMax.z), u, v, minuv, maxuv);
    projectBoundingBox(vec3(aabbMin.x, aabbMax.y, aabbMax.z), u, v, minuv, maxuv);
    projectBoundingBox(vec3(aabbMax.x, aabbMax.y, aabbMax.z), u, v, minuv, maxuv);

    float dist = dot((aabbMin + aabbMax) * 0.5, -omega) + dot(vec3(1.0), aabbMax - aabbMin);
    vec3 y = -dist * omega + normalize(u) * mix(minuv.x, maxuv.x, random1()) + normalize(v) * mix(minuv.y, maxuv.y, random1());

    vec3 tMin = (aabbMin - y) / omega;
    vec3 tMax = (aabbMax - y) / omega;
    vec3 t1 = min(tMin, tMax);
    y += omega * (max(max(t1.x, t1.y), t1.z) - 1.0);

    L_pdf = p / ((maxuv.x - minuv.x) * (maxuv.y - minuv.y));
    return ray(y, omega);
}

#endif // _ENVIRONMENT_GLSL