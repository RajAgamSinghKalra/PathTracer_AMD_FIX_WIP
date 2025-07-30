#include "/lib/buffer/state.glsl"
#include "/lib/lens/focusing.glsl"
#include "/lib/lens/pupil.glsl"
#include "/lib/settings.glsl"

layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

void main() {
    float zFront = 0.0;
    for (int i = 0; i < LENS_ELEMENTS.length(); i++) {
        if (LENS_ELEMENTS[i].curvature == 0.0) {
            renderState.apertureRadius = LENS_ELEMENTS[i].aperture;
        }
        zFront += LENS_ELEMENTS[i].thickness;
    }
    renderState.lensFrontZ = zFront;

    mat2 transferMatrix = computeRayTransferMatrix(550);
    renderState.rayTransferMatrix = transferMatrix;

    renderState.focalLength = computeFocalLength(transferMatrix);

#if (F_NUMBER != 0)
    float entrancePupilDiameter = renderState.focalLength / float(F_NUMBER);
    renderState.apertureRadius = searchApertureRadius(128, 0.5 * entrancePupilDiameter);
#endif
    renderState.entracePupilRadius = searchEntracePupilRadius(128);
    renderState.fNumber = renderState.focalLength / (2.0 * renderState.entracePupilRadius);
}
