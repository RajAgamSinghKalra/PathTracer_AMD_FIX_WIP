#ifndef _FRESNEL_GLSL
#define _FRESNEL_GLSL 1

#include "/lib/utility/constants.glsl"
#include "/lib/utility/complex.glsl"

float fresnelR_sp(float n0, float cos0, float n1, float cos1) {
    return (n0 * cos0 - n1 * cos1) / (n0 * cos0 + n1 * cos1); 
} 

float fresnelR_pp(float n0, float cos0, float n1, float cos1) { 
    return (n1 * cos0 - n0 * cos1) / (n0 * cos1 + n1 * cos0); 
} 

float fresnelT_sp(float n0, float cos0, float n1, float cos1) {
    return 2.0 * n0 * cos0 / (n0 * cos0 + n1 * cos1); 
} 

float fresnelT_pp(float n0, float cos0, float n1, float cos1) { 
    return 2.0 * n0 * cos0 / (n0 * cos1 + n1 * cos0); 
} 

float fresnelThinFilm(float cos0, float wl, vec3 n, float thickness) {
    vec2 sin12 = (1.0 - cos0 * cos0) * n[0] * n[0] / vec2(n[1] * n[1], n[2] * n[2]);
    if (sin12.x > 1.0 || sin12.y > 1.0) return 1.0;

    vec2 cos12 = sqrt(1.0 - sin12);

    float rs = fresnelR_sp(n[1], cos12.x, n[0], cos0) * fresnelR_sp(n[1], cos12.x, n[2], cos12.y); 
    float rp = fresnelR_pp(n[1], cos12.x, n[0], cos0) * fresnelR_pp(n[1], cos12.x, n[2], cos12.y); 
    float ts = fresnelT_sp(n[0], cos0, n[1], cos12.x) * fresnelT_sp(n[1], cos12.x, n[2], cos12.y); 
    float tp = fresnelT_pp(n[0], cos0, n[1], cos12.x) * fresnelT_pp(n[1], cos12.x, n[2], cos12.y);

    float t = cos(4.0 * PI * thickness * n[1] * cos12.x / wl);
    float Ts = (ts * ts) / pow(1.0 - rs * t, 2.0); 
    float Tp = (tp * tp) / pow(1.0 - rp * t, 2.0); 

    return 1.0 - (n[2] * cos12.y) / (n[0] * cos0) * (Ts + Tp) * 0.5; 
}

float fresnelDielectric(float cosTheta_i, float n1, float n2) {
    cosTheta_i = clamp(cosTheta_i, 0.0, 1.0);

    float sin2Theta_i = 1.0 - cosTheta_i * cosTheta_i;
    float sin2Theta_t = sin2Theta_i * (n1 * n1) / (n2 * n2);
    if (sin2Theta_t >= 1.0) return 1.0;

    float cosTheta_t = sqrt(1.0 - sin2Theta_t);

    float rs = fresnelR_sp(n1, cosTheta_i, n2, cosTheta_t);
    float rp = fresnelR_pp(n1, cosTheta_i, n2, cosTheta_t);

    return 0.5 * (rs * rs + rp * rp);
}

float fresnelOverHemisphere(float n) {
    if (n - 1.0 < 1.0e-3) {
        return 0.0;
    }

    float n2 = n * n;
    float n3 = n2 * n;

    float n_1 = (n - 1.0) * (3.0 * n + 1.0);
    float d_1 = 6.0 * (n + 1.0) * (n + 1.0);
    float n_2 = n2 * (n2 - 1.0) * (n2 - 1.0);
    float d_2 = (n2 + 1.0) * (n2 + 1.0) * (n2 + 1.0);
    float n_3 = 2.0 * n3 * (n2 + 2.0 * n - 1.0);
    float d_3 = (n2 + 1.0) * (n2 * n2 - 1.0);
    float n_4 = 8.0 * n2 * n2 * (n2 * n2 + 1.0);
    float d_4 = (n2 + 1.0) * (n2 * n2 - 1.0) * (n2 * n2 - 1.0);
    return clamp(0.5 + n_1 / d_1 + log((n - 1.0) / (n + 1.0)) * n_2 / d_2 - n_3 / d_3 + log(n) * n_4 / d_4, 0.0, 1.0);
}

float fresnelConductor(float cosTheta_i, complex eta) {
    cosTheta_i = clamp(cosTheta_i, 0.0, 1.0);

    float sin2Theta_i = 1.0 - cosTheta_i * cosTheta_i;
    complex sin2Theta_t = complexDiv(sin2Theta_i, complexMul(eta, eta));
    complex cosTheta_t = complexSqrt(1.0 - sin2Theta_t);

    complex rp = complexDiv(
        complexSub(complexMul(eta, cosTheta_i), cosTheta_t),
        complexAdd(complexMul(eta, cosTheta_i), cosTheta_t)
    );
    complex rs = complexDiv(
        complexSub(cosTheta_i, complexMul(eta, cosTheta_t)),
        complexAdd(cosTheta_i, complexMul(eta, cosTheta_t))
    );

    return 0.5 * (complexAbs2(rp) + complexAbs2(rs));
}

#endif // _FRESNEL_GLSL