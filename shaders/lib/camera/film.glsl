#ifndef _FILM_GLSL
#define _FILM_GLSL 1

#include "/lib/buffer/state.glsl"
#include "/lib/settings.glsl"

layout (rgba32f) uniform image2D filmBuffer;
layout (r32f) uniform image2D splatBufferX; // Is there a better way to do this?...
layout (r32f) uniform image2D splatBufferY;
layout (r32f) uniform image2D splatBufferZ;

uniform sampler2D filmSampler;
uniform sampler2D splatSamplerX;
uniform sampler2D splatSamplerY;
uniform sampler2D splatSamplerZ;

vec3 getFilmAverageColor(vec2 coord) {
    coord = coord * 0.5 + 0.5;
    vec3 splat = vec3(
        texture(splatSamplerX, coord).x, 
        texture(splatSamplerY, coord).x, 
        texture(splatSamplerZ, coord).x
    ) / float(max(renderState.frame, 1));
    return texture(filmSampler, coord).xyz + splat;
}

vec3 getFilmAverageColor(vec2 coord, ivec2 offset) {
    coord = coord * 0.5 + 0.5;
    vec3 splat = vec3(
        textureOffset(splatSamplerX, coord, offset).x, 
        textureOffset(splatSamplerY, coord, offset).x, 
        textureOffset(splatSamplerZ, coord, offset).x
    ) / float(max(renderState.frame, 1));
    return textureOffset(filmSampler, coord, offset).xyz + splat;
}

vec3 getFilmAverageColor(ivec2 coord) {
    vec3 splat = vec3(
        texelFetch(splatSamplerX, coord, 0).x, 
        texelFetch(splatSamplerY, coord, 0).x, 
        texelFetch(splatSamplerZ, coord, 0).x
    ) / float(max(renderState.frame, 1));
    return texelFetch(filmSampler, coord, 0).xyz;
}

void logFilmSplat(ivec2 coord, vec3 L) {
    imageAtomicAdd(splatBufferX, coord, L.x);
    imageAtomicAdd(splatBufferY, coord, L.y);
    imageAtomicAdd(splatBufferZ, coord, L.z);
}

void logFilmSample(ivec2 coord, vec3 L) {
    vec4 data = imageLoad(filmBuffer, coord);

    data.w += 1.0;

    data.xyz = mix(data.xyz, L, 1.0 / float(data.w));
    imageStore(filmBuffer, coord, data);
}

void logFilmSplat(vec2 coord, vec3 L) {
    ivec2 size = imageSize(filmBuffer);
    ivec2 imageCoord = ivec2((coord * 0.5 + 0.5) * size);

    logFilmSplat(imageCoord, L);
}

void logFilmSample(vec2 coord, vec3 L) {
    ivec2 size = imageSize(filmBuffer);
    ivec2 imageCoord = ivec2((coord * 0.5 + 0.5) * size);

    logFilmSample(imageCoord, L);
}

#endif // _FILM_GLSL