#include "/lib/post/tonemap.glsl"
#include "/lib/utility/color.glsl"
#include "/lib/settings.glsl"

uniform sampler2D colortex2;
uniform sampler2D colortex10;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec3 color;

void main() {
	color = texture(colortex2, texcoord).rgb;
#ifdef NEIGHBOURHOOD_CLAMPING
	vec3 maxNeighbour = max(
		max(textureOffset(colortex2, texcoord, ivec2(1, 0)).rgb, textureOffset(colortex2, texcoord, ivec2(-1, 0)).rgb),
		max(textureOffset(colortex2, texcoord, ivec2(0, 1)).rgb, textureOffset(colortex2, texcoord, ivec2(0, -1)).rgb)
	);
	color = min(color, maxNeighbour);
#endif

	color = tonemap(color);
	color = linearToSrgb(color);
}