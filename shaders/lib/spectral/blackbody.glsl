#ifndef _BLACKBODY_GLSL
#define _BLACKBODY_GLSL 1

float blackbody(float l, float T) {
    const float h = 6.62607015e-16;
    const float c = 2.99792458e17;
    const float k = 1.380649e-5;

    return 2.0 * h * c * c / pow(l, 5.0) / (exp((h * c) / (l * k * T)) - 1.0);
}

float blackbodyScaled(int lambda, int T) {
    float p = blackbody(float(lambda), float(T));
    float radiated = 5.670374419e-8 * float(T * T) * float(T * T);
    return 15.0 * p / radiated;
}

#endif // _BLACKBODY_GLSL
