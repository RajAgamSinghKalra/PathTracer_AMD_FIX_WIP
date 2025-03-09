#ifndef _STATE_GLSL
#define _STATE_GLSL 1

layout (std430, binding = 1) buffer render_state {
    int frame;
} renderState;

#endif // _STATE_GLSL