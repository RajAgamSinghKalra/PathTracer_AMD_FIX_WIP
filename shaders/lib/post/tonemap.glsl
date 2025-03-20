#ifndef _TONEMAP_GLSL
#define _TONEMAP_GLSL 1

#include "/lib/post/aces.glsl"
#include "/lib/post/agx.glsl"
#include "/lib/post/camera_tonemap.glsl"

vec3 tonemap(vec3 color) {
    return cameraTonemap(color, 1.0);
}

#endif // _TONEMAP_GLSL