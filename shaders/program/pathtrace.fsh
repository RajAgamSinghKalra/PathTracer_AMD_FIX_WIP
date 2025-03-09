#include "/lib/buffer/state.glsl"
#include "/lib/lighting/environment.glsl"
#include "/lib/raytracing/trace.glsl"
#include "/lib/utility/color.glsl"
#include "/lib/utility/projection.glsl"
#include "/lib/utility/random.glsl"
#include "/lib/utility/sampling.glsl"
#include "/lib/settings.glsl"

uniform sampler2D colortex2;
uniform sampler2D colortex10;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform vec3 cameraPositionFract;

in vec2 texcoord;

/* RENDERTARGETS: 2 */
layout(location = 0) out vec3 color;

void main() {
	vec3 seed = vec3(texcoord, float(renderState.frame));

	vec3 rayOrigin = projectAndDivide(gbufferProjectionInverse, vec3(texcoord * 2.0 - 1.0, 0.0));
	vec3 rayDirection = projectAndDivide(gbufferProjectionInverse, vec3(texcoord * 2.0 - 1.0, 1.0));
	rayOrigin = (gbufferModelViewInverse * vec4(rayOrigin, 1.0)).xyz + cameraPositionFract;
	rayDirection = normalize((gbufferModelViewInverse * vec4(rayDirection, 1.0)).xyz);

	ray r = ray(rayOrigin, rayDirection);

	vec3 L = vec3(0.0);
	vec3 throughput = vec3(1.0);

	for (int i = 0; i < 5; i++) {
		intersection it = traceRay(colortex10, r);
		if (it.t < 0.0) {
			L += throughput * environmentMap(r);
			break;
		}

		vec3 nextDir;
		vec3 brdf;
		float pdf;

		nextDir = sampleCosineWeightedHemisphere(random2(seed), it.normal);
		brdf = srgbToLinear(it.albedo.rgb) / PI;
		pdf = cosineWeightedHemispherePDF(nextDir, it.normal);

		float costh = dot(nextDir, it.normal);
        
        throughput *= (brdf / pdf) * abs(costh);
        r = ray(r.origin + r.direction * it.t + it.normal * (sign(costh) * 0.001), nextDir);
	}

	vec3 history = texture(colortex2, texcoord).rgb;
	color = mix(history, L, 1.0 / float(renderState.frame + 1));
}