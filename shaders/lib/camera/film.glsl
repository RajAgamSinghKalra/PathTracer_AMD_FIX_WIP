#ifndef _FILM_GLSL
#define _FILM_GLSL 1

layout (rgba32f) uniform image2D filmBuffer;
uniform sampler2D filmSampler;

vec3 getFilmAverageColor(vec2 coord) {
    return texture(filmSampler, coord * 0.5 + 0.5).xyz;
}

vec3 getFilmAverageColor(vec2 coord, ivec2 offset) {
    return textureOffset(filmSampler, coord * 0.5 + 0.5, offset).xyz;
}

vec3 getFilmAverageColor(ivec2 coord) {
    return texelFetch(filmSampler, coord, 0).xyz;
}

void logFilmSample(ivec2 coord, vec3 L) {
    vec4 data = imageLoad(filmBuffer, coord);
    data.w += 1.0;

	data.xyz = mix(data.xyz, L, 1.0 / float(data.w));
    imageStore(filmBuffer, coord, data);
}

void logFilmSample(vec2 coord, vec3 L) {
    ivec2 size = imageSize(filmBuffer);
    ivec2 imageCoord = ivec2((coord * 0.5 + 0.5) * size);

    logFilmSample(imageCoord, L);
}

#endif // _FILM_GLSL