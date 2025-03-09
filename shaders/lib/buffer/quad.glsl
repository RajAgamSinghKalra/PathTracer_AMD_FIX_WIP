#ifndef _QUAD_GLSL
#define _QUAD_GLSL 1

struct quad_entry {
    vec4 point;
    vec4 tangent;
    vec4 bitangent;
    vec2 uv0;
    vec2 uv1;
    uint tint;
    uint next;
};

layout (std430, binding = 0) buffer quad_buffer {
    uint count;
    quad_entry list[];
} quadBuffer;

#endif // _QUAD_GLSL