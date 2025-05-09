#ifndef _PUPIL_GLSL
#define _PUPIL_GLSL 1

#include "/lib/buffer/state.glsl"
#include "/lib/lens/aperture.glsl"
#include "/lib/lens/configuration.glsl"
#include "/lib/lens/intersection.glsl"

bool rayPassesThroughAperture(ray r, float apertureRadius, const int lambda) {
    float z = -renderState.rearThicknessDelta;

    float currentEta = 1.0;
    for (int i = 0; i < LENS_ELEMENTS.length(); i++) {
        lens_element element = LENS_ELEMENTS[i];

        z += i > 0 ? LENS_ELEMENTS[i - 1].thickness : 0.0;
        
        float t;
        vec3 normal;
        if (element.curvature == 0.0) {
            if (!intersectPlanarLensElement(z, r, t, normal)) {
                return false;
            }
            
            r.origin += t * r.direction;
            if (!insideCircularAperture(r.origin.xy, apertureRadius)) {
                return false;
            } else {
                return true;
            }
        } else {
            if (!intersectSphericalLensElement(element.curvature, z, r, t, normal)) {
                return false;
            }
            
            r.origin += t * r.direction;
            if (!insideCircularAperture(r.origin.xy, element.aperture)) {
                return false;
            }
            
            float transmittedEta = sellmeier(element.glass, lambda);

            r.direction = refract(r.direction, normal, currentEta / transmittedEta);
            if (r.direction == vec3(0.0)) {
                return false;
            }

            currentEta = transmittedEta;
        }
    }

    return true;
}

float searchEntracePupilRadius(const int iterations) {
    float boundMin = 0.0;
    float boundMax = frontLensElement().aperture;

    for (int i = 0; i < iterations; i++) {
        float midPoint = 0.5 * (boundMin + boundMax);
        if (rayPassesThroughAperture(ray(vec3(midPoint, 0.0, -1.0), vec3(0.0, 0.0, 1.0)), renderState.apertureRadius, 550)) {
            boundMin = midPoint;
        } else {
            boundMax = midPoint;
        }
    }

    return 0.5 * (boundMin + boundMax);
}

float searchApertureRadius(const int iterations, float entracePupilRadius) {
    float radiusMin = 1.0e-10;
    float radiusMax = 1.0;

    for (int i = 0; i < LENS_ELEMENTS.length(); i++) {
        if (LENS_ELEMENTS[i].curvature == 0.0) {
            radiusMax = LENS_ELEMENTS[i].aperture;
            break;
        }
    }

    for (int i = 0; i < iterations; i++) {
        float midPoint = 0.5 * (radiusMin + radiusMax);
        if (rayPassesThroughAperture(ray(vec3(entracePupilRadius, 0.0, -1.0), vec3(0.0, 0.0, 1.0)), midPoint, 550)) {
            radiusMax = midPoint;
        } else {
            radiusMin = midPoint;
        }
    }

    return 0.5 * (radiusMin + radiusMax);
}

#endif // _PUPIL_GLSL