#ifndef _RANDOM_GLSL
#define _RANDOM_GLSL 1

uint hash(uint x) {
    x += (x << 10u);
    x ^= (x >> 6u);
    x += (x << 3u);
    x ^= (x >> 11u);
    x += (x << 15u);
    return x;
}

uint hash(uvec3 v) {
    return hash(v.x ^ hash(v.y) ^ hash(v.z));
}

float floatConstruct(uint m) {
    const uint ieeeMantissa = 0x007FFFFFu;
    const uint ieeeOne = 0x3F800000u;

    m &= ieeeMantissa;
    m |= ieeeOne;

    float f = uintBitsToFloat(m);
    return fract(f - 1.0);
}

float random1(inout vec3 v) {
    return floatConstruct(hash(floatBitsToUint(v += 1.0)));
}

vec2 random2(inout vec3 v) {
    return vec2(random1(v), random1(v));
}

vec3 random3(inout vec3 v) {
    return vec3(random1(v), random1(v), random1(v));
}

vec4 random4(inout vec3 v) {
    return vec4(random2(v), random2(v));
}

#endif // _RANDOM_GLSL