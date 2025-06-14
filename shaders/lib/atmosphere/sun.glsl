#ifndef _SUN_GLSL
#define _SUN_GLSL 1

#include "/lib/atmosphere/constants.glsl"
#include "/lib/buffer/solar_irradiance.glsl"
#include "/lib/buffer/spectral.glsl"
#include "/lib/spectral/blackbody.glsl"
#include "/lib/utility/orthonormal.glsl"
#include "/lib/utility/sampling.glsl"

vec3 getSunPosition(vec3 sunDirection) {
    return astronomicalUnit * sunDirection;
}

vec3 sampleSunDirection(vec2 rand, vec3 sunPosition, vec3 x, out float weight) {
    vec3 centerDirection = normalize(sunPosition - x);
    
    vec3 b1, b2;
    buildOrthonormalBasis(centerDirection, b1, b2);
    
    vec2 pLocal = sunRadius * sampleDisk(rand);
    vec3 point = pLocal.x * b1 + pLocal.y * b2 + sunPosition;
    float pDistance = distance(point, x);
    
    vec3 sampleDirection = (point - x) / pDistance;
    
    float diskArea = sunRadius * sunRadius * PI;
    weight = diskArea * dot(sampleDirection, centerDirection) / (pDistance * pDistance);
    
    return sampleDirection;
}

// https://www.nrel.gov/grid/solar-resource/spectra-astm-e490
float getSunRadiance(float wavelength) {
    return solarIrradiance.data[clamp(int(wavelength), WL_MIN, WL_MAX) - WL_MIN] * 1000.0 / (2.0 * PI);
}

#endif // _SUN_GLSL