#include "/lib/buffer/state.glsl"
#include "/lib/lens/focusing.glsl"
#include "/lib/raytracing/trace.glsl"
#include "/lib/utility/projection.glsl"

layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

uniform sampler2D colortex10;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform vec3 cameraPositionFract;

void main() {
    if (renderState.frame != 0) {
        return;
    }

    vec3 rayDirection = projectAndDivide(gbufferProjectionInverse, vec3(0.0, 0.0, -1.0));
    ray r = ray(cameraPositionFract, normalize((mat3(gbufferModelViewInverse) * rayDirection).xyz));

    ivec3 voxelOffset = ivec3(mat3(gbufferModelViewInverse) * vec3(0.0, 0.0, VOXEL_OFFSET));
    
    intersection it = traceRay(voxelOffset, colortex10, r, 1024);
    renderState.focusDistance = it.t;
    if (renderState.focusDistance < 0.0) {
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