#include "/lib/lighting/environment.glsl"
#include "/lib/raytracing/trace.glsl"
#include "/lib/utility/color.glsl"
#include "/lib/utility/projection.glsl"
#include "/lib/settings.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex10;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform vec3 cameraPositionFract;

in vec2 texcoord;

/* RENDERTARGETS: 1 */
layout(location = 0) out vec3 color;

void main() {
	vec3 rayOrigin = projectAndDivide(gbufferProjectionInverse, vec3(texcoord * 2.0 - 1.0, 0.0));
	vec3 rayDirection = projectAndDivide(gbufferProjectionInverse, vec3(texcoord * 2.0 - 1.0, 1.0));
	rayOrigin = (gbufferModelViewInverse * vec4(rayOrigin, 1.0)).xyz + cameraPositionFract;
	rayDirection = normalize((gbufferModelViewInverse * vec4(rayDirection, 1.0)).xyz);

	ray r = ray(rayOrigin, rayDirection);

	vec3 L = vec3(0.0);
	vec3 throughput = vec3(1.0);

	for (int i = 0; i < 1; i++) {
		intersection it = traceRay(colortex10, r);
		if (it.t < 0.0) {
			L += environmentMap(r);
			break;
		}

		it.albedo.rgb = srgbToLinear(it.albedo.rgb);
		L += it.albedo.rgb;
	}

	color = L;
}