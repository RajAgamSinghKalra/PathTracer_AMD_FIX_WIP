#include "/lib/atmosphere/pathtracer.glsl"
#include "/lib/buffer/state.glsl"
#include "/lib/camera/film.glsl"
#include "/lib/camera/lens_system.glsl"
#include "/lib/camera/pinhole.glsl"
#include "/lib/lens/flares.glsl"
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

// Viewport uniforms may not be valid before rendering starts, so derive the
// dimensions from the film buffer instead.

void pathTracer(vec2 fragCoord) {
    ivec2 dim = imageSize(filmBuffer);
    float width = float(dim.x);
    float height = float(dim.y);
    float lambdaPDF;
    int lambda = sampleWavelength(random1(), lambdaPDF);

    ivec3 voxelOffset = ivec3(renderState.viewMatrixInverse[2].xyz * VOXEL_OFFSET);

    vec2 filmSample = (fragCoord + random2()) / vec2(width, height);
    filmSample = filmSample * 2.0 - 1.0;
    filmSample.x *= width / height;

#ifdef SKY_CONTRIBUTION
    vec3 sunPosition = renderState.sunPosition;
    float sunRadiance = getSunRadiance(float(lambda));
    vec3 extinctionBeta = atmosphereExtinctionBeta(float(lambda));

    if ((renderState.frame % 2) == 1) {
        prng_state prngLocal = initLocalPRNG(floor(fragCoord / 8.0) / width, renderState.frame);

        float sampleWeight, lensPDFinv;
        vec3 point = samplePointOnFrontElement(filmSample * 0.5 + 0.5, lensPDFinv);
        vec3 origin = renderState.cameraPosition + (mat3(renderState.viewMatrixInverse) * point);

        vec3 earthPosition = convertToEarthSpace(origin);
        vec3 direction = sampleSunDirection(random2(prngLocal), sunPosition, earthPosition, sampleWeight);
        vec3 viewDirection = normalize(mat3(renderState.viewMatrix) * direction);

        if (viewDirection.z < 0.0 && !traceShadowRay(voxelOffset, ray(origin + direction * 1024.0, -direction), 1024.0)) {
            float transmittance = estimateTransmittance(ray(earthPosition, direction), extinctionBeta);
            float weight = 2.0 * lensPDFinv / lambdaPDF * transmittance * sunRadiance * sampleWeight;
            if (!isnan(weight) && !isinf(weight) && weight != 0.0) {
                estimateLensFlares(prngLocal, lambda, -viewDirection, point, weight);
            }
        }
    }
#endif

    float cameraWeight = 1.0;
    bool lensFlare;
    ray r = generateCameraRay(lambda, filmSample, cameraWeight, lensFlare);
    if (cameraWeight == 0.0) {
        logFilmSample(filmSample, vec3(0.0));
        return;
    }

    float L = 0.0;
    float throughput = 1.0;
    bsdf_sample bsdfSample;
    intersection it;

    const int maxBounces = 256;
    for (int i = 0;; i++) {
        if (!traceRay(it, voxelOffset, r)) {
#ifdef SKY_CONTRIBUTION
            if (i == 0 || (i > 0 && bsdfSample.dirac)) {
                ray earthRay = convertToEarthSpace(r);
                if (intersectSphere(earthRay, sunPosition, sunRadius).x >= 0.0) {
                    float transmittance = estimateTransmittance(earthRay, extinctionBeta);
                    L += throughput * transmittance * sunRadiance;
                }
            }
#endif
            break;
        }

        if (currentMediumAbsorbtance != 0.0) {
            throughput *= exp(-currentMediumAbsorbtance * it.t);
        }

        vec3 wi = -r.direction * it.tbn;

        material mat = decodeMaterial(lambda, it.albedo, it.specular, it.normal);

        L += throughput * mat.emission;

#ifdef SKY_CONTRIBUTION
        float sampleWeight;
        ray sunRay = convertToEarthSpace(r);
        sunRay.direction = sampleSunDirection(random2(), sunPosition, sunRay.origin, sampleWeight);
        if (dot(sunRay.direction, it.tbn[2]) > 0.0) {
            vec3 shadowOrigin = r.origin + r.direction * it.t + it.tbn[2] * 0.001;
            float visibility = float(!traceShadowRay(voxelOffset, ray(shadowOrigin, sunRay.direction), 1024.0));
            if (visibility > 0.0) {
                vec3 wo = sunRay.direction * it.tbn;
                float bsdfDirect = evaluateBSDF(mat, wi, wo, false);
                
                float transmittance = estimateTransmittance(sunRay, extinctionBeta);
                L += sampleWeight * transmittance * sunRadiance * bsdfDirect * throughput * wo.z;
            }
        }
#endif

        if (i >= maxBounces) {
            throughput = 0.0;
            break;
        }

#ifdef RUSSIAN_ROULETTE
        float probability = min(1.0, throughput);
        if (random1() > probability) {
            throughput = 0.0;
            break;
        }
        throughput /= probability;
#endif

        if (!sampleBSDF(bsdfSample, float(lambda), it.tbn, mat, wi)) {
            throughput = 0.0;
            break;
        }

        throughput *= (bsdfSample.value / bsdfSample.pdf) * abs(bsdfSample.direction.z);

        vec3 offset = it.tbn[2] * (sign(bsdfSample.direction.z) * 0.001);
        r = ray(r.origin + r.direction * it.t + offset, it.tbn * bsdfSample.direction);
    }

#ifdef SKY_CONTRIBUTION
    if (throughput != 0.0) {
        ray earthRay = convertToEarthSpace(r);
        L += throughput * pathTraceAtmosphere(earthRay, sunPosition, sunRadiance, extinctionBeta, float(lambda));
    }
#endif

    L /= lambdaPDF;

    if (isnan(L) || isinf(L)) {
        return;
    }

    vec3 L_xyz = spectrumToXYZ(lambda, L * cameraWeight);

    logFilmSample(filmSample, L_xyz);
}

