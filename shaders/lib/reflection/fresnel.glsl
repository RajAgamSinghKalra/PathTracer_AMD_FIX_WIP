#ifndef _FRESNEL_GLSL
#define _FRESNEL_GLSL 1

#include "/lib/complex/float.glsl"
#include "/lib/utility/constants.glsl"

float fresnelRs(float n0, float cos0, float n1, float cos1) {
    return (n0 * cos0 - n1 * cos1) / (n0 * cos0 + n1 * cos1);
}

float fresnelRp(float n0, float cos0, float n1, float cos1) {
    return (n0 * cos1 - n1 * cos0) / (n0 * cos1 + n1 * cos0);
}

float fresnelTs(float n0, float cos0, float n1, float cos1) {
    return 2.0 * n0 * cos0 / (n0 * cos0 + n1 * cos1);
}

float fresnelTp(float n0, float cos0, float n1, float cos1) {
    return 2.0 * n0 * cos0 / (n0 * cos1 + n1 * cos0);
}

complexFloat fresnelRs(complexFloat n0, complexFloat cos0, complexFloat n1, complexFloat cos1) {
    return complexDiv(complexSub(complexMul(n0, cos0), complexMul(n1, cos1)), complexAdd(complexMul(n0, cos0), complexMul(n1, cos1)));
}

complexFloat fresnelRp(complexFloat n0, complexFloat cos0, complexFloat n1, complexFloat cos1) {
    return complexDiv(complexSub(complexMul(n0, cos1), complexMul(n1, cos0)), complexAdd(complexMul(n0, cos1), complexMul(n1, cos0)));
}

complexFloat fresnelTs(complexFloat n0, complexFloat cos0, complexFloat n1, complexFloat cos1) {
    return complexDiv(complexMul(complexMul(complexFloat(2.0, 0.0), n0), cos0), complexAdd(complexMul(n0, cos0), complexMul(n1, cos1)));
}

complexFloat fresnelTp(complexFloat n0, complexFloat cos0, complexFloat n1, complexFloat cos1) {
    return complexDiv(complexMul(complexMul(complexFloat(2.0, 0.0), n0), cos0), complexAdd(complexMul(n0, cos1), complexMul(n1, cos0)));
}

float fresnelThinFilm(float cos0, float wl, vec3 n, float thickness) {
    vec2 sin12 = (1.0 - cos0 * cos0) * n[0] * n[0] / vec2(n[1] * n[1], n[2] * n[2]);
    if (sin12.x > 1.0 || sin12.y > 1.0) return 1.0;

    vec2 cos12 = sqrt(1.0 - sin12);

    float rs = fresnelRs(n[1], cos12.x, n[0], cos0) * fresnelRs(n[1], cos12.x, n[2], cos12.y); 
    float rp = fresnelRp(n[1], cos12.x, n[0], cos0) * fresnelRp(n[1], cos12.x, n[2], cos12.y); 
    float ts = fresnelTs(n[0], cos0, n[1], cos12.x) * fresnelTs(n[1], cos12.x, n[2], cos12.y); 
    float tp = fresnelTp(n[0], cos0, n[1], cos12.x) * fresnelTp(n[1], cos12.x, n[2], cos12.y);

    float t = cos(4.0 * PI * thickness * n[1] * cos12.x / wl);
    float Ts = (ts * ts) / pow(1.0 - rs * t, 2.0); 
    float Tp = (tp * tp) / pow(1.0 - rp * t, 2.0); 

    return 1.0 - (n[2] * cos12.y) / (n[0] * cos0) * (Ts + Tp) * 0.5; 
}

float fresnelDielectric(float cosTheta0, float n0, float n1) {
    float sin2Theta0 = 1.0 - cosTheta0 * cosTheta0;
    float sin2Theta1 = sin2Theta0 * (n0 * n0) / (n1 * n1);
    if (sin2Theta1 >= 1.0) return 1.0;

    float cosTheta1 = sqrt(1.0 - sin2Theta1);

    float rs = fresnelRs(n0, cosTheta0, n1, cosTheta1);
    float rp = fresnelRp(n0, cosTheta0, n1, cosTheta1);

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

float fresnelConductor(float cosTheta0, complexFloat n0, complexFloat n1) {
    complexFloat sin2Theta0 = complexFloat(1.0 - cosTheta0 * cosTheta0, 0.0);
    complexFloat sin2Theta1 = complexMul(sin2Theta0, complexDiv(complexMul(n0, n0), complexMul(n1, n1)));
    complexFloat cosTheta1 = complexSqrt(complexSub(complexFloat(1.0, 0.0), sin2Theta1));

    complexFloat rp = fresnelRp(complexFloat(cosTheta0, 0.0), n0, cosTheta1, n1);
    complexFloat rs = fresnelRs(complexFloat(cosTheta0, 0.0), n0, cosTheta1, n1);

    return 0.5 * (complexNorm(rp) + complexNorm(rs));
}

#endif // _FRESNEL_GLSL