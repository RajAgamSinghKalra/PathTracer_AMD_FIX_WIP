#ifndef _SOLAR_IRRADIANCE_GLSL
#define _SOLAR_IRRADIANCE_GLSL 1

layout (std430, binding = 2) readonly buffer solar_irradiance {
    float data[];
} solarIrradiance;

#endif // _SOLAR_IRRADIANCE_GLSL