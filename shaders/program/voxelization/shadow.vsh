#include "/lib/settings.glsl"

in vec4 at_midBlock;
in vec2 mc_midTexCoord;

out vec3 vPosition;
out vec3 vMidOffset;
out vec4 vColor;
out vec2 vUV;

uniform int renderStage;

uniform sampler2D gtexture;

uniform mat4 shadowProjectionInverse;
uniform mat4 shadowModelViewInverse;

void main() {
    gl_Position = vec4(-1.0);

    vec3 normal = gl_NormalMatrix * gl_Normal;
    vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;

    float bias = mix(1.0e-6, 2.0e-5, clamp(length(viewPos.xyz) / 128.0, 0.0, 1.0));
    vPosition = (shadowModelViewInverse * (viewPos + vec4(normal * bias, 0.0))).xyz;

    vMidOffset = at_midBlock.xyz * (1.0 / 64.0);
    vColor = vec4(gl_Color.rgb, 1.0);
    vUV = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

#ifdef HIDE_NAMEPLATES
    if (renderStage == MC_RENDER_STAGE_ENTITIES && 
        clamp(gl_Color.a, 0.24, 0.255) == gl_Color.a &&
        gl_Color.rgb == vec3(0.0)) {
        vColor.a = 0.0;
    }
#endif

#ifdef ENABLE_SPHERES
    int alpha = int(textureLod(gtexture, mc_midTexCoord, 0).a * 255.0 + 0.5);
    if (alpha == 254) { // I hate this
        vColor.a = 254.0 / 255.0;
    }
#endif
}
