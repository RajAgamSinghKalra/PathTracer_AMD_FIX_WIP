#ifndef _CAMERA_RESPONSE_GLSL
#define _CAMERA_RESPONSE_GLSL 1

struct camera_response_entry {
    vec2 channels[3];
};

layout (std430, binding = 6) readonly buffer camera_response {
    camera_response_entry entries[];
} cameraResponse;

float binarySearchCameraResponse(int channel, float irradiance) {
    if (cameraResponse.entries[0].channels[channel].x >= irradiance) {
        return cameraResponse.entries[0].channels[channel].y;
    }
    if (cameraResponse.entries[1023].channels[channel].x <= irradiance) {
        return cameraResponse.entries[1023].channels[channel].y;
    }

    int low = 0;
    int high = 1023;

    while (low <= high) {
        int mid = (low + high) / 2;
        vec2 entry = cameraResponse.entries[mid].channels[channel];
        if (entry.x == irradiance) {
            return entry.y;
        } else if (entry.x < irradiance) {
            vec2 next = cameraResponse.entries[mid + 1].channels[channel];
            if (next.x > irradiance) {
                float t = (irradiance - entry.x) / (next.x - entry.x);
                return mix(entry.y, next.y, t);
            }
            low = mid + 1;
        } else if (entry.x > irradiance) {
            vec2 prev = cameraResponse.entries[mid - 1].channels[channel];
            if (prev.x < irradiance) {
                float t = (irradiance - prev.x) / (entry.x - prev.x);
                return mix(prev.y, entry.y, t);
            }
            high = mid - 1;
        }
    }

    return cameraResponse.entries[low].channels[channel].y;
}

#endif // _CAMERA_RESPONSE_GLSL
