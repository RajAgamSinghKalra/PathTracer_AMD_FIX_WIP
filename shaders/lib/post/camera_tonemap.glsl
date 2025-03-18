#ifndef _CAMERA_TONEMAP_GLSL
#define _CAMERA_TONEMAP_GLSL 1

#include "/lib/buffer/camera_response.glsl"

vec3 cameraTonemap(vec3 intensity, float iso) {
    intensity = clamp(intensity, 0.0, iso) / iso;
    intensity = vec3(
        binarySearchCameraResponse(0, intensity.x),
        binarySearchCameraResponse(1, intensity.y),
        binarySearchCameraResponse(2, intensity.z)
    );
    return clamp(intensity, 0.0, 1.0);
}

#endif // _CAMERA_TONEMAP_GLSL