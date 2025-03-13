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