#ifndef _SPECTRAL_GLSL
#define _SPECTRAL_GLSL 1

#define WL_MIN 390
#define WL_MAX 830

layout (std430, binding = 3) readonly buffer spectral_data {
    vec3 cie_cmf_xyz[441];
    vec3 cie_bt709_basis[391];
    float illuminant_d65[97];
    float cie_y_integral;
} spectralData;

float CIE_Y_Integral() {
    return spectralData.cie_y_integral;
}

vec3 CIE_CMF_XYZ(int lambda) {
    if (lambda < 390 || lambda > 830) {
        return vec3(0.0);
    }
    return spectralData.cie_cmf_xyz[lambda - 390];
}

vec3 CIE_BT709_Basis(int lambda) {
    if (lambda < 390 || lambda > 780) {
        return vec3(0.0);
    }
    return spectralData.cie_bt709_basis[lambda - 390];
}

float Illuminant_D65(int lambda) {
    if (lambda < 300 || lambda >= 780) {
        return 0.0;
    }
    int index = (lambda - 300) / 5;
    float t = float((lambda - 300) - index * 5) / 5.0;
    return mix(spectralData.illuminant_d65[index], spectralData.illuminant_d65[index + 1], t);
}

#endif // _SPECTRAL_GLSL