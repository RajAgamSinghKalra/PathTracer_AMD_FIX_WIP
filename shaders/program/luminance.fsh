#include "/lib/camera/film.glsl"
#include "/lib/utility/color.glsl"

in vec2 texcoord;

/* RENDERTARGETS: 2 */
layout(location = 0) out float luminance;

void main() {
    vec2 filmCoord = texcoord * 2.0 - 1.0;
    vec3 color = getFilmAverageColor(filmCoord);
    luminance = color.y;
}