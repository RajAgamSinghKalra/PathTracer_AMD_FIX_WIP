#ifndef _LENS_COMMON_GLSL
#define _LENS_COMMON_GLSL 1

#include "/lib/reflection/sellmeier.glsl"

struct sensor_data {
    float extent;
};

struct lens_element {
    float curvature;
    float thickness;
    sellmeier_coeffs glass;
    float aperture;
    bool coated;
};

vec2 getSensorPhysicalExtent(sensor_data data, mat4 projection) {
    return vec2(data.extent) * 0.001 / vec2(1.0, projection[1][1] / projection[0][0]);
}

#endif // _LENS_COMMON_GLSL