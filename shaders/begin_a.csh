#version 460 compatibility

#include "/lib/buffer/quad.glsl"

layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
const ivec3 workGroups = ivec3(1, 1, 1);

void main() {
    quadBuffer.count = 0u;
}