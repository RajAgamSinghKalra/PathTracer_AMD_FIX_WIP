#include "/lib/post/tonemap.glsl"
#include "/lib/utility/color.glsl"

uniform sampler2D colortex1;
uniform sampler2D colortex10;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec3 color;

void main() {
	color = texture(colortex1, texcoord).rgb;
	color = tonemap(color);
	color = linearToSrgb(color);
}