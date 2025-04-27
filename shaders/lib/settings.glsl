#ifndef _SETTINGS_GLSL
#define _SETTINGS_GLSL 1

const float sunPathRotation = 30.0;
const int shadowMapResolution = 512;

/*
const int colortex2Format = R32F;
*/

const ivec3 VOXEL_VOLUME_SIZE = ivec3(512, 386, 512);
const ivec3 HALF_VOXEL_VOLUME_SIZE = VOXEL_VOLUME_SIZE / 2;

#define EMISSION_STRENGTH 2.0 // [1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0]
#define SKY_CONTRIBUTION

#define RUSSIAN_ROULETTE
#define BSDF_EVAL_RUSSIAN_ROULETTE
// #define BSDF_SAMPLE_RUSSIAN_ROULETTE

// #define NEIGHBOURHOOD_CLAMPING
#define TONEMAP 0 // [0 1 2 3]

#define LENS_TYPE 2 // [0 1 2 3 4]
#define APERTURE_SHAPE 0 // [0 1]
#define ISO 200.0 // [50.0 100.0 200.0 400.0 800.0 1600.0 3200.0]
#define SHUTTER_SPEED 1500.0 // [1500.0 1000.0 500.0 250.0 125.0 60.0 30.0 15.0 8.0]

#define VOXEL_OFFSET 196.0

#define DEBUG_INFO 1 // [0 1 2]
#define PRINT_LENS_TYPE
#define PRINT_CAMERA_SETTINGS
#define PRINT_COATING_INFO
#define PRINT_RENDER_TIME
#define PRINT_SAMPLES

#define THIN_FILM_CONFIGURATION 0 // [0 1]

#endif // _SETTINGS_GLSL