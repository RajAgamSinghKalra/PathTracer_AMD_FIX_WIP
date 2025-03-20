#include "/lib/camera/film.glsl"
#include "/lib/post/tonemap.glsl"
#include "/lib/utility/color.glsl"
#include "/lib/settings.glsl"

in vec2 texcoord;

/*
const bool colortex2MipmapEnabled = true;
*/

uniform sampler2D colortex2;

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
	color /= clamp(avgLum * 120.0 / 12.5, 1.0e-30, 1.0e1);

	color = tonemap(color);
	color = linearToSrgb(color);
}