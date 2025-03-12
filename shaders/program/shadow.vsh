#include "/lib/settings.glsl"

in vec4 at_midBlock;

out vec3 vPosition;
out vec3 vMidOffset;
out vec4 vColor;
out vec2 vUV;

uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelViewInverse;

void main() {
    gl_Position = vec4(-1.0);

    vec3 normal = gl_NormalMatrix * gl_Normal;
    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
    vPosition = (shadowModelViewInverse * (viewPos - vec4(normal * 1.0e-5, 0.0))).xyz;

    vMidOffset = at_midBlock.xyz * (1.0 / 64.0);
    vColor = vec4(gl_Color.rgb, 1.0);
    vUV = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}