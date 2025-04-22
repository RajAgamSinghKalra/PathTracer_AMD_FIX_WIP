#include "/lib/buffer/state.glsl"
#include "/lib/camera/film.glsl"
#include "/lib/debug/debug_text.glsl"
#include "/lib/post/tonemap.glsl"
#include "/lib/utility/color.glsl"
#include "/lib/settings.glsl"

in vec2 texcoord;

uniform ivec3 currentDate;
uniform ivec2 currentYearTime;

/*
const bool colortex2MipmapEnabled = true;
*/

uniform sampler2D colortex2;

uniform float viewHeight;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec3 color;

void main() {
    vec2 filmCoord = texcoord * 2.0 - 1.0;
    color = getFilmAverageColor(filmCoord);
#ifdef NEIGHBOURHOOD_CLAMPING
    vec3 maxNeighbour = max(
        max(getFilmAverageColor(filmCoord, ivec2(1, 0)).rgb, getFilmAverageColor(filmCoord, ivec2(-1, 0)).rgb),
        max(getFilmAverageColor(filmCoord, ivec2(0, 1)).rgb, getFilmAverageColor(filmCoord, ivec2(0, -1)).rgb)
    );
    color = min(color, maxNeighbour);
#endif

    color = max(XYZ_TO_RGB * color, 0.0);

    float avgLum = texelFetch(colortex2, ivec2(0, 0), 10).r;
    color /= 1.2 * SHUTTER_SPEED * 100.0 / ISO;

    color = tonemap(color);
    color = linearToSrgb(color);

    ivec2 time = ivec2(currentDate.x, currentYearTime.x);
    renderTextOverlay(color, ivec2(gl_FragCoord.xy) / 2, ivec2(1.0, viewHeight * 0.5 - 1.0), time);
}