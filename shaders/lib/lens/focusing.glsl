#ifndef _FOCUSING_GLSL
#define _FOCUSING_GLSL 1

#include "/lib/lens/configuration.glsl"

mat2 computeRayTransferMatrix(const int wavelength) {
    mat2 transferMatrix = mat2(1.0);
    for (int i = 0; i < LENS_ELEMENTS.length(); i++) {
        lens_element element = LENS_ELEMENTS[i];

        mat2 propagationTransfer = mat2(1.0, 0.0, element.thickness, 1.0);
        if (element.curvature == 0.0) {
            transferMatrix = propagationTransfer * transferMatrix;
            continue;
        }

        float currentEta = i == 0 ? 1.0 : sellmeier(LENS_ELEMENTS[i - 1].glass, wavelength);
        float transmittedEta = sellmeier(element.glass, wavelength);

        mat2 refractionTransfer = mat2(1.0, (currentEta - transmittedEta) / (element.curvature * transmittedEta), 0.0, currentEta / transmittedEta);
        transferMatrix = refractionTransfer * transferMatrix;
        if (i != LENS_ELEMENTS.length() - 1) {
            transferMatrix = propagationTransfer * transferMatrix;
        }
    }

    return transferMatrix;
}

float computeFocalLength(mat2 transferMatrix) {
    const float x = 0.001;

    vec2 r = transferMatrix * vec2(x, 0.0);
    return -x / tan(r.y);
}

float focusLensSystem(mat2 transferMatrix, float focusDistance) {
    const float x = 0.001;

    vec2 r = transferMatrix * vec2(x, atan(x, focusDistance));
    return -r.x / tan(r.y);
}

#endif // _FOCUSING_GLSL
