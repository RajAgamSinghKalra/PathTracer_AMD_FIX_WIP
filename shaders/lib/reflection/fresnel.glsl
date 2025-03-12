#ifndef _FRESNEL_GLSL
#define _FRESNEL_GLSL 1

#include "/lib/utility/complex.glsl"

float fresnelConductor(float cosTheta_i, complex eta) {
    cosTheta_i = clamp(cosTheta_i, 0.0, 1.0);

    float sin2Theta_i = 1.0 - cosTheta_i * cosTheta_i;
    complex sin2Theta_t = complexDiv(sin2Theta_i, complexMul(eta, eta));
    complex cosTheta_t = complexSqrt(1.0 - sin2Theta_t);

    complex pp = complexDiv(
        complexSub(complexMul(eta, cosTheta_i), cosTheta_t),
        complexAdd(complexMul(eta, cosTheta_i), cosTheta_t)
    );
    complex sp = complexDiv(
        complexSub(cosTheta_i, complexMul(eta, cosTheta_t)),
        complexAdd(cosTheta_i, complexMul(eta, cosTheta_t))
    );

    return 0.5 * (complexAbs2(pp) + complexAbs2(sp));
}

#endif // _FRESNEL_GLSL