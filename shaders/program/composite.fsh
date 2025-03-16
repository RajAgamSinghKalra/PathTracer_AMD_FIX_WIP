#include "/lib/camera/film.glsl"
#include "/lib/post/tonemap.glsl"
#include "/lib/utility/color.glsl"
#include "/lib/settings.glsl"

in vec2 texcoord;

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

	color = tonemap(color);
	color = linearToSrgb(color);
}