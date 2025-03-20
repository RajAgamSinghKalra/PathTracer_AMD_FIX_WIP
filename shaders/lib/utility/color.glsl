#ifndef _COLOR_GLSL
#define _COLOR_GLSL 1

vec3 linearToSrgb(vec3 x) {
    return mix(12.92 * x, 1.055 * pow(x, vec3(1.0 / 2.4)) - 0.055, step(0.0031308, x));
}

vec3 srgbToLinear(vec3 x){
    return mix(x / 12.92, pow((x + 0.055) / 1.055, vec3(2.4)), step(0.04045, x));
}

float luminance(vec3 rgb) {
    return dot(rgb, vec3(0.2125, 0.7154, 0.0721));
}

const mat3 XYZ_TO_RGB = transpose(mat3(
     3.2404542, -1.5371385, -0.4985314,
    -0.9692660,  1.8760108,  0.0415560,
     0.0556434, -0.2040259,  1.0572252
));

#endif // _COLOR_GLSL