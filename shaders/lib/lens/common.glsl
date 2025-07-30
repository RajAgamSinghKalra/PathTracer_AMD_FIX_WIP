#ifndef _LENS_COMMON_GLSL
#define _LENS_COMMON_GLSL 1

#include "/lib/buffer/state.glsl"
#include "/lib/reflection/sellmeier.glsl"
#include "/lib/settings.glsl"

struct sensor_data {
    float baseExtent;
};

struct lens_element {
    float curvature;
    float thickness;
    sellmeier_coeffs glass;
    float aperture;
    bool coated;
};

vec2 getSensorPhysicalExtent(sensor_data data) {
    float aspect = renderState.projection[1][1] / renderState.projection[0][0];
    float verticalFov = 2.0 * atan(1.0 / renderState.projection[1][1]);
    float sensorHeight = 2.0 * renderState.focalLength * tan(verticalFov * 0.5);
    float sensorWidth = sensorHeight / aspect;

    float scale = float(SENSOR_SIZE) / 100.0;
    return scale * vec2(sensorWidth, sensorHeight);
}

#endif // _LENS_COMMON_GLSL