void preview(vec2 fragCoord) {
    ivec2 dim = imageSize(filmBuffer);
    float width = float(dim.x);
    float height = float(dim.y);
    vec2 filmCoord = (fragCoord + 0.5) / vec2(width, height);
    filmCoord = filmCoord * 2.0 - 1.0;
    filmCoord.x *= width / height;
    ivec3 voxelOffset = ivec3(renderState.viewMatrixInverse[2].xyz * VOXEL_OFFSET);

    ray r = generatePinholeCameraRay(filmCoord);

    intersection it;
    if (traceRay(it, voxelOffset, r)) {
        vec3 sunDirection = renderState.sunDirection;
        float cosTheta = dot(it.tbn[2], sunDirection);

        vec3 albedo = sRGB_TO_XYZ * srgbToLinear(it.albedo.rgb);
        vec3 L = albedo * 0.05 * (0.25 * abs(cosTheta) + 0.75);

        if (cosTheta > 0.0) {
            L += albedo * cosTheta * 0.3;
        }

        logFilmSample(filmCoord, L * 683.0);
    } else {
        vec3 sky = mix(vec3(1.0), vec3(0.5, 0.7, 1.0), sqrt(r.direction.y * 0.5 + 0.5));
        logFilmSample(filmCoord, sRGB_TO_XYZ * (68.3 * srgbToLinear(sky)));
    }
}

void main() {
    currentIOR = 1.0;
    currentMediumAbsorbtance = 0.0;

    ivec2 dim = imageSize(filmBuffer);
    float width = float(dim.x);
    float height = float(dim.y);

    for (int y = int(gl_GlobalInvocationID.y); y < dim.y; y += int(gl_NumWorkGroups.y) * int(gl_WorkGroupSize.y)) {
        for (int x = int(gl_GlobalInvocationID.x); x < dim.x; x += int(gl_NumWorkGroups.x) * int(gl_WorkGroupSize.x)) {
            vec2 fragCoord = vec2(x, y);
            initGlobalPRNG(fragCoord / vec2(width, height), renderState.frame);

            if (renderState.frame == 0) {
                preview(fragCoord);
            } else {
                pathTracer(fragCoord);
            }
        }
    }
}
