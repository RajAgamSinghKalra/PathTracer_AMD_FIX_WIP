#ifndef _LENS_FLARES_GLSL
#define _LENS_FLARES_GLSL 1

#include "/lib/lens/aperture.glsl"
#include "/lib/lens/common.glsl"
#include "/lib/lens/configuration.glsl"
#include "/lib/lens/intersection.glsl"
#include "/lib/lens/reflection.glsl"
#include "/lib/spectral/conversion.glsl"
#include "/lib/utility/random.glsl"

void traceReflectedLensFlarePath(vec2 sensorExtent, int lambda, ray r, float weight, float z, int i, float currentEta) {
    int bounce = 0;
    int nR = 0;

    while (i < LENS_ELEMENTS.length()) {
        if (bounce++ > 32) {
            return;
        }

        lens_element element = LENS_ELEMENTS[i];

        z += r.direction.z > 0.0 ? (i > 0 ? LENS_ELEMENTS[i - 1].thickness : 0.0) : -element.thickness;
        
        float t;
        vec3 normal;
        if (element.curvature == 0.0) {
            if (!intersectPlanarLensElement(z, r, t, normal)) {
                return;
            }
            
            r.origin += t * r.direction;
            if (!insideAperture(r.origin.xy, element.aperture)) {
                return;
            }
        } else {
            if (!intersectSphericalLensElement(element.curvature, z, r, t, normal)) {
                return;
            }
            
            r.origin += t * r.direction;
            if (!insideCircularAperture(r.origin.xy, element.aperture)) {
                return;
            }
            
            float transmittedEta = r.direction.z < 0.0 ? sellmeier((i > 0) ? LENS_ELEMENTS[i - 1].glass : AIR, lambda) : sellmeier(element.glass, lambda);
            vec2 intensities = computeLensElementReflectance(dot(-r.direction, normal), lambda, currentEta, transmittedEta, element.coated);
            
            float reflectionProbability = 0.5 / float(nR + 3);
            if (i == 0 || (nR == 0 && i == LENS_ELEMENTS.length() - 1)) {
                reflectionProbability = 1.0;
            }
            if (intensities.x == 0.0 || intensities.x == 1.0) {
                reflectionProbability = intensities.x;
            }

            if (random1() < reflectionProbability) {
                weight *= intensities.x / reflectionProbability;
                r.direction = reflect(r.direction, normal);
                nR++;
            } else {
                weight *= intensities.y / (1.0 - reflectionProbability);
                r.direction = refract(r.direction, normal, currentEta / transmittedEta);
                if (r.direction == vec3(0.0)) {
                    return;
                }

                currentEta = transmittedEta;
            }
        }

        i += (r.direction.z <= 0.0 ? -1 : 1);
    }

    float t = -r.origin.z / r.direction.z;
    r.origin += t * r.direction;

    vec2 pointOnSensor = -r.origin.xy / sensorExtent;
    if (clamp(pointOnSensor, -1.0, 1.0) != pointOnSensor) {
        return;
    }

    weight *= r.direction.z;
    logFilmSplat(pointOnSensor.xy, spectrumToXYZ(lambda, weight));
}

void traceLensFlarePaths(vec2 sensorExtent, int lambda, ray r, float weight) {
    float z = frontLensElementZ();

    float currentEta = 1.0;
    for (int i = 0; i < LENS_ELEMENTS.length(); i++) {
        lens_element element = LENS_ELEMENTS[i];

        z += i > 0 ? LENS_ELEMENTS[i - 1].thickness : 0.0;
        
        float t;
        vec3 normal;
        if (element.curvature == 0.0) {
            if (!intersectPlanarLensElement(z, r, t, normal)) {
                return;
            }
            
            r.origin += t * r.direction;
            if (!insideAperture(r.origin.xy, element.aperture)) {
                return;
            }
        } else {
            if (!intersectSphericalLensElement(element.curvature, z, r, t, normal)) {
                return;
            }
            
            r.origin += t * r.direction;
            if (!insideCircularAperture(r.origin.xy, element.aperture)) {
                return;
            }

            float transmittedEta = sellmeier(element.glass, lambda);
            vec2 intensities = computeLensElementReflectance(dot(-r.direction, normal), lambda, currentEta, transmittedEta, element.coated);

            if (intensities.x != 0.0 && i > 0) {
                ray reflectedRay = r;
                reflectedRay.direction = reflect(r.direction, normal);
                traceReflectedLensFlarePath(sensorExtent, lambda, reflectedRay, weight * intensities.x, z, i - 1, currentEta);
            }

            weight *= intensities.y;
            r.direction = refract(r.direction, normal, currentEta / transmittedEta);
            if (weight == 0.0 || r.direction == vec3(0.0)) {
                return;
            }

            currentEta = transmittedEta;
        }
    }
}

void estimateLensFlares(int lambda, vec3 direction, mat4 projection, mat4 view, vec3 position, float weight) {
    vec2 sensorExtent = getSensorPhysicalExtent(CAMERA_SENSOR, projection);
    weight /= (sensorExtent.x * sensorExtent.y * 4.0);

    direction = normalize(mat3(view) * direction);
    if (direction.z <= 0.0) {
        return;
    }

    ray r = ray(position, direction);
    r.origin -= 0.1 * direction;

    traceLensFlarePaths(sensorExtent, lambda, r, weight);
}

#endif // _LENS_FLARES_GLSL