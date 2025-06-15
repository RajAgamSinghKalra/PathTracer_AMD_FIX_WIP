#ifndef _STATE_GLSL
#define _STATE_GLSL 1

#include "/lib/entity/structures.glsl"

struct pupil_bounds {
    vec2 minBound;
    vec2 maxBound;
};

struct exit_pupil_data {
    pupil_bounds samples[256];
};

layout (std430, binding = 1) buffer render_state {
    bool clear;
    int frame;
    float lensFrontZ;
    float focusDistance;
    float rearThicknessDelta;
    exit_pupil_data exitPupil;
    float entracePupilRadius;
    float focalLength;
    float apertureRadius;
    float fNumber;
    mat2 rayTransferMatrix;
    ivec2 startTime;
    vec3 sunDirection;
    int invalidSplat;
    uint histogram[256];
    float avgLuminance;
    mat4 projection;
    mat4 projectionInverse;
    mat4 viewMatrix;
    mat4 viewMatrixInverse;
    vec3 cameraPosition;
    float altitude;
    entity_data entityData;
} renderState;

#endif // _STATE_GLSL