/* RENDERTARGETS: 0 */
layout(location = 0) out uvec3 materialData;

flat in int storeTexture;
flat in ivec2 origin;

uniform sampler2D gtexture;
uniform sampler2D normals;
uniform sampler2D specular;

void main() {
    if (storeTexture != 1) {
        discard;
    }

    ivec2 fragCoord = ivec2(gl_FragCoord.xy) - origin;
    if (clamp(fragCoord, ivec2(0, 0), textureSize(gtexture, 0).xy - 1) != fragCoord) {
        discard;
    }

    vec4 albedoData = texelFetch(gtexture, fragCoord, 0);
    vec4 normalData = texelFetch(normals, fragCoord, 0);
    vec4 specularData = texelFetch(specular, fragCoord, 0);

    materialData = uvec3(packUnorm4x8(albedoData), packUnorm4x8(normalData), packUnorm4x8(specularData));
}
