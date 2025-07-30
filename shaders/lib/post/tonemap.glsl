#ifndef _TONEMAP_GLSL
#define _TONEMAP_GLSL 1

#include "/lib/post/aces.glsl"
#include "/lib/post/agx.glsl"
#include "/lib/post/camera_tonemap.glsl"
#include "/lib/settings.glsl"

vec3 tonemap(vec3 color) {
#if (TONEMAP == 0)
    return agxTonemap(color);
#elif (TONEMAP == 1)
    return cameraTonemap(color, 4.0);
#elif (TONEMAP == 2)
    return clamp(1.0 - exp(-color), 0.0, 1.0);
#elif (TONEMAP == 3)
    return acesFitted(color);
#endif
}

#endif // _TONEMAP_GLSL
