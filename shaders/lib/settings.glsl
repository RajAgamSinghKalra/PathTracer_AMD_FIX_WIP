#ifndef _SETTINGS_GLSL
#define _SETTINGS_GLSL 1

const ivec3 VOXEL_VOLUME_SIZE = ivec3(512, 386, 512);
const ivec3 HALF_VOXEL_VOLUME_SIZE = VOXEL_VOLUME_SIZE / 2;

#define SKY_CONTRIBUTION
#define SUN_PATH_ANGLE 30 // [0 5 10 15 20 25 30 35 40 45 50 55 60]

#define RUSSIAN_ROULETTE
#define BSDF_EVAL_RUSSIAN_ROULETTE
// #define BSDF_SAMPLE_RUSSIAN_ROULETTE

// #define NEIGHBOURHOOD_CLAMPING
#define TONEMAP 3 // [0 1 2 3]

#define LENS_TYPE 2 // [0 1 2 3 4]
#define APERTURE_SHAPE 0 // [0 1]
#define SENSOR_SIZE 100 // [50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200]
#define EXPOSURE 0 // [0 1]
#define ISO 100 // [50 100 200 400 800 1600 3200]
#define SHUTTER_SPEED 125 // [1500 1000 500 250 125 60 30 15 8]
#define EV 0 // [-5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.75 -0.5 -0.25 0 +0.25 +0.5 +0.75 +1 +1.5 +2 +2.5 +3 +3.5 +4 +4.5 +5]
#define F_NUMBER 16 // [0 1 1.4 2 2.8 4 5.6 8 11 16 22 32]

#define VOXEL_OFFSET 0.0

#define DEBUG_INFO 1 // [0 1 2]
#define PRINT_LENS_TYPE
#define PRINT_CAMERA_SETTINGS
#define PRINT_COATING_INFO
#define PRINT_RENDER_TIME
#define PRINT_SAMPLES
#define PRINT_FRAME_TIME

#define EMISSION_STRENGTH 3.0 // [0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0]
#define THIN_FILM_CONFIGURATION 0 // [0 1]
// #define ENABLE_TRANSLUCENTS
#define GLASS_ABSORPTION 3.0 // [0.10 0.25 0.50 0.75 1.0 1.5 2.0 3.0 4.0]

// #define ENABLE_SPHERES

#define QUAD_BUFFER_SIZE 1 // [1 2 3 4]
// #define VOXELIZE_ENTITIES
#define ENTITY_ATLAS_SIZE 4096 // [1024 2048 4096 8192 16384]
#define MAX_ENTITY_TEXTURE_SIZE 256 // [128 256 512 1024]
#define HIDE_NAMEPLATES

const float sunPathRotation = SUN_PATH_ANGLE;

#ifdef VOXELIZE_ENTITIES
/*
const int shadowcolor0Format = RGB32UI;
const bool shadowcolor0Clear = false;
*/

const int shadowMapResolution = ENTITY_ATLAS_SIZE;
#else
const int shadowMapResolution = 512;
#endif

#endif // _SETTINGS_GLSL