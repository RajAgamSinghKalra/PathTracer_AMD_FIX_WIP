#include "/lib/buffer/state.glsl"
#include "/lib/camera/film.glsl"
#include "/lib/camera/lens.glsl"
#include "/lib/lens/flares.glsl"
#include "/lib/lighting/environment.glsl"
#include "/lib/raytracing/trace.glsl"
#include "/lib/reflection/bsdf.glsl"
#include "/lib/spectral/conversion.glsl"
#include "/lib/spectral/sampling.glsl"
#include "/lib/utility/color.glsl"
#include "/lib/utility/random.glsl"
#include "/lib/utility/sampling.glsl"
#include "/lib/settings.glsl"

layout (local_size_x = 8, local_size_y = 4, local_size_z = 1) in;
const vec2 workGroupsRender = vec2(1.0, 1.0);

uniform sampler2D colortex10;
uniform sampler2D colortex11;
uniform sampler2D colortex12;

uniform mat4 gbufferProjection;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;

uniform vec3 cameraPositionFract;
uniform float viewWidth;
uniform float viewHeight;

void main() {
	vec2 fragCoord = vec2(gl_GlobalInvocationID.xy);
	if (fragCoord.x > viewWidth || fragCoord.y > viewHeight) return;

	initGlobalPRNG(fragCoord / vec2(viewWidth, viewHeight), renderState.frame);

	float lambdaPDF;
	int lambda = sampleWavelength(random1(), lambdaPDF);

    ivec3 voxelOffset = ivec3(mat3(gbufferModelViewInverse) * vec3(0.0, 0.0, VOXEL_OFFSET));

	if ((renderState.frame % 2) == 1) {
		prng_state prngLocal = initLocalPRNG(floor(fragCoord / 8.0) / viewWidth, renderState.frame);

		float pdf, lensPDFinv;
		vec3 direction = sampleEnvironmentMap(random3(prngLocal), pdf);
		vec3 point = samplePointOnFrontElement(random2(), lensPDFinv);
		vec3 origin = cameraPositionFract + (mat3(gbufferModelViewInverse) * point);
		if (!traceShadowRay(voxelOffset, colortex10, ray(origin + direction * 256.0, -direction), 256.0)) {
			float weight = 2.0 * lensPDFinv / lambdaPDF * environmentMap(lambda, direction) / pdf;
			estimateLensFlares(lambda, -direction, gbufferProjection, gbufferModelView, point, weight);
		}
	}

	vec2 filmSample = (fragCoord + random2()) / vec2(viewWidth, viewHeight) * 2.0 - 1.0;

	float cameraWeight = 1.0;
	bool lensFlare;
	ray r = generateCameraRay(lambda, cameraPositionFract, gbufferProjection, gbufferModelViewInverse, filmSample, cameraWeight, lensFlare);
	if (cameraWeight == 0.0) {
		logFilmSample(filmSample, vec3(0.0));
		return;
	}

	float L = 0.0;
	float throughput = 1.0;
	bsdf_sample bsdfSample;

	for (int i = 0; i < 25; i++) {
		intersection it = traceRay(voxelOffset, colortex10, r, i == 0 ? 1024 : 128);
		if (it.t < 0.0) {
			float misWeight = i == 0 ? float(!lensFlare) : bsdfSample.pdf / (bsdfSample.pdf + environmentMapWeight(lambda, r));
			L += misWeight * throughput * environmentMap(lambda, r);
			break;
		}

		vec3 w1, w2;
		buildOrthonormalBasis(it.normal, w1, w2);
		mat3 localToWorld = mat3(w1, w2, it.normal);

		vec3 wi = -r.direction * localToWorld;
		
		material mat = decodeMaterial(lambda, it.tbn, it.albedo, textureLod(colortex11, it.uv, 0), textureLod(colortex12, it.uv, 0));

		L += throughput * mat.emission;

		float pdfDirect;
		vec3 skyDirection = sampleEnvironmentMap(random3(), pdfDirect);
		if (dot(skyDirection, it.normal) > 0.0 && pdfDirect > 0.0) {
			vec3 shadowOrigin = r.origin + r.direction * it.t + it.normal * 0.001;
			float visibility = float(!traceShadowRay(voxelOffset, colortex10, ray(shadowOrigin, skyDirection), 1024.0));
			if (visibility > 0.0) {
				vec3 wo = skyDirection * localToWorld;
				float bsdfDirect = evaluateBSDF(mat, wi, wo, false);
				float environmentWeight = environmentMapWeight(lambda, skyDirection);
				float misWeight = environmentWeight / (environmentWeight + evaluateBSDFSamplePDF(mat, wi, wo));
				L += environmentMap(lambda, skyDirection) * (bsdfDirect / pdfDirect) * misWeight * throughput * wo.z * visibility;
			}
		}

#ifdef RUSSIAN_ROULETTE
		float probability = min(1.0, throughput);
		if (random1() > probability) {
			break;
		}
		throughput /= probability;
#endif

		if (!sampleBSDF(bsdfSample, mat, wi)) {
			break;
		}

		throughput *= (bsdfSample.value / bsdfSample.pdf) * abs(bsdfSample.direction.z);

		vec3 offset = it.normal * (sign(bsdfSample.direction.z) * 0.001);
		r = ray(r.origin + r.direction * it.t + offset, localToWorld * bsdfSample.direction);
	}

	L /= lambdaPDF;

	if (isnan(L) || isinf(L)) {
		return;
	}

	vec3 L_xyz = spectrumToXYZ(lambda, L * cameraWeight);

	logFilmSample(filmSample, L_xyz);
}