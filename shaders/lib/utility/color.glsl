#ifndef _COLOR_GLSL
#define _COLOR_GLSL 1

vec3 linearToSrgb(vec3 x) {
    return mix(12.92 * x, 1.055 * pow(x, vec3(1.0 / 2.4)) - 0.055, step(0.0031308, x));
}

vec3 srgbToLinear(vec3 x){
    return mix(x / 12.92, pow((x + 0.055) / 1.055, vec3(2.4)), step(0.04045, x));
}

const mat3 XYZ_TO_sRGB = mat3(
     3.2404542, -0.9692660,  0.0556434,
    -1.5371385,  1.8760108, -0.2040259,
    -0.4985314,  0.0415560,  1.0572252
);

const mat3 sRGB_TO_XYZ = inverse(XYZ_TO_sRGB);

#endif // _COLOR_GLSL
