#include "/lib/buffer/quad.glsl"
#include "/lib/buffer/state.glsl"

layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

uniform bool hideGUI;

uniform vec3 sunPosition;

uniform mat4 gbufferProjection;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPositionFract;
uniform float eyeAltitude;

uniform ivec3 currentDate;
uniform ivec2 currentYearTime;

void main() {
    if (hideGUI) {
        renderState.frame++;
    } else {
        renderState.frame = 0;
        renderState.invalidSplat = 0;
        renderState.startTime = ivec2(currentDate.x, currentYearTime.x);
        renderState.sunDirection = normalize(mat3(gbufferModelViewInverse) * sunPosition) * vec3(1.0, 1.0, -1.0);

        renderState.projection = gbufferProjection;
        renderState.projectionInverse = gbufferProjectionInverse;
        renderState.viewMatrix = gbufferModelView;
        renderState.viewMatrixInverse = gbufferModelViewInverse;
        renderState.cameraPosition = cameraPositionFract;
        renderState.altitude = eyeAltitude;
    }

    renderState.clear = (renderState.frame <= 1);

    if (renderState.frame <= 1) {
        quadBuffer.aabb = scene_aabb(10000, 10000, 10000, -10000, -10000, -10000);
        quadBuffer.count = 0u;
    }
}