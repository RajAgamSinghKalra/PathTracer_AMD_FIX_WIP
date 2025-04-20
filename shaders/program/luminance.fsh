#include "/lib/camera/film.glsl"
#include "/lib/utility/color.glsl"

in vec2 texcoord;

/* RENDERTARGETS: 2 */
layout(location = 0) out float luma;

void main() {
    vec2 filmCoord = texcoord * 2.0 - 1.0;
    vec3 color = getFilmAverageColor(filmCoord);
    color = max(XYZ_TO_RGB * color, 0.0);
    luma = luminance(color);
}