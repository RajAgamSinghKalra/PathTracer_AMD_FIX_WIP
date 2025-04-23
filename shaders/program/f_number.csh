#include "/lib/buffer/state.glsl"
#include "/lib/lens/focusing.glsl"
#include "/lib/lens/pupil.glsl"

layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

void main() {
    float zFront = 0.0;
    for (int i = 0; i < LENS_ELEMENTS.length(); i++) {
        zFront += LENS_ELEMENTS[i].thickness;
    }
    renderState.lensFrontZ = zFront;

    mat2 transferMatrix = computeRayTransferMatrix(550);
    renderState.rayTransferMatrix = transferMatrix;

    renderState.entracePupilRadius = searchEntracePupilRadius(128);
    renderState.focalLength = computeFocalLength(transferMatrix);
    renderState.fNumber = renderState.focalLength / (2.0 * renderState.entracePupilRadius);
}