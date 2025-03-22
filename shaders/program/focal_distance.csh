#include "/lib/buffer/state.glsl"
#include "/lib/raytracing/trace.glsl"
#include "/lib/utility/projection.glsl"

layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

uniform sampler2D colortex10;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform vec3 cameraPositionFract;

void main() {
    vec3 rayDirection = projectAndDivide(gbufferProjectionInverse, vec3(0.0, 0.0, 1.0));
	ray r = ray(cameraPositionFract, normalize((gbufferModelViewInverse * vec4(rayDirection, 1.0)).xyz));

    ivec3 voxelOffset = ivec3(mat3(gbufferModelViewInverse) * vec3(0.0, 0.0, 128.0));
	
    intersection it = traceRay(voxelOffset, colortex10, r, 1024);
    renderState.focalDistance = it.t;
}