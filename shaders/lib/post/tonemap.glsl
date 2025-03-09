#ifndef _TONEMAP_GLSL
#define _TONEMAP_GLSL 1

#include "/lib/post/aces.glsl"
#include "/lib/post/agx.glsl"

vec3 tonemap(vec3 color) {
    return agxTonemap(color);
}

#endif // _TONEMAP_GLSL