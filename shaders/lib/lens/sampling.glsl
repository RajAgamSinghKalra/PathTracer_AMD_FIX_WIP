#ifndef _LENS_SAMPLING_GLSL
#define _LENS_SAMPLING_GLSL 1

#include "/lib/buffer/state.glsl"
#include "/lib/lens/configuration.glsl"
#include "/lib/utility/sampling.glsl"

vec3 samplePointOnFrontElement(vec2 rand, out float weight) {
    const float radiusMultiplier = 2.5;
    
    float aperture = frontLensElement().aperture;
    vec2 pointOnFront = aperture * sampleDisk(rand) * radiusMultiplier;
    weight = aperture * aperture * radiusMultiplier * radiusMultiplier * PI;

    return vec3(pointOnFront, frontLensElementZ());
}

vec2 samplePointOnRearElement(vec2 rand, out float weight) {
    const float radiusMultiplier = 1.5;

    float aperture = rearLensElement().aperture;
    weight = aperture * aperture * radiusMultiplier * radiusMultiplier * PI;

    return aperture * sampleDisk(rand) * radiusMultiplier;
}

vec2 sampleExitPupil(vec2 rand, vec2 pointOnSensor, vec2 sensorExtent, out float weight) {
    float sampleRadius = length(pointOnSensor);
    float physicalRadius = length(sensorExtent);
    float index = 255.0 * sampleRadius / physicalRadius;
    pupil_bounds bounds1 = renderState.exitPupil.samples[clamp(int(ceil(index)), 0, 255)];
    pupil_bounds bounds2 = renderState.exitPupil.samples[clamp(int(floor(index)), 0, 255)];
    pupil_bounds bounds = pupil_bounds(min(bounds1.minBound, bounds2.minBound), max(bounds1.maxBound, bounds2.maxBound));
    
    weight = (bounds.maxBound.x - bounds.minBound.x) * (bounds.maxBound.y - bounds.minBound.y);

    float sinTheta = pointOnSensor.y / sampleRadius;
    float cosTheta = pointOnSensor.x / sampleRadius;

    return mix(bounds.minBound, bounds.maxBound, rand) * mat2(cosTheta, -sinTheta, sinTheta, cosTheta);;
}

#endif // _LENS_SAMPLING_GLSL