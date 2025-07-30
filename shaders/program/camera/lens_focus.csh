#include "/lib/buffer/state.glsl"
#include "/lib/lens/focusing.glsl"
#include "/lib/raytracing/trace.glsl"

layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

void main() {
    // Run focusing on the first frame even if the GUI is visible so the
    // camera parameters are initialized correctly. Previously this pass only
    // executed when `renderState.frame` was exactly 1 which required the user
    // to hide the GUI (F1) once. Allow frames 0 and 1 to perform focusing by
    // skipping only when the frame counter has advanced beyond initialization.
    if (renderState.frame > 1) {
        return;
    }

    vec3 direction = normalize(-renderState.viewMatrixInverse[2].xyz);
    ivec3 voxelOffset = ivec3(renderState.viewMatrixInverse[2].xyz * VOXEL_OFFSET);
    
    intersection it;
    if (traceRay(it, voxelOffset, ray(renderState.cameraPosition, direction))) {
        renderState.focusDistance = it.t;
    } else {
        renderState.focusDistance = 1024.0;
    }

    renderState.rearThicknessDelta = 0.0;
    float zFront = frontLensElementZ();

    mat2 transferMatrix = renderState.rayTransferMatrix;

    const int focusIterations = 4;
    for (int i = 0; i < focusIterations; i++) {
        float focusDistance = renderState.focusDistance + zFront - renderState.rearThicknessDelta;
        float rearThickness = focusLensSystem(transferMatrix, max(focusDistance, 0.0));
        renderState.rearThicknessDelta = max(0.0, rearThickness) - rearLensElement().thickness;
    }
}
