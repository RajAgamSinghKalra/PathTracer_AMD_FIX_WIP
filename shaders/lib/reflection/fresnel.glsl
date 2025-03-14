#ifndef _FRESNEL_GLSL
#define _FRESNEL_GLSL 1

#include "/lib/utility/complex.glsl"

float fresnelDielectric(float cosTheta_i, float eta) {
    cosTheta_i = clamp(cosTheta_i, 0.0, 1.0);

    float sin2Theta_i = max(0.0, 1.0 - cosTheta_i * cosTheta_i);
    float sin2Theta_t = sin2Theta_i / (eta * eta);
    if (sin2Theta_t >= 1.0) return 1.0;

    float cosTheta_t = sqrt(1.0 - sin2Theta_t);
    float rp = (eta * cosTheta_i - cosTheta_t) /
               (eta * cosTheta_i + cosTheta_t);
    float rs = (cosTheta_i - eta * cosTheta_t) /
               (cosTheta_i + eta * cosTheta_t);
    return 0.5 * (rp * rp + rs * rs);
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