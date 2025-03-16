#ifndef _SETTINGS_GLSL
#define _SETTINGS_GLSL 1

const float sunPathRotation = 30.0;
const int shadowMapResolution = 512;

const ivec2 environmentMapSize = ivec2(4096, 2048);

/*
const int colortex2Format = RGB32F;
const bool colortex2Clear = false;
*/

const ivec3 VOXEL_VOLUME_SIZE = ivec3(512, 386, 512);
const ivec3 HALF_VOXEL_VOLUME_SIZE = VOXEL_VOLUME_SIZE / 2;

#define ENVMAP_OFFSET_U 0.5 // [ 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 ]
#define EMISSION_STRENGTH 30.0 // [ 1.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 45.0 50.0 55.0 60.0 ]

// #define NEIGHBOURHOOD_CLAMPING

#define RUSSIAN_ROULETTE
#define BSDF_EVAL_RUSSIAN_ROULETTE
// #define BSDF_SAMPLE_RUSSIAN_ROULETTE

#endif // _SETTINGS_GLSL